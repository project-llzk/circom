#![allow(unused_variables)] // TODO: TEMP
use ansi_term::Color;
use anyhow::{anyhow, Result};
use llzk::{
    error::Error,
    prelude::{
        felt, function,
        r#struct::{
            self,
            helpers::{compute_fn, constrain_fn},
        },
        undef, ArrayType, FeltConstAttribute, FeltType, FuncDefOp, FuncDefOpLike, FuncDefOpRef,
        FuncDefOpRefMut, FunctionType, IntegerAttribute, LlzkContext, OperationMutLike,
        PublicAttribute, StructDefOp, StructDefOpLike, StructDefOpRef, StructDefOpRefMut,
        StructType,
    },
};
use melior::ir::{
    operation::{OperationLike as _, OperationRefMut, WalkOrder, WalkResult},
    Attribute, Block, BlockLike, BlockRef, Identifier, Location, Module, Operation, OperationRef,
    RegionLike, Type, Value,
};
use num_bigint_dig::BigInt;
use num_traits::cast::ToPrimitive;
use program_structure::{
    ast::{AssignOp, Expression, Meta, SignalType, Statement, VariableType},
    error_code::ReportCode,
    error_definition::Report,
    file_definition::{FileID, FileLocation},
    function_data::FunctionData,
    program_archive::ProgramArchive,
    template_data::TemplateData,
};
use std::{
    collections::HashMap,
    convert::{TryFrom, TryInto as _},
    fs::{self, File},
    io::Write,
    ops::{Deref, DerefMut},
    os::raw::c_void,
    path::Path,
};

/// Stack of blocks where the top block is the current block where code should be appended and the
/// previous block in the list is the parent of the block after it. When an op containing nested
/// blocks is encountered, the current block within that op is pushed to the stack so that any code
/// generated will be placed inside that block and when the nested block is complete, it is popped.
struct BlockContextStack<'llzk> {
    /// The function entry block.
    initial_block: BlockRef<'llzk, 'llzk>,
    /// Additional nesting of blocks within the function representing the current insertion point.
    other_blocks: Vec<BlockRef<'llzk, 'llzk>>,
}

impl<'llzk> BlockContextStack<'llzk> {
    /// Push a new block onto the stack to make it the current block.
    fn push(&mut self, item: BlockRef<'llzk, 'llzk>) {
        self.other_blocks.push(item);
    }

    /// Pop the current block off the stack to return to the previous block.
    fn pop(&mut self) {
        self.other_blocks.pop().expect("There is no block to pop!");
    }

    /// Append an operation to the current block (i.e. the top of the stack).
    fn append_current(&mut self, operation: Operation<'llzk>) -> OperationRef<'llzk, 'llzk> {
        let current = match self.other_blocks.last() {
            Some(block) => block,
            None => &self.initial_block,
        };
        // Account for possible terminator in the current block. For example, the `compute_fn()`
        // and `constrain_fn()` helpers automatically add a return op at the end of the block
        // so new ops must be inserted before that terminator.
        match current.terminator() {
            Some(terminator) => current.insert_operation_before(terminator, operation),
            None => current.append_operation(operation),
        }
    }
}

impl<'llzk> TryFrom<&FuncDefOp<'llzk>> for BlockContextStack<'llzk> {
    type Error = anyhow::Error;

    /// Create a BlockContextStack starting with the function entry block.
    fn try_from(func: &FuncDefOp<'llzk>) -> Result<Self, Self::Error> {
        let initial_block =
            func.region(0)?.first_block().ok_or_else(|| anyhow!("missing function entry block"))?;
        Ok(BlockContextStack { initial_block, other_blocks: Default::default() })
    }
}

/// Stores necessary context for generating LLZK IR.
/// 'ast: lifetime of the circom AST element
/// 'llzk: lifetime of the `LlzkContext` and generated `Module`
struct LlzkCodegen<'ast, 'llzk> {
    /// The circom program AST.
    program_archive: &'ast ProgramArchive,
    /// The LLZK (and MLIR) context.
    context: &'llzk LlzkContext,
    /// The generated LLZK `Module`.
    module: &'llzk Module<'llzk>,
}

impl<'ast, 'llzk> LlzkCodegen<'ast, 'llzk> {
    /// Emit a circom-style warning.
    fn emit_circom_warning(&self, meta: &Meta, message: &str, code: ReportCode) {
        let mut report = Report::warning(String::from(message), code);
        report.add_primary(meta.file_location(), meta.get_file_id(), String::from("here"));
        Report::print_reports(&[report], &self.program_archive.file_library);
    }

