//! Helper types for handling subcomponents.

use crate::function::FunctionContext;
use crate::program_ext::ProgramInfo;
use crate::program_ext::ProgramLike;
use crate::shared::map_array_inner_type;
use crate::shared::LlzkCodegen;
use crate::template_ext::SignalDeclarations;
use crate::template_ext::TemplateLike as _;
use anyhow::Result;
use llzk::dialect::array::ArrayCtor;
use llzk::dialect::llzk::nondet;
use llzk::dialect::pod;
use llzk::dialect::r#struct;
use llzk::prelude::ArrayType;
use llzk::prelude::Attribute;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::Location;
use llzk::prelude::PodType;
use llzk::prelude::StructType;
use llzk::prelude::Type;
use llzk::prelude::TypeLike as _;
use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::TryFrom;

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

    /// Returns the inputs field name for a subcomponent by appending "$inputs" suffix.
    #[inline]
    pub fn inputs(name: &str) -> String {
        format!("{name}$inputs")
    }
}

/// Gives information about subcomponents.
pub trait SubcmpInfo<'ctx>: std::fmt::Debug {
    /// Returns true if the given variable name is a subcomponent.
    fn is_subcmp(&self, var: &str) -> bool;

    /// Returns the mixed subcomponent pod record for the given concrete index tuple, if any.
    fn mixed_subcmp_record_for_indices<'a>(
        &'a self,
        _var: &str,
        _indices: &[usize],
    ) -> Option<&'a str> {
        None
    }

    /// Returns information about a mixed subcomponent pod.
    fn mixed_subcmp_info(&self, var: &str) -> Result<&MixedSubcmpLayout<'ctx>>;

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

impl<'ctx> SubcmpInfo<'ctx> for NoSubcmps {
    fn is_subcmp(&self, _var: &str) -> bool {
        false
    }

    fn subcmp_info<'i>(
        &self,
        _var: &str,
        _info: &'i dyn ProgramInfo,
    ) -> Result<&'i dyn SignalDeclarations> {
        unreachable!()
    }

    fn mixed_subcmp_info(&self, _: &str) -> Result<&MixedSubcmpLayout<'ctx>> {
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
    /// Instances of a mixed concrete subcomponent binding.
    mixed_instances: Vec<MixedSubcmpInstance<'ctx>>,
}

impl<'ctx> SubcmpDeclInfo<'ctx> {
    /// Creates a new declaration instance.
    pub fn new(dimensions: Vec<Attribute<'ctx>>, location: Location<'ctx>) -> Self {
        Self {
            template: None,
            dimensions,
            location,
            instances: Default::default(),
            mixed_instances: Default::default(),
        }
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

    /// Returns a mutable reference to the mixed concrete instances.
    pub fn mixed_instances_mut(&mut self) -> &mut Vec<MixedSubcmpInstance<'ctx>> {
        &mut self.mixed_instances
    }

    /// Returns a reference to the mixed concrete instances.
    pub fn mixed_instances(&self) -> &[MixedSubcmpInstance<'ctx>] {
        &self.mixed_instances
    }

    /// Returns true if the declaration uses a mixed concrete representation.
    pub fn is_mixed(&self) -> bool {
        !self.mixed_instances.is_empty()
    }

    /// Applies the dimensions to the given type, wrapping it in an array type if necessary.
    pub fn extend_dims(&self, t: Type<'ctx>) -> Type<'ctx> {
        match self.dimensions() {
            [] => t,
            dims => ArrayType::new(t, dims).into(),
        }
    }
}

/// Returns a list with the unique struct types in the given instances.
pub fn unique_instance_types<'ctx>(instances: &[StructType<'ctx>]) -> Vec<StructType<'ctx>> {
    instances.iter().copied().map(ST).collect::<HashSet<_>>().into_iter().map(|s| s.0).collect()
}

/// A concrete instance in a mixed subcomponent binding.
#[derive(Clone, Debug)]
pub struct MixedSubcmpInstance<'ctx> {
    /// Stable pod record name for this instance.
    record_name: String,
    /// Concrete index tuple used to instantiate the component.
    indexed_with: Vec<usize>,
    /// Concrete struct type for this instance.
    struct_type: StructType<'ctx>,
}

impl<'ctx> MixedSubcmpInstance<'ctx> {
    /// Creates a new mixed subcomponent instance.
    pub fn new(
        record_name: String,
        indexed_with: Vec<usize>,
        struct_type: StructType<'ctx>,
    ) -> Self {
        Self { record_name, indexed_with, struct_type }
    }

    /// Returns the pod record name for this instance.
    pub fn record_name(&self) -> &str {
        &self.record_name
    }

