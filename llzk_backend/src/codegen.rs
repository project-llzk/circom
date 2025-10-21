use std::{
    convert::TryInto as _,
    fs::{self, File},
    io::Write,
    os::raw::c_void,
    path::Path,
};
use ansi_term::Color;
use anyhow::{Result, anyhow};
use program_structure::{
    ast::{Expression, Meta, SignalType, Statement, VariableType},
    file_definition::{FileID, FileLocation},
    function_data::FunctionData,
    program_archive::ProgramArchive,
    template_data::TemplateData,
};
use melior::ir::{
    operation::OperationLike as _, Attribute, BlockLike, Identifier, Location, Module, Operation,
    RegionLike, Type, Value,
};
use llzk::{
    error::Error,
    prelude::{
        function,
        r#struct::{
            self,
            helpers::{compute_fn, constrain_fn},
        },
        FeltType, FuncDefOp, FuncDefOpRef, FuncDefOpRefMut, FunctionType, LlzkContext,
        PublicAttribute, StructDefOp, StructDefOpLike, StructDefOpRef, StructDefOpRefMut,
    },
};

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
    /// Convert circom location information to MLIR location.
    pub fn location(&self, file_id: FileID, file_location: FileLocation) -> Location<'llzk> {
        let files = &self.program_archive.file_library;
        let filename = files.get_filename_or_default(&file_id);
        let line = files.get_line(file_location.start, file_id).unwrap_or(0);
        let column = files.get_column(file_location.start, file_id).unwrap_or(0);
        Location::new(self.context, &filename, line, column)
    }

    /// Convert circom Meta location information to MLIR location.
    pub fn location_from_meta(&self, meta: &Meta) -> Location<'llzk> {
        if let Some(file) = meta.file_id {
            self.location(file, meta.file_location())
        } else {
            Location::unknown(self.context)
        }
    }

    /// Insert the struct into the module and return a reference to it.
    pub fn add_struct(&self, s: StructDefOp<'llzk>) -> Result<StructDefOpRefMut<'llzk, '_>> {
        let s: StructDefOpRef = self.module.body().append_operation(s.into()).try_into()?;
        Ok(s.into())
    }

    /// Insert the free function into the module and return a reference to it.
    pub fn add_function(&self, f: FuncDefOp<'llzk>) -> Result<FuncDefOpRefMut<'llzk, '_>> {
        let f: FuncDefOpRef = self.module.body().append_operation(f.into()).try_into()?;
        Ok(f.into())
    }

    /// Verify the generated `Module`.
    pub fn verify(&self) -> bool {
        self.module.as_operation().verify()
    }

    /// Write the generated `Module` to a file.
    pub fn write_to_file(self, filename: &str) -> Result<(), ()> {
        let out_path = Path::new(filename);
        // Ensure parent directories exist
        if let Some(parent) = out_path.parent() {
            fs::create_dir_all(parent).map_err(|_err| {})?;
        }
        let mut file = File::create(out_path).map_err(|_err| {})?;

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

/// Information collected from Declaration statements within a template that
/// is used to setup LLZK struct fields and function parameters.
#[derive(Default)]
struct DeclarationInfo<'llzk> {
    /// Input declarations to use as function parameters
    func_inputs: Vec<(Type<'llzk>, Location<'llzk>)>,
    /// Function parameter attributes. Same length as `func_inputs`.
    func_input_attrs: Vec<Vec<(Identifier<'llzk>, Attribute<'llzk>)>>,
    /// Output and Intermediate declarations to use as struct fields
    struct_fields: Vec<Result<Operation<'llzk>, Error>>,
}

