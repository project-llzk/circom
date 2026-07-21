//! Handles template-level LLZK code generation. The [TemplateContext] carries information about the
//! current LLZK struct being generated and some helpers related to generating code within the
//! struct. The [GenerateLLZKInTemplate] trait provides the visitor to generate LLZK IR for all
//! circom [Expression](program_structure::ast::Expression) and
//! [Statement](program_structure::ast::Statement) nodes. There are also a few helper traits like
//! [GenResult] and [Chainable] that implement some boilerplate to make the actual code generation
//! within [GenerateLLZKInTemplate] a lot simpler.

use std::{
    cell::RefCell,
    collections::{HashMap, HashSet},
    convert::{TryFrom, TryInto as _},
    rc::Rc,
};

use anyhow::{anyhow, Result};
use llzk::{
    attributes::array::AffineMapAttribute,
    dialect::{array::ArrayCtor, global, pod, r#struct},
    map_operands::MapOperandsBuilder,
    prelude::{
        ArrayType, BlockRef, FlatSymbolRefAttribute, FuncDefOpLike as _, IntegerAttribute,
        LlzkContext, LoopBoundsAttribute, MemberDefOpLike as _, PodType, RecordValue, StringRef,
        StructDefOpLike as _, StructDefOpRefMut, SymbolRefAttribute, TemplateOpLike as _,
        TemplateOpRefMut, TemplateSymbolBindingOpLike as _, Type, Value, ValueLike as _,
    },
    value_ext::{OwningValueRange, ValueRange},
};
use melior::ir::{Attribute, Location};
use num_bigint_dig::BigInt;
use program_structure::{
    ast::{AssignOp, Expression, Meta, Statement},
    error_code::ReportCode,
};

use crate::{
    function::{FunctionContext, InfoProviders},
    gen_context::{
        BlockGenContext, GenWithCircomScopeHandling, GenerateLLZKInAnyBlock, NestedBlockInfo,
    },
    lvalue::{Lvalue, Root},
    program_ext::{ProgramInfo, ProgramLike},
    shared,
    shared::{
        comp_type, map_array_inner_type, wrap_pod_records, ArrayDimExprKind, ArrayDimension,
        ExprToPolyBinding, ExprToPolyBindingOutput, LlzkCodegen, StructTemplateParamExprKind,
        StructTemplateParams,
    },
    subcmp::{names::COMP, MixedSubcmpLayout, SubcmpBinding, SubcmpInfo, SubcmpLayout, SubcmpType},
    template_ext::{SignalDeclarations, TemplateLike as _},
    write_chain::{WriteChain, WriteTarget},
};

/// Alias for `Option<T>` to make it clear what the meaning of the option is within the
/// [TemplateContext] below.
type ShouldGenerate<T> = Option<T>;

/// A pair of things, one for the "@compute" function and one for the "@constrain" function.
#[derive(Debug, Default)]
pub struct TemplateFuncPair<T> {
    /// The value for the "@compute" function.
    compute: ShouldGenerate<T>,
    /// The value for the "@constrain" function.
    constrain: ShouldGenerate<T>,
}

impl<'ctx, 'blk, 'val> TemplateFuncPair<NestedBlockInfo<'ctx, 'blk, 'val>>
where
    'ctx: 'blk,
    'blk: 'val,
{
    /// Returns a [TemplateFuncPair] with a default [NestedBlockInfo] for `compute`/`constrain`
    /// according to the respective [ShouldGenerate] value in the given [TemplateContext].
    pub fn new(template: &TemplateContext<'_, '_, '_, '_, '_, '_>) -> Self {
        Self {
            compute: template.compute.is_some().then(NestedBlockInfo::default),
            constrain: template.constrain.is_some().then(NestedBlockInfo::default),
        }
    }

    /// Returns a [TemplateFuncPair] containing just the `block` fields of `self`.
    pub fn block(&self) -> TemplateFuncPair<BlockRef<'ctx, 'blk>> {
        TemplateFuncPair {
            compute: self.compute.as_ref().map(|i| i.block),
            constrain: self.constrain.as_ref().map(|i| i.block),
        }
    }
}

/// Stores refs to the current struct and its associated functions while generating LLZK IR for a
/// template. Implemented as a lightweight wrapper around several mutable references to allow
/// derived versions for witness-only or constraint-only to be created cheaply.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'str: lifetime of the generated `StructDefOp`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    /// Current LLZK `TemplateOp`
    template_def: TemplateOpRefMut<'ctx, 'str>,
    /// Current LLZK `StructDefOp` within the `TemplateOp`
    struct_def: StructDefOpRefMut<'ctx, 'str>,
    /// Codegen refs for the "@compute" function within `struct_def`
    compute: ShouldGenerate<Rc<RefCell<FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>>>>,
    /// Codegen refs for the "@constrain" function within `struct_def`
    constrain: ShouldGenerate<Rc<RefCell<FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>>>>,
    /// Map of subcomponent names to their binding metadata.
    subcmps: &'str HashMap<String, SubcmpBinding<'ctx>>,
    /// Tracks for what component signals we have created their `struct.writem` op already.
    written_signals: Rc<RefCell<HashSet<String>>>,
    /// Pre-computed LLZK types for circom `var` declarations, keyed by var name. Populated from
    /// [crate::module::DeclarationInfo] when generating `poly.expr` bodies for templates so that
    /// dimension expressions referencing other vars do not trigger recursive code generation.
    ///
    /// Note: this is also stored in `compute` and/or `constrain` but it made several things more
    /// straightforward to just store it here as well since it's just a reference.
    var_decl_types: &'decls HashMap<String, Type<'ctx>>,
}

