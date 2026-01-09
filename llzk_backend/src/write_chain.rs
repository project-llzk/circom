//! Helper type for constructing operations that write using [`Access`].

use std::convert::TryFrom as _;

use anyhow::Result;
use llzk::{
    builder::OpBuilder,
    dialect::{array, cast, r#struct},
    prelude::{ArrayType, CallOpLike as _, CallOpRef, FuncDefOpLike as _, OperationLike as _},
};
use melior::ir::{Location, Value, ValueLike as _};
use program_structure::ast::Access;

use crate::{
    function::{FunctionContext, GenerateLLZKInFunction as _},
    program_ext::ProgramLike,
    shared::{
        get_constrain_call, insert_after_if_op_result, op_result_owner, set_operand_if_undef,
        LlzkCodegen,
    },
    template::TemplateContext,
    template_ext::TemplateLike as _,
};

/// Type of write operation performed at the root of the chain
#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
pub enum RootWriteOp {
    /// The write is done to a signal.
    Signal,
}

/// Indicates the target function the write operation is happening on.
#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
pub enum WriteTarget {
    /// The `@compute` function of a struct.
    Compute,
    /// The `@constrain` function of a struct.
    Constrain,
    /// A free function.
    Free,
}

/// Helper type that defines a chain of write operations.
#[derive(Debug)]
pub enum WriteChain<'ast, V> {
    /// Root of the chain.
    Root { self_value: V, var: &'ast str, op: RootWriteOp },
    /// Represents a write into an array.
    Array { indices: Vec<V>, prev: Box<WriteChain<'ast, V>> },
    /// Represents a write into a subcomponent signal
    Subcmp { name: &'ast str, prev: Box<WriteChain<'ast, V>> },
}

impl<'ast, 'ctx, 'val> WriteChain<'ast, Value<'ctx, 'val>> {
    /// Creates a new write chain while lowering inside a template.
    pub fn new<'func, 'blk>(
        var: &'ast str,
        op: RootWriteOp,
        access: &'ast [Access],
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
        location: Location<'ctx>,
    ) -> Result<Self> {
        let self_value = fc.func.self_value_of_compute()?;
        access.iter().try_fold(Self::Root { self_value, var, op }, |wc, access| {
            match (wc, access) {
                (WriteChain::Array { mut indices, prev }, Access::ArrayAccess(expression)) => {
                    let expr_value = expression.gen_llzk_in_function(codegen, fc)?;
                    indices.push(fc.append_op_unnamed_result(cast::toindex(location, expr_value))?);
                    Ok(WriteChain::Array { indices, prev })
                }
                (wc, Access::ComponentAccess(name)) => {
                    Ok(WriteChain::Subcmp { name, prev: Box::new(wc) })
                }
                (wc, Access::ArrayAccess(expression)) => {
                    let expr_value = expression.gen_llzk_in_function(codegen, fc)?;
                    Ok(WriteChain::Array {
                        indices: vec![
                            fc.append_op_unnamed_result(cast::toindex(location, expr_value))?
                        ],
                        prev: Box::new(wc),
                    })
                }
            }
        })
    }

    /// Emits the write operations.
    pub fn write<'func, 'blk>(
        self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
        location: Location<'ctx>,
        template: &TemplateContext<'ctx, '_, 'func, 'blk, 'val>,
    ) -> Result<()> {
        match self {
            WriteChain::Root { self_value, var, op: RootWriteOp::Signal } => {
                if !template.signal_already_written(var) {
                    let block = fc.block_ctx.get_decl_block_of_value(var)?;

                    // Write value to field of "self" struct.
                    fc.block_ctx.enqueue_in_block(
                        r#struct::writef(location, self_value, var, val)?.into(),
                        block,
                    )?;
                    fc.block_ctx.set_named_value_at_declaration(var.to_string(), val)?;
                    template.mark_signal_as_written(var.to_string())
                }
                Ok(())
            }
            WriteChain::Array { indices, prev } => {
                let array = prev.get_value(codegen, fc, location, target)?;
                fc.append_op_no_result(array::write(location, array, &indices, val))?;
                prev.write(array, target, codegen, fc, location, template)
            }
            WriteChain::Subcmp { name, prev } => {
                let subcmp_value = prev.get_value(codegen, fc, location, target)?;
                let arg_idx = fc.lookup_arg_idx(name, &subcmp_value, codegen)?;
                let (arg_offset, call_op) = match target {
                    WriteTarget::Compute => (0, op_result_owner(subcmp_value)?),
                    WriteTarget::Constrain => (1, get_constrain_call(subcmp_value)?),
                    WriteTarget::Free => unreachable!(),
                };
                set_operand_if_undef(call_op, arg_idx + arg_offset, val)?;
                insert_after_if_op_result(val, call_op);

                prev.write(subcmp_value, target, codegen, fc, location, template)
            }
        }
    }

    /// Returns a SSA representing the op.
    ///
    /// It could be a placeholder operation at this point (usually represented with `undef.undef`).
    fn get_value<'func, 'blk>(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
        location: Location<'ctx>,
        target: WriteTarget,
    ) -> Result<Value<'ctx, 'val>> {
        match self {
            WriteChain::Root { var, .. } => fc.block_ctx.get_named_value(*var).copied(),
            WriteChain::Array { indices, prev } => {
                let array = prev.get_value(codegen, fc, location, target)?;
                let elt_type = ArrayType::try_from(array.r#type())?.element_type();
                fc.append_op_unnamed_result(array::read(location, elt_type, array, &indices))
            }
            WriteChain::Subcmp { name: signal_name, prev } => match target {
                WriteTarget::Compute => {
                    let subcmp_value = prev.get_value(codegen, fc, location, target)?;
                    let template_data = fc
                        .subcmp_calls
                        .get(&subcmp_value)
                        .ok_or_else(|| {
                            anyhow::anyhow!("subcomponent call for {subcmp_value} not found")
                        })
                        .and_then(|name| {
                            codegen
                                .find_template_data(name)
                                .ok_or_else(|| anyhow::anyhow!("template {name:?} not found"))
                        })?;
                    if template_data.get_outputs().contains_key(*signal_name) {
                        fc.append_op_unnamed_result(r#struct::readf(
                            &OpBuilder::new(codegen.context),
                            location,
                            codegen.felt_type().into(),
                            subcmp_value,
                            signal_name,
                        )?)
                    } else if template_data.get_inputs().contains_key(*signal_name) {
                        let idx = template_data
                            .get_declaration_inputs()
                            .iter()
                            .find_map(|(s, idx)| (signal_name == s).then_some(*idx))
                            .expect("signal in mapping but not in declaration list");
                        let call = CallOpRef::try_from(op_result_owner(subcmp_value)?)?;
                        assert!(call.callee_is_struct_compute());
                        Ok(call.operand(idx)?)
                    } else {
                        anyhow::bail!("signal {signal_name} is internal");
                    }
                }
                WriteTarget::Constrain => {
                    let subcmp_value = prev.get_value(codegen, fc, location, target)?;
                    let template_data = fc
                        .subcmp_calls
                        .get(&subcmp_value)
                        .ok_or_else(|| {
                            anyhow::anyhow!("subcomponent call for {subcmp_value} not found")
                        })
                        .and_then(|name| {
                            codegen
                                .find_template_data(name)
                                .ok_or_else(|| anyhow::anyhow!("template {name:?} not found"))
                        })?;
                    if template_data.get_outputs().contains_key(*signal_name) {
                        fc.append_op_unnamed_result(r#struct::readf(
                            &OpBuilder::new(codegen.context),
                            location,
                            codegen.felt_type().into(),
                            subcmp_value,
                            signal_name,
                        )?)
                    } else if template_data.get_inputs().contains_key(*signal_name) {
                        let idx = template_data
                            .get_declaration_inputs()
                            .iter()
                            .enumerate()
                            .find_map(|(idx, (s, _))| (signal_name == s).then_some(idx))
                            .expect("signal in mapping but not in declaration list");
                        let call = get_constrain_call(subcmp_value)?;
                        Ok(call.operand(idx + 1)?)
                    } else {
                        anyhow::bail!("signal {signal_name}  is internal");
                    }
                }
                WriteTarget::Free => unreachable!(),
            },
        }
    }
}
