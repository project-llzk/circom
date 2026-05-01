//! Helper type for constructing operations that write using [`Access`].

use crate::function::FunctionContext;
use crate::function::InfoProviders;
use crate::gen_context::NestedBlockInfo;
use crate::lvalue::concrete_indices;
use crate::lvalue::emit_condition;
use crate::lvalue::Combine;
use crate::lvalue::CombineEntry;
use crate::lvalue::Lvalue;
use crate::lvalue::OverrideVar;
use crate::lvalue::Root;
use crate::program_ext::ProgramLike;
use crate::shared::comp_type;
use crate::shared::LlzkCodegen;
use crate::subcmp::names::COMP;
use crate::subcmp::names::PARAMS;
use crate::subcmp::SubcmpInfo;
use crate::template::TemplateContext;
use anyhow::Result;
use llzk::dialect::r#struct;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::Location;
use llzk::prelude::PodType;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use melior::dialect::arith;
use program_structure::ast::Access;
use program_structure::ast::Expression;
use std::convert::TryFrom as _;
use std::convert::TryInto as _;
use std::fmt;

/// Gives information about signals written into the component.
pub trait SignalWriteInfo: std::fmt::Debug {
    /// Returns true if we already generated a `struct.writem` op for the given signal.
    fn signal_already_written(&self, name: &str) -> bool;

    /// Marks the given signal as written.
    fn mark_signal_as_written(&self, name: String);
}

impl SignalWriteInfo for TemplateContext<'_, '_, '_, '_, '_, '_> {
    fn signal_already_written(&self, name: &str) -> bool {
        self.signal_already_written(name)
    }

    fn mark_signal_as_written(&self, name: String) {
        self.mark_signal_as_written(name)
    }
}

/// Implementation of [`SignalWriteInfo`] for when no signals are allowed.
#[derive(Debug)]
pub struct NoSignalsInfo;

impl SignalWriteInfo for NoSignalsInfo {
    fn signal_already_written(&self, _name: &str) -> bool {
        unreachable!()
    }

    fn mark_signal_as_written(&self, _name: String) {
        unreachable!()
    }
}

/// Indicates the target function the write operation is happening on.
#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
pub enum WriteTarget {
    /// The `@compute` function of a struct.
    Compute,
    /// The `@constrain` function of a struct.
    Constrain,
    /// A free function.
    #[allow(dead_code)]
    Free,
}

impl WriteTarget {
    /// Returns true if the target is  `@compute`.
    #[inline]
    fn is_compute(&self) -> bool {
        matches!(self, WriteTarget::Compute)
    }
    /// Returns true if the target is `@constrain`.
    #[inline]
    fn is_constrain(&self) -> bool {
        matches!(self, WriteTarget::Constrain)
    }
}

/// Overrides a subcomponent's variable name.
#[derive(Clone, Copy)]
struct Override<'info, 'ctx> {
    /// If true, means that the write chain is storing the result of a call to compute.
    compute_result: bool,
    /// Reference to a subcomponent information provider.
    subcmp_info: &'info dyn SubcmpInfo<'ctx>,
}

impl OverrideVar for Override<'_, '_> {
    fn override_var(&self, var: &str, op: Root) -> Option<String> {
        (!self.compute_result && self.subcmp_info.is_subcmp(var) && op == Root::Signal)
            .then(|| crate::subcmp::names::inputs(var))
    }
}

/// Helper type that defines a chain of write operations.
#[derive(Debug, Clone)]
pub struct WriteChain<'ast> {
    /// Location value this write action takes place on.
    lvalue: Lvalue<'ast>,
    /// If true, means that the write chain is storing the result of a call to compute.
    compute_result: bool,
}

/// Borrowed access in source order from a [`Lvalue`].
#[derive(Clone, Copy)]
enum AccessRef<'a, 'ast> {
    /// Array access.
    Array(&'a [&'ast Expression]),
    /// Component/signal access.
    Subcmp(&'ast str),
}

impl<'ast> WriteChain<'ast> {
    /// Creates a new write chain.
    pub fn new(var: &'ast str, op: Root, access: &'ast [Access]) -> Self {
        Self::from_lvalue(Lvalue::new(var, op, access), false)
    }