impl<'decls, 'ctx, 'str, 'func, 'blk, 'val> TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val> {
    /// Creates a new [TemplateContext].
    #[inline]
    pub fn new(
        template_def: TemplateOpRefMut<'ctx, 'str>,
        struct_def: StructDefOpRefMut<'ctx, 'str>,
        compute: FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
        constrain: FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
        subcmps: &'str HashMap<String, SubcmpBinding<'ctx>>,
        var_decl_types: &'decls HashMap<String, Type<'ctx>>,
    ) -> TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            template_def,
            struct_def,
            compute: Some(Rc::new(RefCell::new(compute))),
            constrain: Some(Rc::new(RefCell::new(constrain))),
            subcmps,
            written_signals: Default::default(),
            var_decl_types,
        }
    }

    /// Creates a new [TemplateContext] that will only generate within the "@compute" function.
    #[inline]
    pub fn compute_only(&self) -> TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            template_def: self.template_def,
            struct_def: self.struct_def,
            compute: self.compute.as_ref().map(Rc::clone),
            constrain: None,
            subcmps: self.subcmps,
            written_signals: self.written_signals.clone(),
            var_decl_types: self.var_decl_types,
        }
    }

    /// Creates a new [TemplateContext] that will only generate within the "@constrain" function.
    #[inline]
    pub fn constrain_only(&self) -> TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            template_def: self.template_def,
            struct_def: self.struct_def,
            compute: None,
            constrain: self.constrain.as_ref().map(Rc::clone),
            subcmps: self.subcmps,
            written_signals: self.written_signals.clone(),
            var_decl_types: self.var_decl_types,
        }
    }

    /// Returns true if we already generated a `struct.writem` op for the given signal.
    pub fn signal_already_written(&self, name: &str) -> bool {
        self.written_signals.borrow().contains(name)
    }

    /// Marks the given signal as written.
    pub fn mark_signal_as_written(&self, name: String) {
        self.written_signals.borrow_mut().insert(name);
    }

    /// Declares a local name in the generated compute/constrain functions by reading a module
    /// global. Used by concrete VCP preamble generation for deduplicated array constants.
    pub(crate) fn declare_name_from_global_read(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        name: &str,
        global_name: &str,
        ty: Type<'ctx>,
        location: Location<'ctx>,
    ) -> Result<()> {
        let global_ref = || SymbolRefAttribute::new_from_str(codegen.context, global_name, &[]);
        if let Some(fc) = self.compute.as_ref() {
            fc.borrow_mut().block_ctx.declare_value_if_not_present(
                name,
                |builder| {
                    shared::single_result_as_value(global::read(
                        builder,
                        location,
                        global_ref(),
                        ty,
                    ))
                },
                codegen.context,
            )?;
        }
        if let Some(fc) = self.constrain.as_ref() {
            fc.borrow_mut().block_ctx.declare_value_if_not_present(
                name,
                |builder| {
                    shared::single_result_as_value(global::read(
                        builder,
                        location,
                        global_ref(),
                        ty,
                    ))
                },
                codegen.context,
            )?;
        }
        Ok(())
    }

    /// Get the type of the struct field with the given name.
    /// Errors if the field does not exist within the struct.
    pub fn get_signal_type(&self, name: &str) -> Result<Type<'ctx>> {
        Ok(self
            .struct_def
            .find_member_def(name)
            .ok_or_else(|| anyhow!("no field '{name}' in struct"))?
            .member_type())
    }

    /// Part of the finalization procedure that emits the pending operations in the queue.
    fn finalize_queue(self, codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>) -> Result<Self> {
        self.and_then_same::<_, GenResultUnit>(|fc, _| {
            if !fc.block_ctx.is_only_root() {
                anyhow::bail!("Template generation reached final step with more than one scope");
            }
            fc.block_ctx.append_queue(codegen.context)?;
            Ok(())
        })?;
        Ok(self)
    }

    /// Part of the finalization procedure that emits the operations related to the subcomponents.
    ///
    /// For `@compute` emits the write operations for the results of calling the `@compute`
    /// functions of the subcomponents and the values of the inputs.
    ///
    /// For `@constrain` emits calls to `@constrain` for each subcomponent.
    fn finalize_subcmps(self, codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>) -> Result<Self>
    where
        // Required by `loop_nest`
        'val: 'blk,
    {
        let mut subcmps: Vec<_> = self.subcmps.keys().collect();
        if codegen.config.stabilize {
            // Sort by circom subcomponent names to ensure a stable order of operations.
            subcmps.sort_by(Ord::cmp);
        }
        let location = codegen.location_unknown();
        self.and_then::<_, _, GenResultUnit>(|fc, _| {
                // Write the subcomponent declarations to self.
                let self_value = fc.func.self_value_of_compute()?;
                subcmps.iter().try_for_each(|name| {
                    let binding = &self.subcmps[*name];
                    // Write the inputs of the subcomponent.
                    let name_inputs = crate::subcmp::names::inputs(name);
                    let name_inputs_val = *fc.block_ctx.get_named_value(&name_inputs)?;
                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    let write = r#struct::writem(
                        &builder,
                        location,
                        self_value,
                        &name_inputs,
                        name_inputs_val,
                    )?;
                    fc.append_op_ref_no_result(write)?;

                    // This value is the memory SSA value. We need to extract the component from
                    // it.
                    let mem = *fc.block_ctx.get_named_value(name)?;
                    let value = match binding.layout() {
                        SubcmpLayout::Uniform => type_switch! { ty = mem.r#type(),
                            ArrayType => {
                                // Copy the components into an array of the same dimensions.
                                let struct_type = comp_type(ty.element_type().try_into()?)?;

                                let builder = fc.builder_at_current_insertion_point(codegen.context);
                                let comp_array = fc.append_op_ref_unnamed_result(codegen.new_array_new_op(
                                    &builder,
                                    location,
                                    map_array_inner_type(ty.into(), struct_type).try_into()?,
                                    ArrayCtor::Empty
                                ))?;

                                fc.gen_loop_nest_from_attrs(codegen, codegen.location_unknown(), &ty.dims(), |fc, indices| {
                                    let comp_memory = fc.append_array_read(
                                        codegen,
                                        mem,
                                        indices,
                                        location,
                                        None
                                    )?;
                                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                                    let read = pod::read(
                                        &builder,
                                        location,
                                        comp_memory,
                                        COMP,
                                        struct_type
                                    );
                                    let comp_instance = fc.append_op_ref_unnamed_result(read)?;
                                    fc.append_array_write(
                                        codegen,
                                        comp_array,
                                        indices,
                                        location,
                                        comp_instance,
                                        None
                                    )
                                })?;

                                comp_array
                            }
                            PodType => {
                                let builder = fc.builder_at_current_insertion_point(codegen.context);
                                let read = pod::read(
                                    &builder,
                                    location,
                                    mem,
                                    COMP,
                                    comp_type(ty)?
                                );
                                fc.append_op_ref_unnamed_result(read)?
                            }
                        },
                        SubcmpLayout::Mixed(layout) => {
                            let records = layout.entries().iter().map(|entry| {
                                let builder = fc.builder_at_current_insertion_point(codegen.context);
                                let read = pod::read(
                                    &builder,
                                    location,
                                    mem,
                                    entry.record_name(),
                                    entry.memory_type().into(),
                                );
                                let comp_memory = fc.append_op_ref_unnamed_result(read)?;
                                let builder = fc.builder_at_current_insertion_point(codegen.context);
                                let read = pod::read(
                                    &builder,
                                    location,
                                    comp_memory,
                                    COMP,
                                    entry.struct_type().into(),
                                );
                                let comp_instance = fc.append_op_ref_unnamed_result(read)?;
                                Ok(RecordValue::new(
                                    StringRef::new(entry.record_name()),
                                    comp_instance,
                                ))
                            }).collect::<Result<Vec<_>>>()?;
                            let builder = fc.builder_at_current_insertion_point(codegen.context);
                            fc.append_op_ref_unnamed_result(pod::new(
                                &builder,
                                location,
                                &records,
                                Some(layout.component_type()),
                            ))?
                        }
                    };

                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    let write = r#struct::writem(
                        &builder,
                        location,
                        self_value,
                        name,
                        value,
                    )?;
                    fc.append_op_ref_no_result(write)

                })

        }, |fc, _| {
                subcmps.iter().try_for_each(|name| {
                    let binding = &self.subcmps[*name];
                    // Read the subcomponent
                    let subcmp = *fc.block_ctx.get_named_value(name)?;

                    // Read the subcomponent inputs. The pod records are in declaration order,
                    // which matches the order of the `@constrain` function.
                    let inputs = *fc.block_ctx.get_named_value(&crate::subcmp::names::inputs(name))?;
                    // Call `@constrain`
                    match binding.layout() {
                        SubcmpLayout::Uniform => type_switch! { inputs_type = inputs.r#type(),
                            ArrayType => {
                                let dims = inputs_type.dims();
                                let subcmp_type = ArrayType::try_from(subcmp.r#type())?;
                                assert_eq!(dims, subcmp_type.dims());

                                fc.gen_loop_nest_from_attrs(codegen, location, &dims, |fc, indices| {
                                    let subcmp_instance = fc.append_array_read(
                                        codegen,
                                        subcmp,
                                        indices,
                                        location,
                                        None
                                    )?;
                                    let subcmp_inputs = fc.append_array_read(
                                        codegen,
                                        inputs,
                                        indices,
                                        location,
                                        None
                                    )?;
                                    fc.gen_constrain_call(
                                        subcmp_instance,
                                        subcmp_inputs,
                                        location,
                                        codegen
                                    )
                                })
                            }
                            PodType as _ => fc.gen_constrain_call(subcmp, inputs,  location, codegen),
                        },
                        SubcmpLayout::Mixed(layout) => {
                            layout.entries().iter().try_for_each(|entry| {
                                let builder = fc.builder_at_current_insertion_point(codegen.context);
                                let read = pod::read(
                                    &builder,
                                    location,
                                    subcmp,
                                    entry.record_name(),
                                    entry.struct_type().into(),
                                );
                                let subcmp_instance = fc.append_op_ref_unnamed_result(read)?;
                                let builder = fc.builder_at_current_insertion_point(codegen.context);
                                let read = pod::read(
                                    &builder,
                                    location,
                                    inputs,
                                    entry.record_name(),
                                    entry.inputs_type().into(),
                                );
                                let subcmp_inputs = fc.append_op_ref_unnamed_result(read)?;
                                fc.gen_constrain_call(
                                    subcmp_instance,
                                    subcmp_inputs,
                                    location,
                                    codegen,
                                )
                            })
                        }
                    }
                })
        })?;
        Ok(self)
    }

    /// Finalizes the context by emitting the final write operations that write subcomponent
    /// declarations to the declaring component.
    pub fn finalize(self, codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>) -> Result<()>
    where
        // Required by `finalize_subcmps`
        'val: 'blk,
    {
        self.finalize_subcmps(codegen)?
            .finalize_queue(codegen)?
            .and_then_same(|fc, _| fc.finalize(codegen))
    }

    /// Returns the real type of the subcomponent, which may be a more general version
    /// than the one returned by the IR generation for constructor calls.
    fn get_subcmp_type(&self, var: &str) -> Result<Type<'ctx>> {
        Ok(self
            .subcmps
            .get(var)
            .ok_or_else(|| anyhow!("subcomponent '{var}' not found"))?
            .memory_type())
    }
}

