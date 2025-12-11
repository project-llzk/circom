#![allow(unused_variables)] // TODO: TEMP
use ansi_term::Color;
use anyhow::{anyhow, Ok, Result};
use llzk::prelude::{
    felt, undef, verify_operation_with_diags, ArrayType, FeltConstAttribute, FeltType, FuncDefOp,
    FuncDefOpLike, FuncDefOpRef, FuncDefOpRefMut, IntegerAttribute, LlzkContext, LlzkError,
    StructDefOp, StructDefOpRef, StructDefOpRefMut,
};
use melior::{
    ir::{
        operation::OperationLike as _, Attribute, BlockLike, Location, Module, Operation,
        OperationRef, Type, TypeLike, Value,
    },
    pass, utility,
};
use num_bigint_dig::BigInt;
use num_traits::cast::ToPrimitive;
use program_structure::{
    ast::{Expression, Meta},
    error_code::ReportCode,
    error_definition::Report,
    file_definition::{FileID, FileLocation},
    program_archive::ProgramArchive,
};
use std::{
    collections::HashMap,
    convert::{TryFrom, TryInto as _},
    fs::{self, File},
    io::Write,
    ops::Deref,
    os::raw::c_void,
    path::Path,
};

/// Stores necessary context for generating LLZK IR.
///
/// 'ast: lifetime of the circom AST element
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
pub struct LlzkCodegen<'ast, 'ctx> {
    /// The circom program AST.
    pub program_archive: &'ast ProgramArchive,
    /// The LLZK (and MLIR) context.
    pub context: &'ctx LlzkContext,
    /// The generated LLZK `Module`.
    pub module: Module<'ctx>,
}

impl<'ast, 'ctx> LlzkCodegen<'ast, 'ctx> {
    /// Emit a circom-style warning.
    pub fn emit_circom_warning(&self, meta: &Meta, message: &str, code: ReportCode) {
        let mut report = Report::warning(String::from(message), code);
        report.add_primary(meta.file_location(), meta.get_file_id(), String::from("here"));
        Report::print_reports(&[report], &self.program_archive.file_library);
    }

    /// Emit a circom-style error.
    pub fn emit_circom_error(&self, meta: &Meta, message: &str, code: ReportCode) {
        let mut report = Report::error(String::from(message), code);
        report.add_primary(meta.file_location(), meta.get_file_id(), String::from("here"));
        Report::print_reports(&[report], &self.program_archive.file_library);
    }

    /// Convert circom location information to MLIR location.
    pub fn location(&self, file_id: FileID, file_location: FileLocation) -> Location<'ctx> {
        let files = &self.program_archive.file_library;
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
            Location::unknown(self.context)
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

    /// Convert a circom [Expression] used as an array dimension to an LLZK Attribute.
    ///
    /// Note: The LLZK ArrayType can only use the following Attribute types for dimensions:
    /// IntegerAttr (`index` or `i1`), SymbolRefAttr, or AffineMapAttr (with single result,
    /// probably an identity map).
    ///
    /// 'ast: lifetime of the circom AST element
    pub fn convert_dim_expr(&self, expr: &Expression) -> Result<Attribute<'ctx>> {
        match expr {
            Expression::Number(meta, big_int) => {
                let int_attr = IntegerAttribute::new(
                    Type::index(self.context),
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

    /// If `dimensions` is empty, return `base_type`. Otherwise, create ArrayType by converting the
    /// dimension circom [Expressions](Expression) to LLZK Attributes.
    pub fn type_with_dimensions(
        &self,
        base_type: Type<'ctx>,
        dimensions: &[Expression],
    ) -> Result<Type<'ctx>> {
        if dimensions.is_empty() {
            Ok(base_type)
        } else {
            dimensions
                .iter()
                .map(|e| self.convert_dim_expr(e))
                .collect::<Result<Vec<_>, _>>()
                .map(|dims| ArrayType::new(base_type, &dims).into())
        }
    }

    /// Create an LLZK operation that produces a nondeterministic value of the given `dimensions`.
    pub fn new_nondet_value_of_dimensions(
        &self,
        meta: &Meta,
        dimensions: &[Expression],
    ) -> Result<Operation<'ctx>> {
        Ok(undef::undef(
            self.location_from_meta(meta),
            self.type_with_dimensions(FeltType::new(self.context).into(), dimensions)?,
        ))
    }

    /// Run cleanup passes on the generated `Module`.
    pub fn run_passes(&mut self, pass_pipeline: &str) -> Result<()> {
        if pass_pipeline.is_empty() {
            return Ok(());
        }
        let manager = pass::PassManager::new(self.context);
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
}

/// Generate a `felt.const` operation from a BigInt. Returns an `Err` result if unsuccessful
/// or if the number of bits required to represent the BigInt does not fit in 32 bits.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
pub fn new_felt_const_op<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx>,
    meta: &Meta,
    from: &BigInt,
) -> Result<Operation<'ctx>> {
    // ASSERT: The circom parser always produces non-negative constants. These can be negated via
    // PrefixOp but negative BigInt constants are never created directly.
    assert_ne!(from.sign(), num_bigint_dig::Sign::Minus, "Felt constants must be non-negative");
    let attr = FeltConstAttribute::parse(
        codegen.context,
        // use required bits +1 to ensure unsigned representation
        u32::try_from(from.bits())? + 1,
        from.to_string().as_str(),
    );
    felt::constant(codegen.location_from_meta(meta), attr).map_err(Into::into)
}

/// Extract the single result Value from an OperationRef. Returns an `Err` result if the operation
/// does not have exactly one result.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn single_result_as_value<'ctx, 'val>(
    op: OperationRef<'ctx, 'val>,
) -> Result<Value<'ctx, 'val>> {
    if op.result_count() != 1 {
        return Err(anyhow!(
            "Expected operation to have a single result, found {}",
            op.result_count()
        ));
    }
    op.result(0).map(Value::from).map_err(Into::into)
}

/// Create a map of circom variable names (either function arguments or template input signals) to
/// LLZK function argument Values.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn map_name_to_arg_value<'ctx, 'val>(
    func: FuncDefOpRefMut<'ctx, 'val>,
    arg_names: &[String],
) -> Result<HashMap<String, Value<'ctx, 'val>>> {
    arg_names
        .iter()
        .enumerate()
        .map(|(i, name)| {
            func.deref().argument(i).map(|x| (name.clone(), Value::from(x))).map_err(Into::into)
        })
        .collect::<Result<HashMap<_, _>, _>>()
}

/// Replicates MLIR `isa` functionality for Rust types using `TryFrom`.
pub trait IsA: Sized {
    /// Like MLIR `isa`, check if `self` can be converted to type `Out`.
    #[inline]
    fn isa<Out: TryFrom<Self>>(self) -> bool {
        Out::try_from(self).is_ok()
    }
}
impl<T> IsA for T {}

/// Return `true` iff the given Type is an `IndexType`.
#[inline]
pub fn is_index(t: Type) -> bool {
    t.is_index()
}

/// Return `true` iff the given Type is a `FeltType`.
#[inline]
pub fn is_felt(t: Type) -> bool {
    t.isa::<llzk::prelude::FeltType>()
}
