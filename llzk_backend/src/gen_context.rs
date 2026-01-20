//! Handles circom var scoping and LLZK blocks stack management.

use crate::function::FunctionContext;
use crate::shared::single_result_as_value;
use anyhow::anyhow;
use anyhow::ensure;
use anyhow::Result;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::BlockRef;
use llzk::prelude::FuncDefOp;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::OperationRef;
use llzk::prelude::Region;
use llzk::prelude::RegionLike as _;
use llzk::prelude::Value;
use std::collections::HashMap;

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
        BlockContext {
            block,
            scope_local_name_to_value: Default::default(),
            overwriting_name_to_value: Default::default(),
            op_queue: Default::default(),
        }
    }

    /// Create a new [BlockContext] for the given block, initializing the scope local
    /// declarations with the mapping of parameter names to values.
    fn new_with_params(
        block: BlockRef<'ctx, 'blk>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Self {
        BlockContext {
            block,
            scope_local_name_to_value: param_name_to_value,
            overwriting_name_to_value: Default::default(),
            op_queue: Default::default(),
        }
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
    /// Create a new [BlockContextStack] for the given function with an initial name-to-value
    /// mapping containing function parameters.
    pub fn new(
        func: &FuncDefOp<'ctx>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Result<Self> {
        let root_block =
            func.region(0)?.first_block().ok_or_else(|| anyhow!("missing function entry block"))?;
        Ok(BlockContextStack {
            root: BlockContext::new_with_params(root_block, param_name_to_value),
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
    pub fn is_name_present(
        &self,
        name: &str,
    ) -> bool {
        self.top().scope_local_name_to_value.contains_key(name)
    }

    /// Ensure the given name is not already declared in the current scope, then declare it by producing an
    /// [Operation] via the callback, inserting that into the current block, and using its result.
    /// The only scenario where a declaration would already be present is when the same Declaration
    /// statements are visited that were used to produce the parameters of the current function.
    /// Otherwise, the checks performed earlier in the circom parser pipeline will produce an error
    /// if a symbol is declared more than once in the same scope.
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

impl<'ctx, 'func, 'blk, 'val> NestedBlockInfo<'ctx, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Update `self.var_overwrites` to ensure it has all keys from `other.var_overwrites`, using
    /// values from the current scope in the [FunctionContext] for missing keys.
    pub fn add_missing_values(
        &mut self,
        other: &NestedBlockInfo<'ctx, 'blk, 'val>,
        fc: &FunctionContext<'ctx, 'func, 'blk, 'val>,
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
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
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
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
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
