//! Helper types for handling subcomponents.

use crate::function::FunctionContext;
use crate::gen_context::BlockGenContext;
use crate::program_ext::ProgramInfo;
use crate::program_ext::ProgramLike;
use crate::shared::map_array_inner_type;
use crate::shared::LlzkCodegen;
use crate::shared::TmplParamsInstance;
use crate::shared::TypeSizeExpr;
use crate::template_ext::SignalDeclarations;
use anyhow::Result;
use llzk::builder::OpBuilder;
use llzk::dialect::array;
use llzk::dialect::array::ArrayCtor;
use llzk::dialect::pod;
use llzk::dialect::r#struct;
use llzk::prelude::ArrayType;
use llzk::prelude::Attribute;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::Location;
use llzk::prelude::PodType;
use llzk::prelude::RecordValue;
use llzk::prelude::StructType;
use llzk::prelude::Type;
use llzk::prelude::TypeLike as _;
use melior::ir::AttributeLike as _;
use melior::ir::Value;
use melior::StringRef;
use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::TryFrom;
use std::convert::TryFrom as _;
use std::convert::TryInto as _;

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

/// Holds the information required for generating the IR to support subcomponents in the prologue
/// of the template's functions.
#[derive(Debug)]
pub struct SubcmpPrologueData<'ast, 'ctx> {
    /// Name of the subcomponent.
    pub name: String,
    /// Type of the subcomponent.
    pub subcmp: Type<'ctx>,
    /// Type representing the inputs of the subcomponent.
    pub inputs: Type<'ctx>,
    /// Number of inputs in the subcomponent.
    pub inputs_size: TypeSizeExpr<'ctx>,
    /// Maps the params to attributes.
    pub template_params: TmplParamsInstance<'ast, 'ctx>,
}

