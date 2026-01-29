//! Shared code generation utilities.

use crate::function::FunctionContext;
use crate::module::DeclarationInfo;
use crate::program_ext::ProgramLike;
use crate::subcmp::names::COMP;
use crate::template_ext::TemplateLike;
use crate::template_ext::WireLike;
use crate::traversal::walk_from_block;
use crate::traversal::WalkCallbacks;
use ansi_term::Color;
use anyhow::anyhow;
use anyhow::ensure;
use anyhow::Result;
use llzk::dialect::undef;
use llzk::operation::move_op_after;
use llzk::prelude::felt;
use llzk::prelude::melior_dialects::arith;
use llzk::prelude::verify_operation_with_diags;
use llzk::prelude::ArrayType;
use llzk::prelude::Attribute;
use llzk::prelude::AttributeLike;
use llzk::prelude::BlockLike;
use llzk::prelude::BlockRef;
use llzk::prelude::BoolAttribute;
use llzk::prelude::CallOpLike as _;
use llzk::prelude::CallOpRef;
use llzk::prelude::FeltConstAttribute;
use llzk::prelude::FeltType;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::FuncDefOp;
use llzk::prelude::FuncDefOpLike;
use llzk::prelude::FuncDefOpRef;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::IntegerType;
use llzk::prelude::LlzkContext;
use llzk::prelude::LlzkError;
use llzk::prelude::Location;
use llzk::prelude::Module;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike;
use llzk::prelude::OperationRef;
use llzk::prelude::OperationResult;
use llzk::prelude::PassManager;
use llzk::prelude::PodType;
use llzk::prelude::StringAttribute;
use llzk::prelude::StructDefOp;
use llzk::prelude::StructDefOpRef;
use llzk::prelude::StructDefOpRefMut;
use llzk::prelude::StructType;
use llzk::prelude::Type;
use llzk::prelude::TypeLike as _;
use llzk::prelude::Value;
use llzk::prelude::ValueLike;
use llzk::value_ext::get_single_user;
use llzk::value_ext::replace_all_uses_in_block_with;
use llzk::value_ext::OwningValueRange;
use llzk::value_ext::ValueRange;
use melior::dialect::scf;
use melior::ir::Block;
use melior::ir::Region;
use melior::ir::RegionLike as _;
use melior::utility;
use num_bigint_dig::BigInt;
use num_bigint_dig::BigUint;
use num_bigint_dig::ModInverse;
use num_bigint_dig::ToBigInt as _;
use num_traits::cast::ToPrimitive;
use num_traits::One;
use num_traits::Zero;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use program_structure::ast::Meta;
use program_structure::constants::UsefulConstants;
use program_structure::error_code::ReportCode;
use program_structure::error_definition::Report;
use program_structure::file_definition::FileID;
use program_structure::file_definition::FileLocation;
use program_structure::wire_data::WireType;
use std::cell::RefCell;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::convert::TryInto;
use std::convert::TryInto as _;
use std::fs;
use std::fs::File;
use std::io::Write;
use std::ops::Deref;
use std::os::raw::c_void;
use std::path::Path;

