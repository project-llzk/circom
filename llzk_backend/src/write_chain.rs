//! Helper type for constructing operations that write using [`Access`].

use crate::function::FunctionContext;
use crate::function::GenerateLLZKInFunction;
use crate::program_ext::ProgramLike;
use crate::shared::get_constrain_call;
use crate::shared::insert_after_if_op_result;
use crate::shared::op_result_owner;
use crate::shared::set_operand_if_undef;
use crate::shared::LlzkCodegen;
use crate::template::TemplateContext;
use crate::template_ext::TemplateLike as _;
use anyhow::Result;
use llzk::builder::OpBuilder;
use llzk::dialect::cast;
use llzk::dialect::r#struct;
use llzk::prelude::r#struct::is_struct_readf;
use llzk::prelude::CallOpLike as _;
use llzk::prelude::CallOpRef;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::Location;
use llzk::prelude::OperationLike as _;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use llzk::value_ext::replace_all_uses;
use program_structure::ast::Access;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use std::cmp;
use std::convert::TryFrom as _;
use std::fmt;

/// Type of write operation performed at the root of the chain
#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
pub enum RootWriteOp {
    /// Write into a signal.
    Signal,
    /// Write into a felt var.
    Var,
    /// Write into a subcomponent var.
    Subcmp,
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

/// Helper type that defines a chain of write operations.
#[derive(Debug)]
pub enum WriteChain<'ast> {
    /// Root of the chain.
    Root {
        /// Name of the variable.
        var: &'ast str,
        /// Type of the variable written into.
        op: RootWriteOp,
    },
    /// Represents a write into an array.
    Array {
        /// List of indexing expressions.
        indices: Vec<&'ast Expression>,
        /// Location accessed with as an array.
        prev: Box<WriteChain<'ast>>,
    },
    /// Represents a write into a subcomponent signal.
    Subcmp {
        /// Name of the field read with dot-notation.
        name: &'ast str,
        /// Location the field is read from.
        prev: Box<WriteChain<'ast>>,
    },
}

impl<'ast> WriteChain<'ast> {
    /// Creates a new write chain.
    pub fn new(var: &'ast str, op: RootWriteOp, access: &'ast [Access]) -> Self {
        access.iter().fold(Self::Root { var, op }, |wc, access| match (wc, access) {
            (WriteChain::Array { mut indices, prev }, Access::ArrayAccess(expression)) => {
                indices.push(expression);
                WriteChain::Array { indices, prev }
            }
            (wc, Access::ComponentAccess(name)) => WriteChain::Subcmp { name, prev: Box::new(wc) },
            (wc, Access::ArrayAccess(expression)) => {
                WriteChain::Array { indices: vec![expression], prev: Box::new(wc) }
            }
        })
    }

    fn write_array<'ctx, 'val>(
        indices: Vec<&Expression>,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        template: &TemplateContext<'ctx, '_, '_, '_, 'val>,
    ) -> Result<()> {
        let arr_ref = prev.get_value(codegen, fc, location, target)?;
        let indices = gen_index_ops(indices, codegen, fc, location)?;
        fc.append_array_write(arr_ref, &indices, location, val, None)?;
        prev.write(arr_ref, target, codegen, fc, location, template)
    }

    fn write_subcmp<'ctx, 'val>(
        name: &str,
        prev: Self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        template: &TemplateContext<'ctx, '_, '_, '_, 'val>,
    ) -> Result<()> {
        let subcmp_value = prev.get_value(codegen, fc, location, target)?;
        let arg_idx = fc.lookup_arg_idx(name, &subcmp_value, codegen)?;
        let (arg_offset, call_op) = match target {
            WriteTarget::Compute => (0, op_result_owner(subcmp_value)?),
            WriteTarget::Constrain => (1, get_constrain_call(subcmp_value)?),
            WriteTarget::Free => unreachable!(),
        };
        set_operand_if_undef(call_op, arg_idx + arg_offset, val)?;
        insert_after_if_op_result(val, call_op)?;

        prev.write(subcmp_value, target, codegen, fc, location, template)
    }

