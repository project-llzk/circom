//! Types for handling location values (a.k.a. lvalues).

use crate::function::InfoProviders;
use crate::gen_context::BlockGenContext;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::LlzkCodegen;
use crate::subcmp::names::COMP;
use crate::subcmp::SubcmpInfo;
use anyhow::Result;
use llzk::dialect::pod;
use llzk::dialect::r#struct;
use llzk::prelude::Location;
use llzk::prelude::PodType;
use llzk::prelude::StructType;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use program_structure::ast::Access;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use std::borrow::Cow;
use std::cmp;
use std::convert::TryFrom as _;
use std::fmt;

/// Decorator trait that can modify the name of the root variable.
pub trait OverrideVar {
    /// May override the var name. Returns `None` if the var name was not overriden.
    fn override_var(&self, var: &str, op: Root) -> Option<String>;
}

impl OverrideVar for Option<&dyn OverrideVar> {
    fn override_var(&self, var: &str, op: Root) -> Option<String> {
        self.as_ref().and_then(|t| t.override_var(var, op))
    }
}

/// Type of data at the root of the lvalue
#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
pub enum Root {
    /// Write into a signal.
    Signal,
    /// Write into a felt var.
    Var,
}

/// Helper type that defines a chain of write operations.
#[derive(Debug, Clone)]
pub enum Lvalue<'ast> {
    /// Root of the chain.
    Root {
        /// Name of the variable.
        var: &'ast str,
        /// Type of the variable written into.
        op: Root,
    },
    /// Array access.
    Array {
        /// List of indexing expressions.
        indices: Vec<&'ast Expression>,
        /// Location accessed from as an array.
        prev: Box<Lvalue<'ast>>,
    },
    /// Access via dot-notation.
    Subcmp {
        /// Name of the field read with dot-notation.
        name: &'ast str,
        /// Location the field is read from.
        prev: Box<Lvalue<'ast>>,
    },
}

impl<'ast> Lvalue<'ast> {
    /// Creates a new lvalue.
    pub fn new(var: &'ast str, op: Root, access: &'ast [Access]) -> Self {
        access.iter().fold(Lvalue::Root { var, op }, |wc, access| match (wc, access) {
            (Lvalue::Array { mut indices, prev }, Access::ArrayAccess(expression)) => {
                indices.push(expression);
                Lvalue::Array { indices, prev }
            }
            (wc, Access::ComponentAccess(name)) => Lvalue::Subcmp { name, prev: Box::new(wc) },
            (wc, Access::ArrayAccess(expression)) => {
                Lvalue::Array { indices: vec![expression], prev: Box::new(wc) }
            }
        })
    }

    /// Returns the root of the lvalue.
    pub fn root(&self) -> &Self {
        match self {
            root @ Lvalue::Root { .. } => root,
            Lvalue::Array { prev, .. } | Lvalue::Subcmp { prev, .. } => prev.root(),
        }
    }

    /// Returns the root var name of the lvalue.
    fn root_var(&self) -> &str {
        match self {
            Lvalue::Root { var, .. } => var,
            Lvalue::Array { prev, .. } | Lvalue::Subcmp { prev, .. } => prev.root_var(),
        }
    }

    /// Handle [Lvalue::Root] with [Root::Signal] case of [`Lvalue::get_value`].
    fn get_root_signal<'ctx, 'val>(
        &self,
        var: &str,
        block_gen: &mut BlockGenContext<'ctx, '_, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // Both compute and constrain functions should have the `var` defined:
        // compute from an existing assignment, or constrain from pre-generation
        // of the `readm` in `gen_template_llzk`.
        block_gen.block_ctx.get_named_value(var).copied()
    }

    /// Handle [Lvalue::Root] case of [`Lvalue::get_value`] other than
    /// [Root::Signal].
    fn get_root_value<'ctx, 'val>(
        &self,
        var: &str,
        block_gen: &mut BlockGenContext<'ctx, '_, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        block_gen.block_ctx.get_named_value(var).copied()
    }

    /// Handle [Lvalue::Array] case of [`Lvalue::get_value`].
    fn get_array_value<'ctx, 'val>(
        &self,
        indices: &[&Expression],
        prev: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut BlockGenContext<'ctx, '_, 'val>,
        location: Location<'ctx>,
        info: InfoProviders<'_>,
    ) -> Result<Value<'ctx, 'val>> {
        let indices = block_gen.gen_index_ops(indices.iter().copied(), codegen, location, info)?;
        block_gen.append_array_read(prev, &indices, location, None)
    }