    /// Convert circom location information to MLIR location.
    fn location(&self, file_id: FileID, file_location: FileLocation) -> Location<'llzk> {
        let files = &self.program_archive.file_library;
        let filename = files.get_filename_or_default(&file_id);
        let line = files.get_line(file_location.start, file_id).unwrap_or(0);
        let column = files.get_column(file_location.start, file_id).unwrap_or(0);
        Location::new(self.context, &filename, line, column)
    }

    /// Convert circom Meta location information to MLIR location.
    fn location_from_meta(&self, meta: &Meta) -> Location<'llzk> {
        if let Some(file) = meta.file_id {
            self.location(file, meta.file_location())
        } else {
            Location::unknown(self.context)
        }
    }

    /// Insert the struct into the module and return a reference to it.
    fn add_struct(&self, s: StructDefOp<'llzk>) -> Result<StructDefOpRefMut<'llzk, '_>> {
        let s: StructDefOpRef = self.module.body().append_operation(s.into()).try_into()?;
        Ok(s.into())
    }

    /// Insert the free function into the module and return a reference to it.
    fn add_function(&self, f: FuncDefOp<'llzk>) -> Result<FuncDefOpRefMut<'llzk, '_>> {
        let f: FuncDefOpRef = self.module.body().append_operation(f.into()).try_into()?;
        Ok(f.into())
    }

    /// Verify the generated `Module`.
    fn verify(&self) -> bool {
        self.module.as_operation().verify()
    }

    /// Write the generated `Module` to a file.
    fn write_to_file(self, filename: &str) -> Result<()> {
        let out_path = Path::new(filename);
        // Ensure parent directories exist
        if let Some(parent) = out_path.parent() {
            fs::create_dir_all(parent).map_err(|e| anyhow!(e))?;
        }
        let mut file = File::create(out_path).map_err(|e| anyhow!(e))?;

        unsafe extern "C" fn callback(string_ref: mlir_sys::MlirStringRef, user_data: *mut c_void) {
            let file = &mut *(user_data as *mut File);
            let slice = std::slice::from_raw_parts(string_ref.data as *const u8, string_ref.length);
            file.write_all(slice).unwrap();
        }

        unsafe {
            // TODO: may need to switch to bytecode at some point. Or add an option for it.
            // mlir_sys::mlirOperationWriteBytecode(
            mlir_sys::mlirOperationPrint(
                self.module.as_operation().to_raw(),
                Some(callback),
                &mut file as *mut File as *mut c_void,
            );
        }
        println!("{} {}", Color::Green.paint("Written successfully:"), filename);
        Ok(())
    }
}

/// Generate a `felt.const` operation from a BigInt. Returns an `Err` result if unsuccessful
/// or if the number of bits required to represent the BigInt does not fit in 32 bits.
fn new_felt_const_op<'llzk>(
    codegen: &LlzkCodegen<'_, 'llzk>,
    meta: &Meta,
    from: &BigInt,
) -> Result<Operation<'llzk>> {
    // ASSERT: The circom parser always produces non-negative constants. These can be negated via
    // PrefixOp but negative BigInt constants are never created directly.
    assert_ne!(from.sign(), num_bigint_dig::Sign::Minus, "Felt constants must be non-negative");
    let attr = FeltConstAttribute::parse(
        codegen.context,
        // use required bits +1 to ensure unsigned representation
        u32::try_from(from.bits())? + 1,
        from.to_string().as_str(),
    );
    felt::constant(codegen.location_from_meta(meta), attr).map_err(|e| anyhow!(e))
}

/// Extract the single result Value from an OperationRef. Returns an `Err` result if the operation
/// does not have exactly one result.
#[inline]
fn single_result_as_value<'c, 'a>(op: OperationRef<'c, 'a>) -> Result<Value<'c, 'a>> {
    if op.result_count() != 1 {
        return Err(anyhow!(
            "Expected operation to have a single result, found {}",
            op.result_count()
        ));
    }
    op.result(0).map(Value::from).map_err(|e| anyhow!(e))
}

/// Create a map of circom variable names (either function arguments or template input signals) to
/// LLZK function argument Values.
#[inline]
fn map_name_to_arg_value<'c, 'a>(
    func: FuncDefOpRefMut<'c, 'a>,
    arg_names: &[String],
) -> Result<HashMap<String, Value<'c, 'a>>> {
    arg_names
        .iter()
        .enumerate()
        .map(|(i, name)| {
            func.deref().argument(i).map(|x| (name.clone(), Value::from(x))).map_err(|e| anyhow!(e))
        })
        .collect::<Result<HashMap<_, _>, _>>()
}