impl<'ast, 'ctx> SubcmpPrologueData<'ast, 'ctx> {
    pub fn generate_constraint_func_prologue(
        &self,
        //compute_ctx: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        constrain_ctx: &mut FunctionContext<'_, 'ctx, '_, '_, '_>,
        op_builder: &OpBuilder<'ctx>,
        subcmp_decls: &HashMap<String, SubcmpDeclInfo<'ctx>>,
    ) -> Result<()> {
        let decl = &subcmp_decls[self.name()];
        let self_ref = constrain_ctx.func.self_value_of_constrain()?;
        let name_inputs = self.name_inputs();
        constrain_ctx.block_ctx.declare_name_if_not_present(self.name(), || {
            Ok(r#struct::readm(op_builder, decl.location(), self.subcmp, self_ref, self.name())?)
        })?;
        constrain_ctx.block_ctx.declare_name_if_not_present(&name_inputs, || {
            Ok(r#struct::readm(op_builder, decl.location(), self.inputs, self_ref, &name_inputs)?)
        })?;
        Ok(())
    }

    /// Returns the element type if the type is an [`ArrayType`]. Returns the type itself otherwise.
    fn scalar_or_inner(&self) -> Type<'ctx> {
        ArrayType::try_from(self.subcmp).map(|t| t.element_type()).unwrap_or(self.subcmp)
    }

    /// Returns the list of records of the "memory" comp pod of the subcomponent.
    ///
    /// That pod holds the inputs for the constructor, the component itself, and the countdown
    /// for the number of assigned inputs.
    pub fn comp_pod_records(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> [(&'static str, Type<'ctx>); 3] {
        let felt_type = Type::from(codegen.felt_type());
        let params_records = self
            .template_params
            .iter()
            .filter_map(|(name, attr)| attr.is_affine_map().then_some((*name, felt_type)))
            .collect::<Vec<_>>();

        [
            // Counts the number of inputs pending an assignment. When it reaches 0 it's safe
            // to call the corresponding `@compute` function.
            (names::COUNT, codegen.index_type()),
            // Holds the output of calling `@compute`. Before the call, this value is undefined
            // and should not be read from.
            (names::COMP, self.scalar_or_inner()),
            // Holds the affine map operands of the subcomponents, if any.
            (names::PARAMS, codegen.pod_type(&params_records).into()),
        ]
    }

    fn comp_pod(&self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Type<'ctx> {
        let records = self.comp_pod_records(codegen);
        map_array_inner_type(self.subcmp, codegen.pod_type(&records).into())
    }

    pub fn generate_compute_func_prologue<'func, 'blk, 'val>(
        &self,
        compute_ctx: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        //constrain_ctx: &mut FunctionContext<'_, 'ctx, '_, '_, '_>,
        op_builder: &OpBuilder<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        println!("Subcmp '{}': {self:?}", self.name);
        //let affine_map_param_count = StructType::try_from(subcmp_struct_type)?
        //    .params_vec()
        //    .into_iter()
        //    .filter(Attribute::is_affine_map)
        //    .count();

        let name_inputs = self.name_inputs();
        let comp_pod = self.comp_pod(codegen);
        // XXX: We should use some actual location here.
        let location = codegen.location_unknown();
        match ArrayType::try_from(comp_pod) {
            Ok(comp_pod) => {
                compute_ctx.block_ctx.declare_name_ensure_not_present(
                    self.name(),
                    array::new(op_builder, location, comp_pod, ArrayCtor::Empty),
                )?;
                let comp_memory = *compute_ctx.block_ctx.get_named_value(self.name())?;

                compute_ctx.gen_loop_nest_from_attrs(
                    codegen,
                    location,
                    &comp_pod.dims(),
                    |fc, indices| {
                        let comp_memory_pod =
                            fc.append_array_read(comp_memory, indices, location, None)?;

                        self.initial_records(fc, location, codegen, op_builder)?
                            .into_iter()
                            .try_for_each(|r| {
                                r.into_write_op(codegen, fc, comp_memory_pod, location)
                            })?;

                        fc.append_array_write(
                            codegen,
                            comp_memory,
                            indices,
                            location,
                            comp_memory_pod,
                            None,
                        )
                    },
                )?;
            }
            Err(_) => {
                let initial_records =
                    self.initial_records(compute_ctx, location, codegen, op_builder)?;
                compute_ctx.block_ctx.declare_name_ensure_not_present(
                    self.name(),
                    pod::new(
                        op_builder,
                        location,
                        &initial_records.into_iter().map(Into::into).collect::<Vec<_>>(),
                        Some(PodType::try_from(comp_pod)?),
                    ),
                )?
            }
        };
        compute_ctx.block_ctx.declare_name_ensure_not_present(
            &name_inputs,
            match self.inputs_as::<ArrayType>() {
                Ok(inputs) => array::new(op_builder, location, inputs, ArrayCtor::Empty),
                Err(_) => pod::new(op_builder, location, &[], Some(self.inputs_as()?)),
            },
        )
    }

    /// Returns the records that will be initialized during the prologue.
    fn initial_records<'val>(
        &self,
        //compute_ctx: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        fc: &mut BlockGenContext<'_, 'ctx, '_, 'val>,
        location: Location<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        op_builder: &OpBuilder<'ctx>,
    ) -> Result<Vec<Record<'ctx, 'val>>> {
        Ok(if self.inputs_size.is_const_zero() {
            let empty_inputs = fc.append_op_unnamed_result(pod::new(
                op_builder,
                location,
                &[],
                Some(codegen.pod_type(&[])),
            ))?;
            let instance = fc.gen_compute_call(
                self.scalar_or_inner().try_into()?,
                empty_inputs,
                location,
                codegen,
            )?;
            vec![Record(names::COMP, instance)]
        } else {
            let count_value = self.inputs_size.to_index_value(
                codegen,
                fc,
                location,
                Some(&self.template_params),
            )?;
            vec![Record(names::COUNT, count_value)]
        })
    }

    fn inputs_as<T: TryFrom<Type<'ctx>>>(&self) -> Result<T, <T as TryFrom<Type<'ctx>>>::Error> {
        T::try_from(self.inputs)
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    /// Returns the name of the inputs member for this subcomponent.
    pub fn name_inputs(&self) -> String {
        names::inputs(self.name())
    }
}

#[derive(Copy, Clone)]
struct Record<'ctx, 'val>(&'static str, Value<'ctx, 'val>);

impl<'ctx, 'val> Record<'ctx, 'val> {
    /// Appends a write operation into a pod that inserts this record.
    fn into_write_op(
        self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        fc: &mut BlockGenContext<'_, 'ctx, '_, 'val>,
        pod: Value<'ctx, '_>,
        location: Location<'ctx>,
    ) -> Result<()> {
        fc.append_op_no_result(codegen.new_pod_write_op(location, pod, self.0, self.1))
    }
}

impl<'ctx, 'val> From<Record<'ctx, 'val>> for RecordValue<'ctx, 'val> {
    fn from(value: Record<'ctx, 'val>) -> Self {
        RecordValue::new(StringRef::new(value.0), value.1)
    }
}