    /// Returns the concrete index tuple for this instance.
    pub fn indexed_with(&self) -> &[usize] {
        &self.indexed_with
    }

    /// Returns the concrete struct type for this instance.
    pub fn struct_type(&self) -> StructType<'ctx> {
        self.struct_type
    }
}

/// A fully typed record in a mixed subcomponent binding.
#[derive(Clone, Debug)]
pub struct MixedSubcmpEntry<'ctx> {
    /// Stable pod record name for this instance.
    record_name: String,
    /// Concrete index tuple used to instantiate the component.
    indexed_with: Vec<usize>,
    /// Concrete struct type for this instance.
    struct_type: StructType<'ctx>,
    /// Memory pod type for this instance.
    memory_type: PodType<'ctx>,
    /// Inputs pod type for this instance.
    inputs_type: PodType<'ctx>,
}

impl<'ctx> MixedSubcmpEntry<'ctx> {
    /// Creates a new typed mixed subcomponent entry.
    pub fn new(
        instance: &MixedSubcmpInstance<'ctx>,
        memory_type: PodType<'ctx>,
        inputs_type: PodType<'ctx>,
    ) -> Self {
        Self {
            record_name: instance.record_name.clone(),
            indexed_with: instance.indexed_with.clone(),
            struct_type: instance.struct_type,
            memory_type,
            inputs_type,
        }
    }

    /// Returns the pod record name for this entry.
    pub fn record_name(&self) -> &str {
        &self.record_name
    }

    /// Returns the concrete index tuple for this entry.
    pub fn indexed_with(&self) -> &[usize] {
        &self.indexed_with
    }

    /// Returns the concrete struct type for this entry.
    pub fn struct_type(&self) -> StructType<'ctx> {
        self.struct_type
    }

    /// Returns the memory pod type for this entry.
    pub fn memory_type(&self) -> PodType<'ctx> {
        self.memory_type
    }

    /// Returns the inputs pod type for this entry.
    pub fn inputs_type(&self) -> PodType<'ctx> {
        self.inputs_type
    }
}

/// Fully typed data for a mixed subcomponent binding.
#[derive(Clone, Debug)]
pub struct MixedSubcmpLayout<'ctx> {
    /// Type of the owner struct member containing computed component instances.
    component_type: PodType<'ctx>,
    /// Type of the compute-time memory binding.
    memory_type: PodType<'ctx>,
    /// Type of the owner struct member containing component inputs.
    inputs_type: PodType<'ctx>,
    /// Per-position entries.
    entries: Vec<MixedSubcmpEntry<'ctx>>,
}

impl<'ctx> MixedSubcmpLayout<'ctx> {
    /// Creates a new mixed subcomponent layout.
    pub fn new(
        component_type: PodType<'ctx>,
        memory_type: PodType<'ctx>,
        inputs_type: PodType<'ctx>,
        entries: Vec<MixedSubcmpEntry<'ctx>>,
    ) -> Self {
        Self { component_type, memory_type, inputs_type, entries }
    }

    /// Returns the indices the entries are indexed with.
    pub fn indices(&self) -> impl IntoIterator<Item = &[usize]> {
        self.entries.iter().map(MixedSubcmpEntry::indexed_with)
    }

    /// Returns the owner struct member type containing computed component instances.
    pub fn component_type(&self) -> PodType<'ctx> {
        self.component_type
    }

    /// Returns the compute-time memory binding type.
    pub fn memory_type(&self) -> PodType<'ctx> {
        self.memory_type
    }

    /// Returns the owner struct member type containing component inputs.
    pub fn inputs_type(&self) -> PodType<'ctx> {
        self.inputs_type
    }

    /// Returns per-position entries.
    pub fn entries(&self) -> &[MixedSubcmpEntry<'ctx>] {
        &self.entries
    }
}

/// Runtime layout for a subcomponent binding.
#[derive(Clone, Debug)]
pub enum SubcmpLayout<'ctx> {
    /// Uniform scalar or array binding.
    Uniform,
    /// Mixed concrete binding.
    Mixed(MixedSubcmpLayout<'ctx>),
}

/// Template context metadata for a subcomponent binding.
#[derive(Clone, Debug)]
pub struct SubcmpBinding<'ctx> {
    /// Template used for signal declaration lookup.
    template_name: String,
    /// Compute-time memory binding type.
    memory_type: Type<'ctx>,
    /// Binding layout.
    layout: SubcmpLayout<'ctx>,
}

impl<'ctx> SubcmpBinding<'ctx> {
    /// Creates a new uniform binding.
    pub fn new_uniform(template_name: String, memory_type: Type<'ctx>) -> Self {
        Self { template_name, memory_type, layout: SubcmpLayout::Uniform }
    }