    /// Handle [Lvalue::Subcmp]  in [`Lvalue::get_value`] when the signal is an output of the
    /// subcomponent.
    fn get_subcmp_output<'ctx, 'val>(
        &self,
        signal_name: &str,
        subcmp_value: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut BlockGenContext<'ctx, '_, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        let comp_value = type_switch! { let ty = subcmp_value.r#type();
            PodType => {
                block_gen.append_op_unnamed_result(pod::read(
                    location,
                    subcmp_value,
                    codegen.flat_sym(COMP),
                    ty
                        .get_type_of_record(COMP)
                        .ok_or_else(|| {
                            anyhow::anyhow!(
                                "record {COMP} not found in subcomponent memory pod: {subcmp_value}"
                            )
                        })?,
                ))?
            }
            StructType as _ => subcmp_value,
        };
        let comp_value_type = StructType::try_from(comp_value.r#type())?;
        let field_ty = codegen
            .get_output_signal_type(shared::get_name_tail(&comp_value_type)?, signal_name)?;

        block_gen.append_op_unnamed_result(r#struct::readm(
            codegen.op_builder(),
            location,
            field_ty,
            comp_value,
            signal_name,
        )?)
    }

    /// Handle [Lvalue::Subcmp]  in [`Lvalue::get_value`] when the signal is an input of the
    /// subcomponent.
    fn get_subcmp_input<'ctx, 'val>(
        &self,
        signal_name: &str,
        subcmp_value: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut BlockGenContext<'ctx, '_, 'val>,
        location: Location<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        block_gen.append_op_unnamed_result(pod::read(
            location,
            subcmp_value,
            codegen.flat_sym(signal_name),
            PodType::try_from(subcmp_value.r#type())
                .map_err(|e| anyhow::anyhow!("not a pod type '{e}' coming from {subcmp_value}"))?
                .get_type_of_record(signal_name)
                .ok_or_else(|| {
                    anyhow::anyhow!(
                        "subcomponent input signal {signal_name} not found: {subcmp_value}"
                    )
                })?,
        ))
    }

    /// Returns the SSA [`Value`] representing the op.
    ///
    /// It could be a placeholder operation at this point (usually represented with `llzk.nondet`).
    pub fn get_value<'ctx, 'val>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut BlockGenContext<'ctx, '_, 'val>,
        subcmp_info: &dyn SubcmpInfo,
        location: Location<'ctx>,
        ov: Option<&dyn OverrideVar>,
    ) -> Result<Value<'ctx, 'val>> {
        macro_rules! var_name {
            ($ov:ident, $var:ident, $op:expr) => {
                $ov.override_var(*$var, $op)
                    .map(Cow::Owned)
                    .unwrap_or(Cow::Borrowed(*$var))
                    .as_ref()
            };
        }

        match self {
            Lvalue::Root { var, op: Root::Signal } => {
                self.get_root_signal(var_name!(ov, var, Root::Signal), block_gen)
            }
            Lvalue::Root { var, op: Root::Var } => {
                self.get_root_value(var_name!(ov, var, Root::Var), block_gen)
            }
            Lvalue::Array { indices, prev } => self.get_array_value(
                indices,
                prev.get_value(codegen, block_gen, subcmp_info, location, ov)?,
                codegen,
                block_gen,
                location,
                InfoProviders { subcmp_info, ..Default::default() },
            ),
            Lvalue::Subcmp { name: signal_name, prev } => {
                let root = prev.root_var();
                if !subcmp_info.is_subcmp(root) {
                    anyhow::bail!(
                        "variable '{root}' is not a subcomponent but it was accessed like one"
                    );
                }

                /// Overrides the input if the root is Signal. Only used if no decorator was passed.
                /// Replaces "{var}" with "{var}$inputs" in the inner layers of this lvalue.
                struct OverrideIfInput {
                    /// If true, and if the root is Signal, replaces the variable with the
                    /// `$inputs` version.
                    do_override: bool,
                }
                impl OverrideVar for OverrideIfInput {
                    fn override_var(&self, var: &str, op: Root) -> Option<String> {
                        let will_override = self.do_override && op == Root::Signal;
                        (will_override).then(|| crate::subcmp::names::inputs(var))
                    }
                }
                let info = subcmp_info.subcmp_info(root, codegen)?;
                let is_input = info.signal_is_input(signal_name);
                let ovii = OverrideIfInput { do_override: is_input };

                let subcmp_value =
                    prev.get_value(codegen, block_gen, subcmp_info, location, ov.or(Some(&ovii)))?;

                if is_input {
                    self.get_subcmp_input(signal_name, subcmp_value, codegen, block_gen, location)
                } else {
                    self.get_subcmp_output(signal_name, subcmp_value, codegen, block_gen, location)
                }
            }
        }
    }
}

impl fmt::Display for Lvalue<'_> {
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
            Lvalue::Root { var, op, .. } => {
                write!(
                    f,
                    "{}:{var}",
                    match op {
                        Root::Signal => "Signal",
                        Root::Var => "Var",
                    }
                )
            }
            Lvalue::Array { indices, prev } => {
                fmt::Display::fmt(prev.as_ref(), f)?;
                for index in indices {
                    write!(f, "[")?;
                    display_expr(index, f)?;
                    write!(f, "]")?;
                }
                Ok(())
            }
            Lvalue::Subcmp { name, prev } => {
                fmt::Display::fmt(prev.as_ref(), f)?;
                write!(f, ".{name}")
            }
        }
    }
}