impl<'llzk> DeclarationInfo<'llzk> {
    /// Visit a statement and populate this `DeclarationInfo` with any declarations found.
    fn visit<'ast>(&mut self, stmt: &'ast Statement, codegen: &LlzkCodegen<'ast, 'llzk>) {
        match stmt {
            Statement::InitializationBlock { initializations, .. } => {
                // The InitializationBlock is just a wrapper that contains no additional information
                // beyond the Declaration that must appear within it so just process the inner statements.
                for init in initializations {
                    self.visit(init, codegen);
                }
            }
            Statement::Declaration { meta, name, xtype, dimensions, .. } => {
                // The Signal and Bus types use SignalType to indicate if they are input, output, or intermediate.
                // The others are all intermediate. Intermediates become struct fields, outputs become "pub" struct
                // fields, and inputs become arguments to the functions.
                match xtype {
                    VariableType::Signal(signal_type, ..) => {
                        let location = codegen.location_from_meta(meta);
                        let decl_type = if dimensions.is_empty() {
                            FeltType::new(codegen.context).into()
                        } else {
                            todo!("create FeltType array with dimensions: {:?}", dimensions);
                        };
                        if SignalType::Input == *signal_type {
                            self.func_inputs.push((decl_type, location));
                            if codegen
                                .program_archive
                                .get_public_inputs_main_component()
                                .contains(name)
                            {
                                self.func_input_attrs
                                    .push(vec![PublicAttribute::named_attr_pair(codegen.context)]);
                            } else {
                                self.func_input_attrs.push(vec![]);
                            }
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
                    }
                    VariableType::Bus(bus_name, signal_type, ..) => {
                        //TODO: this should be StructType instead of FeltType, but otherwise similar to above
                        todo!("Handle bus declaration")
                    }
                    VariableType::Var => {
                        todo!("Handle var declaration")
                    }
                    VariableType::Component => {
                        todo!("Handle component declaration")
                    }
                    VariableType::AnonymousComponent => {
                        unreachable!("removed by 'syntax_sugar_remover'")
                    }
                }
            }
            _ => {}
        }
    }
}

/// Stores refs to the current struct and its associated functions
/// while generating LLZK IR for a template.
struct TemplateContext<'llzk> {
    /// Current LLZK `StructDefOp`
    struct_def: StructDefOpRefMut<'llzk, 'llzk>,
    /// The "@constrain" function within the current LLZK `StructDefOp`
    constrain_func: FuncDefOpRefMut<'llzk, 'llzk>,
    /// The "@compute" function within the current LLZK `StructDefOp`
    compute_func: FuncDefOpRefMut<'llzk, 'llzk>,
}

/// Stores ref to the current free function (i.e. function outside of a template/struct)
/// while generating LLZK IR for the function.
struct FunctionContext<'llzk> {
    /// The function reference
    func: FuncDefOpRefMut<'llzk, 'llzk>,
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
        let func_loc = codegen.location(self.get_file_id(), self.get_param_location());
        let felt_type = FeltType::new(codegen.context).into();
        let func_type = FunctionType::new(
            &codegen.context,
            &vec![felt_type; self.get_num_of_params()],
            &[felt_type],
        );
        let func_def = function::def(func_loc, self.get_name(), func_type, &[], None)?;
        let new_func = codegen.add_function(func_def)?;

        // Visit the body of the function and generate LLZK IR for it.
        let func_context = FunctionContext { func: new_func.into() };
        for s in self.get_body_as_vec() {
            s.gen_llzk_in_function(codegen, &func_context)?;
        }

        Ok(())
    }
}

