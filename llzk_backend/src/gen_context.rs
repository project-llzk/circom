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
    /// Maps circom var name to the LLZK SSA Value for that var.
    name_to_value: HashMap<String, Value<'ctx, 'val>>,
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
        name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Result<Self> {
        let root_block =
            func.region(0)?.first_block().ok_or_else(|| anyhow!("missing function entry block"))?;
        Ok(BlockContextStack {
            root: BlockContext { block: root_block, name_to_value },
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

    /// Set the LLZK IR SSA Value for the given circom var name, local to the top block context.
    pub fn set_named_value(&mut self, name: String, value: Value<'ctx, 'val>) {
        self.top_mut().name_to_value.insert(name, value);
    }

    /// Get the LLZK IR SSA Value for the given circom var name, checking the top block context
    /// and then proceeding down the stack until found (if at all).
    pub fn get_named_value(&self, name: &str) -> Option<&Value<'ctx, 'val>> {
        for bc in self.other_blocks.iter().rev() {
            let lookup = bc.name_to_value.get(name);
            if lookup.is_some() {
                return lookup;
            }
        }
        self.root.name_to_value.get(name)
    }

    /// Push a new block onto the stack to make it the current block.
    pub fn push(&mut self, block: BlockRef<'ctx, 'blk>) {
        self.other_blocks.push(BlockContext { block, name_to_value: Default::default() });
    }

    /// Pop the current block off the stack to return to the previous block. The vars defined in the
    /// popped frame are dropped unless they were present in the context prior to the current frame,
    /// in which case the new values assigned to the vars are updated in the previous frame (i.e.
    /// the new top frame after popping).
    pub fn pop(&mut self) {
        let popped = self.other_blocks.pop().expect("There is no block to pop!");
        for (name, value) in popped.name_to_value.into_iter() {
            // If var exists in some lower context, copy to current top context.
            if self.get_named_value(&name).is_some() {
                self.top_mut().name_to_value.insert(name, value);
            }
        }
    }
}
