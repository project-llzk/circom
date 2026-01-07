//! Helper types for handling subcomponents.

use llzk::prelude::*;
use std::collections::HashMap;
use std::collections::HashSet;
use std::marker::PhantomData;

/// Version of [`Access`](program_structure::ast::Access) that uses LLZK
/// Attributes instead.
#[derive(Debug, Eq, PartialEq)]
pub enum LlzkAccess<'ctx> {
    /// Access to the signals of a component.
    ComponentAccess(String),
    /// Index access.
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
    /// Creates a new declaration instance.
    pub fn new(dimensions: Vec<Attribute<'ctx>>, location: Location<'ctx>) -> Self {
        Self { dimensions, location, instances: Default::default() }
    }

    /// Returns the dimensions of the declaration.
    pub fn dimensions(&self) -> &[Attribute<'ctx>] {
        &self.dimensions
    }

    /// Returns the location of the declaration.
    pub fn location(&self) -> Location<'ctx> {
        self.location
    }

    /// Returns a mutable reference to the different type instances.
    pub fn instances_mut(&mut self) -> &mut HashMap<Vec<LlzkAccess<'ctx>>, StructType<'ctx>> {
        &mut self.instances
    }

    /// Returns a reference to the different type instances.
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

/// Maps the values of a subcomponent call to it's name.
///
/// The actual value used depends on the context; if it's a call to `@compute` then is the value
/// returned by the call op. If it's a call to `@constrain` then is the value of the first operand
/// of the call op.
///
/// # Safety
///
/// Uses the raw pointer as key since [`Value`] does not implement [`Hash`](std::hash::Hash). To
/// minimize risk, it has a lifetime parameter tied to a [`Context`].
#[derive(Debug)]
pub struct SubcmpCallsMap<'ctx> {
    /// Mapping between a value representing a constructor and the name of the type it constructs.
    map: HashMap<*const std::ffi::c_void, String>,
    /// Marker to link the lifetime of a MLIR context to this instance.
    _marker: PhantomData<&'ctx Context>,
}

impl<'ctx> SubcmpCallsMap<'ctx> {
    /// Creates an empty map.
    pub fn new() -> Self {
        Self { map: HashMap::new(), _marker: PhantomData }
    }

    /// Inserts a new mapping.
    ///
    /// Panics if the key already exists.
    pub fn insert(&mut self, value: &impl ValueLike<'ctx>, name: String) {
        assert!(self.map.insert(value.to_raw().ptr, name).is_none());
    }

    /// Returns the name of the type or `None` if not found.
    pub fn get(&self, value: &impl ValueLike<'ctx>) -> Option<&str> {
        self.map.get(&value.to_raw().ptr).map(String::as_str)
    }

    /// Updates the mapping with the new key.
    ///
    /// The new key must not be already mapped to another name.
    pub fn update_keys(&mut self, key: impl ValueLike<'ctx>, new: impl ValueLike<'ctx>) {
        if let Some(name) = self.map.remove(&key.to_raw().ptr) {
            self.insert(&new, name)
        }
    }
}

impl Default for SubcmpCallsMap<'_> {
    fn default() -> Self {
        Self::new()
    }
}