impl GenerateLLZKInModule for TemplateData {
    fn gen_llzk<'llzk, 'ast: 'llzk>(&'ast self, codegen: &LlzkCodegen<'ast, 'llzk>) -> Result<()> {
        // Collect declarations first to determine struct fields and function parameters.
        let mut declarations = DeclarationInfo::default();
        for s in self.get_body_as_vec() {
            declarations.visit(s, codegen);
        }

        // Generate the struct definition, prepopulated with fields.
        let struct_loc = codegen.location(self.get_file_id(), self.get_param_location());
        let struct_params: Vec<_> = self.get_name_of_params().iter().map(String::as_str).collect();
        let struct_def =
            r#struct::def(struct_loc, self.get_name(), &struct_params, declarations.struct_fields)?;
        let new_struct = codegen.add_struct(struct_def)?;

        // Generate the compute and constrain functions.
        let new_struct_type = new_struct.r#type();
        let struct_body = new_struct.body();
        let arg_attrs: Vec<_> = declarations.func_input_attrs.iter().map(Vec::as_slice).collect();
        let compute_func: FuncDefOpRef = struct_body
            .append_operation(
                compute_fn(
                    struct_loc,
                    new_struct_type,
                    &declarations.func_inputs,
                    Some(&arg_attrs),
                )?
                .into(),
            )
            .try_into()?;
        let constrain_func: FuncDefOpRef = struct_body
            .append_operation(
                constrain_fn(
                    struct_loc,
                    new_struct_type,
                    &declarations.func_inputs,
                    Some(&arg_attrs),
                )?
                .into(),
            )
            .try_into()?;

        // Visit the body of the template and generate LLZK IR for it within the functions.
        let template_context = TemplateContext {
            struct_def: new_struct,
            constrain_func: constrain_func.into(),
            compute_func: compute_func.into(),
        };
        for s in self.get_body_as_vec() {
            s.gen_llzk_in_template(codegen, &template_context)?;
        }

        Ok(())
    }
}

/// A trait to generate LLZK IR from the body of a circom function.
trait GenerateLLZKInFunction {
    /// Generates LLZK IR from [Statement] and [Expression] nodes in the body of a circom
    /// function. [Expressions](Expression) produce a value should return it wrapped in
    /// Some(..) whereas [Statements](Statement) do not produce a value should return None.
    ///
    /// 'ret: lifetime of the returned `Value`
    /// 'ast: lifetime of the circom AST element
    /// 'llzk: lifetime of the `LlzkContext` and generated `Module`
    fn gen_llzk_in_function<'ret, 'ast: 'ret, 'llzk: 'ret>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        function: &FunctionContext<'llzk>,
    ) -> Result<Option<Value<'llzk, 'llzk>>>;
}

impl GenerateLLZKInFunction for Statement {
    fn gen_llzk_in_function<'ret, 'ast: 'ret, 'llzk: 'ret>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        function: &FunctionContext<'llzk>,
    ) -> Result<Option<Value<'llzk, 'llzk>>> {
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
                if let VariableType::Var = xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                todo!("Handle declaration in function")
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
                todo!("Handle variable assignment in function")
            }
            Statement::UnderscoreSubstitution { meta, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                todo!("Handle underscore assignment in function")
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
            }
            Statement::ConstraintEquality { .. } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Function uses template operators");
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                todo!("Handle if-then-else statement in function")
            }
            Statement::While { meta, cond, stmt } => {
                todo!("Handle while statement in function")
            }
            Statement::Return { meta, value } => {
                let value = value
                    .gen_llzk_in_function(codegen, function)?
                    .ok_or_else(|| anyhow!("expression must produce a value"))?;

                let body_region = function.func.region(0)?;
                let body_block = body_region
                    .first_block()
                    .ok_or_else(|| anyhow!("function body has no entry block"))?;
                let location = codegen.location_from_meta(meta);
                body_block.append_operation(function::r#return(location, &[value]));
            }
            Statement::LogCall { .. } => {
                eprintln!("Warning: log calls are not currently supported in LLZK");
            }
            Statement::Assert { meta, arg } => {
                todo!("Handle assert statement in function")
            }
        }
        Ok(None)
    }
}