/// Information needed to create an LLZK struct function parameter collected from the input signal
/// Declaration statements within a circom template.
struct InputSignalInfo<'llzk> {
    /// Name of circom input signal that maps to a function parameter.
    name: String,
    /// Type+Location information for the function parameter.
    type_and_loc: (Type<'llzk>, Location<'llzk>),
    /// Named Attributes for the function parameter.
    attrs: Vec<(Identifier<'llzk>, Attribute<'llzk>)>,
}

/// Information collected from Declaration statements within a template that is used to setup LLZK
/// struct fields and parameters to the functions with the struct.
#[derive(Default)]
struct DeclarationInfo<'llzk> {
    /// Input Signal declarations to use as parameters to the LLZK struct functions.
    inputs: Vec<InputSignalInfo<'llzk>>,
    /// Output and Intermediate declarations to use as LLZK struct fields.
    struct_fields: Vec<Result<Operation<'llzk>, Error>>,
    /// Map `var` name to its LLZK declaration Operation (usually `undef.undef`).
    var_decls: HashMap<String, Operation<'llzk>>,
}

impl<'llzk> DeclarationInfo<'llzk> {
    /// Visit a statement and populate this `DeclarationInfo` with any declarations found.
    fn visit<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        stmt: &'ast Statement,
    ) -> Result<()> {
        match stmt {
            Statement::InitializationBlock { initializations, .. } => {
                // The InitializationBlock is just a wrapper that contains no additional information
                // beyond the Declarations that must appear within it so just process the inner
                // statements.
                for init in initializations {
                    self.visit(codegen, init)?;
                }
                Ok(())
            }
            Statement::Declaration { meta, name, xtype, dimensions, .. } => {
                // The Signal and Bus types use SignalType to indicate if they are input, output, or
                // intermediate. The others are all intermediate. Intermediates become SSA values
                // (which could later be stored as a struct field if used in a constraint), outputs
                // become "pub" struct fields, and inputs become arguments to the functions.
                match xtype {
                    VariableType::Signal(signal_type, ..) => self.visit_signal_or_bus(
                        codegen,
                        meta,
                        name,
                        dimensions,
                        signal_type,
                        FeltType::new(codegen.context).into(),
                    ),
                    VariableType::Bus(bus_name, signal_type, ..) => self.visit_signal_or_bus(
                        codegen,
                        meta,
                        name,
                        dimensions,
                        signal_type,
                        StructType::from_str(codegen.context, bus_name).into(),
                    ),
                    VariableType::Var => {
                        // Create an `undef` of the appropriate type. When the actual assignment is
                        // processed later, replace the `undef` with the appropriate value.
                        let op = undef::undef(
                            codegen.location_from_meta(meta),
                            Self::type_with_dimensions(
                                codegen,
                                FeltType::new(codegen.context).into(),
                                dimensions,
                            )?,
                        );
                        self.var_decls.insert(name.clone(), op);
                        Ok(())
                    }
                    VariableType::Component => {
                        todo!("Handle component declaration in template")
                    }
                    VariableType::AnonymousComponent => {
                        unreachable!("removed by 'syntax_sugar_remover'")
                    }
                }
            }
            _ => Ok(()),
        }
    }

    /// `visit()` helper for Signal and Bus VariableType.
    fn visit_signal_or_bus(
        &mut self,
        codegen: &LlzkCodegen<'_, 'llzk>,
        meta: &Meta,
        name: &String,
        dimensions: &[Expression],
        signal_type: &SignalType,
        base_type: Type<'llzk>,
    ) -> Result<()> {
        let location = codegen.location_from_meta(meta);
        let decl_type = Self::type_with_dimensions(codegen, base_type, dimensions)?;
        if SignalType::Input == *signal_type {
            // self.func_inputs.push((decl_type, location));
            let mut attrs = Vec::new();
            if codegen.program_archive.get_public_inputs_main_component().contains(name) {
                attrs.push(PublicAttribute::named_attr_pair(codegen.context));
            }
            self.inputs.push(InputSignalInfo {
                name: name.clone(),
                type_and_loc: (decl_type, location),
                attrs,
            });
        } else {
            let new = r#struct::field(
                location,
                name,
                decl_type,
                false,
                SignalType::Output == *signal_type,
            );
            self.struct_fields.push(new.map(|f| f.into()));
        }
        Ok(())
    }

    /// If `dimensions` is empty, return `base_type`. Otherwise, create ArrayType by converting the
    /// dimension circom Expressions to LLZK Attributes.
    fn type_with_dimensions(
        codegen: &LlzkCodegen<'_, 'llzk>,
        base_type: Type<'llzk>,
        dimensions: &[Expression],
    ) -> Result<Type<'llzk>> {
        if dimensions.is_empty() {
            Ok(base_type)
        } else {
            dimensions
                .iter()
                .map(|e| Self::convert_dim_expr(codegen, e))
                .collect::<Result<Vec<_>, _>>()
                .map(|dims| ArrayType::new(base_type, &dims).into())
        }
    }

    /// Convert a circom Expression used as an array dimension to an LLZK Attribute.
    ///
    /// Note: The LLZK ArrayType can only use the following Attribute types for dimensions:
    /// IntegerAttr (`index` or `i1`), SymbolRefAttr, or AffineMapAttr (with single result,
    /// probably an identity map).
    fn convert_dim_expr<'ast>(
        codegen: &LlzkCodegen<'ast, 'llzk>,
        expr: &Expression,
    ) -> Result<Attribute<'llzk>> {
        match expr {
            Expression::Number(meta, big_int) => {
                let int_attr = IntegerAttribute::new(
                    Type::index(codegen.context),
                    big_int.to_i64().ok_or_else(|| anyhow!("Array dimension must fit in i64"))?,
                );
                Ok(int_attr.into())
            }
            Expression::Variable { meta, name, access } => {
                // TODO: generate AffineMapAttr (with single result) or SymbolRefAttr (from param)
                todo!("Handle Variable expression in dimension")
            }
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                todo!("Handle InfixOp expression in dimension")
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                todo!("Handle PrefixOp expression in dimension")
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                todo!("Handle InlineSwitchOp expression in dimension")
            }
            Expression::Call { meta, id, args } => {
                todo!("Handle Call expression in dimension")
            }
            // The remaining cases do not produce a scalar value.
            // i.e. ParallelOp, ArrayInLine, UniformArray, BusCall, AnonymousComp, Tuple
            // Give the same error that the circom type checker gives. The type checker ran
            // earlier so this should technically be unreachable.
            _ => Err(anyhow!("Array indexes and lengths must be single arithmetic expressions")),
        }
    }
}