    /// Creates a write chain from a lvalue.
    fn from_lvalue(lvalue: Lvalue<'ast>, compute_result: bool) -> Self {
        Self { lvalue, compute_result }
    }

    /// Creates a copy of the chain with the `compute_result` flag set to true.
    pub fn clone_for_compute_result(&self) -> Self {
        Self { lvalue: self.lvalue.clone(), compute_result: true }
    }

    /// Collects the root and source-order accesses for the given [`Lvalue`].
    fn collect_accesses<'a>(
        lvalue: &'a Lvalue<'ast>,
        accesses: &mut Vec<AccessRef<'a, 'ast>>,
    ) -> (&'ast str, Root) {
        match lvalue {
            Lvalue::Root { var, op } => (var, *op),
            Lvalue::Array { indices, prev } => {
                let root = Self::collect_accesses(prev, accesses);
                accesses.push(AccessRef::Array(indices));
                root
            }
            Lvalue::Subcmp { name, prev } => {
                let root = Self::collect_accesses(prev, accesses);
                accesses.push(AccessRef::Subcmp(name));
                root
            }
        }
    }

    /// Writes a value into a field of a mixed subcomponent input pod.
    #[allow(clippy::too_many_arguments)]
    fn write_mixed_input_tail<'ctx, 'val>(
        signal_name: &str,
        tail: &[AccessRef<'_, 'ast>],
        input_record: Value<'ctx, 'val>,
        input_record_type: PodType<'ctx>,
        val: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()> {
        let field_type = input_record_type.get_type_of_record(signal_name).ok_or_else(|| {
            anyhow::anyhow!("subcomponent input signal {signal_name} not found: {input_record}")
        })?;

        let field_value = match tail.split_first() {
            Some((AccessRef::Array(indices), rest)) => {
                if !rest.is_empty() {
                    anyhow::bail!("unsupported nested access after subcomponent input array");
                }
                let field_value = fc.append_op_unnamed_result(codegen.new_pod_read_op(
                    input_record,
                    signal_name,
                    location,
                )?)?;
                let index_vals = fc.gen_index_ops(
                    indices.iter().copied(),
                    codegen,
                    location,
                    InfoProviders { subcmp_info, signal_write_info },
                )?;
                fc.append_array_write(codegen, field_value, &index_vals, location, val, None)?;
                field_value
            }
            Some((AccessRef::Subcmp(_), _)) => {
                anyhow::bail!("unsupported nested component access after subcomponent input")
            }
            None => fc.cast_to_expected_type_if_needed(codegen, location, val, field_type)?,
        };

        fc.append_op_no_result(codegen.new_pod_write_op(
            location,
            input_record,
            signal_name,
            field_value,
        ))
    }

    /// Special-case writes through a dynamically indexed mixed subcomponent array.
    ///
    /// The selected record has a concrete component type, but different records may have
    /// different input pod shapes. Keep those record-specific values inside the dispatch branch
    /// and only merge the uniform parent pods back into the surrounding block.
    #[allow(clippy::too_many_arguments)]
    fn try_write_mixed_subcmp<'ctx, 'val>(
        &self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<bool> {
        if target.is_constrain() {
            return Ok(false);
        }

        let mut accesses = Vec::new();
        let (root_var, root_op) = Self::collect_accesses(&self.lvalue, &mut accesses);
        if !subcmp_info.is_subcmp(root_var) {
            return Ok(false);
        }
        let Ok(layout) = subcmp_info.mixed_subcmp_info(root_var) else {
            return Ok(false);
        };

        let Some((AccessRef::Array(component_indices), tail)) = accesses.split_first() else {
            return Ok(false);
        };
        if concrete_indices(component_indices).is_some() {
            return Ok(false);
        }

        let index_vals = fc.gen_index_ops(
            component_indices.iter().copied(),
            codegen,
            location,
            InfoProviders { subcmp_info, signal_write_info },
        )?;
        let true_value = {
            let attr = IntegerAttribute::new(codegen.bool_type().into(), 1);
            fc.append_op_unnamed_result(arith::constant(codegen.context, attr.into(), location))
        }?;

        let memory_value = *fc.block_ctx.get_named_value(root_var)?;
        let memory_type = PodType::try_from(memory_value.r#type())?;
        let inputs_name = crate::subcmp::names::inputs(root_var);
        let inputs_value = if root_op == Root::Signal {
            Some(*fc.block_ctx.get_named_value(&inputs_name)?)
        } else {
            None
        };

        let signal_name = match root_op {
            Root::Var if tail.is_empty() => None,
            Root::Signal => {
                let Some((AccessRef::Subcmp(signal_name), _)) = tail.split_first() else {
                    return Ok(false);
                };
                if !subcmp_info.subcmp_info(root_var, codegen)?.signal_is_input(signal_name) {
                    return Ok(false);
                }
                Some(*signal_name)
            }
            _ => return Ok(false),
        };

        if layout.entries().is_empty() {
            anyhow::bail!("No entries for mixed subcomponent array '{}'", root_var);
        }

        let mut entries = Vec::with_capacity(layout.entries().len());
        for entry in layout.entries() {
            let condition = emit_condition(
                entry.indexed_with(),
                codegen,
                fc,
                location,
                true_value,
                &index_vals,
            )?;

            let (info, ()) = NestedBlockInfo::with_scope(fc, |fc| {
                if let Some(signal_name) = signal_name {
                    let inputs_value = inputs_value.expect("input value exists for signal writes");
                    let memory_record = fc.append_op_unnamed_result(codegen.new_pod_read_op(
                        memory_value,
                        entry.record_name(),
                        location,
                    )?)?;
                    let input_record = fc.append_op_unnamed_result(codegen.new_pod_read_op(
                        inputs_value,
                        entry.record_name(),
                        location,
                    )?)?;
                    Self::write_mixed_input_tail(
                        signal_name,
                        &tail[1..],
                        input_record,
                        entry.inputs_type(),
                        val,
                        codegen,
                        fc,
                        location,
                        signal_write_info,
                        subcmp_info,
                    )?;
                    fc.append_op_no_result(codegen.new_pod_write_op(
                        location,
                        inputs_value,
                        entry.record_name(),
                        input_record,
                    ))?;
                    fc.block_ctx.set_named_value(inputs_name.clone(), inputs_value)?;

                    let counter =
                        fc.gen_subcmp_decrease_counter(codegen, location, memory_record, 1)?;
                    fc.gen_scf_if_is_zero(
                        counter,
                        location,
                        codegen,
                        |fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>| {
                            let params = fc.append_op_unnamed_result(codegen.new_pod_read_op(
                                memory_record,
                                PARAMS,
                                location,
                            )?)?;
                            let subcmp_instance = fc.gen_compute_call(
                                entry.struct_type(),
                                input_record,
                                params,
                                location,
                                codegen,
                            )?;
                            fc.append_op_no_result(codegen.new_pod_write_op(
                                location,
                                memory_record,
                                COMP,
                                subcmp_instance,
                            ))
                        },
                    )?;
                    fc.append_op_no_result(codegen.new_pod_write_op(
                        location,
                        memory_value,
                        entry.record_name(),
                        memory_record,
                    ))?;
                } else {
                    let record_type =
                        memory_type.get_type_of_record(entry.record_name()).ok_or_else(|| {
                            anyhow::anyhow!(
                                "record {} not found in mixed subcomponent pod: {}",
                                entry.record_name(),
                                memory_value
                            )
                        })?;
                    let val =
                        fc.cast_to_expected_type_if_needed(codegen, location, val, record_type)?;
                    fc.append_op_no_result(codegen.new_pod_write_op(
                        location,
                        memory_value,
                        entry.record_name(),
                        val,
                    ))?;
                }
                fc.block_ctx.set_named_value(root_var.to_owned(), memory_value)
            })?;
            entries.push(CombineEntry::new(condition, (), info));
        }

        <() as Combine>::combine(entries, fc.as_mut(), codegen, location)?;
        Ok(true)
    }

    /// Handle [Lvalue::Array] case of [`WriteChain::write`].
    #[allow(clippy::too_many_arguments)]
    fn write_array<'ctx, 'val>(
        indices: Vec<&Expression>,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()> {
        prev.lvalue.get_value(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&prev.ov(subcmp_info)),
            &|arr_ref: Value<'ctx, 'val>, fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>| {
                let Ok(pod_type) = PodType::try_from(arr_ref.r#type()) else {
                    let index_vals = fc.gen_index_ops(
                        indices.clone(),
                        codegen,
                        location,
                        InfoProviders { subcmp_info, signal_write_info },
                    )?;
                    fc.append_array_write(codegen, arr_ref, &index_vals, location, val, None)?;
                    return prev.clone().write(
                        arr_ref,
                        target,
                        codegen,
                        fc,
                        location,
                        signal_write_info,
                        subcmp_info,
                    );
                };

                // The problem here is that concrete_indices expects that the indices are always
                // literal, which is not always the case. We need to take each expression, convert
                // it to values (that is done below with `fc.gen_index_ops`), and then check with a
                // massive if then else for each possible index. The optimizer should be able to
                // remove the dead branches on literal cases...
                if let Some(indices) = concrete_indices(&indices) {
                    // Using `root_var` here is somewhat safe since this representation can only be
                    // done on subcomponents (unless we can do it on buses as well but I'm not sure)
                    // and subcomponents are always top level variables.
                    if let Some(record_name) = subcmp_info
                        .mixed_subcmp_record_for_indices(prev.lvalue.root_var(), &indices)
                    {
                        let record_type =
                            pod_type.get_type_of_record(record_name).ok_or_else(|| {
                                anyhow::anyhow!(
                        "record {record_name} not found in mixed subcomponent pod: {arr_ref}"
                    )
                            })?;
                        let val = fc.cast_to_expected_type_if_needed(
                            codegen,
                            location,
                            val,
                            record_type,
                        )?;
                        fc.append_op_no_result(codegen.new_pod_write_op(
                            location,
                            arr_ref,
                            record_name,
                            val,
                        ))?;
                        return prev.clone().write(
                            arr_ref,
                            target,
                            codegen,
                            fc,
                            location,
                            signal_write_info,
                            subcmp_info,
                        );
                    }
                }
                prev.clone().write(
                    arr_ref,
                    target,
                    codegen,
                    fc,
                    location,
                    signal_write_info,
                    subcmp_info,
                )
            },
        )
    }

    /// Handle [Lvalue::Subcmp] case of [`WriteChain::write`].
    #[allow(clippy::too_many_arguments)]
    fn write_subcmp<'ctx, 'val>(
        name: &str,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()> {
        let prev_for_compute = prev.clone_for_compute_result();
        let ov = prev.ov(subcmp_info);
        prev.lvalue.get_value::<(), _>(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&ov),
            &|subcmp_value_inputs: Value<'ctx, 'val>,
              fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>|
             -> Result<()> {
                fc.append_op_no_result(codegen.new_pod_write_op(
                    location,
                    subcmp_value_inputs,
                    name,
                    val,
                ))?;
                prev.clone().write(
                    subcmp_value_inputs,
                    target,
                    codegen,
                    fc,
                    location,
                    signal_write_info,
                    subcmp_info,
                )
            },
        )?;
        // Read the subcomponent's memory, which should be the memory pod.
        prev_for_compute.lvalue.get_value(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&prev_for_compute.ov(subcmp_info)),
            &|subcmp_value: Value<'ctx, 'val>, fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>| {
                let subcmp_value_inputs = prev_for_compute.lvalue.get_value(
                    codegen,
                    fc,
                    subcmp_info,
                    location,
                    Some(&ov),
                    &|subcmp_value_inputs: Value<'ctx, 'val>,
                      _: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>| {
                        Ok(subcmp_value_inputs)
                    },
                )?;
                let counter = fc.gen_subcmp_decrease_counter(codegen, location, subcmp_value, 1)?;
                fc.gen_scf_if_is_zero(
                    counter,
                    location,
                    codegen,
                    |fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>| {
                        let params = fc.append_op_unnamed_result(codegen.new_pod_read_op(
                            subcmp_value,
                            PARAMS,
                            location,
                        )?)?;
                        let struct_type =
                            comp_type(subcmp_value.r#type().try_into()?)?.try_into()?;

                        let subcmp_instance = fc.gen_compute_call(
                            struct_type,
                            subcmp_value_inputs,
                            params,
                            location,
                            codegen,
                        )?;
                        fc.append_op_no_result(codegen.new_pod_write_op(
                            location,
                            subcmp_value,
                            COMP,
                            subcmp_instance,
                        ))?;
                        prev_for_compute.clone().write(
                            subcmp_value,
                            target,
                            codegen,
                            fc,
                            location,
                            signal_write_info,
                            subcmp_info,
                        )
                    },
                )
            },
        )
    }

    #[allow(clippy::too_many_arguments)]
    /// Emits the write operations.
    pub fn write<'ctx, 'val>(
        self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()> {
        /// Handle [Lvalue::Root] with [Root::Signal] case.
        fn write_root_signal<'ctx, 'val>(
            var: String,
            val: Value<'ctx, 'val>,
            target: WriteTarget,
            fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
            location: Location<'ctx>,
            signal_write_info: &dyn SignalWriteInfo,
        ) -> Result<()> {
            if target.is_compute() && !signal_write_info.signal_already_written(&var) {
                let block = fc.block_ctx.get_decl_block_of_value(&var)?;

                let self_value = fc.func.self_value_of_compute()?;
                // Write value to field of "self" struct.
                fc.block_ctx.enqueue_in_block(
                    r#struct::writem(location, self_value, &var, val)?.into(),
                    block,
                )?;
                fc.block_ctx.set_named_value_at_declaration(var.clone(), val)?;
                signal_write_info.mark_signal_as_written(var)
            }
            Ok(())
        }

        // If we are writing into a variable annotated as a subcomponent and we are
        // writing in the constraint function skip the whole chain.
        if let Lvalue::Root { var, op: Root::Var, .. } = self.lvalue.root() {
            if target.is_constrain() && subcmp_info.is_subcmp(var) {
                return Ok(());
            }
        }

        if self.try_write_mixed_subcmp(
            val,
            target,
            codegen,
            fc,
            location,
            signal_write_info,
            subcmp_info,
        )? {
            return Ok(());
        }

        match self.lvalue {
            Lvalue::Root { var, op: Root::Signal } => {
                let final_var = self
                    .ov(subcmp_info)
                    .override_var(var, Root::Signal)
                    .unwrap_or_else(|| var.to_owned());
                // We know we are assigning a subcomponent signal if the root var is the name
                // of the var listed as a subcomponent.
                if subcmp_info.is_subcmp(var) {
                    return fc.block_ctx.set_named_value(final_var, val);
                }
                write_root_signal(final_var, val, target, fc, location, signal_write_info)
            }
            Lvalue::Root { var, op: Root::Var } => {
                if subcmp_info.is_subcmp(var) {
                    return Ok(()); // Do nothing (for now)
                }
                fc.block_ctx.set_named_value(
                    self.ov(subcmp_info)
                        .override_var(var, Root::Var)
                        .unwrap_or_else(|| var.to_owned()),
                    val,
                )
            }
            Lvalue::Array { indices, prev } => Self::write_array(
                indices,
                Self::from_lvalue(*prev, self.compute_result),
                val,
                target,
                codegen,
                fc,
                location,
                signal_write_info,
                subcmp_info,
            ),
            Lvalue::Subcmp { name, prev } => Self::write_subcmp(
                name,
                Self::from_lvalue(*prev, self.compute_result),
                val,
                target,
                codegen,
                fc,
                location,
                signal_write_info,
                subcmp_info,
            ),
        }
    }

    /// Creates an override configuration for the given template and the internal `compute_result`
    /// state.
    fn ov<'info, 'ctx>(&self, template: &'info dyn SubcmpInfo<'ctx>) -> Override<'info, 'ctx> {
        Override { compute_result: self.compute_result, subcmp_info: template }
    }
}

impl fmt::Display for WriteChain<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Display::fmt(&self.lvalue, f)
    }
}