impl GenerateLLZKInFunction for Expression {
    fn gen_llzk_in_function<'ret, 'ast: 'ret, 'llzk: 'ret>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        function: &FunctionContext<'llzk>,
    ) -> Result<Option<Value<'llzk, 'llzk>>> {
        match self {
            Expression::Number(meta, big_int) => {
                todo!("Handle Number expression in function")
            }
            Expression::Variable { meta, name, access } => {
                todo!("Handle Variable expression in function")
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
trait GenerateLLZKInTemplate {
    /// Generates LLZK IR from [Statement] and [Expression] nodes in the body of a circom
    /// template. [Expressions](Expression) produce a value should return it wrapped in
    /// Some(..) whereas [Statements](Statement) do not produce a value should return None.
    ///
    /// 'ret: lifetime of the returned `Value`
    /// 'ast: lifetime of the circom AST element
    /// 'llzk: lifetime of the `LlzkContext` and generated `Module`
    fn gen_llzk_in_template<'ret, 'ast: 'ret, 'llzk: 'ret>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        template: &TemplateContext<'llzk>,
    ) -> Result<Option<Value<'llzk, 'llzk>>>;
}

impl GenerateLLZKInTemplate for Statement {
    fn gen_llzk_in_template<'ret, 'ast: 'ret, 'llzk: 'ret>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        template: &TemplateContext<'llzk>,
    ) -> Result<Option<Value<'llzk, 'llzk>>> {
        match self {
            Statement::InitializationBlock { initializations, .. } => {
                for init in initializations {
                    init.gen_llzk_in_template(codegen, template)?;
                }
                Ok(None)
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                // TODO: we've already handled declarations to create struct fields and function parameters.
                // Is there any reason to visit them again? If not, then we don't need the InitializationBlock above either.
                println!("TODO: anything else to do with declaration? {name} of type {xtype:?}");
                Ok(None)
            }
            Statement::Block { stmts, .. } => {
                for s in stmts {
                    s.gen_llzk_in_template(codegen, template)?;
                }
                Ok(None)
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                todo!("Handle variable assignment in template")
            }
            Statement::UnderscoreSubstitution { meta, op, rhe } => {
                todo!("Handle underscore assignment in template")
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
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
            Statement::Return { .. } => {
                // per `type_analysis/src/analyzers/no_returns_in_template.rs`
                unreachable!("return statements are not allowed in templates")
            }
            Statement::LogCall { .. } => {
                eprintln!("Warning: log calls are not currently supported in LLZK");
                Ok(None)
            }
            Statement::Assert { meta, arg } => {
                todo!("Handle assert statement in template")
            }
        }
    }
}

impl GenerateLLZKInTemplate for Expression {
    fn gen_llzk_in_template<'ret, 'ast: 'ret, 'llzk: 'ret>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'llzk>,
        template: &TemplateContext<'llzk>,
    ) -> Result<Option<Value<'llzk, 'llzk>>> {
        match self {
            Expression::Number(meta, big_int) => {
                todo!("Handle Number expression in template")
            }
            Expression::Variable { meta, name, access } => {
                todo!("Handle Variable expression in template")
            }
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
fn new_llzk_module<'ast, 'llzk>(
    context: &'llzk LlzkContext,
    program_archive: &'ast ProgramArchive,
) -> Module<'llzk> {
    let files = &program_archive.file_library;
    let filename = files.get_filename_or_default(program_archive.get_file_id_main());
    let main_file_location = Location::new(context, &filename, 0, 0);
    llzk::dialect::module::llzk_module(main_file_location)
}

/// Generate LLZK IR from the given `ProgramArchive` and write it to a file with the given filename.
pub fn generate_llzk(program_archive: &ProgramArchive, filename: &str) -> Result<(), ()> {
    let ctx = LlzkContext::new();
    let module = new_llzk_module(&ctx, program_archive);
    let codegen = LlzkCodegen { program_archive, context: &ctx, module: &module };

    program_archive.gen_llzk(&codegen).map_err(|err| {
        eprintln!("Failed to generate LLZK IR: {err}");
    })?;

    // Verify the module and write it to file
    assert!(codegen.verify());
    codegen.write_to_file(filename).expect("Failed to write LLZK code");

    Ok(())
}