/// Stores ref to the current function while generating LLZK IR for the function.
struct FunctionContext<'llzk> {
    /// The function reference.
    func: FuncDefOpRefMut<'llzk, 'llzk>,
    /// Nested block context within the function.
    block_ctx: BlockContextStack<'llzk>,
    /// Local name mapped to the SSA Value with that name. Initialized with function
    /// parameters and extended with any variable-to-variable assignments found.
    name_to_value: HashMap<String, Value<'llzk, 'llzk>>,
}

impl<'llzk> FunctionContext<'llzk> {
    /// Create a new FunctionContext for the given function and name-to-value map.
    fn new(
        func: FuncDefOpRefMut<'llzk, 'llzk>,
        name_to_value: HashMap<String, Value<'llzk, 'llzk>>,
    ) -> Result<Self> {
        Ok(Self { func, block_ctx: func.deref().try_into()?, name_to_value })
    }

    /// Append an operation that must produce a single result and is NOT associated with a variable
    /// name in the circom code.
    fn append_op_unnamed_result(&mut self, op: Operation<'llzk>) -> Result<Value<'llzk, 'llzk>> {
        single_result_as_value(self.block_ctx.append_current(op))
    }

    /// Append an operation that must produce a single result and store the mapping of the circom
    /// variable name to the result Value.
    fn append_op_named_result(&mut self, op: Operation<'llzk>, name: String) {
        let v = self.append_op_unnamed_result(op).expect("Expected op to produce a single result");
        self.name_to_value.insert(name, v);
    }
}

/// Implement Drop on FunctionContext to remove any remaining `undef.undef` ops from the function.
/// These were added when visiting the Declaration statements and their uses were replaced with
/// actual values when visiting Assignment statements.
impl Drop for FunctionContext<'_> {
    fn drop(&mut self) {
        self.func.walk(WalkOrder::PreOrder, |op| {
            if llzk::dialect::undef::is_undef_op(op) {
                let mut op_ref_mut = unsafe { OperationRefMut::from_raw(op.to_raw()) };
                OperationMutLike::remove_from_parent(op_ref_mut.deref_mut());
                WalkResult::Skip
            } else {
                WalkResult::Advance
            }
        });
    }
}

