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
    pub fn param_type(&self, codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>) -> Type<'ctx> {
        codegen.felt_type().into()
    }

    /// Returns the pod type for the template parameters.
    pub fn params_pod_type(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
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
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
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
    pub fn comp_pod(&self, codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>) -> Type<'ctx> {
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
    /// Type of the subcomponent.
    subcmp: SubcmpType<'ctx>,
    /// Type representing the inputs of the subcomponent.
    inputs: Type<'ctx>,
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
        Self { name, name_inputs, subcmp: SubcmpType::new(subcmp, template_name), inputs }
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
                self.subcmp.r#type(),
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
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        subcmp_decls: &HashMap<String, SubcmpDeclInfo<'ctx>>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let comp_pod = self.subcmp.comp_pod(codegen);
        let decl = &subcmp_decls[self.name()];
        compute_ctx.block_ctx.declare_name_ensure_not_present(
            self.name(),
            match ArrayType::try_from(comp_pod) {
                Ok(ty) => codegen.new_array_new_op(decl.location(), ty, ArrayCtor::Empty),
                Err(_) => nondet(decl.location(), comp_pod),
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

impl<'ctx> std::ops::Deref for SubcmpPrologueData<'ctx> {
    type Target = SubcmpType<'ctx>;

    fn deref(&self) -> &Self::Target {
        &self.subcmp
    }
}