    /// Emits the write operations.
    pub fn write<'ctx, 'val>(
        self,
        val: Value<'ctx, 'val>,
        target: WriteTarget,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        template: &TemplateContext<'ctx, '_, '_, '_, 'val>,
    ) -> Result<()> {
        fn write_root_signal<'ctx, 'val>(
            var: &str,
            val: Value<'ctx, 'val>,
            target: WriteTarget,
            fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
            location: Location<'ctx>,
            template: &TemplateContext<'ctx, '_, '_, '_, 'val>,
        ) -> Result<()> {
            if target.is_compute() && !template.signal_already_written(var) {
                let block = fc.block_ctx.get_decl_block_of_value(var)?;

                let self_value = fc.func.self_value_of_compute()?;
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

        fn write_root_var<'ctx, 'val>(
            var: &str,
            val: Value<'ctx, 'val>,
            fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        ) -> Result<()> {
            fc.block_ctx.set_named_value(var.to_string(), val)
        }

        fn write_root_subcmp_in_compute<'ctx, 'val>(
            var: &str,
            val: Value<'ctx, 'val>,
            fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        ) -> Result<()> {
            let current = fc.block_ctx.get_named_value(var)?;
            if *current != val {
                replace_all_uses(*current, val);
            }
            fc.subcmp_calls.update_keys(*current, val);
            fc.block_ctx.set_named_value(var.to_string(), val)?;
            Ok(())
        }

        fn write_root_subcmp_in_constrain<'ctx, 'val>(
            var: &str,
            val: Value<'ctx, 'val>,
            fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        ) -> Result<()> {
            // Replace value
            let field_read = fc.block_ctx.get_named_value(var)?;
            // ASSERT: value comes from a `struct.readf`
            assert!(is_struct_readf(&op_result_owner(*field_read).unwrap()));
            if val != *field_read {
                replace_all_uses(val, *field_read);
            }
            fc.subcmp_calls.update_keys(val, *field_read);
            Ok(())
        }

        match self {
            WriteChain::Root { var, op: RootWriteOp::Signal } => {
                write_root_signal(var, val, target, fc, location, template)
            }
            WriteChain::Root { var, op: RootWriteOp::Var } => write_root_var(var, val, fc),
            WriteChain::Root { var, op: RootWriteOp::Subcmp } => match target {
                WriteTarget::Compute => write_root_subcmp_in_compute(var, val, fc),
                WriteTarget::Constrain => write_root_subcmp_in_constrain(var, val, fc),
                WriteTarget::Free => unreachable!(),
            },
            WriteChain::Array { indices, prev } => {
                Self::write_array(indices, *prev, val, target, codegen, fc, location, template)
            }
            WriteChain::Subcmp { name, prev } => {
                Self::write_subcmp(name, *prev, val, target, codegen, fc, location, template)
            }
        }
    }

    fn get_root_value<'ctx, 'val>(
        &self,
        var: &str,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        fc.block_ctx.get_named_value(var).copied()
    }

    fn get_array_value<'ctx, 'val>(
        &self,
        indices: &[&Expression],
        prev: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        let indices = gen_index_ops(indices.iter().copied(), codegen, fc, location)?;
        fc.append_array_read(prev, &indices, location, None)
            .map(|v| fc.subcmp_calls.propagate(&prev, v))
    }

    fn get_subcmp_in_compute<'ctx, 'val>(
        &self,
        signal_name: &str,
        subcmp_value: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        let template_data = fc
            .subcmp_calls
            .get(&subcmp_value)
            .ok_or_else(|| anyhow::anyhow!("subcomponent call for {subcmp_value} not found"))
            .and_then(|name| {
                codegen
                    .find_template_data(name)
                    .ok_or_else(|| anyhow::anyhow!("template {name:?} not found"))
            })?;
        if template_data.get_outputs().contains_key(signal_name) {
            fc.append_op_unnamed_result(r#struct::readf(
                &OpBuilder::new(codegen.context),
                location,
                codegen.felt_type().into(),
                subcmp_value,
                signal_name,
            )?)
        } else if template_data.get_inputs().contains_key(signal_name) {
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

    fn get_subcmp_in_constrain<'ctx, 'val>(
        &self,
        signal_name: &str,
        subcmp_value: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        let template_data = fc
            .subcmp_calls
            .get(&subcmp_value)
            .ok_or_else(|| anyhow::anyhow!("subcomponent call for {subcmp_value} not found"))
            .and_then(|name| {
                codegen
                    .find_template_data(name)
                    .ok_or_else(|| anyhow::anyhow!("template {name:?} not found"))
            })?;
        if template_data.get_outputs().contains_key(signal_name) {
            fc.append_op_unnamed_result(r#struct::readf(
                &OpBuilder::new(codegen.context),
                location,
                codegen.felt_type().into(),
                subcmp_value,
                signal_name,
            )?)
        } else if template_data.get_inputs().contains_key(signal_name) {
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

    /// Returns a SSA representing the op.
    ///
    /// It could be a placeholder operation at this point (usually represented with `undef.undef`).
    pub fn get_value<'ctx, 'val>(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
        target: WriteTarget,
    ) -> Result<Value<'ctx, 'val>> {
        match self {
            WriteChain::Root { var, op: RootWriteOp::Signal } => {
                if target.is_constrain() {
                    // Read value from field of "self" struct.
                    let expected_type = fc.block_ctx.get_named_value(var).unwrap().r#type();
                    let self_value = fc.func.self_value_of_constrain()?;
                    fc.append_op_unnamed_result(r#struct::readf(
                        &OpBuilder::new(codegen.context),
                        location,
                        expected_type,
                        self_value,
                        var,
                    )?)
                } else {
                    fc.block_ctx.get_named_value(var).copied()
                }
            }
            WriteChain::Root { var, .. } => self.get_root_value(*var, fc),
            WriteChain::Array { indices, prev } => self.get_array_value(
                indices,
                prev.get_value(codegen, fc, location, target)?,
                codegen,
                fc,
                location,
            ),
            WriteChain::Subcmp { name: signal_name, prev } => match target {
                WriteTarget::Compute => self.get_subcmp_in_compute(
                    *signal_name,
                    prev.get_value(codegen, fc, location, target)?,
                    codegen,
                    fc,
                    location,
                ),
                WriteTarget::Constrain => self.get_subcmp_in_constrain(
                    *signal_name,
                    prev.get_value(codegen, fc, location, target)?,
                    codegen,
                    fc,
                    location,
                ),
                WriteTarget::Free => unreachable!(),
            },
        }
    }
}

/// Creates LLZK ops for array indexing from the collection of elements.
fn gen_index_ops<'ctx, 'func, 'blk, 'val, 'ast, E>(
    indices: impl IntoIterator<Item = &'ast E>,
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    fc: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
) -> Result<Vec<Value<'ctx, 'val>>>
where
    E: GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val, Output = Value<'ctx, 'val>> + 'ast,
{
    indices
        .into_iter()
        .map(|e| {
            let val = e.gen_llzk_in_function(codegen, fc)?;
            fc.append_op_unnamed_result(cast::toindex(location, val))
        })
        .collect()
}

impl fmt::Display for WriteChain<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fn print_expr(expr: &impl AsRef<Expression>, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            let expr = expr.as_ref();
            let d = depth(expr);
            if d > 1 {
                write!(f, "(")?;
            }
            display_expr(expr, f)?;
            if d > 1 {
                write!(f, ")")?;
            }
            Ok(())
        }

        fn interleave<A, I, S>(
            args: I,
            sep: &S,
            f: &mut fmt::Formatter<'_>,
            print_fn: impl Fn(A, &mut fmt::Formatter<'_>) -> fmt::Result,
        ) -> fmt::Result
        where
            I: IntoIterator<Item = A>,
            I::IntoIter: DoubleEndedIterator + ExactSizeIterator,
            S: fmt::Display + ?Sized,
        {
            args.into_iter().rev().enumerate().rev().try_for_each(|(rev_idx, arg)| {
                print_fn(arg, f)?;
                if rev_idx > 0 {
                    write!(f, "{sep}")?;
                }
                Ok(())
            })
        }

        fn print_args<A, I>(
            args: I,
            f: &mut fmt::Formatter<'_>,
            print_fn: impl Fn(A, &mut fmt::Formatter<'_>) -> fmt::Result,
        ) -> fmt::Result
        where
            I: IntoIterator<Item = A>,
            I::IntoIter: DoubleEndedIterator + ExactSizeIterator,
        {
            write!(f, "(")?;
            interleave(args, ", ", f, print_fn)?;
            write!(f, ")")
        }

        fn display_expr(expr: &Expression, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            match expr {
                Expression::InfixOp { meta: _, lhe, infix_op, rhe } => {
                    print_expr(lhe, f)?;
                    let op_str = match infix_op {
                        ExpressionInfixOpcode::Mul => "*",
                        ExpressionInfixOpcode::Div => "/",
                        ExpressionInfixOpcode::Add => "+",
                        ExpressionInfixOpcode::Sub => "-",
                        ExpressionInfixOpcode::Pow => "**",
                        ExpressionInfixOpcode::IntDiv => "\\",
                        ExpressionInfixOpcode::Mod => "%",
                        ExpressionInfixOpcode::ShiftL => "<<",
                        ExpressionInfixOpcode::ShiftR => ">>",
                        ExpressionInfixOpcode::LesserEq => "<=",
                        ExpressionInfixOpcode::GreaterEq => ">=",
                        ExpressionInfixOpcode::Lesser => "<",
                        ExpressionInfixOpcode::Greater => ">",
                        ExpressionInfixOpcode::Eq => "==",
                        ExpressionInfixOpcode::NotEq => "!=",
                        ExpressionInfixOpcode::BoolOr => "||",
                        ExpressionInfixOpcode::BoolAnd => "&&",
                        ExpressionInfixOpcode::BitOr => "|",
                        ExpressionInfixOpcode::BitAnd => "&",
                        ExpressionInfixOpcode::BitXor => "^",
                    };
                    write!(f, " {op_str} ",)?;
                    print_expr(rhe, f)
                }
                Expression::PrefixOp { meta: _, prefix_op, rhe } => {
                    let op_str = match prefix_op {
                        ExpressionPrefixOpcode::Sub => "-",
                        ExpressionPrefixOpcode::BoolNot => "!",
                        ExpressionPrefixOpcode::Complement => "~",
                    };
                    write!(f, "{op_str}")?;
                    print_expr(rhe, f)
                }
                Expression::InlineSwitchOp { meta: _, cond, if_true, if_false } => {
                    print_expr(cond, f)?;
                    write!(f, " ? ")?;
                    print_expr(if_true, f)?;
                    write!(f, " : ")?;
                    print_expr(if_false, f)
                }
                Expression::ParallelOp { meta: _, rhe } => {
                    write!(f, "parallel ")?;
                    print_expr(rhe, f)
                }
                Expression::Variable { meta: _, name, access } => {
                    write!(f, "{name}")?;
                    for a in access {
                        match a {
                            Access::ComponentAccess(name) => write!(f, ".{name}"),
                            Access::ArrayAccess(expression) => display_expr(expression, f),
                        }?;
                    }
                    Ok(())
                }
                Expression::Number(_, big_int) => write!(f, "{big_int}"),
                Expression::BusCall { meta: _, id, args }
                | Expression::Call { meta: _, id, args } => {
                    write!(f, "{id}(")?;
                    print_args(args, f, display_expr)?;
                    write!(f, ")")
                }
                Expression::AnonymousComp { meta: _, id, is_parallel, params, signals, names } => {
                    if *is_parallel {
                        write!(f, "parallel ")?;
                    }
                    write!(f, "{id}")?;
                    print_args(params, f, display_expr)?;
                    match names {
                        Some(names) => print_args(
                            std::iter::zip(names, signals),
                            f,
                            |((op, name), signal), f| {
                                let op_str = match op {
                                    AssignOp::AssignSignal => "<==",
                                    AssignOp::AssignConstraintSignal => "<--",
                                    AssignOp::AssignVar => unreachable!(),
                                };
                                write!(f, "{name} {op_str} ")?;
                                display_expr(signal, f)
                            },
                        ),
                        None => print_args(signals, f, display_expr),
                    }
                }
                Expression::ArrayInLine { meta: _, values } => {
                    write!(f, "[")?;
                    interleave(values, ", ", f, display_expr)?;
                    write!(f, "]")
                }
                Expression::Tuple { meta: _, values } => print_args(values, f, display_expr),
                Expression::UniformArray { meta: _, value, dimension } => {
                    write!(f, "[")?;
                    display_expr(value, f)?;
                    write!(f, "; ")?;
                    display_expr(dimension, f)?;
                    write!(f, "]")
                }
            }
        }

        fn depth(expr: &Expression) -> usize {
            match expr {
                Expression::InfixOp { meta: _, lhe, infix_op: _, rhe } => {
                    1 + cmp::max(depth(lhe), depth(rhe))
                }
                Expression::PrefixOp { meta: _, prefix_op: _, rhe } => depth(rhe),
                Expression::InlineSwitchOp { meta: _, cond, if_true, if_false } => {
                    1 + cmp::max(cmp::max(depth(cond), depth(if_true)), depth(if_false))
                }
                Expression::ParallelOp { meta: _, rhe } => depth(rhe),
                _ => 1,
            }
        }

        match self {
            WriteChain::Root { var, op } => {
                write!(
                    f,
                    "{}:{var}",
                    match op {
                        RootWriteOp::Signal => "Signal",
                        RootWriteOp::Var => "Var",
                        RootWriteOp::Subcmp => "Subcmp",
                    }
                )
            }
            WriteChain::Array { indices, prev } => {
                fmt::Display::fmt(prev.as_ref(), f)?;
                for index in indices {
                    write!(f, "[")?;
                    display_expr(index, f)?;
                    write!(f, "]")?;
                }
                Ok(())
            }
            WriteChain::Subcmp { name, prev } => {
                fmt::Display::fmt(prev.as_ref(), f)?;
                write!(f, ".{name}")
            }
        }
    }
}