/// Stores refs to the current struct and its associated functions
/// while generating LLZK IR for a template.
struct TemplateContext<'llzk> {
    /// Current LLZK `StructDefOp`
    struct_def: StructDefOpRefMut<'llzk, 'llzk>,
    /// Codegen refs for the "@compute" function within `struct_def`
    compute: FunctionContext<'llzk>,
    /// Codegen refs for the "@constrain" function within `struct_def`
    constrain: FunctionContext<'llzk>,
}

/// A trait to generate LLZK IR for structural elements of the circom AST:
/// ProgramArchive, TemplateData, and FunctionData.
trait GenerateLLZKInModule {
    /// Generates LLZK IR from the circom AST element.
    /// 'ast: lifetime of the circom AST element
    /// 'llzk: lifetime of the `LlzkContext` and generated `Module`
    fn gen_llzk<'llzk, 'ast: 'llzk>(&'ast self, codegen: &LlzkCodegen<'ast, 'llzk>) -> Result<()>;
}

impl GenerateLLZKInModule for ProgramArchive {
    fn gen_llzk<'llzk, 'ast: 'llzk>(&'ast self, codegen: &LlzkCodegen<'ast, 'llzk>) -> Result<()> {
        for data in self.functions.values() {
            data.gen_llzk(codegen)?;
        }
        for data in self.templates.values() {
            data.gen_llzk(codegen)?;
        }
        Ok(())
    }
}

impl GenerateLLZKInModule for FunctionData {
    fn gen_llzk<'llzk, 'ast: 'llzk>(&'ast self, codegen: &LlzkCodegen<'ast, 'llzk>) -> Result<()> {
        let location = codegen.location(self.get_file_id(), self.get_param_location());
        let felt_type = FeltType::new(codegen.context).into();
        // TODO: This just uses `felt.type` for param and return types but those must actually
        //  be determined based on the caller. This also affects the dimensions of array types
        //  and which array read/write-like ops must be used when translating the body.
        let inputs = vec![felt_type; self.get_num_of_params()];
        let func_type = FunctionType::new(codegen.context, &inputs, &[felt_type]);
        let func_def =
            function::def(location, self.get_name(), func_type, &[], None).and_then(|f| {
                let arguments: Vec<(Type, Location)> =
                    inputs.into_iter().map(|t| (t, location)).collect();
                f.region(0)?.append_block(Block::new(&arguments));
                Ok(f)
            })?;

        // Store function to the module.
        let func: FuncDefOpRefMut = codegen.add_function(func_def)?;

        // Generate mapping from parameter names to SSA Values.
        let name_to_value = map_name_to_arg_value(func, self.get_name_of_params())?;

        // Visit the body of the function and generate LLZK IR for it.
        let mut func_context = FunctionContext::new(func, name_to_value)?;
        for s in self.get_body_as_vec() {
            s.gen_llzk_in_function(codegen, &mut func_context)?;
        }

        Ok(())
    }
}

