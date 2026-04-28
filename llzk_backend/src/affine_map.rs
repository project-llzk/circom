//! Implementation for affine map attributes, since melior does not have support for them.

use melior::ir::Attribute;
use melior::Context;
use mlir_sys::mlirAffineMapAttrGet;
use mlir_sys::mlirAffineMapMultiDimIdentityGet;

/// Represents an affine map attribute in MLIR.
///
/// This type exists because melior doesn't have it and should be moved to the
/// `llzk` crate at some point.
#[derive(Debug)]
pub struct AffineMapAttribute<'ctx> {
    /// Inner attribute.
    inner: Attribute<'ctx>,
}

impl<'ctx> AffineMapAttribute<'ctx> {
    /// Creates an identity map with the given number of dimensions
    /// (i.e. for 1 creates `(d0)[] -> (d0)`.)
    pub fn identity(context: &'ctx Context, dims: usize) -> Self {
        let raw_map = unsafe { mlirAffineMapMultiDimIdentityGet(context.to_raw(), dims as isize) };
        let raw_attr = unsafe { mlirAffineMapAttrGet(raw_map) };
        Self { inner: unsafe { Attribute::from_option_raw(raw_attr) }.unwrap() }
    }
}

impl<'ctx> From<AffineMapAttribute<'ctx>> for Attribute<'ctx> {
    fn from(value: AffineMapAttribute<'ctx>) -> Self {
        value.inner
    }
}