/// Information about a template's declaration, either full before LLZK IR is generated for the
/// template or, after the template is processed, just the minimal information needed to support
/// queries about input signal types that other templates may need.
#[derive(Debug)]
enum DeclInfo<'ctx> {
    /// Complete declaration info computed initially.
    Full(DeclarationInfo<'ctx>),
    /// Just the map of signal name to type left behind after generating LLZK for a template.
    Remnant(HashMap<String, Type<'ctx>>),
}

/// Stores necessary context for generating LLZK IR.
///
/// 'ast: lifetime of the circom AST element
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
#[derive(Debug)]
pub struct LlzkCodegen<'ast, 'ctx, P: ProgramLike> {
    /// The circom program AST.
    pub program: &'ast P,
    /// The LLZK (and MLIR) context.
    pub context: &'ctx LlzkContext,
    /// The generated LLZK `Module`.
    pub module: Module<'ctx>,
    /// The name of the prime field.
    pub prime_str: &'ctx str,
    /// State of the `--verbose` flag.
    pub verbose: bool,
    /// Declaration info pre-computed for all templates.
    template_decls: RefCell<HashMap<String, DeclInfo<'ctx>>>,
}

impl<'ast, 'ctx, P: ProgramLike> LlzkCodegen<'ast, 'ctx, P> {
    /// Construct.
    pub fn new(
        program: &'ast P,
        context: &'ctx LlzkContext,
        module: Module<'ctx>,
        prime_str: &'ctx str,
        verbose: bool,
    ) -> Self {
        LlzkCodegen {
            program,
            context,
            module,
            prime_str,
            verbose,
            template_decls: RefCell::new(Default::default()),
        }
    }

    /// Store the full [DeclarationInfo] for the template with the given name.
    pub fn put_template_decl(&self, name: &str, decl_info: DeclarationInfo<'ctx>) {
        self.template_decls.borrow_mut().insert(name.to_string(), DeclInfo::Full(decl_info));
    }

    /// Remove and return the full [DeclarationInfo] for the template with the given name and leave
    /// behind just the mapping of signal names to types.
    pub fn take_template_decl(&self, name: &str) -> Result<DeclarationInfo<'ctx>> {
        let mut borrow = self.template_decls.borrow_mut();
        if let Some((name, DeclInfo::Full(decl_info))) = borrow.remove_entry(name) {
            borrow.insert(name, DeclInfo::Remnant(decl_info.build_input_name_to_type_map()));
            return Ok(decl_info);
        }
        Err(anyhow!("No full declaration info for {name}"))
    }

    /// Get the type of the input signal with the given name in the given template, if it exists.
    pub fn get_input_signal_type(
        &self,
        template_name: &str,
        signal_name: &str,
    ) -> Result<Type<'ctx>> {
        let borrow = self.template_decls.borrow();
        match borrow.get(template_name) {
            None => anyhow::bail!("No declaration info for {template_name}"),
            Some(DeclInfo::Full(info)) => info.get_input_type(signal_name),
            Some(DeclInfo::Remnant(map)) => map.get(signal_name).copied(),
        }
        .ok_or_else(|| anyhow!("No input signal with name {signal_name}"))
    }

    /// Get the width of the scalar prime field in bits.
    pub fn prime_field_bits(&self) -> Result<usize> {
        Ok(self.prime()?.bits())
    }

    /// Get the prime field modulus as a BigUint
    pub fn prime(&self) -> Result<BigUint> {
        let c = UsefulConstants::new(&self.prime_str.to_string());
        c.get_p().to_biguint().ok_or_else(|| anyhow!("prime should be convertible to unsigned"))
    }

    /// Emit a circom-style warning.
    pub fn emit_circom_warning(&self, meta: &Meta, message: &str, code: ReportCode) {
        let mut report = Report::warning(String::from(message), code);
        report.add_primary(meta.file_location(), meta.get_file_id(), String::from("here"));
        Report::print_reports(&[report], self.program.get_file_library());
    }

    /// Emit a circom-style error.
    pub fn emit_circom_error(&self, meta: &Meta, message: &str, code: ReportCode) {
        let mut report = Report::error(String::from(message), code);
        report.add_primary(meta.file_location(), meta.get_file_id(), String::from("here"));
        Report::print_reports(&[report], self.program.get_file_library());
    }

    /// Get the unknown location.
    pub fn location_unknown(&self) -> Location<'ctx> {
        Location::unknown(self.context)
    }

    /// Convert circom location information to MLIR location.
    pub fn location(&self, file_id: FileID, file_location: FileLocation) -> Location<'ctx> {
        let files = self.program.get_file_library();
        let filename = files.get_filename_or_default(&file_id);
        let line = files.get_line(file_location.start, file_id).unwrap_or(0);
        let column = files.get_column(file_location.start, file_id).unwrap_or(0);
        Location::new(self.context, &filename, line, column)
    }

    /// Convert circom Meta location information to MLIR location.
    pub fn location_from_meta(&self, meta: &Meta) -> Location<'ctx> {
        if let Some(file) = meta.file_id {
            self.location(file, meta.file_location())
        } else {
            self.location_unknown()
        }
    }

    /// Insert the struct into the module and return a reference to it.
    pub fn add_struct(&self, s: StructDefOp<'ctx>) -> Result<StructDefOpRefMut<'ctx, '_>> {
        let s: StructDefOpRef = self.module.body().append_operation(s.into()).try_into()?;
        Ok(s.into())
    }

    /// Insert the free function into the module and return a reference to it.
    pub fn add_function(&self, f: FuncDefOp<'ctx>) -> Result<FuncDefOpRefMut<'ctx, '_>> {
        let f: FuncDefOpRef = self.module.body().append_operation(f.into()).try_into()?;
        Ok(f.into())
    }

    /// Try to statically compute the value of a circom [Expression] used as an array
    /// dimension. This is computed in a separate function so that nested expressions
    /// return BigUint results instead of IntegerAttributes.
    ///
    /// Returns `None` if the expression cannot be computed statically, Some(BigUint)
    /// if the computation is successful, and an error if a conversion error occurs
    /// along the way.
    pub fn try_compute_dim_expr(&self, expr: &Expression) -> Result<Option<BigUint>> {
        match expr {
            Expression::Number(_, big_int) => {
                let v =
                    big_int.to_biguint().ok_or_else(|| anyhow!("could not convert to signed"))?
                        % self.prime()?;
                Ok(Some(v))
            }
            Expression::InfixOp { lhe, infix_op, rhe, .. } => {
                let lhs = self.try_compute_dim_expr(lhe)?;
                let rhs = self.try_compute_dim_expr(rhe)?;
                match (lhs, rhs) {
                    (Some(lhs), Some(rhs)) => {
                        // Perform the arithmetic
                        let p = self.prime()?;
                        let bool_to_biguint = |b| if b { BigUint::one() } else { BigUint::zero() };
                        let res = match infix_op {
                            ExpressionInfixOpcode::Mul => (lhs * rhs) % p,
                            ExpressionInfixOpcode::Div => {
                                let rhs_inv = rhs
                                    .mod_inverse(&p)
                                    .ok_or_else(|| anyhow!("failed to compute inverse"))?
                                    .to_biguint()
                                    .ok_or_else(|| anyhow!("could not convert to BigUint"))?;
                                (lhs * rhs_inv) % p
                            }
                            ExpressionInfixOpcode::Add => (lhs + rhs) % p,
                            ExpressionInfixOpcode::Sub => (lhs + (&p - rhs)) % p,
                            ExpressionInfixOpcode::Pow => lhs.modpow(&rhs, &p),
                            ExpressionInfixOpcode::IntDiv => (lhs / rhs) % p,
                            ExpressionInfixOpcode::Mod => lhs % rhs,
                            ExpressionInfixOpcode::ShiftL => {
                                (lhs << rhs
                                    .to_usize()
                                    .ok_or_else(|| anyhow!("could not convert to usize"))?)
                                    % p
                            }
                            ExpressionInfixOpcode::ShiftR => {
                                (lhs >> rhs
                                    .to_usize()
                                    .ok_or_else(|| anyhow!("could not convert to usize"))?)
                                    % p
                            }
                            // Comparison operators are performed based on a signed interpretation
                            // of the field elements as defined by the `relational_val` function,
                            // according to the circom spec.
                            ExpressionInfixOpcode::LesserEq => {
                                let res = relational_val(&lhs, &p)? <= relational_val(&rhs, &p)?;
                                bool_to_biguint(res)
                            }
                            ExpressionInfixOpcode::GreaterEq => {
                                let res = relational_val(&lhs, &p)? >= relational_val(&rhs, &p)?;
                                bool_to_biguint(res)
                            }
                            ExpressionInfixOpcode::Lesser => {
                                let res = relational_val(&lhs, &p)? < relational_val(&rhs, &p)?;
                                bool_to_biguint(res)
                            }
                            ExpressionInfixOpcode::Greater => {
                                let res = relational_val(&lhs, &p)? > relational_val(&rhs, &p)?;
                                bool_to_biguint(res)
                            }
                            ExpressionInfixOpcode::Eq => bool_to_biguint(lhs == rhs),
                            ExpressionInfixOpcode::NotEq => bool_to_biguint(lhs != rhs),
                            ExpressionInfixOpcode::BoolOr => {
                                bool_to_biguint(!lhs.is_zero() || !rhs.is_zero())
                            }
                            ExpressionInfixOpcode::BoolAnd => {
                                bool_to_biguint(!lhs.is_zero() && !rhs.is_zero())
                            }
                            ExpressionInfixOpcode::BitOr => (lhs | rhs) % p,
                            ExpressionInfixOpcode::BitAnd => lhs & rhs,
                            ExpressionInfixOpcode::BitXor => (lhs ^ rhs) % p,
                        };
                        Ok(Some(res))
                    }
                    _ => Ok(None),
                }
            }
            Expression::PrefixOp { prefix_op, rhe, .. } => {
                let rhs = self.try_compute_dim_expr(rhe)?;
                match rhs {
                    Some(rhs) => {
                        // Perform the arithmetic
                        let p = &self.prime()?;
                        let res = match prefix_op {
                            ExpressionPrefixOpcode::Sub => {
                                if rhs.is_zero() {
                                    rhs
                                } else {
                                    p - rhs
                                }
                            }
                            ExpressionPrefixOpcode::BoolNot => {
                                if rhs.is_zero() {
                                    BigUint::one()
                                } else {
                                    BigUint::zero()
                                }
                            }
                            ExpressionPrefixOpcode::Complement => {
                                let mask = (BigUint::one() << p.bits()) - BigUint::one();
                                mask ^ rhs
                            }
                        };
                        Ok(Some(res))
                    }
                    _ => Ok(None),
                }
            }
            Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
                let cond = self.try_compute_dim_expr(cond)?;
                let if_true = self.try_compute_dim_expr(if_true)?;
                let if_false = self.try_compute_dim_expr(if_false)?;
                match (cond, if_true, if_false) {
                    (Some(cond), Some(if_true), Some(if_false)) => {
                        Ok(Some(if !cond.is_zero() { if_true } else { if_false }))
                    }
                    _ => Ok(None),
                }
            }
            _ => Ok(None),
        }
    }

    /// If `dimensions` is empty, return `base_type`. Otherwise, create [ArrayType] by
    /// converting the dimension sizes to LLZK Attributes.
    pub fn type_from_dimension_consts(
        &self,
        base_type: Type<'ctx>,
        dimensions: &[usize],
    ) -> Result<Type<'ctx>> {
        if dimensions.is_empty() {
            Ok(base_type)
        } else {
            dimensions
                .iter()
                .map(|c| {
                    i64::try_from(*c)
                        .map_err(Into::into)
                        .map(|c| Attribute::from(self.index_attr(c)))
                })
                .collect::<Result<Vec<_>, _>>()
                .map(|dims| ArrayType::new(base_type, &dims).into())
        }
    }

    /// Create an LLZK operation that produces a nondeterministic value of the given type.
    pub fn new_nondet_at_location(
        &self,
        location: Location<'ctx>,
        result_type: Type<'ctx>,
    ) -> Result<Operation<'ctx>> {
        Ok(undef::undef(location, result_type))
    }

    /// Get the integer type of the given bitwidth.
    #[inline]
    pub fn int_type(&self, bits: u32) -> IntegerType<'ctx> {
        IntegerType::new(self.context, bits)
    }

    /// Get the boolean type (`i1`).
    #[inline]
    pub fn bool_type(&self) -> IntegerType<'ctx> {
        self.int_type(1)
    }

    /// Get the index type.
    #[inline]
    pub fn index_type(&self) -> Type<'ctx> {
        Type::index(self.context)
    }

    /// Get the felt type.
    #[inline]
    pub fn felt_type(&self) -> FeltType<'ctx> {
        FeltType::new(self.context)
    }

    /// Get the struct type for the given struct name.
    #[inline]
    pub fn struct_type(&self, name: &str) -> StructType<'ctx> {
        StructType::from_str(self.context, name)
    }

    /// Create an index attribute.
    #[inline]
    pub fn index_attr<T>(&self, integer: T) -> IntegerAttribute<'ctx>
    where
        T: Into<i64>,
    {
        IntegerAttribute::new(self.index_type(), integer.into())
    }

    /// Create an affine_map attribute from a string definition.
    pub fn affine_map_attr(&self, definition: &str) -> Result<Attribute<'ctx>> {
        Attribute::parse(self.context, definition)
            .ok_or_else(|| anyhow!("could not parse affine_map definition"))
    }

    /// Create an LLZK operation that produces a boolean constant value.
    #[inline]
    pub fn new_bool_const_op(&self, val: bool, location: Location<'ctx>) -> Operation<'ctx> {
        arith::constant(self.context, BoolAttribute::new(self.context, val).into(), location)
    }

    /// Create an LLZK operation that produces an integer constant value.
    #[inline]
    pub fn new_int_const_op(
        &self,
        ty: Type<'ctx>,
        val: i64,
        location: Location<'ctx>,
    ) -> Operation<'ctx> {
        arith::constant(self.context, IntegerAttribute::new(ty, val).into(), location)
    }

    /// Create an LLZK operation that produces an index constant value.
    #[inline]
    pub fn new_index_const_op<T>(&self, val: T, location: Location<'ctx>) -> Operation<'ctx>
    where
        T: Into<i64>,
    {
        arith::constant(self.context, self.index_attr(val).into(), location)
    }

    /// Generate a `felt.const` operation from a BigInt. Returns an `Err` result if unsuccessful
    /// or if the number of bits required to represent the BigInt does not fit in 32 bits.
    pub fn new_felt_const_op(
        &self,
        val: &BigInt,
        location: Location<'ctx>,
    ) -> Result<Operation<'ctx>> {
        // ASSERT: The circom parser always produces non-negative constants. These can be negated
        // via PrefixOp but negative BigInt constants are never created directly.
        assert_ne!(val.sign(), num_bigint_dig::Sign::Minus, "Felt constants must be non-negative");
        let attr = FeltConstAttribute::parse(
            self.context,
            // use required bits +1 to ensure unsigned representation
            u32::try_from(val.bits())? + 1,
            val.to_string().as_str(),
        );
        felt::constant(location, attr).map_err(Into::into)
    }

    /// Run cleanup passes on the generated `Module`.
    pub fn run_passes(&mut self, pass_pipeline: &str) -> Result<()> {
        if pass_pipeline.is_empty() {
            return Ok(());
        }
        let manager = PassManager::new(self.context);
        manager.enable_verifier(true);
        utility::register_all_passes();
        utility::parse_pass_pipeline(manager.as_operation_pass_manager(), pass_pipeline)
            .map_err(anyhow::Error::from)?;
        manager.run(&mut self.module).map_err(Into::into)
    }

    /// Verify the generated `Module`.
    pub fn verify(&self) -> Result<(), LlzkError> {
        verify_operation_with_diags(&self.module.as_operation())
    }

    /// Create file at the given path, ensuring parent directories exist.
    fn create_file(filename: &str) -> Result<File> {
        let out_path = Path::new(filename);
        // Ensure parent directories exist
        if let Some(parent) = out_path.parent() {
            fs::create_dir_all(parent).map_err(anyhow::Error::from)?;
        }
        File::create(out_path).map_err(Into::into)
    }

    /// Write the generated `Module` to a file in LLZK IR assembly format.
    pub fn write_to_file(self, filename: &str) -> Result<()> {
        let mut file = Self::create_file(filename)?;
        write!(file, "{}", self.module.as_operation())?;
        println!("{} {}", Color::Green.paint("Written successfully:"), filename);
        Ok(())
    }

    /// Write the generated `Module` to a file in bytecode format.
    pub fn write_bytecode_to_file(self, filename: &str) -> Result<()> {
        unsafe extern "C" fn callback(string_ref: mlir_sys::MlirStringRef, user_data: *mut c_void) {
            let file = &mut *(user_data as *mut File);
            let slice = std::slice::from_raw_parts(string_ref.data as *const u8, string_ref.length);
            file.write_all(slice).unwrap();
        }

        let mut file = Self::create_file(filename)?;
        unsafe {
            mlir_sys::mlirOperationWriteBytecode(
                self.module.as_operation().to_raw(),
                Some(callback),
                &mut file as *mut File as *mut c_void,
            );
        }
        println!("{} {}", Color::Green.paint("Written successfully:"), filename);
        Ok(())
    }

    /// Returns the data for the template with that name.
    pub fn find_template_data(
        &self,
        name: &'ast str,
    ) -> Option<&'ast (impl TemplateLike + use<'ast, P>)> {
        if self.program.contains_template(name) {
            Some(self.program.get_template_data(name))
        } else {
            None
        }
    }

    /// Returns the types of the inputs for the given template, in declaration order.
    pub fn get_template_input_types(&self, name: &'ast str) -> Result<Vec<Type<'ctx>>> {
        let data =
            self.find_template_data(name).ok_or_else(|| anyhow!("Template {name} not found"))?;
        Ok(data
            .get_declaration_inputs()
            .iter()
            .map(move |(input, _)| -> Type<'ctx> {
                let wire = data
                    .get_input_info(input)
                    // The name comes from `get_declaration_inputs`.
                    // If `get_input_info` fails here with that name,
                    // something has gone very wrong.
                    .unwrap_or_else(|| panic!("Input {:?} not found for type {:?}", input, name));
                match wire.get_type() {
                    WireType::Signal => FeltType::new(self.context).into(),
                    WireType::Bus(name) => StructType::from_str(self.context, &name).into(),
                }
            })
            .collect())
    }

    /// Convert a `Vec<String>` into a comma-separated [StringAttribute].
    #[inline]
    pub fn list_to_attribute(&self, names: &[String]) -> Attribute<'ctx> {
        StringAttribute::new(self.context, &names.join(",")).into()
    }

    /// Convert a [StringAttribute] containing a comma-separated list into a `Vec<String>`.
    #[inline]
    pub fn attribute_to_list(
        &self,
        attr: Attribute<'ctx>,
    ) -> Result<impl Iterator<Item = &'ctx str>> {
        Ok(StringAttribute::try_from(attr)?.value().split(','))
    }
}

