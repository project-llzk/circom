//! Shared LLZK structure traversal utilities.

use llzk::prelude::{
    BlockLike as _, BlockRef, OperationLike as _, OperationRef, RegionLike as _, RegionRef,
};

/// Callbacks for walking LLZK structures.
#[derive(Default)]
#[allow(clippy::type_complexity)]
pub struct WalkCallbacks<'a> {
    /// Optional callback for each block visited.
    pub block_visitor: Option<Box<dyn FnMut(BlockRef) + 'a>>,
    /// Optional callback for each operation visited.
    pub op_visitor: Option<Box<dyn FnMut(OperationRef) + 'a>>,
    /// Optional callback for each region visited.
    pub region_visitor: Option<Box<dyn FnMut(RegionRef) + 'a>>,
}

impl<'a> WalkCallbacks<'a> {
    /// Create a new [WalkCallbacks] with a block visitor.
    #[allow(unused)]
    pub fn for_blocks(visitor: impl FnMut(BlockRef) + 'a) -> Self {
        Self { block_visitor: Some(Box::new(visitor)), ..Default::default() }
    }
    /// Create a new [WalkCallbacks] with an operation visitor.
    #[allow(unused)]
    pub fn for_ops(visitor: impl FnMut(OperationRef) + 'a) -> Self {
        Self { op_visitor: Some(Box::new(visitor)), ..Default::default() }
    }
    /// Create a new [WalkCallbacks] with a region visitor.
    #[allow(unused)]
    pub fn for_regions(visitor: impl FnMut(RegionRef) + 'a) -> Self {
        Self { region_visitor: Some(Box::new(visitor)), ..Default::default() }
    }
    /// Add/overwrite the block visitor in an existing [WalkCallbacks].
    #[allow(unused)]
    pub fn and_blocks(self, visitor: impl FnMut(BlockRef) + 'a) -> Self {
        Self { block_visitor: Some(Box::new(visitor)), ..self }
    }
    /// Add/overwrite the operation visitor in an existing [WalkCallbacks].
    #[allow(unused)]
    pub fn and_ops(self, visitor: impl FnMut(OperationRef) + 'a) -> Self {
        Self { op_visitor: Some(Box::new(visitor)), ..self }
    }
    /// Add/overwrite the region visitor in an existing [WalkCallbacks].
    #[allow(unused)]
    pub fn and_regions(self, visitor: impl FnMut(RegionRef) + 'a) -> Self {
        Self { region_visitor: Some(Box::new(visitor)), ..self }
    }
}

/// Recursive walk visitor for a block.
fn walk_block(block: BlockRef, cb: &mut WalkCallbacks) {
    if let Some(visitor) = cb.block_visitor.as_mut() {
        visitor(block);
    }

    let mut op = block.first_operation();
    while let Some(operation) = op {
        walk_operation(operation, cb);
        op = operation.next_in_block();
    }
}

/// Recursive walk visitor for an operation.
fn walk_operation(op: OperationRef, cb: &mut WalkCallbacks) {
    if let Some(visitor) = cb.op_visitor.as_mut() {
        visitor(op);
    }

    for region in op.regions() {
        walk_region(region, cb);
    }
}

/// Recursive walk visitor for a region.
fn walk_region(region: RegionRef, cb: &mut WalkCallbacks) {
    if let Some(visitor) = cb.region_visitor.as_mut() {
        visitor(region);
    }

    let mut block = region.first_block();
    while let Some(b) = block {
        walk_block(b, cb);
        block = b.next_in_region();
    }
}

/// Walk starting from a block with the given callbacks.
#[inline]
#[allow(unused)]
pub fn walk_from_block(block: BlockRef, mut callbacks: WalkCallbacks) {
    walk_block(block, &mut callbacks);
}

/// Walk starting from an operation with the given callbacks.
#[inline]
#[allow(unused)]
pub fn walk_from_region(region: RegionRef, mut callbacks: WalkCallbacks) {
    walk_region(region, &mut callbacks);
}

/// Walk starting from a region with the given callbacks.
#[inline]
#[allow(unused)]
pub fn walk_from_operation(operation: OperationRef, mut callbacks: WalkCallbacks) {
    walk_operation(operation, &mut callbacks);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn callback_struct_init() {
        let _ = WalkCallbacks {
            block_visitor: Some(Box::new(|b| println!("Visited: {:?}", b))),
            op_visitor: None,
            region_visitor: None,
        };
    }

    #[test]
    fn callback_struct_new_for_ops() {
        let _ = WalkCallbacks::for_ops(|op| println!("Visited op {:?}", op));
    }

    #[test]
    fn callback_struct_new_chained() {
        let _ = WalkCallbacks::for_ops(|op| println!("Visited op {:?}", op))
            .and_blocks(|b| println!("Visited block {:?}", b));
    }
}