    /// Creates a new mixed binding.
    pub fn new_mixed(template_name: String, layout: MixedSubcmpLayout<'ctx>) -> Self {
        Self {
            template_name,
            memory_type: layout.memory_type().into(),
            layout: SubcmpLayout::Mixed(layout),
        }
    }

    /// Returns the template used for signal declaration lookup.
    pub fn template_name(&self) -> &str {
        &self.template_name
    }

    /// Returns the compute-time memory binding type.
    pub fn memory_type(&self) -> Type<'ctx> {
        self.memory_type
    }

    /// Returns the binding layout.
    pub fn layout(&self) -> &SubcmpLayout<'ctx> {
        &self.layout
    }
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

/// A wrapper around a subcomponent's struct type.
///
/// Can be used for obtaining information related to the subcomponent
/// like its memory pod.
#[derive(Debug)]
pub struct SubcmpType<'ctx> {
    /// Inner type of the subcomponent.
    inner: Type<'ctx>,
    /// Name of the template the subcomponent's type comes from.
    template_name: String,
}

impl<'ctx> SubcmpType<'ctx> {
    /// Creates a new subcomponent type wrapper.
    pub fn new(inner: Type<'ctx>, template_name: String) -> Self {
        Self { inner, template_name }
    }

    /// Returns the element type if the type is an [`ArrayType`]. Returns the type itself otherwise.
    fn scalar_or_inner(&self) -> Type<'ctx> {
        ArrayType::try_from(self.inner).map(|t| t.element_type()).unwrap_or(self.inner)
    }

    /// Type used to represent template parameters.
    pub fn param_type(&self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Type<'ctx> {
        codegen.felt_type().into()
    }

    /// Returns the pod type for the template parameters.
    pub fn params_pod_type(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> PodType<'ctx> {
        let param_type = self.param_type(codegen);
        // These need to be in declaration order.
        let params_records = codegen
            .program
            .get_template_data(self.template_name())
            .get_name_of_params()
            .iter()
            .map(|name| (name.as_str(), param_type))
            .collect::<Vec<_>>();

        codegen.pod_type(&params_records)
    }

    /// Returns the list of records of the "memory" comp pod of the subcomponent.
    ///
    /// That pod holds the inputs for the constructor, the component itself, and the countdown
    /// for the number of assigned inputs.
    pub fn comp_pod_records(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> [(&'static str, Type<'ctx>); 3] {
        [
            // Counts the number of inputs pending an assignment. When it reaches 0 it's safe
            // to call the corresponding `@compute` function.
            (names::COUNT, codegen.index_type()),
            // Holds the output of calling `@compute`. Before the call, this value is undefined
            // and should not be read from.
            (names::COMP, self.scalar_or_inner()),
            // Holds the affine map operands of the subcomponents, if any.
            (names::PARAMS, self.params_pod_type(codegen).into()),
        ]
    }

    /// Returns the type of the subcomponent's memory pod.
    ///
    /// That pod represents the subcomponent lifecycle during the compute function.
    /// Holds the template parameters, necessary for passing map operands if the struct type of the
    /// subcomponent requires them. The input countdown, that keeps track of how many inputs have
    /// been assigned, signaling that is safe to call the compute function if it reached 0. And the
    /// subcomponent itself, as a non-deterministic value before the call to compute and the result
    /// of said function after.
    pub fn comp_pod(&self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Type<'ctx> {
        let records = self.comp_pod_records(codegen);
        map_array_inner_type(self.inner, codegen.pod_type(&records).into())
    }

    /// Returns the name of the template the subcomponent's type comes from.
    pub fn template_name(&self) -> &str {
        &self.template_name
    }

    /// Returns the actual MLIR type of the subcomponent.
    pub fn r#type(&self) -> Type<'ctx> {
        self.inner
    }
}

/// Holds the information required for generating the IR to support subcomponents in the prologue
/// of the template's functions.
#[derive(Debug)]
pub struct SubcmpPrologueData<'ctx> {
    /// Name of the subcomponent.
    name: String,
    /// Name of the subcomponent inputs.
    name_inputs: String,
    /// Template used for signal declaration lookup.
    template_name: String,
    /// Type representing the computed subcomponent binding.
    component_type: Type<'ctx>,
    /// Type representing the inputs of the subcomponent.
    inputs: Type<'ctx>,
    /// Prologue layout.
    layout: SubcmpPrologueLayout<'ctx>,
}

