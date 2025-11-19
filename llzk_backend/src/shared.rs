#![allow(unused_variables)] // TODO: TEMP
use ansi_term::Color;
use anyhow::{anyhow, Ok, Result};
use llzk::prelude::{
    felt, FeltConstAttribute, FuncDefOp, FuncDefOpLike, FuncDefOpRef, FuncDefOpRefMut, LlzkContext,
    StructDefOp, StructDefOpRef, StructDefOpRefMut,
};
use melior::{
    ir::{
        operation::OperationLike as _, BlockLike, BlockRef, Location, Module, Operation,
        OperationRef, RegionLike, Value,
    },
    pass, utility,
};
use num_bigint_dig::BigInt;
use program_structure::{
    ast::Meta,
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

/// Stack of blocks where the top block is the current block where code should be appended and the
/// previous block in the list is the parent of the block after it. When an op containing nested
/// blocks is encountered, the current block within that op is pushed to the stack so that any code
/// generated will be placed inside that block and when the nested block is complete, it is popped.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'blk: lifetime of the generated `Block` instances within functions
#[derive(Debug)]
pub struct BlockContextStack<'ctx, 'blk>
where
    'ctx: 'blk,
{
    /// The function entry block.
    initial_block: BlockRef<'ctx, 'blk>,
    /// Additional nesting of blocks within the function representing the current insertion point.
    other_blocks: Vec<BlockRef<'ctx, 'blk>>,
}

impl<'ctx, 'blk> BlockContextStack<'ctx, 'blk>
where
    'ctx: 'blk,
{
    /// Push a new block onto the stack to make it the current block.
    pub fn push(&mut self, item: BlockRef<'ctx, 'blk>) {
        self.other_blocks.push(item);
    }

    /// Pop the current block off the stack to return to the previous block.
    pub fn pop(&mut self) {
        self.other_blocks.pop().expect("There is no block to pop!");
    }

    /// Append an operation to the current block (i.e. the top of the stack).
    ///
    /// 'op: lifetime of the `Operation` instance for the reference returned
    pub fn append_current<'op>(&mut self, operation: Operation<'ctx>) -> OperationRef<'ctx, 'op>
    where
        'blk: 'op,
    {
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

impl<'ctx> TryFrom<&FuncDefOp<'ctx>> for BlockContextStack<'ctx, '_> {
    type Error = anyhow::Error;

    /// Create a BlockContextStack starting with the function entry block.
    fn try_from(func: &FuncDefOp<'ctx>) -> Result<Self, Self::Error> {
        let initial_block =
            func.region(0)?.first_block().ok_or_else(|| anyhow!("missing function entry block"))?;
        Ok(BlockContextStack { initial_block, other_blocks: Default::default() })
    }
}

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

    /// Run cleanup passes on the generated `Module`.
    pub fn run_passes(&mut self, pass_pipeline: &str) -> Result<()> {
        if pass_pipeline.is_empty() {
            return Ok(());
        }
        let manager = pass::PassManager::new(self.context);
        manager.enable_verifier(true);
        utility::register_all_passes();
        utility::parse_pass_pipeline(manager.as_operation_pass_manager(), pass_pipeline)
            .map_err(|e| anyhow!(e))?;
        manager.run(&mut self.module).map_err(|e| anyhow!(e))
    }

    /// Verify the generated `Module`.
    pub fn verify(&self) -> bool {
        self.module.as_operation().verify()
    }

    /// Create file at the given path, ensuring parent directories exist.
    fn create_file(filename: &str) -> Result<File> {
        let out_path = Path::new(filename);
        // Ensure parent directories exist
        if let Some(parent) = out_path.parent() {
            fs::create_dir_all(parent).map_err(|e| anyhow!(e))?;
        }
        File::create(out_path).map_err(|e| anyhow!(e))
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
    felt::constant(codegen.location_from_meta(meta), attr).map_err(|e| anyhow!(e))
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
    op.result(0).map(Value::from).map_err(|e| anyhow!(e))
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
            func.deref().argument(i).map(|x| (name.clone(), Value::from(x))).map_err(|e| anyhow!(e))
        })
        .collect::<Result<HashMap<_, _>, _>>()
}

/// Replicates MLIR `isa` functionality for Rust types using `TryFrom`.
pub trait IsA: Sized {
    #[inline]
    fn isa<Out: TryFrom<Self>>(self) -> bool {
        Out::try_from(self).is_ok()
    }
}
impl<T> IsA for T {}
