//! Handles circom var scoping and LLZK blocks stack management.

use crate::function::InfoProviders;
use crate::function_ext::FunctionLike as _;
use crate::lvalue::Lvalue;
use crate::lvalue::Root;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::append_tail;
use crate::shared::dim_expr_name;
use crate::shared::is_bool;
use crate::shared::is_index;
use crate::shared::new_array_type;
use crate::shared::no_results;
use crate::shared::region_with_block;
use crate::shared::replace_uses_with_new_block_argument;
use crate::shared::single_result_as_value;
use crate::shared::ArrayDimension;
use crate::shared::ArrayDimensionResult;
use crate::shared::DimExprConverter;
use crate::shared::LlzkCodegen;
use crate::subcmp::names::COUNT;
use anyhow::anyhow;
use anyhow::ensure;
use anyhow::Context as _;
use anyhow::Result;
use llzk::dialect::array;
use llzk::dialect::array::ArrayCtor;
use llzk::dialect::bool;
use llzk::dialect::cast;
use llzk::dialect::constrain;
use llzk::dialect::felt;
use llzk::dialect::function;
use llzk::dialect::pod;
use llzk::dialect::poly;
use llzk::prelude::is_felt_type;
use llzk::prelude::melior_dialects::arith;
use llzk::prelude::melior_dialects::index;
use llzk::prelude::melior_dialects::scf;
use llzk::prelude::ArrayType;
use llzk::prelude::Attribute;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::BlockRef;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::FuncDefOp;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::Location;
use llzk::prelude::LoopBoundsAttribute;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::OperationMutLike as _;
use llzk::prelude::OperationRef;
use llzk::prelude::PodType;
use llzk::prelude::Region;
use llzk::prelude::RegionLike as _;
use llzk::prelude::StringAttribute;
use llzk::prelude::StructType;
use llzk::prelude::TemplateExprOp;
use llzk::prelude::Type;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use llzk::prelude::FUNC_NAME_COMPUTE;
use llzk::prelude::FUNC_NAME_CONSTRAIN;
use llzk::typing::types_equal_or_unifiable;
use melior::dialect::ods::math;
use melior::ir::AttributeLike as _;
use melior::ir::TypeLike as _;
use num_bigint_dig::BigInt;
use num_traits::Zero;
use program_structure::ast::Access;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use program_structure::ast::Meta;
use program_structure::error_code::ReportCode;
use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::TryFrom;
use std::convert::TryInto;
use std::iter::zip;

/// Special variable name used to reference the return Value throughout the
/// conversion of circom return locations to LLZK return locations.
pub(crate) const VAR_NAME_RETURN_VAL: &str = "**return_val**";
/// Special variable name used to reference the status of whether or not a circom block
/// had a `return` when translating to an LLZK block that cannot contain a `return`.
pub(crate) const VAR_NAME_HAD_RETURN: &str = "**had_return**";
/// LLZK attribute used to mark yield/return ops generated from circom return statements.
pub(crate) const CIRCOM_RETURN_MARKER_ATTR: &str = "from_circom_return";
/// LLZK attribute used to attach comma-separated list of variable names for the operands
/// of an `scf.yield` op.
pub(crate) const OPERAND_VAL_NAMES: &str = "operand_val_names";

/// Single frame in the [BlockContextStack].
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct BlockContext<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Reference to a block in LLZK IR.
    block: BlockRef<'ctx, 'blk>,
    /// For variables declared in the current scope, maps circom variable name to current LLZK SSA
    /// Value stored for that variable. These are local to the current block and go out of scope
    /// when the block is popped.
    scope_local_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    /// For variables declared in an outer scope, maps circom variable name to current LLZK SSA
    /// Value stored for that variable. These are preserved when the block is popped because they
    /// overwrite the value of existing variables in outer scopes.
    overwriting_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    /// Queue of operations that need to be appended before the context goes out of scope.
    op_queue: Vec<Operation<'ctx>>,
}

impl<'ctx, 'blk, 'val> BlockContext<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Create a new empty [BlockContext] for the given block.
    fn new(block: BlockRef<'ctx, 'blk>) -> Self {
        Self {
            block,
            scope_local_name_to_value: Default::default(),
            overwriting_name_to_value: Default::default(),
            op_queue: Default::default(),
        }
    }

    /// Set the scope local declarations with the mapping of parameter names to values.
    fn with_params(mut self, param_name_to_value: HashMap<String, Value<'ctx, 'val>>) -> Self {
        self.scope_local_name_to_value = param_name_to_value;
        self
    }

    /// Get the LLZK IR SSA Value for the given circom var name. Check the local scope first since
    /// the names there may shadow the same name from parent scope(s).
    fn get(&self, name: &str) -> Option<&Value<'ctx, 'val>> {
        self.scope_local_name_to_value
            .get(name)
            .or_else(|| self.overwriting_name_to_value.get(name))
    }

    /// Set the LLZK IR SSA Value for the given circom var name. If the name is declared in the
    /// local scope, assign the new value there since it's shadowing the same name from parent
    /// scope(s). Otherwise, assign the new value in the overwriting map.
    fn insert(&mut self, name: String, value: Value<'ctx, 'val>) {
        if let Some(v) = self.scope_local_name_to_value.get_mut(&name) {
            *v = value;
        } else {
            self.overwriting_name_to_value.insert(name, value);
        }
    }

    /// Return true iff the given name is declared in the local scope of this block context.
    fn declares(&self, name: &str) -> bool {
        self.scope_local_name_to_value.contains_key(name)
    }
}

/// Stack of blocks where the top block is the current block where code should be appended and the
/// previous block in the list is the parent of the block after it. When an op containing nested
/// blocks is encountered, the current block within that op is pushed to the stack so that any code
/// generated will be placed inside that block and when the nested block is complete, it is popped.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct BlockContextStack<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Context for the function entry block.
    root: BlockContext<'ctx, 'blk, 'val>,
    /// Additional nesting of blocks within the function. Tail is the current insertion point.
    other_blocks: Vec<BlockContext<'ctx, 'blk, 'val>>,
}