impl<'ctx> SubcmpInfo<'ctx> for TemplateContext<'_, 'ctx, '_, '_, '_, '_> {
    fn is_subcmp(&self, var: &str) -> bool {
        self.subcmps.contains_key(var)
    }

    fn mixed_subcmp_record_for_indices<'a>(
        &'a self,
        var: &str,
        indices: &[usize],
    ) -> Option<&'a str> {
        let binding = self.subcmps.get(var)?;
        let SubcmpLayout::Mixed(layout) = binding.layout() else {
            return None;
        };
        layout
            .entries()
            .iter()
            .find_map(|entry| (entry.indexed_with() == indices).then(|| entry.record_name()))
    }

    fn subcmp_info<'i>(
        &self,
        var: &str,
        info: &'i dyn ProgramInfo,
    ) -> Result<&'i dyn SignalDeclarations> {
        let binding =
            self.subcmps.get(var).ok_or_else(|| anyhow!("subcomponent '{var}' not found"))?;
        info.find_template(binding.template_name())
    }

    fn mixed_subcmp_info(&self, var: &str) -> Result<&MixedSubcmpLayout<'ctx>> {
        let binding = self
            .subcmps
            .get(var)
            .ok_or_else(|| anyhow::anyhow!("subcomponent '{var}' not found"))?;
        let SubcmpLayout::Mixed(layout) = binding.layout() else {
            anyhow::bail!("subcomponent '{var}' is not a mixed subcomponent");
        };
        Ok(layout)
    }
}

/// The [TemplateContext] must deal with the block context stack in both functions for circom
/// scope handling.
///
/// Note: The [GenWithCircomScopeHandling] trait requires mutable references in several places to
/// support `gen_llzk_in_function()` where the [FunctionContext] is passed as a mutable reference.
/// However, the [TemplateContext] instead uses internal mutability and is passed as an immutable
/// reference to the `gen_llzk_in_template()` functions. Thus, this trait cannot be implemented for
/// `TemplateContext` and is instead implemented for `&TemplateContext` which means its functions
/// must be called via a `&mut &TemplateContext` reference.
impl<'ctx, 'str, 'func, 'blk, 'val> GenWithCircomScopeHandling<'ctx, 'func, 'blk, 'val>
    for &TemplateContext<'_, 'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type BlockType = TemplateFuncPair<BlockRef<'ctx, 'blk>>;
    type HandlerDataType = TemplateFuncPair<NestedBlockInfo<'ctx, 'blk, 'val>>;

    fn stack_top(&self) -> Self::BlockType {
        TemplateFuncPair {
            compute: self.compute.as_ref().map(|rc| *rc.borrow().block_ctx.top_block()),
            constrain: self.constrain.as_ref().map(|rc| *rc.borrow().block_ctx.top_block()),
        }
    }

    fn stack_push(&mut self, block: Self::BlockType) {
        if let Some(rc) = self.compute.as_ref() {
            rc.borrow_mut().block_ctx.push(block.compute.unwrap())
        }
        if let Some(rc) = self.constrain.as_ref() {
            rc.borrow_mut().block_ctx.push(block.constrain.unwrap())
        }
    }

    fn stack_pop<H>(
        &mut self,
        context: &'ctx LlzkContext,
        overwrite_handler: H,
        overwrite_data: &mut Self::HandlerDataType,
    ) -> Result<()>
    where
        H: Fn(
            &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
            &mut NestedBlockInfo<'ctx, 'blk, 'val>,
            HashMap<String, Value<'ctx, 'val>>,
        ) -> Result<()>,
    {
        // Note: even when `self.X` is Some, `overwrite_data.X` may be None because of
        // `gen_in_given_block_with_new_circom_scope_and_merge_overwrites()` using
        // `HandlerDataType::default()`. The overwrite handler in that function ignores the
        // `NestedBlockInfo` passed to it so just insert a default `NestedBlockInfo`.
        if let Some(rc) = self.compute.as_ref() {
            let mut fc = rc.borrow_mut();
            let popped = fc.block_ctx.pop(context)?;
            overwrite_handler(
                &mut fc,
                overwrite_data.compute.get_or_insert_with(NestedBlockInfo::default),
                popped,
            )?;
        }
        if let Some(rc) = self.constrain.as_ref() {
            let mut fc = rc.borrow_mut();
            let popped = fc.block_ctx.pop(context)?;
            overwrite_handler(
                &mut fc,
                overwrite_data.constrain.get_or_insert_with(NestedBlockInfo::default),
                popped,
            )?;
        }
        Ok(())
    }
}