/// Extract the single result Value from an OperationRef. Returns an `Err` result if the operation
/// does not have exactly one result.
///
/// 'c: lifetime of the `LlzkContext` and generated `Module`
/// 'a: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn single_result_as_value<'c: 'a, 'a>(op: impl OperationLike<'c, 'a>) -> Result<Value<'c, 'a>> {
    if op.result_count() != 1 {
        return Err(anyhow!(
            "Expected operation to have a single result, found {}",
            op.result_count()
        ));
    }
    op.result(0).map(Value::from).map_err(Into::into)
}

/// Ensures the given OperationRef has 0 result Values, else returns an `Err` result.
///
/// 'c: lifetime of the `LlzkContext` and generated `Module`
/// 'a: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn no_results<'c: 'a, 'a>(op: impl OperationLike<'c, 'a>) -> Result<()> {
    if op.result_count() != 0 {
        return Err(anyhow!("Expected operation to have no results, found {}", op.result_count()));
    }
    Ok(())
}

/// Create a map of circom variable names (either function arguments or template input signals) to
/// LLZK function argument Values.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn map_name_to_arg_value<'ctx, 'val>(
    func: FuncDefOpRefMut<'ctx, 'val>,
    arg_names: Vec<String>,
) -> Result<HashMap<String, Value<'ctx, 'val>>> {
    arg_names
        .into_iter()
        .enumerate()
        .map(|(i, name)| {
            func.deref().argument(i).map_err(Into::into).map(|a| (name, Value::from(a)))
        })
        .collect::<Result<HashMap<_, _>, _>>()
}