impl GenerateLLZKInModule for TemplateData {
    fn gen_llzk<'llzk, 'ast: 'llzk>(&'ast self, codegen: &LlzkCodegen<'ast, 'llzk>) -> Result<()> {
        // Collect declarations first to determine struct fields and function parameters.
        let mut declarations = DeclarationInfo::default();
        for s in self.get_body_as_vec() {
            declarations.visit(codegen, s)?;
        }

        // Generate the struct definition, prepopulated with fields.
        let struct_loc = codegen.location(self.get_file_id(), self.get_param_location());
        let struct_params: Vec<_> = self.get_name_of_params().iter().map(String::as_str).collect();
        let struct_def =
            r#struct::def(struct_loc, self.get_name(), &struct_params, declarations.struct_fields)?;
        let new_struct = codegen.add_struct(struct_def)?;

        // Generate the compute and constrain functions.
        let inputs: Vec<_> = declarations.inputs.iter().map(|v| v.type_and_loc).collect();
        let arg_attrs: Vec<_> = declarations.inputs.iter().map(|v| v.attrs.as_slice()).collect();
        let new_struct_type = new_struct.r#type();
        let struct_body = new_struct.body();
        let compute_func = FuncDefOpRef::try_from(struct_body.append_operation(
            compute_fn(struct_loc, new_struct_type, &inputs, Some(&arg_attrs))?.into(),
        ))?
        .into();
        let constrain_func = FuncDefOpRef::try_from(struct_body.append_operation(
            constrain_fn(struct_loc, new_struct_type, &inputs, Some(&arg_attrs))?.into(),
        ))?
        .into();

        // Map parameter Values of each LLZK function to the corresponding circom variable names and
        // then create the FunctionContext for each function. Before creating the FunctionContext
        // for constrain, add a dummy name at index 0 since the first parameter is the struct ref.
        let mut arg_names: Vec<_> = declarations.inputs.iter().map(|i| i.name.clone()).collect();
        let mut compute_ctx =
            FunctionContext::new(compute_func, map_name_to_arg_value(compute_func, &arg_names)?)?;
        arg_names.insert(0, "**self**".to_string());
        let mut constrain_ctx = FunctionContext::new(
            constrain_func,
            map_name_to_arg_value(constrain_func, &arg_names)?,
        )?;
        // Insert the Operations created from variable Declaration statements and map the circom
        // variable name to LLZK op result Value (do this in each function).
        declarations.var_decls.into_iter().for_each(|(name, op)| {
            // Insert (a clone of) the declaration into the compute function.
            compute_ctx.append_op_named_result(op.clone(), name.clone());
            // Insert the declaration into the constrain function.
            constrain_ctx.append_op_named_result(op, name);
        });

        // Visit the body of the template and generate LLZK IR for it within the struct functions.
        let mut template_context = TemplateContext {
            struct_def: new_struct,
            compute: compute_ctx,
            constrain: constrain_ctx,
        };
        for s in self.get_body_as_vec() {
            s.gen_llzk_in_template(codegen, &mut template_context)?;
        }

        Ok(())
    }
}

/// A trait to generate LLZK IR from the body of a circom function.
///
/// 'llzk: lifetime of the `LlzkContext` and generated `Module`
trait GenerateLLZKInFunction<'llzk> {
    /// Output type of the generator function. [Statement] nodes do not produce a value so this
    /// should be the unit type whereas [Expression] nodes produce a Value.
    type Output: 'llzk;

    /// Generates LLZK IR from [Statement] and [Expression] nodes in a circom function.
    ///
    /// 'ast: lifetime of the circom AST element
    fn gen_llzk_in_function<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        function: &mut FunctionContext<'llzk>,
    ) -> Result<Self::Output>;
}

impl<'llzk> GenerateLLZKInFunction<'llzk> for Statement {
    type Output = ();

    fn gen_llzk_in_function<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        function: &mut FunctionContext<'llzk>,
    ) -> Result<Self::Output> {
        match self {
            Statement::InitializationBlock { xtype, initializations, .. } => {
                if let VariableType::Signal(..) = xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                for init in initializations {
                    init.gen_llzk_in_function(codegen, function)?;
                }
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                if VariableType::Var != *xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                // TODO: I don't think there's actually anything to do here, unless we
                //  need to store some info about the declared dimensions of the var.
            }
            Statement::Block { stmts, .. } => {
                for s in stmts {
                    s.gen_llzk_in_function(codegen, function)?;
                }
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                let rhv = rhe.gen_llzk_in_function(codegen, function)?;
                if access.is_empty() {
                    // Since there's no simple assignment in LLZK, just update the mapped Value
                    // which essentially propagates the assignment.
                    function.name_to_value.insert(var.clone(), rhv);
                } else {
                    todo!("Generate array write operation in function");
                }
            }
            Statement::UnderscoreSubstitution { meta, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                todo!("Handle underscore assignment in function")
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                todo!("Handle if-then-else statement in function")
            }
            Statement::While { meta, cond, stmt } => {
                todo!("Handle while statement in function")
            }
            Statement::Return { meta, value } => {
                let value = value.gen_llzk_in_function(codegen, function)?;
                let location = codegen.location_from_meta(meta);
                function.block_ctx.append_current(function::r#return(location, &[value]));
            }
            Statement::Assert { meta, arg } => {
                todo!("Handle assert statement in function")
            }
            Statement::LogCall { meta, .. } => {
                codegen.emit_circom_warning(
                    meta,
                    "log calls are not currently supported in LLZK",
                    ReportCode::NotAllowedOperation,
                );
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
            }
            Statement::ConstraintEquality { .. } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Function uses template operators");
            }
        }
        Ok(())
    }
}

