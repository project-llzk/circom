//! Helper types for handling subcomponents.

use anyhow::Result;
use llzk::prelude::*;
use std::collections::HashMap;
use std::collections::HashSet;
use std::marker::PhantomData;

use crate::program_ext::ProgramInfo;
use crate::template_ext::SignalDeclarations;

/// Names used for `pod` records.
pub mod names {
    /// Counts the number of inputs pending an assignment. When it reaches 0 it's safe
    /// to call the corresponding `@compute` function.
    pub const COUNT: &str = "count";
    /// Holds the output of calling `@compute`. Before the call, this value is undefined
    /// and should not be read from.
    pub const COMP: &str = "comp";
    /// Holds the affine map operands of the subcomponents, if any.
    pub const PARAMS: &str = "params";
}

/// Gives information about subcomponents.
pub trait SubcmpInfo: std::fmt::Debug {
    /// Returns true if the given variable name is a subcomponent.
    fn is_subcmp(&self, var: &str) -> bool;

    /// Returns the template information for the given subcomponent.
    fn subcmp_info<'i>(
        &self,
        var: &str,
        info: &'i dyn ProgramInfo,
    ) -> Result<&'i dyn SignalDeclarations>;
}

/// Empty implementation for [`SubcmpInfo`].
#[derive(Debug)]
pub struct NoSubcmps;

impl SubcmpInfo for NoSubcmps {
    fn is_subcmp(&self, var: &str) -> bool {
        false
    }

    fn subcmp_info<'i>(
        &self,
        var: &str,
        info: &'i dyn ProgramInfo,
    ) -> Result<&'i dyn SignalDeclarations> {
        unreachable!()
    }
}

/// Information collected about a subcomponent.
#[derive(Debug)]
pub struct SubcmpDeclInfo<'ctx> {
    /// Name of the template type.
    template: Option<String>,
    /// List of dimensions for arrays of subcomponents of the same type.
    dimensions: Vec<Attribute<'ctx>>,
    /// Location of the declaration.
    location: Location<'ctx>,
    /// Instances of the subcomponent type.
    instances: Vec<StructType<'ctx>>,
}

impl<'ctx> SubcmpDeclInfo<'ctx> {
    /// Creates a new declaration instance.
    pub fn new(dimensions: Vec<Attribute<'ctx>>, location: Location<'ctx>) -> Self {
        Self { template: None, dimensions, location, instances: Default::default() }
    }

    /// Sets the name of the subcomponent's template type.
    pub fn set_template(&mut self, name: String) {
        self.template = Some(name)
    }

    /// Gets the name of the subcomponent's template type.
    pub fn template(&self) -> Option<&str> {
        self.template.as_deref()
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
    pub fn instances_mut(&mut self) -> &mut Vec<StructType<'ctx>> {
        &mut self.instances
    }

    /// Returns a reference to the different type instances.
    pub fn instances(&self) -> &[StructType<'ctx>] {
        &self.instances
    }
}

/// Returns a list with the unique struct types in the given instances.
pub fn unique_instance_types<'ctx>(instances: &[StructType<'ctx>]) -> Vec<StructType<'ctx>> {
    instances.iter().copied().map(ST).collect::<HashSet<_>>().into_iter().map(|s| s.0).collect()
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

    /// If the left value exists in the map, adds the right value with the same name.
    ///
    /// Returns the right value.
    pub fn propagate<V>(&mut self, lhs: &impl ValueLike<'ctx>, rhs: V) -> V
    where
        V: ValueLike<'ctx>,
    {
        if let Some(name) = self.get(lhs) {
            self.insert(&rhs, name.to_string())
        }
        rhs
    }
}

impl Default for SubcmpCallsMap<'_> {
    fn default() -> Self {
        Self::new()
    }
}

/// Holds the information required for generating the IR to support subcomponents in the prologue
/// of the template's functions.
pub struct SubcmpPrologueData<'ctx> {
    /// Name of the subcomponent.
    pub name: String,
    /// Type of the subcomponent.
    pub subcmp: Type<'ctx>,
    /// Type representing the inputs of the subcomponent.
    pub inputs: Type<'ctx>,
    /// Number of inputs in the subcomponent.
    pub inputs_size: usize,
}