/// Return `true` iff the given Type is an `IndexType`.
#[inline]
pub fn is_index(t: Type) -> bool {
    t.is_index()
}

/// Return `true` iff the given Type is a boolean type, i.e. `i1`.
#[inline]
pub fn is_bool(t: Type) -> bool {
    t.is_integer() && IntegerType::try_from(t).is_ok_and(|it| it.width() == 1)
}

/// Add a new argument to the given [BlockRef] with the same type as `orig` and replace all uses of
/// `orig` within the given [BlockRef] (and within any nested blocks) with the new block argument.
pub fn replace_uses_with_new_block_argument<'ctx, 'val>(
    block: BlockRef<'ctx, 'val>,
    orig: &Value<'ctx, 'val>,
    location: Location<'ctx>,
) -> Value<'ctx, 'val> {
    let replacement = block.add_argument(orig.r#type(), location);
    walk_from_block(
        block,
        WalkCallbacks::for_blocks(|b| replace_all_uses_in_block_with(b, *orig, replacement)),
    );
    replacement
}

/// Sets the n-th operand of the operation to the given value if the current value is an
/// `undef.undef` op.
pub fn set_operand_if_undef<'ctx, 'op>(
    op: OperationRef<'ctx, 'op>,
    idx: usize,
    value: impl ValueLike<'ctx>,
) -> Result<()> {
    if let Ok(arg) = OperationResult::try_from(op.operand(idx)?) {
        if !undef::is_undef_op(&arg.owner()) {
            anyhow::bail!("Argument {idx} was assigned twice: {arg}");
        }
    }
    unsafe { mlir_sys::mlirOperationSetOperand(op.to_raw(), idx as isize, value.to_raw()) }
    Ok(())
}

/// Moves the operation after the value if the value comes from another operation.
///
/// If the operation the value comes from is in an inner block, moves the op right after the parent
/// op that is in the same block as the op about to be moved.
///
/// # Panics
///
/// If the parent search reaches the top, meaning that the value comes from an op in a block that
/// is a 'parent' of the other op or that the value's op is not owned by a block.
pub fn insert_after_if_op_result<'ctx, 'val, 'op>(
    val: Value<'ctx, 'val>,
    op: OperationRef<'ctx, 'op>,
) -> Result<()> {
    if let Ok(mut owner) = op_result_owner(val) {
        anyhow::ensure!(owner.block().is_some(), "reference op must belong to a block");
        if let Some(op_block) = op.block() {
            owner = find_parent_in_block(op_block, owner).expect("parent op not found");
        };
        move_op_after(&owner, &op);
    }
    Ok(())
}