impl<'llzk> GenerateLLZKInFunction<'llzk> for Expression {
    type Output = Value<'llzk, 'llzk>;

    fn gen_llzk_in_function<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        function: &mut FunctionContext<'llzk>,
    ) -> Result<Self::Output> {
        match self {
            Expression::Number(meta, big_int) => {
                // Convert the BigInt to an LLZK `felt.const` op. The user of the Expression is
                // responsible for converting this `felt.type` value to another type if needed.
                function.append_op_unnamed_result(new_felt_const_op(codegen, meta, big_int)?)
            }
            Expression::Variable { meta, name, access } => {
                match access.as_slice() {
                    [] => {
                        let v = function
                            .name_to_value
                            .get(name)
                            .ok_or_else(|| anyhow!("variable {name} not found"))?;
                        Ok(*v)
                    }
                    a => {
                        // Note: `Access::ComponentAccess` is not legal in functions per
                        // `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                        // so each must be `Access::ArrayAccess` only.
                        todo!("Handle accesses in variable expression in function")
                    }
                }
            }
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                todo!("Handle InfixOp expression in function")
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                todo!("Handle PrefixOp expression in function")
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                todo!("Handle InlineSwitchOp expression in function")
            }
            Expression::ParallelOp { meta, rhe } => {
                todo!("Handle ParallelOp expression in function")
            }
            Expression::ArrayInLine { meta, values } => {
                todo!("Handle ArrayInLine expression in function")
            }
            Expression::UniformArray { meta, value, dimension } => {
                todo!("Handle UniformArray expression in function")
            }
            Expression::Call { meta, id, args } => {
                todo!("Handle Call expression in function")
            }
            Expression::BusCall { meta, id, args } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Template elements declared inside the function")
            }
            Expression::AnonymousComp { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::Tuple { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
        }
    }
}

/// A trait to generate LLZK IR from the body of a circom template.
///
/// 'llzk: lifetime of the `LlzkContext` and generated `Module`
trait GenerateLLZKInTemplate<'llzk> {
    /// Output type of the generator function. [Statement] nodes do not produce a value so this
    /// should be the unit type whereas [Expression] nodes produce a Value.
    type Output: 'llzk;

    /// Generates LLZK IR from [Statement] and [Expression] nodes in a circom template.
    ///
    /// 'ast: lifetime of the circom AST element
    fn gen_llzk_in_template<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        template: &mut TemplateContext<'llzk>,
    ) -> Result<Self::Output>;
}

impl<'llzk> GenerateLLZKInTemplate<'llzk> for Statement {
    type Output = ();

    fn gen_llzk_in_template<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        template: &mut TemplateContext<'llzk>,
    ) -> Result<Self::Output> {
        match self {
            Statement::InitializationBlock { initializations, .. } => {
                for init in initializations {
                    init.gen_llzk_in_template(codegen, template)?;
                }
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                // TODO: we've already handled declarations to create struct fields and function
                // parameters. Is there any reason to visit them again? If not, then
                // we don't need the InitializationBlock above either.
                println!("TODO: anything else to do with declaration? {name} of type {xtype:?}");
            }
            Statement::Block { stmts, .. } => {
                for s in stmts {
                    s.gen_llzk_in_template(codegen, template)?;
                }
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                let rhv = rhe.gen_llzk_in_template(codegen, template)?;
                if access.is_empty() {
                    // Since there's no simple assignment in LLZK, just update the mapped Value
                    // which essentially propagates the assignment.
                    match op {
                        AssignOp::AssignVar => {
                            template.compute.name_to_value.insert(var.clone(), rhv.compute_val);
                            template.constrain.name_to_value.insert(var.clone(), rhv.constrain_val);
                        }
                        AssignOp::AssignSignal => {
                            todo!("Handle AssignSignal in Substitution in template")
                        }
                        AssignOp::AssignConstraintSignal => {
                            todo!("Handle AssignConstraintSignal in Substitution in template")
                        }
                    }
                } else {
                    todo!("Generate array write operation in template");
                }
            }
            Statement::UnderscoreSubstitution { meta, op, rhe } => {
                todo!("Handle underscore assignment in template")
            }
            Statement::ConstraintEquality { meta, lhe, rhe } => {
                todo!("Handle constraint equality in template")
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                todo!("Handle if-then-else statement in template")
            }
            Statement::While { meta, cond, stmt } => {
                todo!("Handle while statement in template")
            }
            Statement::Assert { meta, arg } => {
                todo!("Handle assert statement in template")
            }
            Statement::LogCall { meta, .. } => {
                codegen.emit_circom_warning(
                    meta,
                    "log calls are not currently supported in LLZK",
                    ReportCode::NotAllowedOperation,
                );
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
            }
            Statement::Return { .. } => {
                // per `type_analysis/src/analyzers/no_returns_in_template.rs`
                unreachable!("return statements are not allowed in templates")
            }
        }
        Ok(())
    }
}