/// For both the "@compute" and "@constrain" functions, holds the result (SSA Value or list thereof,
/// per the type aliases below) that comes from generating LLZK for a circom Expression within a
/// template.
#[derive(Debug)]
pub struct GenResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    /// Reference to the template context in which the expression was generated.
    template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
    /// Result for the "@compute" function.
    compute_res: ShouldGenerate<ResultType>,
    /// Result for the "@constrain" function.
    constrain_res: ShouldGenerate<ResultType>,
}

/// Alias for [GenResult] containing a single SSA Value result.
type GenResultSingleVal<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r> =
    GenResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, Value<'ctx, 'val>>;

/// Alias for [GenResult] containing a list of SSA Value results.
type GenResultMultiVal<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r> =
    GenResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, Vec<Value<'ctx, 'val>>>;

/// Alias for [GenResult] containing the unit type (i.e. nothing).
type GenResultUnit<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r> =
    GenResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, ()>;

/// This trait abstracts over the output type of [Chainable::and_then] to allow a single
/// implementation of that function to produce different result types depending on the callback
/// function type provided.
trait ChainResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r> {
    /// Output type of the generator callback functions.
    type HandlerOutput;

    /// Combines results from the "@compute" and "@constrain" generator functions into the final
    /// result of [Chainable::and_then].
    fn produce(
        template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
        compute_res: ShouldGenerate<Self::HandlerOutput>,
        constrain_res: ShouldGenerate<Self::HandlerOutput>,
    ) -> Self;
}

/// Support [Chainable::and_then] producing a [GenResult]. This allows for chaining another
/// generator function on this result whose input is `ResultType`.
impl<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType>
    ChainResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
    for GenResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerOutput = ResultType;

    fn produce(
        template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
        compute_res: ShouldGenerate<Self::HandlerOutput>,
        constrain_res: ShouldGenerate<Self::HandlerOutput>,
    ) -> Self {
        GenResult::<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType> {
            template,
            compute_res,
            constrain_res,
        }
    }
}

/// Support [Chainable::and_then] producing `()` which can be used when nothing further is generated
/// from the result and there is no [Value] available to return within the generator function.
impl<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
    ChainResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r> for ()
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerOutput = ();

    fn produce(
        _: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
        _: ShouldGenerate<Self::HandlerOutput>,
        _: ShouldGenerate<Self::HandlerOutput>,
    ) -> Self {
    }
}

/// This trait provides a clean interface for chaining multiple code generation steps. It abstracts
/// away most of the complexity (unwrapping, is_some assertions, etc.) that result from
/// [GenResult] containing optional results for both "@compute" and "@constrain" functions.
trait Chainable<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    /// Input type of the generator callback functions.
    type HandlerInput;

    /// Applies the compute and constrain generator functions to the current result, producing
    /// a new [ChainResult].
    fn and_then<F1, F2, CR: ChainResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        self,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>;

    /// Delegates to [Self::and_then] with the same handler for both compute and constrain.
    #[inline]
    fn and_then_same<F, CR: ChainResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        self,
        handle: F,
    ) -> Result<CR>
    where
        Self: Sized,
        F: Fn(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
    {
        self.and_then::<&F, &F, CR>(&handle, &handle)
    }
}

impl<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
    GenResultMultiVal<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    /// Create an empty [GenResultMultiVal] (i.e. an [GenResult] where the result
    /// is a vector of SSA Values).
    #[inline]
    fn new(template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>) -> Self {
        GenResult {
            template,
            // This construction ensures that the result vectors are only created
            // if the corresponding template functions "ShouldGenerate".
            compute_res: template.compute.as_ref().map(|_| Vec::new()),
            constrain_res: template.constrain.as_ref().map(|_| Vec::new()),
        }
    }

    /// Create an [GenResultMultiVal] populated by generating LLZK for each [Expression] given.
    #[inline]
    fn gen_exprs<'ast, I>(
        template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        exprs: I,
    ) -> Result<Self>
    where
        I: IntoIterator<Item = &'ast Expression>,
    {
        let mut result = Self::new(template);
        for e in exprs {
            let r = e.gen_llzk_in_template(codegen, template)?;
            // Note: `unwrap()` is safe so long as the contract is followed that
            // `self.X_res` is None if and only if `self.template.X` is also None
            // since these all use the same template instance.
            if let Some(v) = result.compute_res.as_mut() {
                v.push(r.compute_res.unwrap())
            }
            if let Some(v) = result.constrain_res.as_mut() {
                v.push(r.constrain_res.unwrap())
            }
        }
        Ok(result)
    }
}

/// Implementation of [Chainable] for any [GenResult].
impl<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, T>
    Chainable<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
    for GenResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r, T>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerInput = T;

    fn and_then<F1, F2, CR: ChainResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        self,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
    {
        let template = self.template;
        let compute_res: ShouldGenerate<CR::HandlerOutput> = self
            .compute_res
            .map(|v| {
                // Note: `unwrap()` is safe so long as the contract is followed that
                // `self.X_res` is None if and only if `self.template.X` is also None.
                gen_compute(&mut template.compute.as_ref().unwrap().borrow_mut(), v)
            })
            .transpose()?;
        let constrain_res: ShouldGenerate<CR::HandlerOutput> = self
            .constrain_res
            .map(|v| {
                // Note: `unwrap()` is safe so long as the contract is followed that
                // `self.X_res` is None if and only if `self.template.X` is also None.
                gen_constrain(&mut template.constrain.as_ref().unwrap().borrow_mut(), v)
            })
            .transpose()?;
        Ok(CR::produce(template, compute_res, constrain_res))
    }
}