/// Returns the op (or a parent op) that belongs to the block.
fn find_parent_in_block<'ctx, 'blk, 'op>(
    block: BlockRef<'ctx, 'blk>,
    op: OperationRef<'ctx, 'op>,
) -> Option<OperationRef<'ctx, 'op>> {
    let parent_block = op.block()?;
    if block == parent_block {
        Some(op)
    } else {
        find_parent_in_block(block, parent_block.parent_operation()?)
    }
}

/// Create new array type that is an array of the given sub-array type.
#[inline]
pub fn new_array_type<'c>(dim: Attribute<'c>, subarr_ty: &ArrayType<'c>) -> ArrayType<'c> {
    let dims: Vec<_> = std::iter::once(dim).chain(subarr_ty.dims()).collect();
    ArrayType::new(subarr_ty.element_type(), &dims)
}

/// Tries to obtain the owner operation of a [`Value`](melior::ir::Value).
///
/// This function works around a lifetime issue in [`OperationResult::owner`] that
/// is resolved in [mlir-sys/melior#784](https://github.com/mlir-rs/melior/pull/784) but that
/// we cannot benefit from yet.
#[inline]
pub fn op_result_owner<'ctx, 'val, 'op: 'val>(
    value: Value<'ctx, 'val>,
) -> Result<OperationRef<'ctx, 'op>> {
    if !value.is_operation_result() {
        anyhow::bail!("Value {value} is not an operation result");
    }
    unsafe { OperationRef::from_option_raw(mlir_sys::mlirOpResultGetOwner(value.to_raw())) }
        .ok_or_else(|| anyhow::anyhow!("owner of {value} is not a valid operation"))
}

/// Looks for a call op to a constrain function where the given value is the first argument.
///
/// Fails if:
///     - The value has more than one use.
///     - The use is not a constrain call.
///     - The used value is not the first operand.
#[inline]
pub fn get_constrain_call<'ctx, 'op, 'val>(
    value: Value<'ctx, 'val>,
) -> Result<OperationRef<'ctx, 'op>> {
    let owner: CallOpRef<'ctx, 'op> = get_single_user(value)?.try_into()?;
    if !owner.callee_is_constrain() {
        anyhow::bail!("operation {owner} is not a call to a constrain function");
    }

    let fst_operand = owner.operand(0)?;
    if fst_operand != value {
        anyhow::bail!("first operand {fst_operand} does not match target: {value}");
    }

    Ok(owner.into())
}

/// Convert unsigned field elements into relational values used for comparisons.
///
/// relational_val(a) = a-p  if m/2 +1 <= a < m
/// relational_val(a) = a,    otherwise.
///
/// see https://docs.circom.io/circom-language/basic-operators/#relational-operators
/// for definition.
pub fn relational_val(a: &BigUint, p: &BigUint) -> Result<BigInt> {
    let a = (a % p)
        .to_bigint()
        .ok_or_else(|| anyhow!("could not convert field element to signed int"))?;
    let p =
        p.to_bigint().ok_or_else(|| anyhow!("could not convert field modulus to signed int"))?;
    let val = if ((&p / 2) + 1) <= a { a - p } else { a };
    Ok(val)
}

/// Heuristically detect a circom `for` loop (represented by a `Statement::Block` containing a
/// `Statement::InitializationBlock` followed by a `Statement::While`). Since all values in circom
/// are of type `felt`, we cannot (easily) generate `scf.for` which requires index-typed loop
/// variables so this macro generates code for the `Statement::InitializationBlock` followed by an
/// `scf.while` for the loop (and then returns "Ok" so that the caller does not fall through to the
/// normal code generation for a Block). Additionally, if the loop bounds and step can be computed
/// as compile-time constants, then create an LLZK `loopbounds` attribute to attach to the generated
/// `scf.while` loop.
#[macro_export]
macro_rules! try_for_loop_heuristic {
    ($codegen:expr, $gen_context:expr, $meta:expr, $stmts:expr) => {
        if let [program_structure::ast::Statement::InitializationBlock {
            xtype: program_structure::ast::VariableType::Var,
            initializations,
            ..
        }, program_structure::ast::Statement::While { cond, stmt, .. }] = $stmts.as_slice()
        {
            // TODO: Analyze `initializations` and `While` loop contents to determine if loop bounds
            // and step can be computed. The loop `cond` is probably the starting point to find the
            // loop iteration variable and then `initializations` has the start value and the loop
            // body `stmt` has the step.
            // TODO: Once this is implemented, find "for" loops in all `.circom` test files to add
            // the `loopbounds` attribute to relevant loops (because existing tests will likely not
            // fail when this is added since the lit checks only do line prefix by default).
            let loop_bounds = None;

            gen_init_block($codegen, $gen_context, initializations)?;
            return gen_while($codegen, $gen_context, $meta, cond, stmt, loop_bounds);
        }
    };
}