/// Layout data used by the prologue.
#[derive(Debug)]
enum SubcmpPrologueLayout<'ctx> {
    /// Uniform scalar or array binding.
    Uniform(SubcmpType<'ctx>),
    /// Mixed concrete binding.
    Mixed(MixedSubcmpLayout<'ctx>),
}

impl<'ctx> SubcmpPrologueData<'ctx> {
    /// Creates a new instance.
    pub fn new(
        name: String,
        template_name: String,
        subcmp: Type<'ctx>,
        inputs: Type<'ctx>,
    ) -> Self {
        let name_inputs = names::inputs(&name);
        Self {
            name,
            name_inputs,
            template_name: template_name.clone(),
            component_type: subcmp,
            inputs,
            layout: SubcmpPrologueLayout::Uniform(SubcmpType::new(subcmp, template_name)),
        }
    }

    /// Creates a new mixed concrete instance.
    pub fn new_mixed(name: String, template_name: String, layout: MixedSubcmpLayout<'ctx>) -> Self {
        let name_inputs = names::inputs(&name);
        Self {
            name,
            name_inputs,
            template_name,
            component_type: layout.component_type().into(),
            inputs: layout.inputs_type().into(),
            layout: SubcmpPrologueLayout::Mixed(layout),
        }
    }

    /// Returns binding metadata for template lowering.
    pub fn binding(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> SubcmpBinding<'ctx> {
        match &self.layout {
            SubcmpPrologueLayout::Uniform(subcmp) => {
                SubcmpBinding::new_uniform(self.template_name.clone(), subcmp.comp_pod(codegen))
            }
            SubcmpPrologueLayout::Mixed(layout) => {
                SubcmpBinding::new_mixed(self.template_name.clone(), layout.clone())
            }
        }
    }

    /// Generates the subcomponents prologue in the constraint function.
    ///
    /// For each subcomponent reads the corresponding struct member and binds it
    /// to the subcomponent's name.
    pub fn generate_constraint_func_prologue(
        &self,
        constrain_ctx: &mut FunctionContext<'_, 'ctx, '_, '_, '_>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        subcmp_decls: &HashMap<String, SubcmpDeclInfo<'ctx>>,
    ) -> Result<()> {
        let decl = &subcmp_decls[self.name()];
        let self_ref = constrain_ctx.func.self_value_of_constrain()?;
        constrain_ctx.block_ctx.declare_name_if_not_present(self.name(), || {
            Ok(r#struct::readm(
                codegen.op_builder(),
                decl.location(),
                self.component_type,
                self_ref,
                self.name(),
            )?)
        })?;
        constrain_ctx.block_ctx.declare_name_if_not_present(self.name_inputs(), || {
            Ok(r#struct::readm(
                codegen.op_builder(),
                decl.location(),
                self.inputs,
                self_ref,
                self.name_inputs(),
            )?)
        })?;
        Ok(())
    }

    /// Generates the subcomponents prologue in the compute function.
    ///
    /// For each subcomponent creates an initializer operation and binds it
    /// to the subcomponent's name. For scalar subcomponent the initializer is a
    /// `nondet` op with the type of the subcomponent's memory pod. For array subcomponent
    /// the initializer is an array of the memory pods.
    pub fn generate_compute_func_prologue<'func, 'blk, 'val>(
        &self,
        compute_ctx: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        subcmp_decls: &HashMap<String, SubcmpDeclInfo<'ctx>>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let decl = &subcmp_decls[self.name()];
        let memory_type = self.memory_type(codegen);
        compute_ctx.block_ctx.declare_name_ensure_not_present(
            self.name(),
            match ArrayType::try_from(memory_type) {
                Ok(ty) => codegen.new_array_new_op(decl.location(), ty, ArrayCtor::Empty),
                Err(_) => nondet(decl.location(), memory_type),
            },
        )?;
        compute_ctx.block_ctx.declare_name_ensure_not_present(
            self.name_inputs(),
            match self.inputs_as::<ArrayType>() {
                Ok(ty) => codegen.new_array_new_op(decl.location(), ty, ArrayCtor::Empty),
                Err(_) => {
                    pod::new(codegen.op_builder(), decl.location(), &[], Some(self.inputs_as()?))
                }
            },
        )
    }

    /// Returns the compute-time memory type for this binding.
    fn memory_type(&self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Type<'ctx> {
        match &self.layout {
            SubcmpPrologueLayout::Uniform(subcmp) => subcmp.comp_pod(codegen),
            SubcmpPrologueLayout::Mixed(layout) => layout.memory_type().into(),
        }
    }

    /// Returns the inputs type casted into the given type.
    fn inputs_as<T: TryFrom<Type<'ctx>>>(&self) -> Result<T, <T as TryFrom<Type<'ctx>>>::Error> {
        T::try_from(self.inputs)
    }

    /// Returns the name of the subcomponent.
    pub fn name(&self) -> &str {
        &self.name
    }

    /// Returns the name of the inputs member for this subcomponent.
    pub fn name_inputs(&self) -> &str {
        &self.name_inputs
    }
}
