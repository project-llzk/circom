//! Helper type for constructing operations that write using [`Access`].

use crate::function::FunctionContext;
use crate::function::GenerateLLZKInFunction;
use crate::program_ext::ProgramLike;
use crate::shared::comp_type;
use crate::shared::region_with_block;
use crate::shared::LlzkCodegen;
use crate::subcmp::names::COMP;
use crate::subcmp::names::COUNT;
use crate::template::TemplateContext;
use anyhow::Result;
use llzk::builder::OpBuilder;
use llzk::dialect::cast;
use llzk::dialect::r#struct;
use llzk::prelude::function;
use llzk::prelude::pod;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::Location;
use llzk::prelude::PodType;
use llzk::prelude::StructType;
use llzk::prelude::SymbolRefAttribute;
use llzk::prelude::Value;
use llzk::prelude::ValueLike;
use melior::dialect::arith;
use melior::dialect::scf;
use melior::ir::BlockLike as _;
use melior::ir::RegionLike as _;
use melior::ir::Type;
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
        /// True if we are writing the result of calling a @compute function.
        compute_result: bool,
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
        access.iter().fold(Self::Root { var, op, compute_result: false }, |wc, access| {
            match (wc, access) {
                (WriteChain::Array { mut indices, prev }, Access::ArrayAccess(expression)) => {
                    indices.push(expression);
                    WriteChain::Array { indices, prev }
                }
                (wc, Access::ComponentAccess(name)) => {
                    WriteChain::Subcmp { name, prev: Box::new(wc) }
                }
                (wc, Access::ArrayAccess(expression)) => {
                    WriteChain::Array { indices: vec![expression], prev: Box::new(wc) }
                }
            }
        })
    }

    /// Handle [WriteChain::Array] case of [`WriteChain::write`].
    #[allow(clippy::too_many_arguments)]
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
        let arr_ref = prev.get_value(codegen, fc, template, location, target)?;
        let indices = fc.gen_index_ops(indices, codegen, location)?;
        fc.append_array_write(arr_ref, &indices, location, val, None)?;
        prev.write(arr_ref, target, codegen, fc, location, template)
    }

    /// Handle [WriteChain::Subcmp] case of [`WriteChain::write`].
    #[allow(clippy::too_many_arguments)]
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
        let subcmp_value_inputs = prev.get_value(codegen, fc, template, location, target)?;
        fc.append_op_no_result(codegen.new_pod_write_op(subcmp_value_inputs, name, val, location))?;
        let prev_for_compute = prev.clone_for_compute_result();
        prev.write(subcmp_value_inputs, target, codegen, fc, location, template)?;
        // Read the subcomponent's memory, which should be the memory pod.
        let subcmp_value = prev_for_compute.get_value(codegen, fc, template, location, target)?;

        let counter = fc.gen_subcmp_decrease_counter(codegen, location, subcmp_value, 1)?;
        fc.gen_scf_if_is_zero(counter, location, codegen, |fc| {
            let struct_type =
                StructType::try_from(comp_type(PodType::try_from(subcmp_value.r#type())?)?)?;
            let subcmp_instance =
                fc.gen_compute_call(struct_type, subcmp_value_inputs, location, codegen)?;
            fc.append_op_no_result(codegen.new_pod_write_op(
                subcmp_value,
                COMP,
                subcmp_instance,
                location,
            ))?;
            prev_for_compute.write(subcmp_value, target, codegen, fc, location, template)
        })
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
        /// Handle [WriteChain::Root] with [RootWriteOp::Signal] case.
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

        // If we are writing into a variable annotated as a subcomponent and we are
        // writing in the constraint function skip the whole chain.
        if let WriteChain::Root { var, op: RootWriteOp::Var, .. } = self.root() {
            if target.is_constrain() && template.is_subcmp(var) {
                return Ok(());
            }
        }

        match self {
            WriteChain::Root { var, op: RootWriteOp::Signal, compute_result } => {
                // We know we are assigning a subcomponent signal if the root var is the name
                // of the var listed as a subcomponent.
                if template.is_subcmp(var) {
                    return fc.block_ctx.set_named_value(
                        if compute_result { var.to_owned() } else { format!("{var}$inputs") },
                        val,
                    );
                }
                write_root_signal(var, val, target, fc, location, template)
            }
            WriteChain::Root { var, op: RootWriteOp::Var, .. } => {
                if template.is_subcmp(var) {
                    return Ok(()); // Do nothing (for now)
                }
                fc.block_ctx.set_named_value(var.to_string(), val)
            }
            WriteChain::Array { indices, prev } => {
                Self::write_array(indices, *prev, val, target, codegen, fc, location, template)
            }
            WriteChain::Subcmp { name, prev } => {
                Self::write_subcmp(name, *prev, val, target, codegen, fc, location, template)
            }
        }
    }

    /// Creates a copy of the chain with the `compute_result` flag set to true.
    fn clone_for_compute_result(&self) -> Self {
        match self {
            WriteChain::Root { var, op, .. } => {
                WriteChain::Root { var, op: *op, compute_result: true }
            }
            WriteChain::Array { indices, prev } => WriteChain::Array {
                indices: indices.clone(),
                prev: Box::new(prev.clone_for_compute_result()),
            },
            WriteChain::Subcmp { name, prev } => {
                WriteChain::Subcmp { name, prev: Box::new(prev.clone_for_compute_result()) }
            }
        }
    }

    /// Returns the root of the chain.
    fn root(&self) -> &Self {
        match self {
            root @ WriteChain::Root { .. } => root,
            WriteChain::Array { prev, .. } | WriteChain::Subcmp { prev, .. } => prev.root(),
        }
    }

    /// Handle [WriteChain::Root] with [RootWriteOp::Signal] case of [`WriteChain::get_value`].
    fn get_root_signal<'ctx, 'val>(
        &self,
        var: &str,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // Both compute and constrain functions should have the `var` defined:
        // compute from an existing assignment, or constrain from pre-generation
        // of the `readf` in `gen_template_llzk`.
        fc.block_ctx.get_named_value(var).copied()
    }

    /// Handle [WriteChain::Root] case of [`WriteChain::get_value`] other than
    /// [RootWriteOp::Signal].
    fn get_root_value<'ctx, 'val>(
        &self,
        var: &str,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        fc.block_ctx.get_named_value(var).copied()
    }

    /// Handle [WriteChain::Array] case of [`WriteChain::get_value`].
    fn get_array_value<'ctx, 'val>(
        &self,
        indices: &[&Expression],
        prev: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        let indices = fc.gen_index_ops(indices.iter().copied(), codegen, location)?;
        fc.append_array_read(prev, &indices, location, None)
            .map(|v| fc.subcmp_calls.propagate(&prev, v))
    }

    /// Handle [WriteChain::Subcmp]  in [`WriteChain::get_value`].
    ///
    /// The only subcmp signals that can be used inside a write chain are input signals.
    fn get_subcmp<'ctx, 'val>(
        &self,
        signal_name: &str,
        subcmp_value: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        fc.append_op_unnamed_result(pod::read(
            location,
            subcmp_value,
            FlatSymbolRefAttribute::new(codegen.context, signal_name),
            PodType::try_from(subcmp_value.r#type())?
                .get_type_of_record(signal_name)
                .ok_or_else(|| anyhow::anyhow!("subcomponent signal {signal_name} not found"))?,
        ))
    }

    /// Returns a SSA representing the op.
    ///
    /// It could be a placeholder operation at this point (usually represented with `undef.undef`).
    pub fn get_value<'ctx, 'val>(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        fc: &mut FunctionContext<'ctx, '_, '_, 'val>,
        template: &TemplateContext<'ctx, '_, '_, '_, 'val>,
        location: Location<'ctx>,
        target: WriteTarget,
    ) -> Result<Value<'ctx, 'val>> {
        match self {
            WriteChain::Root { var, op: RootWriteOp::Signal, compute_result } => {
                if !compute_result && template.is_subcmp(var) {
                    return self.get_root_signal(&format!("{var}$inputs"), fc);
                }
                self.get_root_signal(var, fc)
            }
            WriteChain::Root { var, op: RootWriteOp::Var, .. } => self.get_root_value(var, fc),
            WriteChain::Array { indices, prev } => self.get_array_value(
                indices,
                prev.get_value(codegen, fc, template, location, target)?,
                codegen,
                fc,
                location,
            ),
            WriteChain::Subcmp { name: signal_name, prev } => self.get_subcmp(
                signal_name,
                prev.get_value(codegen, fc, template, location, target)?,
                codegen,
                fc,
                location,
            ),
        }
    }
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
            WriteChain::Root { var, op, .. } => {
                write!(
                    f,
                    "{}:{var}",
                    match op {
                        RootWriteOp::Signal => "Signal",
                        RootWriteOp::Var => "Var",
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