/// Returns a reference to a parent operation.
///
/// This function provides an API that is added in a newer release of melior via
/// [mlir-sys/melior#789](https://github.com/mlir-rs/melior/pull/789).
pub fn parent_operation_mut<'c: 'a, 'a>(
    op: &impl OperationLike<'c, 'a>,
) -> Option<melior::ir::operation::OperationRefMut<'c, 'a>> {
    unsafe {
        melior::ir::operation::OperationRefMut::from_option_raw(
            mlir_sys::mlirOperationGetParentOperation(op.to_raw()),
        )
    }
}

/// Returns a mutable reference to the next operation in the same block.
///
/// This function provides an API fix that is added in a newer release of melior via
/// [mlir-sys/melior#790](https://github.com/mlir-rs/melior/pull/790).
pub fn next_in_block_mut<'c: 'a, 'a>(
    op: &impl melior::ir::operation::OperationLike<'c, 'a>,
) -> Option<melior::ir::operation::OperationRefMut<'c, 'a>> {
    unsafe {
        melior::ir::operation::OperationRefMut::from_option_raw(
            mlir_sys::mlirOperationGetNextInBlock(op.to_raw()),
        )
    }
}

/// Removes itself from a parent block and returns the owned [Operation].
pub fn remove_from_parent<'c: 'a, 'a>(
    op: &mut impl melior::ir::operation::OperationMutLike<'c, 'a>,
) -> Operation<'c> {
    unsafe {
        mlir_sys::mlirOperationRemoveFromParent(op.to_raw());
    }
    unsafe { Operation::from_raw(op.to_raw()) }
}

/// Information needed to create a new LLZK array type with the given dimension
/// and to instantiate that array if the dimension attribute is an affine_map
/// with symbols.
#[derive(Debug, Clone)]
pub struct ArrayDimension<'ctx, 'val> {
    /// The attribute to use as the dimension; could be a constant, a symbol, or an affine map.
    attr: Attribute<'ctx>,
    /// The symbols to be passed to the affine map, if attr is an AffineMapAttr
    symbols: Option<OwningValueRange<'ctx, 'val>>,
}

impl<'ctx, 'val> ArrayDimension<'ctx, 'val> {
    /// Construct a new ArrayDimension.
    /// If attr is not an affine map, then symbol_vals should be empty.
    pub fn new(attr: Attribute<'ctx>, symbol_vals: &[Value<'ctx, 'val>]) -> Result<Self> {
        ensure!(
            attr.is_affine_map() || symbol_vals.is_empty(),
            "if attribute is not an affine map, no symbols should be provided"
        );
        Ok(Self {
            attr,
            symbols: (!symbol_vals.is_empty()).then(|| OwningValueRange::from(symbol_vals)),
        })
    }
    /// Access the inner attribute.
    pub fn attr(&self) -> &Attribute<'ctx> {
        &self.attr
    }
    /// Access the inner symbols, if present, as a [ValueRange].
    pub fn value_range(&self) -> Result<Option<ValueRange<'ctx, '_, 'val>>> {
        let range = match &self.symbols {
            None => None,
            Some(s) => Some(ValueRange::try_from(s)?),
        };
        Ok(range)
    }
    /// Create a new [ArrayType] with the given dimension.
    pub fn new_array_type(&self, element_type: &Type<'ctx>) -> ArrayType<'ctx> {
        if let Ok(subarr_ty) = ArrayType::try_from(*element_type) {
            new_array_type(self.attr, &subarr_ty)
        } else {
            ArrayType::new(*element_type, &[self.attr])
        }
    }
    /// Transform the array dimension using the given function that converts
    /// values into new values (e.g., casting operations to index).
    pub fn transform(
        &self,
        mut map_fn: impl FnMut(Value<'ctx, 'val>) -> Result<Value<'ctx, 'val>>,
    ) -> Result<Self> {
        Ok(Self {
            attr: self.attr,
            symbols: match &self.symbols {
                None => None,
                Some(ovr) => {
                    let translated_vals = ovr
                        .values()
                        .iter()
                        .map(|v| map_fn(unsafe { Value::from_raw(*v) }))
                        .collect::<Result<Vec<_>>>()?;
                    Some(OwningValueRange::from(translated_vals.as_slice()))
                }
            },
        })
    }
}

#[derive(Debug, Clone)]
/// Conveys information about array dimension computation.
pub enum ArrayDimensionResult<'ctx, 'val> {
    /// Indicates that the computing context had
    /// sufficient information to compute the array and computed it successfully.
    Computed(ArrayDimension<'ctx, 'val>),
    /// Indicates that the computing context
    /// was missing information (e.g., variables defined within the function not accessible
    /// at template level).
    InsufficientData,
}

impl<'ctx, 'val> ArrayDimensionResult<'ctx, 'val> {
    /// Construct a new [ArrayDimensionResult::Computed].
    pub fn new(attr: Attribute<'ctx>, symbol_vals: &[Value<'ctx, 'val>]) -> Result<Self> {
        Ok(Self::Computed(ArrayDimension::new(attr, symbol_vals)?))
    }
    /// Construct a [ArrayDimensionResult::InsufficientData].
    /// A convenience method for cases needing a return value of [Result<ArrayDimensionResult>]
    pub fn insufficient_data_result() -> Result<Self> {
        Ok(Self::InsufficientData)
    }
}

impl<'ctx, 'val> From<ArrayDimensionResult<'ctx, 'val>> for Option<ArrayDimension<'ctx, 'val>> {
    fn from(value: ArrayDimensionResult<'ctx, 'val>) -> Self {
        match value {
            ArrayDimensionResult::Computed(array_dimension) => Some(array_dimension),
            ArrayDimensionResult::InsufficientData => None,
        }
    }
}

impl<'ctx, 'val> TryFrom<&ArrayDimension<'ctx, 'val>> for IntegerAttribute<'ctx> {
    type Error = anyhow::Error;

    fn try_from(dim: &ArrayDimension<'ctx, 'val>) -> Result<Self> {
        ensure!(dim.value_range()?.is_none(), "const dimension should have no symbols");
        if let Ok(d) = IntegerAttribute::try_from(*dim.attr()) {
            Ok(d)
        } else {
            Err(anyhow!("could not convert to IntegerAttribute"))
        }
    }
}

