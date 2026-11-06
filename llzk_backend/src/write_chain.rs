//! Helper type for constructing operations that write using [`Access`].

use std::{
    convert::{TryFrom as _, TryInto as _},
    fmt,
};

use anyhow::Result;
use llzk::prelude::{ArrayType, FuncDefOpLike as _, Location, PodType, Value, ValueLike as _};
use program_structure::ast::{Access, Expression};

use crate::{
    function::{FunctionContext, InfoProviders},
    gen_context::NestedBlockInfo,
    lvalue::{concrete_indices, emit_condition, Combine, CombineEntry, Lvalue, OverrideVar, Root},
    program_ext::ProgramLike,
    shared::{comp_type, LlzkCodegen, TypeSizeExpr},
    subcmp::{
        names::{COMP, PARAMS},
        SubcmpInfo,
    },
    template::TemplateContext,
};

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
    /// Number of trailing input-field indices in the original write, excluding component indices.
    input_indices: usize,
}

/// Borrowed access in source order from a [`Lvalue`].
#[derive(Clone, Copy)]
enum AccessRef<'a, 'ast> {
    /// Array access.
    Array(&'a [&'ast Expression]),
    /// Component/signal access.
    Field(&'ast str),
}

impl<'ast> WriteChain<'ast> {
    /// Update a data aggregate, writing each copied child back into its parent.
    /// Indices are evaluated on the descent only; the ascent reuses those values.
    fn update_data<'ctx, 'blk, 'val>(
        value: Value<'ctx, 'val>,
        accesses: &[AccessRef<'_, 'ast>],
        rhs: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
        info: InfoProviders<'_, 'ctx>,
    ) -> Result<(Value<'ctx, 'val>, TypeSizeExpr<'ctx>)>
    where
        'val: 'blk,
    {
        let Some((access, tail)) = accesses.split_first() else {
            // Count destination leaves, excluding any padding removed from the RHS below.
            // Templated destinations may have affine dimensions, so fall back to the RHS.
            let count = codegen
                .count_input_signals(value.r#type())
                .or_else(|_| codegen.count_input_signals(rhs.r#type()))?;
            let rhs = fc.cast_signal_assignment_value(codegen, location, rhs, value.r#type())?;
            return Ok((rhs, count));
        };
        match access {
            AccessRef::Field(name) => {
                let builder = fc.builder_at_current_insertion_point(codegen.context);
                let child = fc.append_op_ref_unnamed_result(
                    codegen.new_pod_read_op(&builder, value, name, location)?,
                )?;
                let (child, count) =
                    Self::update_data(child, tail, rhs, codegen, fc, location, info)?;
                let builder = fc.builder_at_current_insertion_point(codegen.context);
                fc.append_op_ref_no_result(
                    codegen.new_pod_write_op(&builder, location, value, name, child),
                )?;
                Ok((value, count))
            }
            AccessRef::Array(indices) => {
                let indices = fc.gen_index_ops(indices.iter().copied(), codegen, location, info)?;
                let child = fc.append_array_read(codegen, value, &indices, location, None)?;
                let (child, count) =
                    Self::update_data(child, tail, rhs, codegen, fc, location, info)?;
                fc.append_array_write(codegen, value, &indices, location, child, None)?;
                Ok((value, count))
            }
        }
    }

    /// Write bus fields and uniform component inputs as one aggregate transaction.
    fn try_write_data<'ctx, 'blk, 'val>(
        &self,
        rhs: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<bool>
    where
        'val: 'blk,
    {
        let mut accesses = Vec::new();
        let (root, op) = Self::collect_accesses(&self.lvalue, &mut accesses);
        if target != WriteTarget::Compute
            || op != Root::Signal
            || self.compute_result
            || accesses.is_empty()
        {
            return Ok(false);
        }
        let info = InfoProviders { signal_write_info, subcmp_info };
        if !subcmp_info.is_subcmp(root) {
            let value = *fc.block_ctx.get_named_value(root)?;
            if !crate::bus_entry::contains_bus(value.r#type()) {
                return Ok(false);
            }
            let (value, _) = Self::update_data(value, &accesses, rhs, codegen, fc, location, info)?;
            Self::new(root, Root::Signal, &[]).write(
                value,
                target,
                codegen,
                fc,
                location,
                signal_write_info,
                subcmp_info,
            )?;
            return Ok(true);
        }
        if subcmp_info.mixed_subcmp_info(root).is_ok() {
            return Ok(false);
        }
        let input_name = crate::subcmp::names::inputs(root);
        let input_root = *fc.block_ctx.get_named_value(&input_name)?;
        let element = ArrayType::try_from(input_root.r#type())
            .map_or(input_root.r#type(), |a| a.element_type());
        if !PodType::try_from(element)?
            .records()
            .iter()
            .any(|r| crate::bus_entry::contains_bus(r.r#type()))
        {
            return Ok(false);
        }
        let memory_root = *fc.block_ctx.get_named_value(root)?;
        let (indices, tail) = match accesses.first() {
            Some(AccessRef::Array(indices)) => (
                fc.gen_index_ops(indices.iter().copied(), codegen, location, info)?,
                &accesses[1..],
            ),
            _ => (Vec::new(), &accesses[..]),
        };
        let Some(AccessRef::Field(signal)) = tail.first() else { return Ok(false) };
        anyhow::ensure!(
            subcmp_info.subcmp_info(root, codegen)?.signal_is_input(signal),
            "cannot assign component output {root}.{signal} at {location}"
        );
        let (inputs, memory) = if indices.is_empty() {
            (input_root, memory_root)
        } else {
            (
                fc.append_array_read(codegen, input_root, &indices, location, None)?,
                fc.append_array_read(codegen, memory_root, &indices, location, None)?,
            )
        };
        let (inputs, count) = Self::update_data(inputs, tail, rhs, codegen, fc, location, info)?;
        if !count.is_const_zero() {
            let builder = fc.builder_at_current_insertion_point(codegen.context);
            let pending = fc.append_op_ref_unnamed_result(codegen.new_pod_read_op(
                &builder,
                memory,
                crate::subcmp::names::COUNT,
                location,
            )?)?;
            let zero = fc.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
            let complete = fc.append_op_unnamed_result(melior::dialect::arith::cmpi(
                codegen.context,
                melior::dialect::arith::CmpiPredicate::Eq,
                pending,
                zero,
                location,
            ))?;
            let one = fc.append_op_unnamed_result(codegen.new_index_const_op(1, location))?;
            let complete = fc.append_op_unnamed_result(melior::dialect::arith::select(
                complete, one, zero, location,
            ))?;
            fc.gen_scf_if_is_zero(complete, location, codegen, |fc| {
                Self::complete_subcmp_write(memory, inputs, count, codegen, fc, location)
            })?;
        }
        if !indices.is_empty() {
            fc.append_array_write(codegen, input_root, &indices, location, inputs, None)?;
            fc.append_array_write(codegen, memory_root, &indices, location, memory, None)?;
        }
        fc.block_ctx.set_named_value(input_name, input_root)?;
        fc.block_ctx.set_named_value(root.to_owned(), memory_root)?;
        Ok(true)
    }
    /// Creates a new write chain.
    pub fn new(var: &'ast str, op: Root, access: &'ast [Access]) -> Self {
        let lvalue = Lvalue::new(var, op, access);
        let input_indices = match &lvalue {
            Lvalue::Array { indices, prev } if matches!(**prev, Lvalue::Field { .. }) => {
                indices.len()
            }
            _ => 0,
        };
        Self::from_lvalue(lvalue, false, input_indices)
    }

    /// Creates a write chain from a lvalue.
    fn from_lvalue(lvalue: Lvalue<'ast>, compute_result: bool, input_indices: usize) -> Self {
        Self { lvalue, compute_result, input_indices }
    }

    /// Creates a copy of the chain with the `compute_result` flag set to true.
    pub fn clone_for_compute_result(&self) -> Self {
        Self {
            lvalue: self.lvalue.clone(),
            compute_result: true,
            input_indices: self.input_indices,
        }
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
            Lvalue::Field { name, prev } => {
                let root = Self::collect_accesses(prev, accesses);
                accesses.push(AccessRef::Field(name));
                root
            }
        }
    }

    /// Count the destination signals assigned by a whole-field or indexed input write.
    /// Dimensions consumed by indices are excluded, so scalar writes count as one and
    /// subarray writes count only the remaining dimensions.
    fn input_write_size<'ctx>(
        signal_name: &str,
        input_type: PodType<'ctx>,
        input_indices: usize,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Result<TypeSizeExpr<'ctx>> {
        let mut written_type = input_type.record_type(signal_name).ok_or_else(|| {
            anyhow::anyhow!("subcomponent input signal {signal_name} not found: {input_type}")
        })?;
        if input_indices != 0 {
            let array_type = ArrayType::try_from(written_type)?;
            let dims = array_type.dims();
            anyhow::ensure!(
                input_indices <= dims.len(),
                "too many indices for input {signal_name}"
            );
            written_type = if input_indices == dims.len() {
                array_type.element_type()
            } else {
                ArrayType::new(array_type.element_type().into(), &dims[input_indices..]).into()
            };
        }
        codegen.count_input_signals(written_type)
    }

    /// Decrement a component's pending inputs and store its instance when complete.
    /// Callers retain their dispatch, zero-input guards, and parent aggregate writeback.
    fn complete_subcmp_write<'ctx, 'blk, 'val>(
        memory: Value<'ctx, 'val>,
        inputs: Value<'ctx, 'val>,
        written_size: TypeSizeExpr<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let counter = fc.gen_subcmp_decrease_counter(codegen, location, memory, written_size)?;
        fc.gen_scf_if_is_zero(counter, location, codegen, |fc| {
            let builder = fc.builder_at_current_insertion_point(codegen.context);
            let params = fc.append_op_ref_unnamed_result(
                codegen.new_pod_read_op(&builder, memory, PARAMS, location)?,
            )?;
            let instance = fc.gen_compute_call(
                comp_type(memory.r#type().try_into()?)?.try_into()?,
                inputs,
                params,
                location,
                codegen,
            )?;
            let builder = fc.builder_at_current_insertion_point(codegen.context);
            fc.append_op_ref_no_result(
                codegen.new_pod_write_op(&builder, location, memory, COMP, instance),
            )
        })
    }

    /// Assign an input field, removing concrete function return padding when needed.
    fn write_input_field<'ctx, 'blk, 'val>(
        signal_name: &str,
        input_record: Value<'ctx, 'val>,
        val: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let input_record_type = PodType::try_from(input_record.r#type())?;
        let field_type = input_record_type.record_type(signal_name).ok_or_else(|| {
            anyhow::anyhow!("subcomponent input signal {signal_name} not found: {input_record}")
        })?;
        let val = fc.cast_signal_assignment_value(codegen, location, val, field_type)?;
        let builder = fc.builder_at_current_insertion_point(codegen.context);
        fc.append_op_ref_no_result(codegen.new_pod_write_op(
            &builder,
            location,
            input_record,
            signal_name,
            val,
        ))
    }

    /// Remove concrete return padding before inserting into a signal subarray.
    /// Adapting the containing field later cannot repair the inserted value's type.
    fn narrow_indexed_signal_value<'ctx, 'blk, 'val>(
        arr_ref: Value<'ctx, 'val>,
        num_indices: usize,
        val: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>>
    where
        'val: 'blk,
    {
        let array_type = ArrayType::try_from(arr_ref.r#type())?;
        let dims = array_type.dims();
        if num_indices < dims.len() {
            let expected = ArrayType::new(array_type.element_type().into(), &dims[num_indices..]);
            fc.narrow_concrete_signal_value(codegen, location, val, expected.into())
        } else {
            // Scalar casts and invalid index counts are handled by append_array_write.
            Ok(val)
        }
    }

    /// Writes a value into a field of a mixed subcomponent input pod.
    fn write_mixed_input_tail<'ctx, 'blk, 'val>(
        signal_name: &str,
        tail: &[AccessRef<'_, 'ast>],
        input_record: Value<'ctx, 'val>,
        val: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let field_value = match tail.split_first() {
            Some((AccessRef::Array(indices), rest)) => {
                if !rest.is_empty() {
                    anyhow::bail!("unsupported nested access after subcomponent input array");
                }
                let builder = fc.builder_at_current_insertion_point(codegen.context);
                let field_value = fc.append_op_ref_unnamed_result(codegen.new_pod_read_op(
                    &builder,
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
                let val = Self::narrow_indexed_signal_value(
                    field_value,
                    index_vals.len(),
                    val,
                    codegen,
                    fc,
                    location,
                )?;
                fc.append_array_write(codegen, field_value, &index_vals, location, val, None)?;
                field_value
            }
            Some((AccessRef::Field(_), _)) => {
                anyhow::bail!("unsupported nested component access after subcomponent input")
            }
            None => val,
        };

        Self::write_input_field(signal_name, input_record, field_value, codegen, fc, location)
    }

    /// Special-case writes through a dynamically indexed mixed subcomponent array.
    ///
    /// The selected record has a concrete component type, but different records may have
    /// different input pod shapes. Keep those record-specific values inside the dispatch branch
    /// and only merge the uniform parent pods back into the surrounding block.
    fn try_write_mixed_subcmp<'ctx, 'blk, 'val>(
        &self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<bool>
    where
        'val: 'blk,
    {
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
        let has_bus = layout.entries().iter().any(|entry| {
            entry
                .inputs_type()
                .records()
                .iter()
                .any(|record| crate::bus_entry::contains_bus(record.r#type()))
        });
        if !has_bus && concrete_indices(component_indices).is_some() {
            return Ok(false);
        }

        let index_vals = fc.gen_index_ops(
            component_indices.iter().copied(),
            codegen,
            location,
            InfoProviders { subcmp_info, signal_write_info },
        )?;
        let true_value = fc.append_op_unnamed_result(codegen.new_bool_const_op(true, location))?;
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
                let Some((AccessRef::Field(signal_name), _)) = tail.split_first() else {
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

            let val = if has_bus && signal_name.is_some() {
                let mut expected: llzk::prelude::Type = entry.inputs_type().into();
                for access in tail {
                    expected = match access {
                        AccessRef::Field(name) => {
                            PodType::try_from(expected)?.record_type(name).ok_or_else(|| {
                                anyhow::anyhow!("unknown bus field {name} at {location}")
                            })?
                        }
                        AccessRef::Array(indices) => {
                            let array = ArrayType::try_from(expected)?;
                            let dims = array.dims();
                            anyhow::ensure!(
                                indices.len() <= dims.len(),
                                "too many bus indices at {location}"
                            );
                            if indices.len() == dims.len() {
                                array.element_type()
                            } else {
                                ArrayType::new(array.element_type(), &dims[indices.len()..]).into()
                            }
                        }
                    };
                }
                // Remove concrete return padding before deciding whether this entry is
                // impossible. Concrete execution has already checked assignment shapes.
                let val = fc.narrow_concrete_signal_value(codegen, location, val, expected)?;
                // A mixed array dispatch can still contain incompatible entries. Guard
                // those entries instead of manufacturing an incompatible cast.
                if !llzk::typing::types_unify(expected, val.r#type()) {
                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    let valid = fc.append_op_ref_unnamed_result(llzk::dialect::bool::r#not(
                        &builder, location, condition,
                    )?)?;
                    fc.append_assert(
                        codegen,
                        location,
                        valid,
                        "incompatible mixed component bus input",
                    )?;
                    continue;
                }
                val
            } else {
                val
            };

            let (info, ()) = NestedBlockInfo::with_scope(codegen.context, fc, |fc| {
                if let Some(signal_name) = signal_name {
                    let inputs_value = inputs_value.expect("input value exists for signal writes");
                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    let memory_record =
                        fc.append_op_ref_unnamed_result(codegen.new_pod_read_op(
                            &builder,
                            memory_value,
                            entry.record_name(),
                            location,
                        )?)?;
                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    let input_record =
                        fc.append_op_ref_unnamed_result(codegen.new_pod_read_op(
                            &builder,
                            inputs_value,
                            entry.record_name(),
                            location,
                        )?)?;
                    let (input_record, written_size) = if has_bus {
                        Self::update_data(
                            input_record,
                            tail,
                            val,
                            codegen,
                            fc,
                            location,
                            InfoProviders { signal_write_info, subcmp_info },
                        )?
                    } else {
                        Self::write_mixed_input_tail(
                            signal_name,
                            &tail[1..],
                            input_record,
                            val,
                            codegen,
                            fc,
                            location,
                            signal_write_info,
                            subcmp_info,
                        )?;
                        (
                            input_record,
                            Self::input_write_size(
                                signal_name,
                                entry.inputs_type(),
                                self.input_indices,
                                codegen,
                            )?,
                        )
                    };
                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    fc.append_op_ref_no_result(codegen.new_pod_write_op(
                        &builder,
                        location,
                        inputs_value,
                        entry.record_name(),
                        input_record,
                    ))?;
                    fc.block_ctx.set_named_value(inputs_name.clone(), inputs_value)?;

                    if written_size.is_const_zero() {
                        return Ok(());
                    }

                    Self::complete_subcmp_write(
                        memory_record,
                        input_record,
                        written_size,
                        codegen,
                        fc,
                        location,
                    )?;
                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    fc.append_op_ref_no_result(codegen.new_pod_write_op(
                        &builder,
                        location,
                        memory_value,
                        entry.record_name(),
                        memory_record,
                    ))?;
                } else {
                    let record_type =
                        memory_type.record_type(entry.record_name()).ok_or_else(|| {
                            anyhow::anyhow!(
                                "record {} not found in mixed subcomponent pod: {}",
                                entry.record_name(),
                                memory_value
                            )
                        })?;
                    let val =
                        fc.cast_to_expected_type_if_needed(codegen, location, val, record_type)?;
                    let builder = fc.builder_at_current_insertion_point(codegen.context);
                    fc.append_op_ref_no_result(codegen.new_pod_write_op(
                        &builder,
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
    fn write_array<'ctx, 'blk, 'val>(
        indices: Vec<&Expression>,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        prev.lvalue.get_value(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&prev.ov(subcmp_info)),
            &|arr_ref: Value<'ctx, 'val>, fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>| {
                let Ok(pod_type) = PodType::try_from(arr_ref.r#type()) else {
                    let index_vals = fc.gen_index_ops(
                        indices.clone(),
                        codegen,
                        location,
                        InfoProviders { subcmp_info, signal_write_info },
                    )?;
                    let val = if !prev.compute_result
                        && matches!(prev.lvalue.root(), Lvalue::Root { op: Root::Signal, .. })
                    {
                        Self::narrow_indexed_signal_value(
                            arr_ref,
                            index_vals.len(),
                            val,
                            codegen,
                            fc,
                            location,
                        )?
                    } else {
                        val
                    };
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
                        let record_type = pod_type.record_type(record_name).ok_or_else(|| {
                            anyhow::anyhow!(
                                "record {} not found in mixed subcomponent pod: {}",
                                record_name,
                                arr_ref
                            )
                        })?;
                        let val = fc.cast_to_expected_type_if_needed(
                            codegen,
                            location,
                            val,
                            record_type,
                        )?;
                        let builder = fc.builder_at_current_insertion_point(codegen.context);
                        fc.append_op_ref_no_result(codegen.new_pod_write_op(
                            &builder,
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

    /// Handle [Lvalue::Field] case of [`WriteChain::write`].
    fn write_subcmp<'ctx, 'blk, 'val>(
        name: &str,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let prev_for_compute = prev.clone_for_compute_result();
        let ov = prev.ov(subcmp_info);
        prev.lvalue.get_value::<(), _>(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&ov),
            &|subcmp_value_inputs: Value<'ctx, 'val>,
              fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>|
             -> Result<()> {
                Self::write_input_field(name, subcmp_value_inputs, val, codegen, fc, location)?;
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
            &|subcmp_value: Value<'ctx, 'val>,
              fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>| {
                let subcmp_value_inputs = prev_for_compute.lvalue.get_value(
                    codegen,
                    fc,
                    subcmp_info,
                    location,
                    Some(&ov),
                    &|subcmp_value_inputs: Value<'ctx, 'val>,
                      _: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>| {
                        Ok(subcmp_value_inputs)
                    },
                )?;
                let written_size = Self::input_write_size(
                    name,
                    subcmp_value_inputs.r#type().try_into()?,
                    prev.input_indices,
                    codegen,
                )?;
                Self::complete_subcmp_write(
                    subcmp_value,
                    subcmp_value_inputs,
                    written_size,
                    codegen,
                    fc,
                    location,
                )?;
                // Persist the decremented count regardless of whether this input completed
                // the subcomponent. If it did, this also stores the computed instance.
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
    }

    /// Emits the write operations.
    pub fn write<'ctx, 'blk, 'val>(
        self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        /// Handle [Lvalue::Root] with [Root::Signal] case.
        fn write_root_signal<'ctx, 'blk, 'val>(
            var: String,
            val: Value<'ctx, 'val>,
            target: WriteTarget,
            fc: &mut FunctionContext<'_, 'ctx, '_, 'blk, 'val>,
            location: Location<'ctx>,
            signal_write_info: &dyn SignalWriteInfo,
        ) -> Result<()> {
            if target.is_compute() && !signal_write_info.signal_already_written(&var) {
                let block = fc.block_ctx.get_decl_block_of_value(&var)?;

                let self_value = fc.func.self_value_of_compute()?;
                // Write value to field of "self" struct.
                fc.block_ctx.enqueue_struct_write_in_block(
                    block,
                    location,
                    self_value,
                    var.clone(),
                    val,
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

        if self.try_write_data(
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
                Self::from_lvalue(*prev, self.compute_result, self.input_indices),
                val,
                target,
                codegen,
                fc,
                location,
                signal_write_info,
                subcmp_info,
            ),
            Lvalue::Field { name, prev } => Self::write_subcmp(
                name,
                Self::from_lvalue(*prev, self.compute_result, self.input_indices),
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