/// For both the compute and constrain function, holds the SSA Value that results from generating
/// LLZK for a circom Expression within a template.
#[derive(Debug)]
struct GenTemplateOutput<'llzk> {
    /// Result Value for the `@compute` function.
    compute_val: Value<'llzk, 'llzk>,
    /// Result Value for the `@constrain` function.
    constrain_val: Value<'llzk, 'llzk>,
}

impl<'llzk> GenerateLLZKInTemplate<'llzk> for Expression {
    type Output = GenTemplateOutput<'llzk>;

    fn gen_llzk_in_template<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        template: &mut TemplateContext<'llzk>,
    ) -> Result<Self::Output> {
        match self {
            Expression::Number(meta, big_int) => {
                // Convert the BigInt to an LLZK `felt.const` op. The user of the Expression is
                // responsible for converting this `felt.type` value to another type if needed.
                let op = new_felt_const_op(codegen, meta, big_int)?;
                // Add the op to both functions (if the result is unused in one, dce can remove it).
                Ok(GenTemplateOutput {
                    compute_val: template.compute.append_op_unnamed_result(op.clone())?,
                    constrain_val: template.constrain.append_op_unnamed_result(op)?,
                })
            }
            Expression::Variable { meta, name, access } => match access.as_slice() {
                [] => {
                    let compute_val = *template
                        .compute
                        .name_to_value
                        .get(name)
                        .ok_or_else(|| anyhow!("variable {name} not found"))?;

                    let constrain_val = *template
                        .constrain
                        .name_to_value
                        .get(name)
                        .ok_or_else(|| anyhow!("variable {name} not found"))?;

                    Ok(GenTemplateOutput { compute_val, constrain_val })
                }
                a => {
                    todo!("Handle accesses in Variable expression in template")
                }
            },
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                todo!("Handle InfixOp expression in template")
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                todo!("Handle PrefixOp expression in template")
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                todo!("Handle InlineSwitchOp expression in template")
            }
            Expression::ParallelOp { meta, rhe } => {
                todo!("Handle ParallelOp expression in template")
            }
            Expression::ArrayInLine { meta, values } => {
                todo!("Handle ArrayInLine expression in template")
            }
            Expression::UniformArray { meta, value, dimension } => {
                todo!("Handle UniformArray expression in template")
            }
            Expression::Call { meta, id, args } => {
                todo!("Handle Call expression in template")
            }
            Expression::BusCall { meta, id, args } => {
                todo!("Handle BusCall expression in template")
            }
            Expression::AnonymousComp { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::Tuple { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
        }
    }
}

/// Create a new, empty LLZK `Module` with Location "main" from the `ProgramArchive`.
fn new_llzk_module<'llzk>(
    context: &'llzk LlzkContext,
    program_archive: &ProgramArchive,
) -> Module<'llzk> {
    let files = &program_archive.file_library;
    let filename = files.get_filename_or_default(program_archive.get_file_id_main());
    let main_file_location = Location::new(context, &filename, 0, 0);
    llzk::dialect::module::llzk_module(main_file_location)
}

/// Generate LLZK IR from the given `ProgramArchive` and write it to a file with the given filename.
#[allow(clippy::result_unit_err)]
pub fn generate_llzk(program_archive: &ProgramArchive, filename: &str) -> Result<(), ()> {
    let ctx = LlzkContext::new();
    let module = new_llzk_module(&ctx, program_archive);
    let codegen = LlzkCodegen { program_archive, context: &ctx, module: &module };

    program_archive.gen_llzk(&codegen).map_err(|err| {
        eprintln!("{} {err}", Color::Red.paint("Failed to generate LLZK IR:"));
    })?;

    // Verify the module and write it to file
    if !codegen.verify() {
        eprintln!("{}", Color::Red.paint("Generated LLZK IR is invalid"));
        eprintln!("{}", codegen.module.as_operation());
        return Err(());
    }

    codegen.write_to_file(filename).map_err(|err| {
        eprintln!("{} {err}", Color::Red.paint("Failed to write LLZK IR:"));
    })
}