/// Implementation of [Chainable] for a [TemplateContext]. Useful when there is no initial
/// [GenResult] to chain onto.
impl<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r> Chainable<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
    for &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerInput = ();

    fn and_then<F1, F2, CR: ChainResult<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        self,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
    {
        let compute_res: ShouldGenerate<CR::HandlerOutput> =
            self.compute.as_ref().map(|fc| gen_compute(&mut fc.borrow_mut(), ())).transpose()?;
        let constrain_res: ShouldGenerate<CR::HandlerOutput> = self
            .constrain
            .as_ref()
            .map(|fc| gen_constrain(&mut fc.borrow_mut(), ()))
            .transpose()?;
        Ok(CR::produce(self, compute_res, constrain_res))
    }
}

impl<'decls, 'ctx, 'func, 'blk, 'val, 'str> ExprToPolyBinding<'ctx, 'val>
    for TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    fn get_var_decl_types(&self) -> &HashMap<String, Type<'ctx>> {
        self.var_decl_types
    }

    fn poly_template_binding_names(
        &self,
    ) -> impl IntoIterator<Item = (String, Option<Type<'ctx>>)> {
        self.template_def
            .const_binding_ops()
            .into_iter()
            .map(|binding| (binding.sym_name().to_owned(), binding.type_opt()))
    }

    fn get_poly_binding<K: crate::shared::ExprToPolyBindingKind<'ctx, 'val>>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ExprToPolyBindingOutput<'ctx, 'val, K>> {
        // First try to compute statically, falling back to literal computation if all values are
        // not compile-time constants or if the final result does not properly convert to i64.
        if let Some(integer) = shared::try_compute_as_i64(expr, codegen.prime())? {
            ExprToPolyBindingOutput::<K>::new(codegen.index_attr(integer).into(), &[])
        } else {
            match expr {
                Expression::Number(_, _) => {
                    let expr_name = K::expr_name(expr);
                    if self.template_def.has_const_expr_named(&expr_name) {
                        // Return the const expr representing the constant value.
                        ExprToPolyBindingOutput::<K>::new(codegen.flat_sym(expr_name).into(), &[])
                    } else {
                        // Generate it otherwise.
                        self.gen_template_poly_expr::<K>(codegen, expr)
                    }
                }
                Expression::Variable { name, access, .. } if access.is_empty() => {
                    // Grab the template symbol binding name if it exists (first try `poly.param`
                    // name then try `poly.expr` name). Otherwise, defer to `BlockGenContext`.
                    if self.template_def.has_const_param_named(name) {
                        ExprToPolyBindingOutput::<K>::new(codegen.flat_sym(name).into(), &[])
                    } else {
                        let expr_name = K::expr_name(expr);
                        if self.template_def.has_const_expr_named(&expr_name) {
                            ExprToPolyBindingOutput::<K>::new(
                                codegen.flat_sym(expr_name).into(),
                                &[],
                            )
                        } else {
                            // Return an identity affine map instead.
                            ExprToPolyBindingOutput::<K>::new(
                                AffineMapAttribute::identity(codegen.context, 1).into(),
                                &[],
                            )
                        }
                    }
                }
                // Variable case with non-empty `access`
                Expression::Variable { .. }
                | Expression::InlineSwitchOp { .. }
                | Expression::PrefixOp { .. }
                | Expression::InfixOp { .. }
                | Expression::Call { .. } => {
                    let expr_name = K::expr_name(expr);
                    if self.template_def.has_const_expr_named(&expr_name) {
                        // Return the const expr representing the constant value.
                        ExprToPolyBindingOutput::<K>::new(codegen.flat_sym(expr_name).into(), &[])
                    } else {
                        // Generate it otherwise.
                        self.gen_template_poly_expr::<K>(codegen, expr)
                    }
                }

                // The remaining cases do not produce a scalar value.
                // i.e. ParallelOp, ArrayInLine, UniformArray, BusCall, AnonymousComp, Tuple
                // Give the same error that the circom type checker gives. The type checker ran
                // earlier so this should technically be unreachable.
                _ => {
                    unreachable!("Array indexes and lengths must produce a scalar value")
                }
            }
        }
    }
}

/// A trait to generate LLZK IR from the body of a circom template.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'str: lifetime of the generated `StructDefOp`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
pub trait GenerateLLZKInTemplate<'decls, 'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'decls,
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Output type of the generator function. [Statement] nodes do not produce a value so this
    /// should be the unit type whereas [Expression] nodes produce a Value.
    type Output<'r>
    where
        'decls: 'r,
        'val: 'r,
        'val: 'blk;

    /// Generates LLZK IR from [Statement] and [Expression] nodes in a circom template.
    fn gen_llzk_in_template<'r>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r;
}

impl<'decls, 'ctx, 'str, 'func, 'blk, 'val>
    GenerateLLZKInTemplate<'decls, 'ctx, 'str, 'func, 'blk, 'val> for [Statement]
where
    'ctx: 'decls,
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    type Output<'r>
        = ()
    where
        'decls: 'r,
        'val: 'r;

    fn gen_llzk_in_template<'r>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r,
    {
        for s in self {
            s.gen_llzk_in_template(codegen, template)?;
            // circom allows unreachable code after a return but it is not processed
            // (e.g. `assert(1 == 0)` after a return does not cause an error as it normally
            // would) so replicate the same behavior here by stopping processing after a
            // return (which is also what MLIR expects, no code after a terminator op).
            if matches!(s, Statement::Return { .. }) {
                break;
            }
        }
        Ok(())
    }
}

