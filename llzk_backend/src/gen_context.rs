use crate::shared::single_result_as_value;
use anyhow::{anyhow, Ok, Result};
use llzk::prelude::{FuncDefOp, OperationLike as _};
use melior::ir::{BlockLike as _, BlockRef, Operation, OperationRef, RegionLike as _, Value};
use std::collections::HashMap;

/// Single frame in the [BlockContextStack].
/// ˝
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

    /// Get reference to the current block (i.e. the top of the stack).
    pub fn top_block(&self) -> &BlockRef<'ctx, 'blk> {
        match self.other_blocks.last() {
            Some(bc) => &bc.block,
            None => &self.root.block,
        }
    }

    /// Ref to the current block context (i.e. the top of the stack).
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

    /// If the given name is not already declared in the current scope, declare it by creating an
    /// [Operation] via the callback, inserting that into the current block, and using its result.
    /// The only scenario where a declaration would already be present is when the same Declaration
    /// statements are visited that were used to produce the parameters of the current function.
    /// Otherwise, the checks performed earlier in the circom parser pipeline will produce an error
    /// if a symbol is declared more than once in the same scope.
    pub fn declare_name_if_not_present(
        &mut self,
        name: String,
        uninit_value: impl FnOnce() -> Result<Operation<'ctx>>,
    ) -> Result<()> {
        if !self.top_mut().scope_local_name_to_value.contains_key(&name) {
            let op = uninit_value()?;
            let value = single_result_as_value(self.append_current_block(op))?;
            self.top_mut().scope_local_name_to_value.insert(name, value);
        }
        Ok(())
    }

    /// Set the LLZK IR SSA Value for the given circom var name, local to the top block context.
    pub fn set_named_value(&mut self, name: String, value: Value<'ctx, 'val>) -> Result<()> {
        let bc = self.top_mut();
        bc.insert(name, value);
        Ok(())
    }

    /// Get the LLZK IR SSA Value for the given circom var name, checking the top block context
    /// and then proceeding down the stack until found (if at all).
    pub fn get_named_value(&self, name: &str) -> Option<&Value<'ctx, 'val>> {
        for bc in self.other_blocks.iter().rev() {
            let lookup = bc.get(name);
            if lookup.is_some() {
                return lookup;
            }
        }
        self.root.get(name)
    }

    /// Push a new block onto the stack to make it the current block.
    pub fn push(&mut self, block: BlockRef<'ctx, 'blk>) {
        self.other_blocks.push(BlockContext::new(block));
    }

    /// Pop the current block off the stack to return to the previous block. The vars declared in
    /// the popped frame are dropped and those which are overwrites are written to the context
    /// prior to the current frame..
    pub fn pop(&mut self) {
        let popped = self.other_blocks.pop().expect("There is no block to pop!");
        let new_top = self.top_mut();
        for (name, value) in popped.overwriting_name_to_value.into_iter() {
            new_top.insert(name, value);
        }
    }
}

/// Provides common functions for generating code that respects circom variable scoping, abstracting
/// access to the [BlockContextStack] so that functions and templates can share these functions.
pub trait GenWithCircomScopeHandling<'ctx, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// LLZK block context type. For functions, this is just [BlockRef], but for templates,
    /// this type holds a [BlockRef] for both the `compute` and `constrain` functions.
    type NewBlock: Copy;

    /// Retrieve the top block(s) from the [BlockContextStack].
    fn stack_top(&self) -> Self::NewBlock;

    /// Push new block(s) onto the [BlockContextStack].
    fn stack_push(&mut self, block: Self::NewBlock);

    /// Pop the top block(s) from the [BlockContextStack].
    fn stack_pop(&mut self);

    /// Use the callback to generate code for a new circom scope/block within the given LLZK
    /// `NewBlock`. Assignments to circom variables that are newly introduced in this context go out
    /// of scope so they are dropped after the callback but overwriting assignments to circom
    /// variables that already exist prior to this new scope are preserved and written into the
    /// existing block context
    fn gen_in_given_block_with_new_circom_scope(
        &mut self,
        block: Self::NewBlock,
        generator: impl FnOnce(&mut Self, Self::NewBlock) -> Result<()>,
    ) -> Result<()> {
        self.stack_push(block);
        let res = generator(self, block);
        self.stack_pop();
        res
    }

    /// Use the callback to generate code for a new circom scope/block but within the current LLZK
    /// `NewBlock`. Assignments to circom variables that are newly introduced in this context go out
    /// of scope so they are dropped after the callback but overwriting assignments to circom
    /// variables that already exist prior to this new scope are preserved and written into the
    /// existing block context
    #[inline]
    fn gen_in_current_block_with_new_circom_scope(
        &mut self,
        generator: impl FnOnce(&mut Self, Self::NewBlock) -> Result<()>,
    ) -> Result<()> {
        self.gen_in_given_block_with_new_circom_scope(self.stack_top(), generator)
    }
}