/// Information needed to create a new LLZK array type with the given dimensions.
#[derive(Debug, Default)]
pub struct ArrayDimensions<'ctx, 'val>(Vec<ArrayDimension<'ctx, 'val>>);

impl<'ast, 'ctx, 'val> ArrayDimensions<'ctx, 'val> {
    /// Check if the number of dimensions is non-zero.
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
    /// Get all contained attributes.
    pub fn attrs(&self) -> Vec<Attribute<'ctx>> {
        self.0.iter().map(|d| *d.attr()).collect()
    }
    /// Create a new [ArrayType] with the given dimensions.
    pub fn new_array_type(&self, element_type: &Type<'ctx>) -> ArrayType<'ctx> {
        ArrayType::new(*element_type, self.attrs().as_slice())
    }
    /// Get the non-empty symbol values for affine map instantiation.
    #[allow(dead_code)] // TODO: temporary, pending more support for computing array dimensions
    pub fn symbol_vals(&self) -> Result<Vec<ValueRange<'ctx, '_, 'val>>> {
        let optional_vec = self.0.iter().map(|d| d.value_range()).collect::<Result<Vec<_>>>()?;
        Ok(optional_vec.into_iter().flatten().collect())
    }

    /// If `self` is empty, return `base_type`. Otherwise, create [ArrayType] by
    /// converting the dimension circom [Expressions](Expression) to LLZK Attributes.
    pub fn type_from_dimension_exprs(&self, base_type: Type<'ctx>) -> Type<'ctx> {
        if self.is_empty() {
            base_type
        } else {
            self.new_array_type(&base_type).into()
        }
    }

    /// Create an LLZK operation that produces a nondeterministic `felt.type` value of the given
    /// `dimensions` (non-array scalar if empty).
    #[inline]
    pub fn new_nondet_felt_of_dimensions_at_location(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<Operation<'ctx>> {
        codegen.new_nondet_at_location(
            location,
            self.type_from_dimension_exprs(codegen.felt_type().into()),
        )
    }

    /// Create an LLZK operation that produces a nondeterministic `felt.type` value of the given
    /// `dimensions` (non-array scalar if empty).
    #[inline]
    pub fn new_nondet_felt_of_dimensions(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        meta: &Meta,
    ) -> Result<Operation<'ctx>> {
        self.new_nondet_felt_of_dimensions_at_location(codegen, codegen.location_from_meta(meta))
    }

    /// If `dimensions` is empty, returns a [`StructType`] with just the name. Otherwise,
    /// returns a [`StructType`] with parameters by converting the
    /// dimension circom Expressions to LLZK Attributes.
    pub fn struct_type_with_concrete_dimensions(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        name: &str,
    ) -> StructType<'ctx> {
        if self.is_empty() {
            StructType::from_str(codegen.context, name)
        } else {
            StructType::new(FlatSymbolRefAttribute::new(codegen.context, name), &self.attrs())
        }
    }
}

/// Constructs a new [ArrayDimensions] if all input [ArrayDimensionResult] are
/// [ArrayDimensionResult::Computed], returns [Err] otherwise.
impl<'ctx, 'val> TryFrom<&[ArrayDimensionResult<'ctx, 'val>]> for ArrayDimensions<'ctx, 'val> {
    type Error = ();

    fn try_from(dim_results: &[ArrayDimensionResult<'ctx, 'val>]) -> Result<Self, Self::Error> {
        let dims = dim_results
            .iter()
            .cloned()
            .map(Option::from)
            .filter_map(|mut x| Option::take(&mut x))
            .collect::<Vec<_>>();
        if dims.len() == dim_results.len() {
            Ok(ArrayDimensions(dims))
        } else {
            Err(())
        }
    }
}

impl<'ctx, 'val, P: ProgramLike> TryFrom<(&[usize], &LlzkCodegen<'_, 'ctx, P>)>
    for ArrayDimensions<'ctx, 'val>
{
    type Error = anyhow::Error;

    fn try_from(
        (dim_sizes, codegen): (&[usize], &LlzkCodegen<'_, 'ctx, P>),
    ) -> Result<Self, Self::Error> {
        dim_sizes
            .iter()
            .map(|size| ArrayDimension::new(codegen.index_attr(i64::try_from(*size)?).into(), &[]))
            .collect::<Result<Vec<_>>>()
            .map(ArrayDimensions)
    }
}

/// A trait to generate array dimensions from the given dimension expressions.
pub trait DimExprConverter<'ctx, 'ast, 'val> {
    /// Convert a circom [Expression] used as an array dimension to an LLZK Attribute.
    /// Returns an error if there was an error converting a dimension that should
    /// be convertible.
    /// Returns [ArrayDimensionResult::InsufficientData] if a dimension is not
    /// convertible due to lack of information in the implementer.
    /// Users can then attempt to resolve the dimension in a different
    /// context, or throw an error if all available contexts are unable to convert
    /// the dimension.
    ///
    /// Note: The LLZK ArrayType can only use the following Attribute types for dimensions:
    /// IntegerAttr (`index` or `i1`) or AffineMapAttr (with single result).
    /// To simplify the implementation, template parameters are read using `poly.read_const`
    /// and passed to an affine map rather than trying to use a symbol attribute as the
    /// dimension (which would only work for bare template parameters without computation anyways).
    fn convert_dim_expr(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ArrayDimensionResult<'ctx, 'val>>;

    /// Computes the [ArrayDimensions] from the given `dimension_exprs`, returning:
    /// - An error if one of the underlying [Expression]s generated an error,
    /// - [None] if one of the underling [Expression]s generated a
    ///   [ArrayDimensionResult::InsufficientData]
    /// - [Some] otherwise
    fn get_dimensions_if_able(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        dimension_exprs: &[Expression],
    ) -> Result<Option<ArrayDimensions<'ctx, 'val>>> {
        let dim_result_vec = dimension_exprs
            .iter()
            .map(|e| self.convert_dim_expr(codegen, e))
            .collect::<Result<Vec<_>>>()?;
        Ok(ArrayDimensions::try_from(dim_result_vec.as_slice()).ok())
    }

    /// Same as [DimExprConverter::get_dimensions_if_able], but converts [None]
    /// into an error. For cases where [ArrayDimensions] are expected to be generated
    /// and there are no fallback contexts to try.
    fn get_dimensions(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        dimension_exprs: &[Expression],
    ) -> Result<ArrayDimensions<'ctx, 'val>> {
        self.get_dimensions_if_able(codegen, dimension_exprs)?.ok_or_else(|| {
            anyhow!("unexpected lack of data needed to convert dimension expressions")
        })
    }
}