/// Generate LLZK code for a circom [Statement::IfThenElse].
fn gen_if_then_else<'ctx, 'str, 'func, 'blk, 'val, 'r>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    template: &'r TemplateContext<'_, 'ctx, 'str, 'func, 'blk, 'val>,
    meta: &Meta,
    cond: &Expression,
    if_case: &Statement,
    else_case: &Option<Box<Statement>>,
) -> Result<()>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    let mut template = template; // satisfy the &mut in `GenWithCircomScopeHandling`

    // Initially, generate the blocks for the 'then' and 'else' cases naively.
    let mut then_info = TemplateFuncPair::new(template);
    template.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        codegen.context,
        then_info.block(),
        |template| if_case.gen_llzk_in_template(codegen, template),
        &mut then_info,
    )?;
    let mut else_info = TemplateFuncPair::new(template);
    if let Some(else_case) = else_case {
        template.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
            codegen.context,
            else_info.block(),
            |template| else_case.gen_llzk_in_template(codegen, template),
            &mut else_info,
        )?;
    }

    // Generate LLZK for the condition and create a GenResult that encapsulates the condition's
    // `GenResultSingleVal` along with the `NestedBlockInfo` for both blocks.
    let blocks_and_cond = {
        let cond_result = cond.gen_llzk_in_template(codegen, template)?;
        let t_compute = then_info.compute;
        let t_constrain = then_info.constrain;
        let e_compute = else_info.compute;
        let e_constrain = else_info.constrain;
        // The unwraps are safe since `then_info` and `else_info` were created from
        // the same `TemplateContext` used for `map()` below.
        GenResult {
            template,
            compute_res: template.compute.as_ref().map(|_| {
                (t_compute.unwrap(), e_compute.unwrap(), cond_result.compute_res.unwrap())
            }),
            constrain_res: template.constrain.as_ref().map(|_| {
                (t_constrain.unwrap(), e_constrain.unwrap(), cond_result.constrain_res.unwrap())
            }),
        }
    };
    // Generate the actual LLZK `scf.if` operations in both functions.
    blocks_and_cond.and_then_same(|fc, (then_info, else_info, condition)| {
        fc.gen_scf_if_with_var_overwrites(
            codegen,
            codegen.location_from_meta(meta),
            condition,
            then_info,
            else_info,
        )
    })
}

/// Generate LLZK code for a circom [Statement::While].
fn gen_while<'ctx, 'str, 'func, 'blk, 'val, 'r>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    template: &'r TemplateContext<'_, 'ctx, 'str, 'func, 'blk, 'val>,
    meta: &Meta,
    cond: &Expression,
    body_stmt: &Statement,
    loop_bounds: Option<LoopBoundsAttribute<'ctx>>,
) -> Result<()>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    let mut template = template; // satisfy the &mut in `GenWithCircomScopeHandling`

    // Generate the loop condition (i.e. "before") and body (i.e. "after") blocks naively.
    let mut loop_cond_info = TemplateFuncPair::new(template);
    let cond_result = template.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        codegen.context,
        loop_cond_info.block(),
        |template| cond.gen_llzk_in_template(codegen, template),
        &mut loop_cond_info,
    )?;
    let mut loop_body_info = TemplateFuncPair::new(template);
    template.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        codegen.context,
        loop_body_info.block(),
        |template| body_stmt.gen_llzk_in_template(codegen, template),
        &mut loop_body_info,
    )?;

    // Create a GenResult that encapsulates both `loop_body_info` and `loop_cond_info` and
    // then call the function to generate the `scf.while` loop in both functions.
    let cond_and_body = {
        let r_compute = cond_result.compute_res;
        let r_constrain = cond_result.constrain_res;
        let c_compute = loop_cond_info.compute;
        let c_constrain = loop_cond_info.constrain;
        let b_compute = loop_body_info.compute;
        let b_constrain = loop_body_info.constrain;
        // The unwraps are safe since these GenResult and TemplateFuncPair instances
        // were created from the same `TemplateContext` used for `map()` below.
        GenResult {
            template,
            compute_res: template
                .compute
                .as_ref()
                .map(|_| (r_compute.unwrap(), c_compute.unwrap(), b_compute.unwrap())),
            constrain_res: template
                .constrain
                .as_ref()
                .map(|_| (r_constrain.unwrap(), c_constrain.unwrap(), b_constrain.unwrap())),
        }
    };
    cond_and_body.and_then_same(|fc, (condition, loop_cond_info, loop_body_info)| {
        fc.gen_scf_while(
            codegen,
            codegen.location_from_meta(meta),
            condition,
            loop_cond_info,
            loop_body_info,
            loop_bounds,
        )
        .map(drop) // ignore the bool result
    })
}

/// Generate LLZK code for a circom [Statement::InitializationBlock].
/// This is needed to support the `try_for_loop_heuristic` macro.
#[inline]
fn gen_init_block<'ctx, 'str, 'func, 'blk, 'val, 'r>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    template: &'r TemplateContext<'_, 'ctx, 'str, 'func, 'blk, 'val>,
    initializations: &[Statement],
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    initializations.gen_llzk_in_template(codegen, template)
}

impl<'decls, 'ctx, 'str, 'func, 'blk, 'val>
    GenerateLLZKInTemplate<'decls, 'ctx, 'str, 'func, 'blk, 'val> for Statement
