//! Shared LLZK structure traversal utilities.

use llzk::prelude::BlockLike as _;
use llzk::prelude::BlockRef;
use llzk::prelude::OperationLike as _;
use llzk::prelude::OperationRef;
use llzk::prelude::RegionLike as _;
use llzk::prelude::RegionRef;

pub struct WalkCallbacks<'a> {
    pub block_visitor: Option<Box<dyn FnMut(BlockRef) + 'a>>,
    pub op_visitor: Option<Box<dyn FnMut(OperationRef) + 'a>>,
    pub region_visitor: Option<Box<dyn FnMut(RegionRef) + 'a>>,
}

impl Default for WalkCallbacks<'_> {
    fn default() -> Self {
        Self { block_visitor: None, op_visitor: None, region_visitor: None }
    }
}

impl<'a> WalkCallbacks<'a> {
    #[allow(unused)]
    pub fn for_blocks(visitor: impl FnMut(BlockRef) + 'a) -> Self {
        Self { block_visitor: Some(Box::new(visitor)), ..Default::default() }
    }
    #[allow(unused)]
    pub fn for_ops(visitor: impl FnMut(OperationRef) + 'a) -> Self {
        Self { op_visitor: Some(Box::new(visitor)), ..Default::default() }
    }
    #[allow(unused)]
    pub fn for_regions(visitor: impl FnMut(RegionRef) + 'a) -> Self {
        Self { region_visitor: Some(Box::new(visitor)), ..Default::default() }
    }
    #[allow(unused)]
    pub fn and_blocks(self, visitor: impl FnMut(BlockRef) + 'a) -> Self {
        Self { block_visitor: Some(Box::new(visitor)), ..self }
    }
    #[allow(unused)]
    pub fn and_ops(self, visitor: impl FnMut(OperationRef) + 'a) -> Self {
        Self { op_visitor: Some(Box::new(visitor)), ..self }
    }
    #[allow(unused)]
    pub fn and_regions(self, visitor: impl FnMut(RegionRef) + 'a) -> Self {
        Self { region_visitor: Some(Box::new(visitor)), ..self }
    }
}

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

fn walk_operation(op: OperationRef, cb: &mut WalkCallbacks) {
    if let Some(visitor) = cb.op_visitor.as_mut() {
        visitor(op);
    }

    for region in op.regions() {
        walk_region(region, cb);
    }
}

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

#[inline]
#[allow(unused)]
pub fn walk_from_block(block: BlockRef, mut callbacks: WalkCallbacks) {
    walk_block(block, &mut callbacks);
}

#[inline]
#[allow(unused)]
pub fn walk_from_region(region: RegionRef, mut callbacks: WalkCallbacks) {
    walk_region(region, &mut callbacks);
}

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