impl<'ctx, 'blk, 'val> BlockContextStack<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Create a new [BlockContextStack] with the given root block.
    pub fn new(root: BlockRef<'ctx, 'blk>) -> Self {
        Self { root: BlockContext::new(root), other_blocks: Default::default() }
    }

    /// Create a new [BlockContextStack] for the given function with an initial name-to-value
    /// mapping containing function parameters and a mapping of `var` declaration names to their
    /// declared LLZK types.
    pub fn from_function(
        func: &FuncDefOp<'ctx>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Result<Self> {
        let root_block =
            func.region(0)?.first_block().ok_or_else(|| anyhow!("missing function entry block"))?;
        Ok(Self {
            root: BlockContext::new(root_block).with_params(param_name_to_value),
            other_blocks: Default::default(),
        })
    }

    /// Return true iff the stack contains only the root block (i.e. stack depth is 1).
    pub fn is_only_root(&self) -> bool {
        self.other_blocks.is_empty()
    }

    /// Get reference to the current block (i.e. the top of the stack).
    pub fn top_block(&self) -> &BlockRef<'ctx, 'blk> {
        match self.other_blocks.last() {
            Some(bc) => &bc.block,
            None => &self.root.block,
        }
    }

    /// Ref to the current block context (i.e. the top of the stack).
    fn top(&self) -> &BlockContext<'ctx, 'blk, 'val> {
        match self.other_blocks.last() {
            Some(bc) => bc,
            None => &self.root,
        }
    }

    /// Mutable ref to the current block context (i.e. the top of the stack).
    fn top_mut(&mut self) -> &mut BlockContext<'ctx, 'blk, 'val> {
        match self.other_blocks.last_mut() {
            Some(bc) => bc,
            None => &mut self.root,
        }
    }

    /// Append an operation to the current block (i.e. the top of the stack).
    pub fn append_current_block(&mut self, operation: Operation<'ctx>) -> OperationRef<'ctx, 'val> {
        let current = &self.top_mut().block;
        // Account for possible terminator in the current block. For example, the `compute_fn()`
        // and `constrain_fn()` helpers automatically add a return op at the end of the block
        // so new ops must be inserted before that terminator.
        match current.terminator() {
            Some(terminator) => current.insert_operation_before(terminator, operation),
            None => current.append_operation(operation),
        }
    }

    /// Queues an operation to the given block that will get appended before it goes out of scope.
    ///
    /// If the block is scoped in multiple contexts picks the deepest one.
    ///
    /// Fails if the block is not part of the stack.
    pub fn enqueue_in_block(
        &mut self,
        operation: Operation<'ctx>,
        block: BlockRef<'ctx, 'blk>,
    ) -> Result<()> {
        let mut blocks = self.blocks_iter_mut_rev();
        let bc = blocks.find(|bc| bc.block == block).ok_or_else(|| block_not_in_stack(block))?;
        bc.op_queue.push(operation);
        Ok(())
    }

    /// Check if the given name is already declared in the current scope.
    pub fn is_name_present(&self, name: &str) -> bool {
        self.top().scope_local_name_to_value.contains_key(name)
    }

    /// Ensure the given name is not already declared in the current scope, then declare it by
    /// producing an [Operation] via the callback, inserting that into the current block, and
    /// using its result. The only scenario where a declaration would already be present is when
    /// the same Declaration statements are visited that were used to produce the parameters of
    /// the current function. Otherwise, the checks performed earlier in the circom parser
    /// pipeline will produce an error if a symbol is declared more than once in the same scope.
    pub fn declare_name_ensure_not_present(
        &mut self,
        name: &str,
        op: Operation<'ctx>,
    ) -> Result<()> {
        ensure!(!self.is_name_present(name), format!("name {name} is already present"));
        let value = single_result_as_value(self.append_current_block(op))?;
        self.top_mut().scope_local_name_to_value.insert(name.to_string(), value);
        Ok(())
    }

    /// If the given name is not already declared in the current scope, declare it by producing an
    /// [Operation] via the callback, inserting that into the current block, and using its result.
    /// The only scenario where a declaration would already be present is when the same Declaration
    /// statements are visited that were used to produce the parameters of the current function.
    /// Otherwise, the checks performed earlier in the circom parser pipeline will produce an error
    /// if a symbol is declared more than once in the same scope.
    pub fn declare_name_if_not_present(
        &mut self,
        name: &str,
        uninit_value: impl FnOnce() -> Result<Operation<'ctx>>,
    ) -> Result<()> {
        if !self.is_name_present(name) {
            let op = uninit_value()?;
            let value = single_result_as_value(self.append_current_block(op))?;
            self.top_mut().scope_local_name_to_value.insert(name.to_string(), value);
        }
        Ok(())
    }

    /// In the top block context, set the LLZK IR SSA Value for the given circom var name.
    pub fn set_named_value(&mut self, name: String, value: Value<'ctx, 'val>) -> Result<()> {
        // This is mainly a sanity check on proper usage of `declare_name_if_not_present()` and
        // this function to ensure values end up in the correct map in the BlockContext and are
        // thus scoped correctly.
        if !self.root.declares(&name) && !self.other_blocks.iter().any(|bc| bc.declares(&name)) {
            return Err(anyhow!("Variable '{name}' was not declared in any scope"));
        }
        self.top_mut().insert(name, value);
        Ok(())
    }

    /// Set the LLZK IR SSA Value for the given circom var name at the declaration scope.
    pub fn set_named_value_at_declaration(
        &mut self,
        name: String,
        value: Value<'ctx, 'val>,
    ) -> Result<()> {
        let scope = self
            .blocks_iter_mut()
            .find(|bc| bc.declares(&name))
            .ok_or_else(|| anyhow!("Variable '{name}' was not declared in any scope"))?;
        scope.insert(name, value);
        Ok(())
    }

    /// Returns an iterator of the blocks in stack order (from the top to the bottom).
    fn blocks_iter(&self) -> impl Iterator<Item = &BlockContext<'ctx, 'blk, 'val>> {
        self.other_blocks.iter().rev().chain(std::iter::once(&self.root))
    }

    /// Returns an iterator of mutable references to the blocks in stack order (from the top to the
    /// bottom).
    fn blocks_iter_mut(&mut self) -> impl Iterator<Item = &mut BlockContext<'ctx, 'blk, 'val>> {
        self.other_blocks.iter_mut().rev().chain(std::iter::once(&mut self.root))
    }

    /// Returns an iterator of mutable references to the blocks in reverse stack order (from the
    /// bottom to the top).
    fn blocks_iter_mut_rev(&mut self) -> impl Iterator<Item = &mut BlockContext<'ctx, 'blk, 'val>> {
        std::iter::once(&mut self.root).chain(self.other_blocks.iter_mut())
    }

    /// In the top block context, set multiple LLZK IR SSA Values for the given circom var names.
    pub fn set_named_values(
        &mut self,
        insert: impl IntoIterator<Item = (String, Value<'ctx, 'val>)>,
    ) -> Result<()> {
        for (name, value) in insert.into_iter() {
            self.set_named_value(name, value)?;
        }
        Ok(())
    }

    /// Get the LLZK IR SSA Value for the given circom var name, checking the top block context
    /// and then proceeding down the stack until found (if at all).
    pub fn get_named_value(&self, name: &str) -> Result<&Value<'ctx, 'val>> {
        self.blocks_iter()
            .find_map(|bc| bc.get(name))
            .ok_or_else(|| anyhow!("variable '{name}' not found"))
    }

    /// Get the block that declared the given circom var name.
    pub fn get_decl_block_of_value(&self, name: &str) -> Result<BlockRef<'ctx, 'blk>> {
        self.blocks_iter()
            .find_map(|bc| bc.declares(name).then_some(bc.block))
            .ok_or_else(|| anyhow!("Variable '{name}' was not declared in any scope"))
    }

    /// Push a new block onto the stack to make it the current block.
    pub fn push(&mut self, block: BlockRef<'ctx, 'blk>) {
        self.other_blocks.push(BlockContext::new(block));
    }

    /// Pop the current block off the stack to return to the previous block. The vars declared in
    /// the popped frame are dropped and those which are overwrites are returned.
    pub fn pop(&mut self) -> HashMap<String, Value<'ctx, 'val>> {
        self.append_queue();
        self.other_blocks.pop().expect("There is no block to pop!").overwriting_name_to_value
    }

    /// Appends the queued operations in the top of the stack.
    pub fn append_queue(&mut self) {
        let queue = std::mem::take(&mut self.top_mut().op_queue);
        for op in queue {
            self.append_current_block(op);
        }
    }
}

/// Items pertaining to a region/block created to nest within another LLZK op.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct NestedBlockInfo<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// The new [Region] to be nested within another LLZK op.
    pub(crate) region: Region<'ctx>,
    /// Reference to the single [Block] in the [Region].
    pub(crate) block: BlockRef<'ctx, 'blk>,
    /// Map from circom variable name to LLZK Value for variables that were
    /// overwritten within by code generated within the new [Block].
    pub(crate) var_overwrites: HashMap<String, Value<'ctx, 'val>>,
}

impl Default for NestedBlockInfo<'_, '_, '_> {
    #[inline]
    fn default() -> Self {
        let region = Region::new();
        let block = region.append_block(Block::new(&[]));
        NestedBlockInfo { region, block, var_overwrites: Default::default() }
    }
}

impl<'ctx, 'blk, 'val> NestedBlockInfo<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Update `self.var_overwrites` to ensure it has all keys from `other.var_overwrites`, using
    /// values from the current scope in the [BlockGenContext] for missing keys.
    pub fn add_missing_values(
        &mut self,
        other: &NestedBlockInfo<'ctx, 'blk, 'val>,
        fc: &BlockGenContext<'_, 'ctx, 'blk, 'val>,
    ) -> Result<()> {
        for name in other.var_overwrites.keys() {
            if !self.var_overwrites.contains_key(name) {
                self.var_overwrites.insert(name.clone(), *fc.block_ctx.get_named_value(name)?);
            }
        }
        Ok(())
    }
}

/// Provides common functions for generating code that respects circom variable scoping, abstracting
/// access to the [BlockContextStack] so that functions and templates can share these functions.
pub trait GenWithCircomScopeHandling<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// LLZK block context type. For functions, this is just [BlockRef], but for templates,
    /// this type holds a [BlockRef] for both the `compute` and `constrain` functions.
    type BlockType;

    /// Type of the additional data passed to the overwrite handler.
    type HandlerDataType: Default;

    /// Retrieve the top `BlockType` from the [BlockContextStack].
    fn stack_top(&self) -> Self::BlockType;

    /// Push new `BlockType` onto the [BlockContextStack].
    fn stack_push(&mut self, block: Self::BlockType);

    /// Pop the top `BlockType` from the [BlockContextStack].
    fn stack_pop<H>(
        &mut self,
        overwrite_handler: H,
        overwrite_data: &mut Self::HandlerDataType,
    ) -> Result<()>
    where
        H: Fn(
            &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
            &mut NestedBlockInfo<'ctx, 'blk, 'val>,
            HashMap<String, Value<'ctx, 'val>>,
        ) -> Result<()>;

    /// Use the callback to generate code for a new circom scope/block within the given LLZK
    /// `BlockType`. Assignments to circom variables that are newly introduced in this context go
    /// out of scope so they are dropped after the callback but overwriting assignments to circom
    /// variables that already exist prior to this new scope are passed to the overwrite handler.
    fn gen_in_given_block_with_new_circom_scope<H, R>(
        &mut self,
        block: Self::BlockType,
        generator: impl FnOnce(&mut Self) -> Result<R>,
        overwrite_handler: H,
        overwrite_data: &mut Self::HandlerDataType,
    ) -> Result<R>
    where
        H: Fn(
            &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
            &mut NestedBlockInfo<'ctx, 'blk, 'val>,
            HashMap<String, Value<'ctx, 'val>>,
        ) -> Result<()>,
    {
        self.stack_push(block);
        let res = generator(self);
        self.stack_pop(overwrite_handler, overwrite_data)?;
        res
    }

    /// Use the callback to generate code for a new circom scope/block within the given LLZK
    /// `BlockType`. Assignments to circom variables that are newly introduced in this context go
    /// out of scope so they are dropped after the callback but overwriting assignments to circom
    /// variables that already exist prior to this new scope are cached in the `var_overwrites`
    /// field of the `NestedBlockInfo` struct.
    #[inline]
    fn gen_in_given_block_with_new_circom_scope_and_cache_overwrites<R>(
        &mut self,
        block: Self::BlockType,
        generator: impl FnOnce(&mut Self) -> Result<R>,
        overwrite_data: &mut Self::HandlerDataType,
    ) -> Result<R> {
        self.gen_in_given_block_with_new_circom_scope(
            block,
            generator,
            |_, block_info, overwrites| {
                block_info.var_overwrites.extend(overwrites);
                Ok(())
            },
            overwrite_data,
        )
    }

    /// Use the callback to generate code for a new circom scope/block within the given LLZK
    /// `BlockType`. Assignments to circom variables that are newly introduced in this context go
    /// out of scope so they are dropped after the callback but overwriting assignments to circom
    /// variables that already exist prior to this new scope are preserved and written into the
    /// existing block context.
    #[inline]
    fn gen_in_given_block_with_new_circom_scope_and_merge_overwrites<R>(
        &mut self,
        block: Self::BlockType,
        generator: impl FnOnce(&mut Self) -> Result<R>,
    ) -> Result<R> {
        self.gen_in_given_block_with_new_circom_scope(
            block,
            generator,
            |fc, _, overwrites| fc.block_ctx.set_named_values(overwrites),
            &mut Self::HandlerDataType::default(), // ignored in the handler ^
        )
    }

    /// Use the callback to generate code for a new circom scope/block but within the current LLZK
    /// `BlockType`. Assignments to circom variables that are newly introduced in this context go
    /// out of scope so they are dropped after the callback but overwriting assignments to circom
    /// variables that already exist prior to this new scope are preserved and written into the
    /// existing block context.
    #[inline]
    fn gen_in_current_block_with_new_circom_scope_and_merge_overwrites<R>(
        &mut self,
        generator: impl FnOnce(&mut Self) -> Result<R>,
    ) -> Result<R> {
        self.gen_in_given_block_with_new_circom_scope_and_merge_overwrites(
            self.stack_top(),
            generator,
        )
    }
}