where
    'ctx: 'decls,
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    type Output<'r>
        = ()
    where
        'decls: 'r,
        'val: 'r;

    fn gen_llzk_in_template<'r>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r,
    {
        let _guard = codegen.trace_statement(self);
        match self {
            Statement::InitializationBlock { initializations, .. } => {
                gen_init_block(codegen, template, initializations)
            }
            Statement::Declaration { meta, name, dimensions, .. } => {
                template.and_then_same(|fc, _| {
                    if !template.is_subcmp(name) {
                        return fc.gen_declaration(codegen, meta, name, dimensions);
                    }
                    Ok(())
                })
            }
            Statement::Block { meta, stmts } => {
                let mut template = template; // satisfy the &mut in `GenWithCircomScopeHandling`
                template.gen_in_current_block_with_new_circom_scope_and_merge_overwrites(
                    codegen.context,
                    |template| {
                        try_for_loop_heuristic!(codegen, template, meta, stmts);
                        // Fallback to standard block handling.
                        stmts.gen_llzk_in_template(codegen, template)
                    },
                )
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                // Since there's no simple assignment in LLZK, just update the mapped Value
                // which essentially propagates the assignment.
                match op {
                    AssignOp::AssignVar => {
                        if access.is_empty() {
                            rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                |fc, mut val| {
                                    // Unify-cast the value if the variable is a subcomponent.
                                    if template.is_subcmp(var) {
                                        let subcmp_type = template.get_subcmp_type(var)?;

                                        if val.r#type() != subcmp_type {
                                            val = fc.unifiable_cast(
                                                codegen,
                                                codegen.location_from_meta(meta),
                                                val,
                                                template.get_subcmp_type(var)?,
                                            )?;
                                        }
                                    };

                                    fc.handle_simple_assignment(codegen, meta, var, val)
                                },
                                |fc, val| {
                                    // Ignore subcmp vars in the constraint function since they are
                                    // handled separately in the prologue and epilogue.
                                    if !template.is_subcmp(var) {
                                        fc.handle_simple_assignment(codegen, meta, var, val)?;
                                    }
                                    Ok(())
                                },
                            )
                        } else {
                            let location = codegen.location_from_meta(meta);
                            rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                |fc, val| {
                                    WriteChain::new(var, Root::Var, access).write(
                                        val,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        location,
                                        template,
                                        template,
                                    )
                                },
                                |fc, val| {
                                    WriteChain::new(var, Root::Var, access).write(
                                        val,
                                        WriteTarget::Constrain,
                                        codegen,
                                        fc,
                                        location,
                                        template,
                                        template,
                                    )
                                },
                            )
                        }
                    }
                    AssignOp::AssignSignal => {
                        match &access[..] {
                            [] => {
                                // The `<--` operator is witness generation only so code for the RHS
                                // expression should only be generated in the compute function.
                                // The constrain function just reads that field from "self" struct.
                                // However, we already inserted these reads at the beginning of the
                                // constrain function in `gen_template_llzk`.
                                let signal_type = template.get_signal_type(var)?;
                                rhe.gen_llzk_in_template(codegen, &template.compute_only())?
                                    .and_then_same(|fc, val| {
                                        let location = codegen.location_from_meta(meta);
                                        // Cast value to signal type if needed.
                                        let value = fc.cast_to_expected_type_if_needed(
                                            codegen,
                                            location,
                                            val,
                                            signal_type,
                                        )?;
                                        // Write value to field of "self" struct.
                                        let self_val = fc.func.self_value_of_compute()?;
                                        let builder =
                                            fc.builder_at_current_insertion_point(codegen.context);
                                        let write = r#struct::writem(
                                            &builder, location, self_val, var, value,
                                        )?;
                                        fc.append_op_ref_no_result(write)?;
                                        fc.block_ctx.set_named_value(var.clone(), value)
                                    })
                            }
                            access => rhe
                                .gen_llzk_in_template(codegen, &template.compute_only())?
                                .and_then_same(|fc, rhe| {
                                    WriteChain::new(var, Root::Signal, access).write(
                                        rhe,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        codegen.location_from_meta(meta),
                                        template,
                                        template,
                                    )
                                }),
                        }
                    }
                    AssignOp::AssignConstraintSignal => {
                        match &access[..] {
                            [] => {
                                let signal_type = template.get_signal_type(var)?;
                                rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                    |fc, val| {
                                        let location = codegen.location_from_meta(meta);
                                        // Cast value to field type if needed.
                                        let value = fc.cast_to_expected_type_if_needed(
                                            codegen,
                                            location,
                                            val,
                                            signal_type,
                                        )?;
                                        // Write value to field of "self" struct.
                                        let self_val = fc.func.self_value_of_compute()?;
                                        let builder =
                                            fc.builder_at_current_insertion_point(codegen.context);
                                        let write = r#struct::writem(
                                            &builder,
                                            location,
                                            self_val,
                                            var,
                                            value,
                                        )?;
                                        fc.append_op_ref_no_result(write)?;
                                        fc.block_ctx.set_named_value(var.clone(), value)
                                    },
                                    |fc, val| {
                                        // Get value of field from "self" struct (already generated
                                        // at the beginning of the constrain function, see
                                        // `gen_template_llzk`) and generate equality constraint
                                        // with 'val'.
                                        let signal_val = *fc.block_ctx.get_named_value(var)?;
                                        fc.append_constrain_eq(
                                            codegen,
                                            codegen.location_from_meta(meta),
                                            signal_val,
                                            val,
                                        )
                                    },
                                )
                            }
                            access => rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                |fc, rhv| {
                                    WriteChain::new(var, Root::Signal, access).write(
                                        rhv,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        codegen.location_from_meta(meta),
                                        template,
                                        template,
                                    )
                                },
                                |fc, rhv| {
                                    let location = codegen.location_from_meta(meta);
                                    Lvalue::new(var, Root::Signal, access)
                                        .get_value(
                                            codegen,
                                            fc,
                                            template,
                                            location,
                                            None,
                                            &|lhv: Value<'ctx,'val>, fc: &mut FunctionContext<'_, 'ctx,'_,'_,'val>| {
                                            fc.append_constrain_eq(codegen, location, lhv, rhv)
                                        })
                                },
                            ),
                        }
                    }
                }
            }
            Statement::UnderscoreSubstitution { op, rhe, .. } => {
                // The `<--` operator is witness generation only so this should not
                // generate any code in the constrain function.
                let template =
                    if AssignOp::AssignSignal == *op { &template.compute_only() } else { template };
                // Just visit and drop the resulting GenResultSingleVal since the value is unused.
                rhe.gen_llzk_in_template(codegen, template).map(drop)
            }
            Statement::ConstraintEquality { meta, lhe, rhe } => {
                // This statement is only relevant to the "@constrain" function.
                let template = template.constrain_only();
                // Generate Value for both sides and then generate the constraint op.
                GenResultMultiVal::gen_exprs(&template, codegen, [lhe, rhe])?.and_then_same(
                    |fc, vals| {
                        fc.append_constrain_eq(
                            codegen,
                            codegen.location_from_meta(meta),
                            vals[0],
                            vals[1],
                        )
                    },
                )
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                gen_if_then_else(codegen, template, meta, cond, if_case, else_case)
            }
            Statement::While { meta, cond, stmt } => {
                gen_while(codegen, template, meta, cond, stmt, None)
            }
            Statement::Assert { meta, arg } => {
                arg.gen_llzk_in_template(codegen, template)?.and_then_same(|fc, val| {
                    fc.append_assert(codegen, codegen.location_from_meta(meta), val)
                })
            }
            Statement::LogCall { meta, .. } => {
                codegen.emit_circom_warning(
                    meta,
                    "log calls are not currently supported in LLZK",
                    ReportCode::NotAllowedOperation,
                );
                Ok(())
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
            }
            Statement::Return { .. } => {
                // per `type_analysis/src/analyzers/no_returns_in_template.rs`
                unreachable!("return statements are not allowed in templates")
            }
        }
    }
}

impl<'decls, 'ctx, 'str, 'func, 'blk, 'val>
    GenerateLLZKInTemplate<'decls, 'ctx, 'str, 'func, 'blk, 'val> for Expression
