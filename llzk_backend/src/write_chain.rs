//! Helper type for constructing operations that write using [`Access`].

use crate::function::FunctionContext;
use crate::function::InfoProviders;
use crate::lvalue::Lvalue;
use crate::lvalue::OverrideVar;
use crate::lvalue::Root;
use crate::program_ext::ProgramLike;
use crate::shared::comp_type;
use crate::shared::LlzkCodegen;
use crate::subcmp::names::COMP;
use crate::subcmp::SubcmpInfo;
use crate::template::TemplateContext;
use anyhow::Result;
use llzk::dialect::r#struct;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::Location;
use llzk::prelude::PodType;
use llzk::prelude::StructType;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use program_structure::ast::Access;
use program_structure::ast::Expression;
use std::convert::TryFrom as _;
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
struct Override<'info> {
    /// If true, means that the write chain is storing the result of a call to compute.
    compute_result: bool,
    /// Reference to a subcomponent information provider.
    subcmp_info: &'info dyn SubcmpInfo,
}

impl OverrideVar for Override<'_> {
    fn override_var(&self, var: &str, op: Root) -> Option<String> {
        (!self.compute_result && self.subcmp_info.is_subcmp(var) && op == Root::Signal)
            .then(|| crate::subcmp::names::inputs(var))
    }
}

/// Helper type that defines a chain of write operations.
#[derive(Debug)]
pub struct WriteChain<'ast> {
    /// Location value this write action takes place on.
    lvalue: Lvalue<'ast>,
    /// If true, means that the write chain is storing the result of a call to compute.
    compute_result: bool,
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

    /// Handle [Lvalue::Array] case of [`WriteChain::write`].
    #[allow(clippy::too_many_arguments)]
    fn write_array<'ctx, 'val>(
        indices: Vec<&Expression>,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo,
    ) -> Result<()> {
        let arr_ref = prev.lvalue.get_value(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&prev.ov(subcmp_info)),
        )?;
        let indices = fc.gen_index_ops(
            indices,
            codegen,
            location,
            InfoProviders { subcmp_info, signal_write_info },
        )?;
        fc.append_array_write(codegen, arr_ref, &indices, location, val, None)?;
        prev.write(arr_ref, target, codegen, fc, location, signal_write_info, subcmp_info)
    }

    /// Handle [Lvalue::Subcmp] case of [`WriteChain::write`].
    #[allow(clippy::too_many_arguments)]
    fn write_subcmp<'ctx, 'val>(
        name: &str,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo,
    ) -> Result<()> {
        let subcmp_value_inputs = prev.lvalue.get_value(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&prev.ov(subcmp_info)),
        )?;
        fc.append_op_no_result(codegen.new_pod_write_op(location, subcmp_value_inputs, name, val))?;
        let prev_for_compute = prev.clone_for_compute_result();
        prev.write(
            subcmp_value_inputs,
            target,
            codegen,
            fc,
            location,
            signal_write_info,
            subcmp_info,
        )?;
        // Read the subcomponent's memory, which should be the memory pod.
        let subcmp_value = prev_for_compute.lvalue.get_value(
            codegen,
            fc,
            subcmp_info,
            location,
            Some(&prev_for_compute.ov(subcmp_info)),
        )?;

        let counter = fc.gen_subcmp_decrease_counter(codegen, location, subcmp_value, 1)?;
        fc.gen_scf_if_is_zero(counter, location, codegen, |fc| {
            let struct_type =
                StructType::try_from(comp_type(PodType::try_from(subcmp_value.r#type())?)?)?;
            let subcmp_instance =
                fc.gen_compute_call(struct_type, subcmp_value_inputs, location, codegen)?;
            fc.append_op_no_result(codegen.new_pod_write_op(
                location,
                subcmp_value,
                COMP,
                subcmp_instance,
            ))?;
            prev_for_compute.write(
                subcmp_value,
                target,
                codegen,
                fc,
                location,
                signal_write_info,
                subcmp_info,
            )
        })
    }

    #[allow(clippy::too_many_arguments)]
    /// Emits the write operations.
    pub fn write<'ctx, 'val>(
        self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'_, 'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        signal_write_info: &dyn SignalWriteInfo,
        subcmp_info: &dyn SubcmpInfo,
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
    fn ov<'info>(&self, template: &'info dyn SubcmpInfo) -> Override<'info> {
        Override { compute_result: self.compute_result, subcmp_info: template }
    }
}

impl fmt::Display for WriteChain<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Display::fmt(&self.lvalue, f)
    }
}