/// Helper function for creating an error reporting that the given block is not part of the stack.
fn block_not_in_stack(block: BlockRef) -> anyhow::Error {
    anyhow!("Block {block:?} is not part of the stack")
}

/// Holds the block context stack for generating LLZK IR within an LLZK Block body.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct BlockGenContext<'decls, 'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Nested block context within the root block.
    pub(crate) block_ctx: BlockContextStack<'ctx, 'blk, 'val>,
    /// Pre-computed LLZK types for circom `var` declarations, keyed by var name. Populated from
    /// [crate::module::DeclarationInfo] when generating `poly.expr` bodies for templates so that
    /// dimension expressions referencing other vars do not trigger recursive code generation.
    pub(crate) var_decl_types: &'decls HashMap<String, Type<'ctx>>,
    /// Names of `poly.param` and `poly.expr` defs visible in the current context.
    poly_template_binding_names: HashSet<String>,
}

impl<'decls, 'ctx, 'blk, 'val> BlockGenContext<'decls, 'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Create a new [BlockGenContext] with the given block context stack, mapping of `var` name to
    /// declared LLZK type, and set of visible `poly.param` and `poly.expr` names.
    pub fn new<'names>(
        block_ctx: BlockContextStack<'ctx, 'blk, 'val>,
        var_decl_types: &'decls HashMap<String, Type<'ctx>>,
        poly_template_binding_names: impl IntoIterator<Item = &'names String>,
    ) -> Self {
        Self {
            block_ctx,
            var_decl_types,
            poly_template_binding_names: poly_template_binding_names.into_iter().cloned().collect(),
        }
    }

    /// For each name in `self.poly_template_binding_names`, generate and append a `read_const`
    /// operation and store the resulting Value in the block context under that name. This ensures
    /// that template parameters are available as SSA Values in the block context.
    pub fn with_poly_template_binding_locals(
        mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<Self> {
        let mut sorted: Vec<_> = self.poly_template_binding_names.iter().collect();
        if codegen.config.stabilize {
            sorted.sort();
        }
        for name in sorted {
            self.block_ctx.declare_name_ensure_not_present(
                name,
                poly::read_const(location, name, codegen.felt_type().into()),
            )?;
        }
        Ok(self)
    }

    /// Append an operation.
    pub fn append_op(&mut self, op: Operation<'ctx>) -> OperationRef<'ctx, 'val> {
        self.block_ctx.append_current_block(op)
    }

    /// Append an operation that must produce no results.
    pub fn append_op_no_result(&mut self, op: Operation<'ctx>) -> Result<()> {
        no_results(self.append_op(op))
    }

    /// Append an operation that must produce a single result and is NOT associated with a variable
    /// name in the circom code.
    pub fn append_op_unnamed_result(&mut self, op: Operation<'ctx>) -> Result<Value<'ctx, 'val>> {
        single_result_as_value(self.append_op(op))
    }

    /// Append an operation that must produce a single result and store the mapping of the circom
    /// variable name to the result Value.
    pub fn append_op_named_result(
        &mut self,
        op: Operation<'ctx>,
        name: String,
    ) -> Result<Value<'ctx, 'val>> {
        let v = self.append_op_unnamed_result(op)?;
        self.block_ctx.set_named_value(name, v)?;
        Ok(v)
    }

    /// Insert cast operations as needed to make `lhs` and `rhs` have compatible types for equality
    /// constraints.
    #[inline]
    fn unify_constrain_eq_types(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
    ) -> Result<(Value<'ctx, 'val>, Value<'ctx, 'val>)> {
        match (lhs.r#type(), rhs.r#type()) {
            (t0, t1) if is_felt_type(t0) && !is_felt_type(t1) => {
                Ok((lhs, self.cast_to_felt(codegen, location, rhs)?))
            }
            (t0, t1) if !is_felt_type(t0) && is_felt_type(t1) => {
                Ok((self.cast_to_felt(codegen, location, lhs)?, rhs))
            }
            _ => Ok((lhs, rhs)),
        }
    }

    /// Generate a `constrain.eq` operation for the given values, casting to compatible felt types
    /// if necessary.
    pub fn append_constrain_eq(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
    ) -> Result<()> {
        let (lhs, rhs) = self.unify_constrain_eq_types(codegen, location, lhs, rhs)?;
        self.append_op_no_result(constrain::eq(location, lhs, rhs).into())
    }

    /// Generate an `array.write` or `array.insert` operation appropriate for the number of indices
    /// and the [ArrayType] of the `arr_ref` value.
    pub fn append_array_write(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        arr_ref: Value<'ctx, 'val>,
        indices: &[Value<'ctx, 'val>],
        location: Location<'ctx>,
        rvalue: Value<'ctx, 'val>,
        var_name: Option<&str>,
    ) -> Result<()> {
        let arr_ty = ArrayType::try_from(arr_ref.r#type()).with_context(|| {
            let v = var_name.map_or(String::from("array"), |s| format!("'{s}'"));
            format!("Conflicting types to write {v} at {location}")
        })?;
        let arr_ty_dims = arr_ty.dims();
        let write_op = match indices.len().cmp(&arr_ty_dims.len()) {
            std::cmp::Ordering::Equal => {
                // Indexing all dimensions requires an `array.write`
                let rvalue = self.cast_to_expected_type_if_needed(
                    codegen,
                    location,
                    rvalue,
                    arr_ty.element_type(),
                )?;
                array::write(location, arr_ref, indices, rvalue)
            }
            std::cmp::Ordering::Less => {
                // Indexing a subset of dimensions requires an `array.insert`
                array::insert(location, arr_ref, indices, rvalue)
            }
            std::cmp::Ordering::Greater => {
                let v = var_name.map_or(String::from("array"), |s| format!("'{s}'"));
                anyhow::bail!("Too many indices to write {v} at {location}");
            }
        };
        self.append_op_no_result(write_op)
    }

    /// Generate an `array.read` or `array.extract` operation appropriate for the number of indices
    /// and the [ArrayType] of the `arr_ref` value.
    pub fn append_array_read(
        &mut self,
        arr_ref: Value<'ctx, 'val>,
        indices: &[Value<'ctx, 'val>],
        location: Location<'ctx>,
        var_name: Option<&str>,
    ) -> Result<Value<'ctx, 'val>> {
        let arr_ty = ArrayType::try_from(arr_ref.r#type()).with_context(|| {
            let v = var_name.map_or(String::from("array"), |s| format!("'{s}'"));
            format!("Conflicting types to read {v} at {location}")
        })?;
        let arr_ty_dims = arr_ty.dims();
        let array_get_op = match indices.len().cmp(&arr_ty_dims.len()) {
            std::cmp::Ordering::Equal => {
                // Indexing all dimensions requires an `array.read`
                array::read(location, arr_ty.element_type(), arr_ref, indices)
            }
            std::cmp::Ordering::Less => {
                // Indexing a subset of dimensions requires an `array.extract`
                let reduced_dims: Vec<_> =
                    arr_ty_dims.iter().skip(indices.len()).copied().collect();
                let reduced_type = ArrayType::new(arr_ty.element_type().into(), &reduced_dims);
                array::extract(location, reduced_type.into(), arr_ref, indices)
            }
            std::cmp::Ordering::Greater => {
                let v = var_name.map_or(String::from("array"), |s| format!("'{s}'"));
                anyhow::bail!("Too many indices to read {v} at {location}");
            }
        };
        self.append_op_unnamed_result(array_get_op)
    }

    /// Cast `val` to bool and emit a `bool.assert` op.
    pub fn append_assert(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<()> {
        let cond = self.cast_to_bool_if_needed(codegen, location, val)?;
        let msg = Some("assertion failed");
        self.append_op_no_result(bool::assert(location, cond, msg)?.into())
    }

    /// Append a `unifiable_cast` operation to cast `val` to the `expected` type.
    #[inline]
    pub fn unifiable_cast(
        &mut self,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
        expected: Type<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        assert!(types_equal_or_unifiable(val.r#type(), expected)); // pre-condition
        self.append_op_unnamed_result(poly::unifiable_cast(location, val, expected))
    }

    /// Append a cast to felt (field element) type.
    #[inline]
    pub fn cast_to_felt(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        self.append_op_unnamed_result(cast::tofelt(location, val, Some(codegen.felt_type())))
    }

    /// Append a cast to felt (field element) type if the given value is not already a felt.
    #[inline]
    pub fn cast_to_felt_if_needed(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        if !is_felt_type(val.r#type()) {
            self.cast_to_felt(codegen, location, val)
        } else {
            Ok(val)
        }
    }

    /// Append a cast to index type if the given value is not already an index.
    #[inline]
    pub fn cast_to_index_if_needed(
        &mut self,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        if !is_index(val.r#type()) {
            self.append_op_unnamed_result(cast::toindex(location, val).into())
        } else {
            Ok(val)
        }
    }

    /// Append a cast to bool type (i1) if the given value is not already a bool.
    #[inline]
    pub fn cast_to_bool_if_needed(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // The conversion to bool is simply to check `!=0` which is the same as
        // `normalize()` in `modular_arithmetic.rs`.
        if is_felt_type(val.r#type()) {
            let zero = self
                .append_op_unnamed_result(codegen.new_felt_const_op(&BigInt::zero(), location)?)?;
            self.append_op_unnamed_result(bool::ne(location, val, zero)?)
        } else if is_index(val.r#type()) {
            let zero = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
            self.append_op_unnamed_result(index::cmp(
                codegen.context,
                arith::CmpiPredicate::Ne,
                val,
                zero,
                location,
            ))
        } else {
            assert!(is_bool(val.r#type()));
            Ok(val)
        }
    }

    /// Append an op to cast `val` to `expected` type, if it does not already have that type.
    #[inline]
    pub fn cast_to_expected_type_if_needed(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
        expected: Type<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        if expected == val.r#type() {
            Ok(val)
        } else if types_equal_or_unifiable(expected, val.r#type()) {
            self.unifiable_cast(location, val, expected)
        } else if is_felt_type(expected) {
            self.cast_to_felt_if_needed(codegen, location, val)
        } else if is_index(expected) {
            self.cast_to_index_if_needed(location, val)
        } else if is_bool(expected) {
            self.cast_to_bool_if_needed(codegen, location, val)
        } else {
            anyhow::bail!(
                "Unsupported 'expected' type '{expected}' with value type {}",
                val.r#type()
            )
        }
    }

    /// Copy the values in the source array into the destination array. Assumes both arrays have
    /// unifiable element types the same number of dimensions, but each dimension may be wider or
    /// narrower than the destination type.
    ///
    /// General overview: create a N-dimensional nested `for` loop to copy. If the indices are
    /// out-of-bounds, then the array is default-filled. Otherwise, copy elements into destination.
    fn copy_into_array(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        dst: Value<'ctx, 'val>,
        dst_ty: ArrayType<'ctx>,
        src: Value<'ctx, 'val>,
        src_ty: ArrayType<'ctx>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        if codegen.config.verbose {
            println!("[copy_into_array] src: {src}");
            println!("[copy_into_array] src_ty: {src_ty}");
            println!("[copy_into_array] dst: {dst}");
            println!("[copy_into_array] dst_ty: {dst_ty}");
        }
        // Check caller pre-conditions to ensure this function is being used correctly.
        assert_eq!(src.r#type(), src_ty.into());
        assert_eq!(dst.r#type(), dst_ty.into());
        assert_eq!(dst_ty.num_dims(), src_ty.num_dims());
        let src_elem_ty = src_ty.element_type();
        let dst_elem_ty = dst_ty.element_type();
        assert!(types_equal_or_unifiable(src_elem_ty, dst_elem_ty));

        let location = codegen.location_from_meta(meta);

        let bounds = zip(src_ty.dims(), dst_ty.dims())
            .map(|(src_dim, dest_dim)| {
                if codegen.config.verbose {
                    println!("[copy_into_array]   src_dim: {src_dim} -> dest_dim: {dest_dim}");
                }
                let src_val = self.array_dim_attr_to_idx_val(codegen, location, src_dim)?;
                let dest_val = self.array_dim_attr_to_idx_val(codegen, location, dest_dim)?;
                let condition = self.append_op_unnamed_result(arith::cmpi(
                    codegen.context,
                    arith::CmpiPredicate::Ult,
                    src_val,
                    dest_val,
                    location,
                ))?;
                let if_op = self.generate_simple_scf_if(
                    codegen,
                    meta,
                    condition,
                    |_| Ok(src_val),
                    |_| Ok(dest_val),
                )?;
                self.append_op_unnamed_result(if_op)
            })
            .collect::<Result<Vec<_>>>()?;

        let element_types_not_equal = src_elem_ty != dst_elem_ty;
        self.gen_loop_nest(codegen, location, &bounds, move |fc, indices| {
            let mut val =
                fc.append_op_unnamed_result(array::read(location, src_elem_ty, src, indices))?;
            if element_types_not_equal {
                val = fc.unifiable_cast(location, val, dst_elem_ty)?;
            }
            fc.append_op_no_result(array::write(location, dst, indices, val))
        })
    }

    /// Perform a direct assignment of `rvalue` to `var`. In many cases this is handled
    /// by updating the variable name map to have `var` -> `rvalue`, but special handling
    /// is required during array assignments where `rvalue` is a different width than the
    /// destination array (this requires 0-filling or truncation).
    pub fn handle_simple_assignment(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        var: &String,
        rvalue: Value<'ctx, 'val>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        // Since there's no simple assignment in LLZK, just update the mapped Value which
        // essentially propagates the assignment. The exception here is the ArrayType case:
        // Circom allows (with a warning) arrays to be assigned to array variables of differing
        // widths (wider/narrower) as long as both arrays have the same number of dimensions
        // (e.g., var x[2][2] = y, where y is var[1][7], is allowed). If the dimension is
        // wider, the values are truncated, and if they are narrower, the array is left in
        // its current state.
        let Ok(existing) = self.block_ctx.get_named_value(var) else {
            // Otherwise, set the var to point to rvalue
            return self.block_ctx.set_named_value(var.clone(), rvalue);
        };
        if existing.r#type() == rvalue.r#type() {
            // Replace existing value reference to rvalue
            return self.block_ctx.set_named_value(var.clone(), rvalue);
        }
        if types_equal_or_unifiable(existing.r#type(), rvalue.r#type()) {
            todo!("'handle_simple_assignment' with unifiable but different types if this happens");
        }
        let existing_arr_ty = ArrayType::try_from(existing.r#type());
        let rvalue_arr_ty = ArrayType::try_from(rvalue.r#type());
        if existing_arr_ty.is_ok() && rvalue_arr_ty.is_ok() {
            let existing_arr_ty = existing_arr_ty.unwrap();
            let rvalue_arr_ty = rvalue_arr_ty.unwrap();
            // If the arrays have the same number of dimensions and unifiable element type,
            // then copy values from the `rvalue` array into the existing array.
            if existing_arr_ty.num_dims() == rvalue_arr_ty.num_dims()
                && types_equal_or_unifiable(
                    existing_arr_ty.element_type(),
                    rvalue_arr_ty.element_type(),
                )
            {
                // Copy values from the rvalue into the existing array.
                // No need to update named value here.
                return self.copy_into_array(
                    codegen,
                    meta,
                    *existing,
                    existing_arr_ty,
                    rvalue,
                    rvalue_arr_ty,
                );
            }
        }
        anyhow::bail!(
            "could not assign value of type '{}' to '{var}', which has type '{}'",
            rvalue.r#type(),
            existing.r#type()
        )
    }

    /// Handle [program_structure::ast::Statement::Substitution] when the operator is not a signal
    /// operator. Note: Do not use directly from `GenerateLLZKInTemplate`.
    #[allow(clippy::too_many_arguments)]
    pub fn handle_substitution_stmt_nonsignal<'info>(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        info: InfoProviders<'info>,
        meta: &Meta,
        var: &String,
        access: &[Access],
        op: &AssignOp,
        rhe: &Expression,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        assert!(!op.is_signal_operator()); // pre-condition

        let rvalue = rhe.gen_llzk_in_block(codegen, self, info)?;
        if access.is_empty() {
            self.handle_simple_assignment(codegen, meta, var, rvalue)
        } else {
            let location = codegen.location_from_meta(meta);
            let indices = &access
                .iter()
                .map(|access| {
                    let idx = match access {
                        Access::ArrayAccess(index_expr) => {
                            index_expr.gen_llzk_in_block(codegen, self, info)
                        }
                        Access::ComponentAccess(_) => {
                            todo!("Handle Substitution component access in BlockGenContext")
                        }
                    }?;
                    self.cast_to_index_if_needed(location, idx)
                })
                .collect::<Result<Vec<Value<'_, '_>>>>()?;
            let arr_ref = *self.block_ctx.get_named_value(var)?;
            self.append_array_write(codegen, arr_ref, indices, location, rvalue, Some(var))
        }
    }

    /// Creates LLZK ops for array indexing from the collection of elements.
    pub fn gen_index_ops<'ast, 'info, E>(
        &mut self,
        indices: impl IntoIterator<Item = &'ast E>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        info: InfoProviders<'info>,
    ) -> Result<Vec<Value<'ctx, 'val>>>
    where
        E: GenerateLLZKInAnyBlock<'ctx, 'blk, 'val> + 'ast,
    {
        indices
            .into_iter()
            .map(|e| {
                let val = e.gen_llzk_in_block(codegen, self, info)?;
                self.append_op_unnamed_result(cast::toindex(location, val))
            })
            .collect()
    }

    /// Generate LLZK code in the current function for a circom prefix operation.
    pub fn gen_prefix_op(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        op: &ExpressionPrefixOpcode,
        rhs: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        let mut get_negative_idx = || {
            let zero = self.append_op_unnamed_result(index::constant(
                codegen.context,
                IntegerAttribute::new(rhs.r#type(), 0),
                codegen.location_from_meta(meta),
            ))?;
            self.append_op_unnamed_result(index::sub(zero, rhs, codegen.location_from_meta(meta)))
        };
        match op {
            ExpressionPrefixOpcode::Sub => {
                if is_felt_type(rhs.r#type()) {
                    return self.append_op_unnamed_result(felt::neg(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
                // For index negation, we need to subtract from zero.
                if shared::is_index(rhs.r#type()) {
                    return get_negative_idx();
                }
            }
            ExpressionPrefixOpcode::BoolNot => {
                if shared::is_bool(rhs.r#type()) {
                    return self.append_op_unnamed_result(bool::not(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
            }
            ExpressionPrefixOpcode::Complement => {
                if is_felt_type(rhs.r#type()) {
                    return self.append_op_unnamed_result(felt::bit_not(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
                // For index negation, we need to subtract one from the negative
                // value (for the identity that `~x == -x - 1`).
                if shared::is_index(rhs.r#type()) {
                    let negative_idx = get_negative_idx()?;
                    let one = self.append_op_unnamed_result(index::constant(
                        codegen.context,
                        IntegerAttribute::new(rhs.r#type(), 1),
                        codegen.location_from_meta(meta),
                    ))?;
                    return self.append_op_unnamed_result(index::sub(
                        negative_idx,
                        one,
                        codegen.location_from_meta(meta),
                    ));
                }
            }
        }
        let err_msg = format!(
            "Cannot generate LLZK for prefix {:?} with operand type '{}'",
            self,
            rhs.r#type()
        );
        codegen.emit_circom_error(meta, err_msg.as_str(), ReportCode::PrefixOperatorWithWrongTypes);
        Err(anyhow!(err_msg))
    }

    /// If both operands have types that match the respective filter predicates, generate the
    /// operation using the provided generator function and return the result, otherwise None.
    #[inline]
    fn gen_infix_op_if_types_are(
        &mut self,
        lhs_type_filter: impl FnOnce(Type) -> bool,
        rhs_type_filter: impl FnOnce(Type) -> bool,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
        op_gen_fn: impl FnOnce(&mut Self) -> Result<Operation<'ctx>>,
    ) -> Result<Option<Value<'ctx, 'val>>> {
        if lhs_type_filter(lhs.r#type()) && rhs_type_filter(rhs.r#type()) {
            let op_res = op_gen_fn(self)?;
            self.append_op_unnamed_result(op_res).map(Option::Some)
        } else {
            Ok(None)
        }
    }

    /// Generate LLZK code in the current function for an infix operation.
    pub fn gen_infix_op(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        op: &ExpressionInfixOpcode,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // Macro to handle the common pattern for type checks for op selection.
        macro_rules! try_callback_for_type {
            ($type_check:path, $cb:expr) => {{
                if let Some(result) =
                    self.gen_infix_op_if_types_are($type_check, $type_check, lhs, rhs, $cb)?
                {
                    return Ok(result);
                }
            }};
        }

        macro_rules! generic_op_callback {
            ($op_path:path) => {{
                |_| {
                    let loc = codegen.location_from_meta(meta);
                    $op_path(loc, lhs, rhs).map_err(Into::into)
                }
            }};
        }

        macro_rules! try_felt_op {
            ($op_path:path) => {{
                try_callback_for_type!(is_felt_type, generic_op_callback!($op_path));
            }};
        }

        macro_rules! try_bool_op {
            ($op_path:path) => {{
                let loc = codegen.location_from_meta(meta);
                let lhs = self.cast_to_bool_if_needed(codegen, loc, lhs)?;
                let rhs = self.cast_to_bool_if_needed(codegen, loc, rhs)?;
                return self.append_op_unnamed_result($op_path(loc, lhs, rhs)?);
            }};
        }

        macro_rules! try_index_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_index, |_| {
                    let loc = codegen.location_from_meta(meta);
                    Ok($op_path(lhs, rhs, loc))
                });
            }};
        }

        macro_rules! try_math_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_index, |_| {
                    let loc = codegen.location_from_meta(meta);
                    Ok(Operation::from($op_path(codegen.context, lhs, rhs, loc)))
                });
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For index operations that use felt:: module and simple index operations.
        macro_rules! try_felt_or_index_op {
            ($felt_op:path, $index_op:path) => {{
                try_felt_op!($felt_op);
                try_index_op!($index_op);
            }};
        }

        macro_rules! try_felt_or_math_op {
            ($felt_op:path, $math_op:path) => {{
                try_felt_op!($felt_op);
                try_math_op!($math_op);
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For comparison operations that use bool:: module and index::cmpi.
        macro_rules! try_bool_cmp_op {
            ($bool_op:path, $cmp:ident) => {{
                try_felt_op!($bool_op);
                try_callback_for_type!(shared::is_index, |_| {
                    let loc = codegen.location_from_meta(meta);
                    Ok(index::cmp(codegen.context, arith::CmpiPredicate::$cmp, lhs, rhs, loc))
                });
            }};
        }

        match op {
            ExpressionInfixOpcode::Add => {
                try_felt_or_index_op!(felt::add, index::add);
            }
            ExpressionInfixOpcode::Sub => {
                try_felt_or_index_op!(felt::sub, index::sub);
            }
            ExpressionInfixOpcode::Mul => {
                try_felt_or_index_op!(felt::mul, index::mul);
            }
            ExpressionInfixOpcode::Div => {
                try_felt_or_index_op!(felt::div, index::divu);
            }
            ExpressionInfixOpcode::IntDiv => {
                try_felt_or_index_op!(felt::uintdiv, index::divu);
            }
            ExpressionInfixOpcode::Mod => {
                try_felt_or_index_op!(felt::umod, index::remu);
            }
            ExpressionInfixOpcode::Pow => {
                try_felt_or_math_op!(felt::pow, math::ipowi);
            }
            ExpressionInfixOpcode::ShiftL => {
                try_felt_or_index_op!(felt::shl, index::shl);
            }
            ExpressionInfixOpcode::ShiftR => {
                try_felt_or_index_op!(felt::shr, index::shru);
            }
            ExpressionInfixOpcode::LesserEq => {
                try_bool_cmp_op!(bool::le, Ule);
            }
            ExpressionInfixOpcode::GreaterEq => {
                try_bool_cmp_op!(bool::ge, Uge);
            }
            ExpressionInfixOpcode::Lesser => {
                try_bool_cmp_op!(bool::lt, Ult);
            }
            ExpressionInfixOpcode::Greater => {
                try_bool_cmp_op!(bool::gt, Ugt);
            }
            ExpressionInfixOpcode::Eq => {
                try_bool_cmp_op!(bool::eq, Eq);
            }
            ExpressionInfixOpcode::NotEq => {
                try_bool_cmp_op!(bool::ne, Ne);
            }
            ExpressionInfixOpcode::BoolOr => {
                try_bool_op!(bool::or);
            }
            ExpressionInfixOpcode::BoolAnd => {
                try_bool_op!(bool::and);
            }
            ExpressionInfixOpcode::BitOr => {
                try_felt_or_index_op!(felt::bit_or, index::or);
            }
            ExpressionInfixOpcode::BitAnd => {
                try_felt_or_index_op!(felt::bit_and, index::and);
            }
            ExpressionInfixOpcode::BitXor => {
                try_felt_or_index_op!(felt::bit_xor, index::xor);
            }
        }
        let err_msg = format!(
            "Cannot generate LLZK for infix {:?} with LHS type '{}' and RHS type '{}'",
            op,
            lhs.r#type(),
            rhs.r#type()
        );
        codegen.emit_circom_error(meta, err_msg.as_str(), ReportCode::InfixOperatorWithWrongTypes);
        Err(anyhow!(err_msg))
    }

    /// Create a new `scf.yield` op, in the given block, that yields multiple values with associated
    /// variable names. Create an [Attribute] containing comma-separated list of `value_names`
    /// and attach it to the `scf.yield` op using the [OPERAND_VAL_NAMES] attribute key.
    fn append_multi_operand_yield_to_block(
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block: BlockRef<'ctx, 'val>,
        values: &[Value<'ctx, 'val>],
        value_names: &[String],
        location: Location<'ctx>,
    ) -> Result<()> {
        assert_eq!(values.len(), value_names.len(), "requires one name per value");
        let mut op = scf::r#yield(values, location);
        op.set_attribute(OPERAND_VAL_NAMES, codegen.list_to_attribute(value_names));
        no_results(block.append_operation(op))
    }

    /// Generate an `scf.if` op based on the given [NestedBlockInfo] for each branch and update the
    /// block context with the results of the `scf.if` op mapped to the given names.
    pub fn gen_scf_if(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        condition: Value<'ctx, 'val>,
        mut then_info: NestedBlockInfo<'ctx, 'blk, 'val>,
        else_info: NestedBlockInfo<'ctx, 'blk, 'val>,
    ) -> Result<()> {
        // Ensure both blocks will yield the same set of variables.
        then_info.add_missing_values(&else_info, self)?;

        // Split `then_block_info.var_overwrites` into ordered lists of names and values. The
        // ordering of names here defines the ordering of results from the `scf.if` op and
        // thus the ordering of operands to `scf.yield` ops in both branches.
        let mut overwrites_sorted: Vec<_> = then_info.var_overwrites.into_iter().collect();
        if codegen.config.stabilize {
            // Sort by circom variable names to ensure a stable order.
            overwrites_sorted.sort_by(|(name_a, _), (name_b, _)| name_a.cmp(name_b));
        }
        let (overwrite_names, then_values): (Vec<_>, Vec<_>) =
            overwrites_sorted.into_iter().unzip();

        // Create list of values to yield from the `else` block in the same order
        // as `overwrite_names`, again using current-scope values for missing keys.
        let else_values = overwrite_names
            .iter()
            .map(|name| {
                else_info
                    .var_overwrites
                    .get(name)
                    .map_or_else(|| self.block_ctx.get_named_value(name).cloned(), |v| Ok(*v))
            })
            .collect::<Result<Vec<_>>>()?;

        // Insert `scf.yield` at the end of each block.
        Self::append_multi_operand_yield_to_block(
            codegen,
            then_info.block,
            &then_values,
            &overwrite_names,
            location,
        )?;
        Self::append_multi_operand_yield_to_block(
            codegen,
            else_info.block,
            &else_values,
            &overwrite_names,
            location,
        )?;

        // Use `overwrite_names` and the current block context to get the types of
        // the named values to define the result types of the `scf.if` op.
        let result_types = overwrite_names
            .iter()
            .map(|name| {
                self.block_ctx
                    .get_named_value(name)
                    .inspect_err(|e| eprintln!("\nERROR: {e:?}"))
                    .map(|v| v.r#type())
            })
            .collect::<Result<Vec<_>>>()?;

        // Cast condition value to bool type if needed.
        let condition = self.cast_to_bool_if_needed(codegen, location, condition)?;
        // Generate the `scf.if` op for the circom `IfThenElse` statement.
        let scf_if_op = self.append_op(scf::r#if(
            condition,
            &result_types,
            then_info.region,
            else_info.region,
            location,
        ));

        // Update the current block context with results from the `scf.if` op.
        overwrite_names
            .into_iter()
            .zip(scf_if_op.results())
            .try_for_each(|(name, result)| self.block_ctx.set_named_value(name, result.into()))?;
        Ok(())
    }

    /// Generate one region for either the then-arm or else-arm of a simple scf.if operation.
    /// Used by [Self::generate_simple_scf_if].
    /// The `value_gen` function is called to generate the value to be yielded from the arm.
    pub fn generate_simple_scf_if_arm<F>(
        &mut self,
        location: Location<'ctx>,
        value_gen: F,
    ) -> Result<(Region<'ctx>, Value<'ctx, 'val>)>
    where
        F: FnOnce(&mut Self) -> Result<Value<'ctx, 'val>>,
    {
        let region = Region::new();
        let block = region.append_block(Block::new(&[]));
        self.block_ctx.push(block);
        let arm_val = value_gen(self)?;
        self.block_ctx.pop();
        no_results(block.append_operation(scf::r#yield(&[arm_val], location)))?;
        Ok((region, arm_val))
    }

    /// Generate a simple scf.if operation that yields the given `then_value` or `else_value`
    /// depending on the `condition` value. Unlike [Self::gen_scf_if], this assumes that the
    /// then and else arms do not modify the current block context and only produce values.
    pub fn generate_simple_scf_if<F1, F2>(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        condition: Value<'ctx, 'val>,
        then_value_gen: F1,
        else_value_gen: F2,
    ) -> Result<Operation<'ctx>>
    where
        F1: FnOnce(&mut Self) -> Result<Value<'ctx, 'val>>,
        F2: FnOnce(&mut Self) -> Result<Value<'ctx, 'val>>,
    {
        let location = codegen.location_from_meta(meta);

        let (then_region, then_value) =
            self.generate_simple_scf_if_arm(location, then_value_gen)?;
        let (else_region, else_value) =
            self.generate_simple_scf_if_arm(location, else_value_gen)?;

        // Ensure then_value and else_value have the same types
        assert_eq!(
            then_value.r#type(),
            else_value.r#type(),
            "then and else branches of scf.if must have matching value types"
        );

        Ok(scf::r#if(condition, &[then_value.r#type()], then_region, else_region, location))
    }

    /// Generate a simple `scf.for` op that doesn't need to override variables
    /// in the block context.
    /// The body function (`body_fn`) accepts a `Block` with a single argument representing
    /// the for-loop induction variable and is used to fill in the `scf.for` op.
    pub fn gen_simple_scf_for(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        start: Value<'ctx, 'val>,
        step: Value<'ctx, 'val>,
        end: Value<'ctx, 'val>,
        body_fn: impl FnOnce(&mut Block<'ctx>) -> Result<()>,
    ) -> Result<()> {
        let block_arg = (codegen.index_type(), location);
        let mut block = Block::new(&[block_arg]);
        body_fn(&mut block)?;
        let region = Region::new();
        region.append_block(block);
        let scf_op = scf::r#for(start, end, step, region, location);
        self.append_op_no_result(scf_op)
    }

    /// Generate a simple `scf.for` op with normalized start=0 and step=1.
    #[inline]
    pub fn gen_normalized_scf_for(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        end: Value<'ctx, 'val>,
        body_fn: impl FnOnce(&mut Block<'ctx>) -> Result<()>,
    ) -> Result<()> {
        let start = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
        let step = self.append_op_unnamed_result(codegen.new_index_const_op(1, location))?;
        self.gen_simple_scf_for(codegen, location, start, step, end, body_fn)
    }

    /// Generates IR for decreasing the counter of a subcomponent.
    ///
    /// Returns a [`Value`] with the updated counter.
    pub fn gen_subcmp_decrease_counter(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        subcmp_memory: Value<'ctx, 'val>,
        amount: u32,
    ) -> Result<Value<'ctx, 'val>> {
        let counter = self.append_op_unnamed_result(codegen.new_pod_read_op(
            subcmp_memory,
            COUNT,
            location,
        )?)?;
        let one = self.append_op_unnamed_result(codegen.new_index_const_op(amount, location))?;
        let counter = self.append_op_unnamed_result(arith::subi(counter, one, location))?;
        self.append_op_no_result(codegen.new_pod_write_op(
            location,
            subcmp_memory,
            COUNT,
            counter,
        ))?;
        Ok(counter)
    }

    /// Decomposes the given value of [`PodType`] into a sequence of values in declaration order.
    pub fn gen_decompose_pod(
        &mut self,
        pod: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<Vec<Value<'ctx, 'val>>> {
        PodType::try_from(pod.r#type())?
            .get_records()
            .into_iter()
            .map(|record| {
                let record_name = codegen.flat_sym(record.name().as_string_ref().as_str()?);
                self.append_op_unnamed_result(pod::read(
                    location,
                    pod,
                    record_name,
                    record.r#type(),
                ))
            })
            .collect()
    }

    /// Generates a call to `@compute` for the given struct type.
    ///
    /// The arguments for the call are given as a value of [`PodType`] representing the inputs of
    /// the subcomponent.
    ///
    /// # TODO
    ///
    /// Map operands are missing.
    pub fn gen_compute_call(
        &mut self,
        struct_type: StructType<'ctx>,
        inputs: Value<'ctx, 'val>,
        location: Location<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<Value<'ctx, 'val>> {
        let input_values = self.gen_decompose_pod(inputs, codegen, location)?;
        let func_name = append_tail(&struct_type.name(), FUNC_NAME_COMPUTE.as_ref());
        self.append_op_unnamed_result(
            function::call(
                codegen.op_builder(),
                location,
                func_name,
                &input_values,
                &[struct_type],
            )?
            .into(),
        )
    }

    /// Generates a call to `@constrain` for the given struct type.
    ///
    /// The arguments for the call are given as a value of [`PodType`] representing the inputs of
    /// the subcomponent.
    pub fn gen_constrain_call(
        &mut self,
        subcmp: Value<'ctx, 'val>,
        inputs: Value<'ctx, 'val>,
        location: Location<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<()> {
        let mut call_args = vec![subcmp];
        call_args.extend(self.gen_decompose_pod(inputs, codegen, location)?);
        let func_name = append_tail(
            &StructType::try_from(subcmp.r#type())?.name(),
            FUNC_NAME_CONSTRAIN.as_ref(),
        );
        let return_types: [Type; 0] = [];
        self.append_op_no_result(
            function::call(codegen.op_builder(), location, func_name, &call_args, &return_types)?
                .into(),
        )
    }

    /// Convert a dimension [Attribute] from an [ArrayType] into a [`Value`] of index type,
    /// generating the necessary IR if the attribute is a symbol reference to a struct param.
    pub fn array_dim_attr_to_idx_val(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        dim: Attribute<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        if IntegerAttribute::try_from(dim).is_ok() {
            if !dim.r#type().is_index() {
                anyhow::bail!(
                    "expected index type for array dimension attribute, got '{}'",
                    dim.r#type()
                );
            }
            return self.append_op_unnamed_result(arith::constant(codegen.context, dim, location));
        }
        if let Ok(sym_ref) = FlatSymbolRefAttribute::try_from(dim) {
            return self.append_op_unnamed_result(poly::read_const(
                location,
                sym_ref.value(),
                codegen.index_type(),
            ));
        }
        unreachable!("Unhandled attribute in array dimensions {}", dim)
    }

    /// Creates a loop nest from a list of array dimension attributes.
    ///
    /// The body of the inner-most loop is defined by the given closure, which accepts a list of
    /// values representing the current value of each loop's induction variable.
    pub fn gen_loop_nest_from_attrs(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        dims: &[Attribute<'ctx>],
        body: impl FnOnce(&mut Self, &[Value<'ctx, 'val>]) -> Result<()>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        // Create values from the dimensions
        let dim_values = dims
            .iter()
            .map(|dim| self.array_dim_attr_to_idx_val(codegen, location, *dim))
            .collect::<Result<Vec<_>>>()?;

        self.gen_loop_nest(codegen, location, &dim_values, body)
    }

    /// Creates a loop nest from a list of array dimension values.
    ///
    /// The body of the inner-most loop is defined by the given closure, which accepts a list of
    /// values representing the current value of each loop's induction variable.
    pub fn gen_loop_nest(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        dim_values: &[Value<'ctx, 'val>],
        body: impl FnOnce(&mut Self, &[Value<'ctx, 'val>]) -> Result<()>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let zero = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
        let one = self.append_op_unnamed_result(codegen.new_index_const_op(1, location))?;

        let loop_block_args = [(codegen.index_type(), location)];
        let top_block = *self.block_ctx.top_block();
        let mut loop_vars: Vec<Value> = vec![];
        // Create the loop nest
        let mut block: Option<BlockRef<'_, '_>> = None;
        for dim in dim_values {
            let op = scf::r#for(zero, *dim, one, region_with_block(&loop_block_args), location);
            let loop_op = match &block {
                Some(block_ref) => block_ref.append_operation(op),
                None => self.append_op(op),
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
        // Push the block of the inner-most loop s.t. the user can use `self` and ops will get added
        // to the right block.
        self.block_ctx.push(block);
        body(self, &loop_vars)?;
        self.block_ctx.pop();

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

    /// Implementation for [Expression::UniformArray] after conversion of dimension
    /// expression. Useful because dimension generation differs between function
    /// and template contexts due to template parameters, but the actual array generation
    /// is otherwise the same.
    pub fn generate_uniform_array(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        value: Value<'ctx, 'val>,
        dimension: &ArrayDimension<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // Ensure all symbols are of index type
        let dimension = &self.transform_symbols_to_index(location, dimension)?;
        let const_dim = IntegerAttribute::try_from(dimension);
        if let Ok(subarr_ty) = ArrayType::try_from(value.r#type()) {
            let arr_ty = dimension.new_array_type(&subarr_ty.into());
            let mut symbols_sto = vec![];
            // The array.new constructor doesn't accept arrays as initializer values,
            // so we instead create the array empty and use array.insert to insert values.
            let ctor = if let Some(symbols) = dimension.value_range()? {
                symbols_sto.push(symbols);
                ArrayCtor::MapDimSlice(&symbols_sto, &[0])
            } else {
                ArrayCtor::Empty
            };
            let new_arr =
                self.append_op_unnamed_result(codegen.new_array_new_op(location, arr_ty, ctor))?;
            if let Ok(const_dim) = const_dim {
                for idx in 0..const_dim.value() {
                    let idx_val =
                        self.append_op_unnamed_result(codegen.new_index_const_op(idx, location))?;
                    self.append_op_no_result(array::insert(location, new_arr, &[idx_val], value))?;
                }
            } else {
                let dim = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
                let array_len =
                    self.append_op_unnamed_result(array::len(location, new_arr, dim))?;
                self.gen_normalized_scf_for(codegen, location, array_len, |b| {
                    let induction_var = b.argument(0)?;
                    b.append_operation(array::insert(
                        location,
                        new_arr,
                        &[induction_var.into()],
                        value,
                    ));
                    b.append_operation(scf::r#yield(&[], location));
                    Ok(())
                })?;
            };
            // Output value is still the newly created array
            Ok(new_arr)
        } else {
            let arr_ty = dimension.new_array_type(&value.r#type());
            if let Ok(const_dim) = const_dim {
                let values = vec![value; usize::try_from(const_dim.value())?];
                self.append_op_unnamed_result(codegen.new_array_new_op(
                    location,
                    arr_ty,
                    ArrayCtor::Values(&values),
                ))
            } else {
                let mut v_sto = vec![];
                let ctor = if let Ok(Some(v)) = dimension.value_range() {
                    v_sto.push(v);
                    ArrayCtor::MapDimSlice(&v_sto, &[0])
                } else {
                    ArrayCtor::Empty
                };
                let array_ref = self
                    .append_op_unnamed_result(codegen.new_array_new_op(location, arr_ty, ctor))?;
                let dim = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
                let array_len =
                    self.append_op_unnamed_result(array::len(location, array_ref, dim))?;
                self.gen_normalized_scf_for(codegen, location, array_len, |b| {
                    let induction_var = b.argument(0)?;
                    b.append_operation(array::write(
                        location,
                        array_ref,
                        &[induction_var.into()],
                        value,
                    ));
                    b.append_operation(scf::r#yield(&[], location));
                    Ok(())
                })?;
                Ok(array_ref)
            }
        }
    }

    /// Generate an `scf.while` op based on the given [NestedBlockInfo] and update the
    /// block context with the results of the `scf.while` op mapped to the given names.
    pub fn gen_scf_while(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        condition: Value<'ctx, 'val>,
        loop_cond_info: NestedBlockInfo<'ctx, 'blk, 'val>,
        loop_body_info: NestedBlockInfo<'ctx, 'blk, 'val>,
        loop_bounds: Option<LoopBoundsAttribute<'ctx>>,
    ) -> Result<bool> {
        // ASSERT: loop condition was a single Expression so there are no variable overwrites.
        assert!(loop_cond_info.var_overwrites.is_empty());

        // Split `loop_body_info.var_overwrites` into ordered lists of names and values. The
        // ordering of names here defines the ordering of the loop-carried variables for the
        // `scf.while` op and thus the ordering of operands for `scf.yield` and `scf.condition`.
        let mut overwrites_sorted: Vec<_> = loop_body_info.var_overwrites.into_iter().collect();
        if codegen.config.stabilize {
            // Sort by circom variable names to ensure a stable order.
            overwrites_sorted.sort_by(|(name_a, _), (name_b, _)| name_a.cmp(name_b));
        }
        let (loop_carried_var_names, body_yield_values): (Vec<_>, Vec<_>) =
            overwrites_sorted.into_iter().unzip();

        // Append the loop body block with an `scf.yield`
        Self::append_multi_operand_yield_to_block(
            codegen,
            loop_body_info.block,
            &body_yield_values,
            &loop_carried_var_names,
            location,
        )?;

        // Use `loop_carried_var_names` and the current block context to build a list of types of
        // the loop-carried variables, add BlockArguments of those types in both blocks, and
        // replace uses of the overwritten variables in both blocks with references to the new
        // BlockArguments Values.
        let mut loop_carried_types = Vec::new();
        // Additionally, track if `VAR_NAME_HAD_RETURN` is among the loop-carried variables
        // (indicating there was a return somewhere within the loop body) to later update the
        // loop condition to ensure iteration stops when a return occurs.
        let mut return_flag: Option<Value> = None;
        for name in loop_carried_var_names.iter() {
            let orig_val = self.block_ctx.get_named_value(name).unwrap();
            loop_carried_types.push(orig_val.r#type());
            replace_uses_with_new_block_argument(loop_body_info.block, orig_val, location);
            let f = replace_uses_with_new_block_argument(loop_cond_info.block, orig_val, location);
            if name == VAR_NAME_HAD_RETURN {
                return_flag = Some(f);
            }
        }

        // In the loop condition block, ensure the condition has bool type and generate an
        // `scf.condition` op with the condition value and the loop-carried variables.
        {
            let mut condition = self.cast_to_bool_if_needed(codegen, location, condition)?;
            // If there is a return within the loop, add prefix "!<VAR_NAME_HAD_RETURN> &&" to the
            // loop condition to ensure the loop terminates when the return occurs.
            if let Some(flag) = return_flag {
                let not_return_flag = single_result_as_value(
                    loop_cond_info.block.append_operation(bool::r#not(location, flag)?.into()),
                )?;
                condition =
                    single_result_as_value(loop_cond_info.block.append_operation(
                        bool::and(location, not_return_flag, condition)?.into(),
                    ))?;
            }
            // Pass the block arguments as the initial values to the condition op.
            let block_arg_values = (0..loop_cond_info.block.argument_count())
                .map(|i| loop_cond_info.block.argument(i).map_err(Into::into).map(Value::from))
                .collect::<Result<Vec<Value>>>()?;
            no_results(loop_cond_info.block.append_operation(scf::condition(
                condition,
                &block_arg_values,
                location,
            )))?;
        }

        // Create list of initial values of the loop-carried variables (i.e. the overwritten
        // variables, in the order of `loop_carried_var_names`) to pass into the `scf.while`.
        let initial_values = loop_carried_var_names
            .iter()
            .map(|name| self.block_ctx.get_named_value(name).cloned())
            .collect::<Result<Vec<_>>>()?;

        // Generate the `scf.while` op for the circom `While` statement, adding `loopbounds`
        // attribute if given, and append it to the current block.
        let mut scf_op = scf::r#while(
            &initial_values,
            &loop_carried_types,
            loop_cond_info.region,
            loop_body_info.region,
            location,
        );
        if let Some(loop_bounds) = loop_bounds {
            scf_op.set_attribute("llzk.loopbounds", loop_bounds.into());
        }
        let scf_op = self.append_op(scf_op);

        // Update the current block context with results from the `scf.while` op.
        loop_carried_var_names
            .into_iter()
            .zip(scf_op.results())
            .try_for_each(|(name, result)| self.block_ctx.set_named_value(name, result.into()))?;

        Ok(return_flag.is_some())
    }

    /// Cast all symbols passed to affine_maps into index types, which is required
    /// for affine_map usage.
    #[inline]
    fn transform_symbols_to_index(
        &mut self,
        location: Location<'ctx>,
        dimension: &ArrayDimension<'ctx, 'val>,
    ) -> Result<ArrayDimension<'ctx, 'val>> {
        dimension.transform(|val| self.cast_to_index_if_needed(location, val))
    }

    /// Handle a [program_structure::ast::Statement::Declaration] by generating a nondet felt value
    /// with the given dimensions and declaring it in the current block context.
    pub fn gen_declaration(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        name: &str,
        dimensions: &[Expression],
    ) -> Result<()> {
        if self.block_ctx.is_name_present(name) {
            return Ok(());
        }
        // If generating from VCP, there are cases where the `sugar_cleaner` added new
        // declarations that only have `MemoryKnowledge` but not `dimensions` in the AST. So
        // check `MemoryKnowledge` first (if not generating from VCP, this will always be
        // empty so `dimensions` will be used).
        let mk = meta.get_memory_knowledge();
        let dims = if mk.has_concrete_dimensions() {
            (mk.get_concrete_dimensions(), codegen).try_into()?
        } else {
            self.get_dim_exprs(codegen, dimensions)?
        };
        if codegen.config.verbose {
            println!("Declaring variable '{name}' with dimensions {dims:?}");
        }
        let op = dims.new_nondet_felt_of_dimensions(codegen, meta)?;
        self.block_ctx.declare_name_ensure_not_present(name, op)
    }
}

impl<'ctx, 'blk, 'val> DimExprConverter<'ctx, 'val> for BlockGenContext<'_, 'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    fn get_var_decl_types(&self) -> &HashMap<String, Type<'ctx>> {
        self.var_decl_types
    }

    fn callback_store_poly_expr(
        &self,
        name: String,
        op: TemplateExprOp<'ctx>,
    ) -> StringAttribute<'ctx> {
        todo!("BlockGenContext::store_template_poly_expr: {name} -> {op:?}");
    }

    fn get_dim_expr(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ArrayDimensionResult<'ctx, 'val>> {
        // First try to compute statically, falling back to literal computation if all values are
        // not compile-time constants or if the final result does not properly convert to i64.
        if let Some(integer) = shared::try_compute_as_i64(expr, codegen.prime())? {
            ArrayDimensionResult::new(codegen.index_attr(integer).into(), &[])
        } else {
            #[allow(unused_variables)] // TODO: TEMP
            match expr {
                Expression::Number(_, _) => {
                    unreachable!("handled by try_compute_as_i64")
                }
                Expression::Variable { meta, name, access } if access.is_empty()=> {
                    if self.poly_template_binding_names.contains(name) {
                        ArrayDimensionResult::new(codegen.flat_sym(name).into(), &[])
                    } else if let Ok(v) = self.block_ctx.get_named_value(name) {
                        ArrayDimensionResult::new(codegen.identity_affine_map_attr()?, &[*v])
                    } else {
                        todo!("Handle Variable expression in dimension for non-integer, non-template parameter attributes in BlockGenContext")
                    }
                },
                Expression::Variable { .. } /* with non-empty `access` */
                | Expression::InlineSwitchOp { .. }
                | Expression::PrefixOp { .. }
                | Expression::InfixOp { .. }
                | Expression::Call { .. } => {
                    self.gen_template_poly_expr(codegen, dim_expr_name(expr), expr)
                }
                // The remaining cases do not produce a scalar value.
                // i.e. ParallelOp, ArrayInLine, UniformArray, BusCall, AnonymousComp, Tuple
                // Give the same error that the circom type checker gives. The type checker ran
                // earlier so this should technically be unreachable.
                _ => {
                    unreachable!("Array indexes and lengths must produce a scalar value")
                }
            }
        }
    }
}

/// A trait to generate LLZK IR to an arbitrary LLZK block.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
pub trait GenerateLLZKInAnyBlock<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Generates LLZK IR in the given block context.
    fn gen_llzk_in_block<'info>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Value<'ctx, 'val>>;
}

/// This handles translation of circom [Expression] nodes within functions and templates (i.e.
/// [crate::template::GenerateLLZKInTemplate] implementation for [Expression] directly calls this)
/// and code generation to LLZK `poly.expr` blocks. Therefore, it must handle things that are not
/// legal in functions such as [Expression::BusCall] and [Access::ComponentAccess] but are legal in
/// other contexts such as circom templates. The `type_analysis_user::analyse_project()` pass that
/// runs before the LLZK translation pass ensures that these illegal constructs do not appear in
/// pure functions.
impl<'ctx, 'blk, 'val> GenerateLLZKInAnyBlock<'ctx, 'blk, 'val> for Expression
where
    'ctx: 'blk,
    'blk: 'val,
{
    fn gen_llzk_in_block<'info>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Value<'ctx, 'val>> {
        match self {
            Expression::Number(meta, big_int) => {
                // Convert the BigInt to an LLZK `felt.const` op. The user of the Expression is
                // responsible for converting this `felt.type` value to another type if needed.
                block_gen.append_op_unnamed_result(
                    codegen.new_felt_const_op(big_int, codegen.location_from_meta(meta))?,
                )
            }
            Expression::Variable { meta, name, access } => {
                let lvalue = Lvalue::new(
                    name,
                    if info.subcmp_info.is_subcmp(name) { Root::Signal } else { Root::Var },
                    access,
                );
                lvalue.get_value(
                    codegen,
                    block_gen,
                    info.subcmp_info,
                    codegen.location_from_meta(meta),
                    None,
                )
            }
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                let lhs = lhe.gen_llzk_in_block(codegen, block_gen, info)?;
                let rhs = rhe.gen_llzk_in_block(codegen, block_gen, info)?;
                block_gen.gen_infix_op(codegen, meta, infix_op, lhs, rhs)
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                let rhs = rhe.gen_llzk_in_block(codegen, block_gen, info)?;
                block_gen.gen_prefix_op(codegen, meta, prefix_op, rhs)
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                let location = codegen.location_from_meta(meta);
                // Ensure the condition is a bool type.
                let cond_val = cond.gen_llzk_in_block(codegen, block_gen, info)?;
                let condition = block_gen.cast_to_bool_if_needed(codegen, location, cond_val)?;

                // Then arm: generate in a nested block so `gen_llzk_in_block` can use `block_gen`
                let then_region = Region::new();
                let then_block = then_region.append_block(Block::new(&[]));
                block_gen.block_ctx.push(then_block);
                let then_value = if_true.gen_llzk_in_block(codegen, block_gen, info)?;
                block_gen.block_ctx.pop();
                no_results(then_block.append_operation(scf::r#yield(&[then_value], location)))?;

                // Else arm
                let else_region = Region::new();
                let else_block = else_region.append_block(Block::new(&[]));
                block_gen.block_ctx.push(else_block);
                let else_value = if_false.gen_llzk_in_block(codegen, block_gen, info)?;
                block_gen.block_ctx.pop();
                no_results(else_block.append_operation(scf::r#yield(&[else_value], location)))?;

                assert_eq!(
                    then_value.r#type(),
                    else_value.r#type(),
                    "then and else branches of scf.if must have matching value types"
                );
                block_gen.append_op_unnamed_result(scf::r#if(
                    condition,
                    &[then_value.r#type()],
                    then_region,
                    else_region,
                    location,
                ))
            }
            Expression::ArrayInLine { meta, values } => {
                let location = codegen.location_from_meta(meta);
                // Multi-dimensional arrays are made up of array values as their elements
                let values = values
                    .iter()
                    .map(|val_expr| val_expr.gen_llzk_in_block(codegen, block_gen, info))
                    .collect::<Result<Vec<Value>>>()?;
                let value_ty =
                    values.first().expect("Array must have at least one element").r#type();
                assert!(
                    values.iter().all(|&v| v.r#type() == value_ty),
                    "All array elements must have the same type"
                );
                if let Ok(subarr_ty) = ArrayType::try_from(value_ty) {
                    // For subarrays, we need to create a new array then insert the values
                    let dim = codegen.index_attr(i64::try_from(values.len())?);
                    let arr_ty = new_array_type(dim.into(), &subarr_ty);
                    let new_arr = block_gen.append_op_unnamed_result(codegen.new_array_new_op(
                        location,
                        arr_ty,
                        ArrayCtor::Empty,
                    ))?;
                    for (idx, val) in values.iter().enumerate() {
                        let idx_val = block_gen.append_op_unnamed_result(
                            codegen.new_index_const_op(i64::try_from(idx)?, location),
                        )?;
                        block_gen.append_op_no_result(array::insert(
                            location,
                            new_arr,
                            &[idx_val],
                            *val,
                        ))?;
                    }

                    // Output value is still the newly created array
                    Ok(new_arr)
                } else {
                    let dim = codegen.index_attr(i64::try_from(values.len())?);
                    let arr_ty = ArrayType::new(value_ty.into(), &[dim.into()]);
                    block_gen.append_op_unnamed_result(codegen.new_array_new_op(
                        location,
                        arr_ty,
                        ArrayCtor::Values(&values),
                    ))
                }
            }
            Expression::UniformArray { meta, value, dimension } => {
                let location = codegen.location_from_meta(meta);
                // Multi-dimensional arrays are made up of array values as their elements
                let value = value.gen_llzk_in_block(codegen, block_gen, info)?;
                let dim = block_gen
                    .get_dim_expr(codegen, dimension)
                    .and_then(ArrayDimension::try_from)?;
                block_gen.generate_uniform_array(codegen, location, value, &dim)
            }
            Expression::Call { meta, id, args } => {
                let location = codegen.location_from_meta(meta);
                let target_function_data = codegen.program.get_function_data(id);
                // Visit each argument and collect the resulting LLZK Values for both functions.
                let param_types = target_function_data.get_type_of_params(codegen);
                assert_eq!(param_types.len(), args.len(), "Argument-parameter count mismatch");
                let call_operands = args
                    .iter()
                    .zip(param_types)
                    .map(|(arg, expected_type)| {
                        let operand_val = arg.gen_llzk_in_block(codegen, block_gen, info)?;
                        block_gen.cast_to_expected_type_if_needed(
                            codegen,
                            location,
                            operand_val,
                            expected_type,
                        )
                    })
                    .collect::<Result<Vec<Value>>>()?;
                // Create the CallOp in each function using the collected args.
                block_gen.append_op_unnamed_result(
                    function::call(
                        codegen.op_builder(),
                        location,
                        codegen.flat_sym(id),
                        &call_operands,
                        &[target_function_data.get_type_of_return(codegen)],
                    )?
                    .into(),
                )
            }
            #[allow(unused_variables)] // TODO: TEMP
            Expression::BusCall { meta, id, args } => {
                todo!("Handle BusCall expression")
            }
            Expression::AnonymousComp { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::Tuple { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::ParallelOp { .. } => {
                unreachable!("handled in templates, illegal in pure functions")
            }
        }
    }
}