where
    'ctx: 'decls,
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    type Output<'r>
        = GenResultSingleVal<'decls, 'ctx, 'str, 'func, 'blk, 'val, 'r>
    where
        'decls: 'r,
        'val: 'r;

    fn gen_llzk_in_template<'r>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        template: &'r TemplateContext<'decls, 'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r,
    {
        // This function handles the special cases that happen in templates and any other kind of
        // expression is delegated.
        match self {
            Expression::ParallelOp { rhe, .. } => {
                // `parallel` is a tag used to generate parallelized code for the C++
                // witness generator. Since LLZK currently has no such hint,
                // we simply generate the underlying expression.
                rhe.gen_llzk_in_template(codegen, template)
            }
            Expression::Call { meta, id, args, .. }
                if meta.get_type_knowledge().is_component()
                    && codegen.program.contains_template(id) =>
            {
                let scope = CtorCallScope::new(meta, id, args, codegen, template)?;

                // Create a `pod.new` operation with the memory for the subcomponent.
                template.and_then(
                    |fc, _| {
                        scope.emit_ctor_call(codegen, fc, |fc, params_pod| {
                            scope.subcmp_type.initialize_records(
                                params_pod,
                                fc,
                                codegen,
                                scope.location,
                                None,
                            )
                        })
                    },
                    |fc, _| scope.emit_ctor_call(codegen, fc, |_, _| Ok(vec![])),
                )
            }
            Expression::UniformArray { meta, value, dimension } => {
                let location = codegen.location_from_meta(meta);
                let template_dim_res =
                    template.get_poly_binding::<ArrayDimExprKind>(codegen, dimension)?;
                let value = value.gen_llzk_in_template(codegen, template)?;
                value.and_then_same(|fc, value| {
                    // Try to convert in template first, defer to function context if unsuccessful.
                    let final_dim = match &template_dim_res {
                        ExprToPolyBindingOutput::Computed(array_dimension) => array_dimension,
                        ExprToPolyBindingOutput::InsufficientData => &fc
                            .get_poly_binding::<ArrayDimExprKind>(codegen, dimension)
                            .and_then(ArrayDimension::try_from)?,
                    };
                    fc.generate_uniform_array(codegen, location, value, final_dim)
                })
            }
            // Delegate any other kind of expression to the implementation in `function.rs`.
            expr => {
                template.and_then_same(|fc, _| expr.gen_llzk_in_block(codegen, fc, template.into()))
            }
        }
    }
}

/// Groups the related data for emitting IR for subcomponent constructor calls.
///
/// Exposes helper functions for emitting the common parts of the IR between the
/// `compute` and `constrain` functions.
struct CtorCallScope<'ast, 'ctx, 'info> {
    /// Name of the subcomponent's template
    id: &'ast str,
    /// Source location.
    location: Location<'ctx>,
    /// Struct template parameters derived from the constructor arguments.
    params: StructTemplateParams<'ctx>,
    /// Type of the subcomponent.
    subcmp_type: SubcmpType<'ctx>,
    /// Subcomponent memory pod type.
    pod_type: PodType<'ctx>,
    /// Constructor arguments.
    args: &'ast [Expression],
    /// Info for emitting IR recursively.
    info: InfoProviders<'info, 'ctx>,
}

impl<'ast, 'ctx, 'val, 'info> CtorCallScope<'ast, 'ctx, 'info> {
    /// Creates a new scope.
    fn new(
        meta: &'ast Meta,
        id: &'ast str,
        args: &'ast [Expression],
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        template: &'info TemplateContext<'_, 'ctx, '_, '_, '_, 'val>,
    ) -> Result<Self> {
        let location = codegen.location_from_meta(meta);
        let params = template.get_poly_bindings::<StructTemplateParamExprKind>(codegen, args)?;
        let subcmp_struct_type = params.struct_type_with_concrete_params(codegen, id);
        let subcmp_type = SubcmpType::new(subcmp_struct_type.into(), id.to_owned());

        let records = subcmp_type.comp_pod_records(codegen);
        let pod_type = codegen.pod_type(&records);
        Ok(Self { id, location, params, subcmp_type, pod_type, args, info: template.into() })
    }

    /// Returns the list of names associated to the template parameters.
    fn params_formals<'f>(
        &self,
        codegen: &LlzkCodegen<'f, 'ctx, '_, impl ProgramLike>,
    ) -> &'f [String] {
        codegen.program.get_template_data(self.id).get_name_of_params()
    }

    /// Emits IR for reading a template parameter, represented by the given attribute.
    fn emit_param_op(
        &self,
        attr: Attribute<'ctx>,
        expr: &Expression,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        map_operands: &mut Vec<OwningValueRange<'ctx, 'val>>,
    ) -> Result<Value<'ctx, 'val>> {
        type_switch! { attr,
            IntegerAttribute as int => {
                let builder = fc.builder_at_current_insertion_point(codegen.context);
                fc.append_op_ref_unnamed_result(codegen.new_felt_const_op(
                    &builder,
                    &BigInt::from(int.value()),
                    self.location,
                )?)
            }
            FlatSymbolRefAttribute as sym => {
                let value = fc.read_poly_template_binding(
                    codegen,
                    self.location,
                    sym.value(),
                    self.subcmp_type.param_type(codegen),
                )?;
                fc.cast_to_felt_if_needed(codegen, self.location, value)
            }
            else => {
                let value = expr.gen_llzk_in_block(codegen, fc, self.info)?;
                let casted = fc.cast_to_index_if_needed(codegen, self.location, value)?;
                map_operands.push(OwningValueRange::from([casted].as_slice()));
                fc.cast_to_felt_if_needed(codegen, self.location, value)
            }
        }
    }

    /// Emits IR representing a read of each template parameter.
    fn emit_params(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        map_operands: &mut Vec<OwningValueRange<'ctx, 'val>>,
    ) -> Result<Vec<RecordValue<'ctx, 'val>>> {
        std::iter::zip(self.params_formals(codegen), std::iter::zip(self.params.attrs(), self.args))
            .map(|(formal, (attr, expr))| {
                let value = self.emit_param_op(attr, expr, codegen, fc, map_operands)?;
                Ok(RecordValue::new(StringRef::new(formal), value))
            })
            .collect()
    }

    /// Shared parts between the constraint and compute functions when emitting IR for subcomponent
    /// constructor calls.
    ///
    /// Accepts a callback that returns the list of initialized records in the subcomponent memory
    /// pod.
    fn emit_ctor_call<'decls, 'str, 'func, 'blk, F>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
        mut cb: F,
    ) -> Result<Value<'ctx, 'val>>
    where
        F: FnMut(
            &mut FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>,
            Value<'ctx, 'val>,
        ) -> Result<Vec<(&'static str, Value<'ctx, 'val>)>>,
    {
        let mut map_operands_values = vec![];
        let params = self.emit_params(codegen, fc, &mut map_operands_values)?;
        let builder = fc.builder_at_current_insertion_point(codegen.context);
        let params_pod = fc.append_op_ref_unnamed_result(pod::new(
            &builder,
            self.location,
            &params,
            Some(self.subcmp_type.params_pod_type(codegen)),
        ))?;

        let records = wrap_pod_records(cb(fc, params_pod)?);
        let mut map_operands = MapOperandsBuilder::new();
        for value_range in &map_operands_values {
            map_operands.append_operands_with_dim_count(ValueRange::try_from(value_range)?, 1);
        }

        let builder = fc.builder_at_current_insertion_point(codegen.context);
        fc.append_op_ref_unnamed_result(pod::new_with_affine_init(
            &builder,
            self.location,
            &records,
            self.pod_type,
            map_operands,
        ))
    }
}
