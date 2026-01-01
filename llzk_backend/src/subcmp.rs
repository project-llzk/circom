//! Helper types for handling subcomponents.

use llzk::prelude::*;
use std::collections::{HashMap, HashSet};

/// Version of [`Access`](program_structure::ast::Access) that uses LLZK
/// Attributes instead.
#[derive(Debug, Eq, PartialEq)]
pub enum LlzkAccess<'ctx> {
    ComponentAccess(String),
    ArrayAccess(Attribute<'ctx>),
}

impl LlzkAccess<'_> {
    /// Returns true if the access is direct.
    ///
    /// An access is direct if it refers to a component or
    /// if the array access refers to a literal value.
    pub fn is_direct(&self) -> bool {
        matches!(self, LlzkAccess::ComponentAccess(_))
            || matches!(self, LlzkAccess::ArrayAccess(attribute)
                if attribute.is_integer())
    }
}

/// Manual implementation of Hash because the inner types do not implement it.
impl std::hash::Hash for LlzkAccess<'_> {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        // Hash variant discriminant first to salt the hash.
        core::mem::discriminant(self).hash(state);
        match self {
            LlzkAccess::ComponentAccess(name) => name.hash(state),
            // Hash the attribute's pointer since they are unique w.r.t. the MLIR context.
            LlzkAccess::ArrayAccess(attribute) => attribute.to_raw().ptr.hash(state),
        }
    }
}

/// Information collected about a subcomponent.
#[derive(Debug)]
pub struct SubcmpDeclInfo<'ctx> {
    /// List of dimensions for arrays of subcomponents of the same type.
    dimensions: Vec<Attribute<'ctx>>,
    /// Location of the declaration.
    location: Location<'ctx>,
    /// Instances of the subcomponent type.
    instances: HashMap<Vec<LlzkAccess<'ctx>>, StructType<'ctx>>,
}

impl<'ctx> SubcmpDeclInfo<'ctx> {
    pub fn new(dimensions: Vec<Attribute<'ctx>>, location: Location<'ctx>) -> Self {
        Self { dimensions, location, instances: Default::default() }
    }

    pub fn dimensions(&self) -> &[Attribute<'ctx>] {
        &self.dimensions
    }

    pub fn location(&self) -> Location<'ctx> {
        self.location
    }

    pub fn instances_mut(&mut self) -> &mut HashMap<Vec<LlzkAccess<'ctx>>, StructType<'ctx>> {
        &mut self.instances
    }

    pub fn instances(&self) -> Vec<(&[LlzkAccess<'ctx>], StructType<'ctx>)> {
        self.instances.iter().map(|(a, s)| (a.as_slice(), *s)).collect()
    }
}

/// Returns a list with the unique struct types in the given instances.
pub fn unique_instance_types<'ctx>(
    instances: &[(&[LlzkAccess<'ctx>], StructType<'ctx>)],
) -> Vec<StructType<'ctx>> {
    instances.iter().map(|(_, t)| ST(*t)).collect::<HashSet<_>>().into_iter().map(|s| s.0).collect()
}

/// Newtype for implementing Hash in StructType.
struct ST<'ctx>(pub StructType<'ctx>);

impl PartialEq for ST<'_> {
    fn eq(&self, other: &Self) -> bool {
        self.0.to_raw().ptr == other.0.to_raw().ptr
    }
}

impl Eq for ST<'_> {}

impl std::hash::Hash for ST<'_> {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.0.to_raw().ptr.hash(state);
    }
}