/// Maps the inner type of the given type if it is an [`ArrayType`]. Returns the new type
/// otherwise.
///
/// ```text
/// map([T], O) -> [O]
/// map(T, O) -> O
/// ```
pub fn map_array_inner_type<'ctx>(t: Type<'ctx>, new_inner: Type<'ctx>) -> Type<'ctx> {
    ArrayType::try_from(t).map(|t| ArrayType::new(new_inner, &t.dims()).into()).unwrap_or(new_inner)
}

/// Returns a region that contains one block with the given arguments.
pub fn region_with_block<'ctx>(arguments: &[(Type<'ctx>, Location<'ctx>)]) -> Region<'ctx> {
    let region = Region::new();
    region.append_block(Block::new(arguments));
    region
}

/// Creates a loop nest from a list of dimensions.
///
/// The body of the inner-most loop is defined by the given closure, which accepts a list of values
/// representing the current value of each loop's induction variable.
pub fn loop_nest<'ctx, 'val, 'func, 'blk>(
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    fc: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
    dims: &[Attribute<'ctx>],
    body: impl FnOnce(&mut FunctionContext<'ctx, 'func, 'blk, 'val>, &[Value<'ctx, 'val>]) -> Result<()>,
) -> Result<()>
where
    'val: 'blk,
{
    let zero = fc.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
    let one = fc.append_op_unnamed_result(codegen.new_index_const_op(1, location))?;

    // Create values from the dimensions
    let dim_values = dims
        .iter()
        .copied()
        .map(|attr| {
            if let Ok(_) = IntegerAttribute::try_from(attr) {
                return fc.append_op_unnamed_result(arith::constant(
                    codegen.context,
                    attr,
                    location,
                ));
            }

            unreachable!("Unhandled attribute in array dimensions {}", attr)
        })
        .collect::<Result<Vec<_>, _>>()?;

    let loop_block_args = [(codegen.index_type(), location)];
    let top_block = *fc.block_ctx.top_block();
    let mut loop_vars: Vec<Value> = vec![];
    // Create the loop nest
    let mut block: Option<BlockRef<'_, '_>> = None;
    for dim in dim_values {
        let op = scf::r#for(zero, dim, one, region_with_block(&loop_block_args), location);
        let loop_op = match &block {
            Some(block_ref) => block_ref.append_operation(op),
            None => fc.append_op(op),
        };
        block = Some(
            loop_op
                .region(0)?
                .first_block()
                .ok_or_else(|| anyhow::anyhow!("region is missing first block"))?,
        );
        // Accumulate the induction variables for later giving all of them to the callback.
        loop_vars.push(block.unwrap().argument(0)?.into());
    }

    // Unwrap the block after creating the loop nest.
    let mut block = block.ok_or_else(|| anyhow::anyhow!("no loops created"))?;
    // Push the block of the inner-most loop s.t. the user can use `fc` and ops will get added to
    // the right block.
    fc.block_ctx.push(block);
    body(fc, &loop_vars)?;
    fc.block_ctx.pop();

    // Traverse the stack of blocks until we reach the block where we inserted the whole nest.
    // For each block traversed this way add the scf terminator op.
    while block != top_block {
        block.append_operation(scf::r#yield(&[], location));
        block = block
            .parent_operation()
            .and_then(|op| op.block())
            .ok_or_else(|| anyhow::anyhow!("detached block while creating loop nest"))?;
    }

    Ok(())
}

/// This macro allows writing type switches with a syntax similar to match expressions.
#[macro_export]
macro_rules! type_switch {
    // Entry point
    { $name:ident = $value:expr, $( $body:tt )+ } => {{
        // Evaluate once
        let $name = $value;

        type_switch!(@parse $name, $( $body )+)
    }};

    // Entry point
    { $name:ident, $( $body:tt )+ } => {
        type_switch!(@parse $name, $( $body )+);
    };

    // Parsing

    (@parse $name:ident, $ty:ty => $body:block $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $name, $body) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as $bind:ident => $body:block $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $bind, $body) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as  => $body:block $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, _, $body) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty  => $body:expr, $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $name, {$body}) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as $bind:ident  => $body:expr, $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $bind, {$body}) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as _  => $body:expr, $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, _, {$body}) $( $rest )*)
    };

    // Inner implementation

    // Last arm without default case
    (@inner $name:ident, ( $ty:ty, $bind:ident, $body:block) $(,)?) => {
        type_switch!(@inner $name, ( $ty, $bind, $body) else => {panic!("unhandled type {}", $name)})
    };
    (@inner $name:ident, ( $ty:ty, _, $body:block) $(,)?) => {
        type_switch!(@inner $name, ( $ty, _, $body) else => {panic!("unhandled type {}", $name)})
    };

    // Last arm with default case
    (@inner $name:ident, ( $ty:ty, $bind:ident, $body:block ) else => $else_body:expr $(,)?) => {
        if let Ok($bind) = <$ty>::try_from($name) {
            $body
        } else {
            $else_body
        }
    };

    (@inner $name:ident, ( $ty:ty, _, $body:block ) else => $else_body:expr $(,)?) => {
        if let Ok(_) = <$ty>::try_from($name) {
            $body
        } else {
            $else_body
        }
    };

    // Recursive case
    (@inner $name:ident, ( $ty:ty, $bind:ident, $body:block ) $( $rest:tt )+ ) => {
        if let Ok($bind) = <$ty>::try_from($name) {
            $body
        } else {
            type_switch!(@parse $name, $( $rest )+)
        }
    };

    (@inner $name:ident, ( $ty:ty, _, $body:block ) $( $rest:tt )+ ) => {
        if let Ok(_) = <$ty>::try_from($name) {
            $body
        } else {
            type_switch!(@parse $name, $( $rest )+)
        }
    };
}

/// Returns the type of a subcomponent as defined in its memory.
pub fn comp_type<'ctx>(pod: PodType<'ctx>) -> Result<Type<'ctx>> {
    pod.get_type_of_record(COMP)
        .ok_or_else(|| anyhow::anyhow!("missing {} record in memory struct: {pod:?}", COMP))
}
