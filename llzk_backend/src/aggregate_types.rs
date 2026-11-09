//! Pure navigation of aggregate storage types, independent of access syntax and diagnostics.

use std::convert::TryFrom;

use anyhow::Result;
use llzk::prelude::{ArrayType, PodType, Type};

/// Whether a storage type contains a bus record.
pub(crate) fn contains_bus(ty: Type<'_>) -> bool {
    PodType::try_from(ty).is_ok()
        || ArrayType::try_from(ty).is_ok_and(|a| contains_bus(a.element_type()))
}

/// Look up a POD field, returning `None` for a missing field and an error for a non-POD type.
pub(crate) fn field_type<'ctx>(ty: Type<'ctx>, field: &str) -> Result<Option<Type<'ctx>>> {
    Ok(PodType::try_from(ty)?.record_type(field))
}

/// Consume leading array dimensions without inspecting or evaluating index expressions.
///
/// Remaining dimensions retain their original attributes, including symbolic dimensions.
/// Returns `None` for excess indices and an error for a non-array type, even with zero indices.
pub(crate) fn indexed_type<'ctx>(ty: Type<'ctx>, indices: usize) -> Result<Option<Type<'ctx>>> {
    let array = ArrayType::try_from(ty)?;
    let dims = array.dims();
    if indices > dims.len() {
        return Ok(None);
    }
    Ok(Some(if indices == dims.len() {
        array.element_type()
    } else {
        ArrayType::new(array.element_type(), &dims[indices..]).into()
    }))
}
