//! Types for handling location values (a.k.a. lvalues).

use crate::function::InfoProviders;
use crate::gen_context::BlockGenContext;
use crate::gen_context::NestedBlockInfo;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::LlzkCodegen;
use crate::subcmp::names::COMP;
use crate::subcmp::SubcmpInfo;
use anyhow::Result;
use llzk::dialect::llzk::nondet;
use llzk::dialect::pod;
use llzk::dialect::r#struct;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::Location;
use llzk::prelude::PodType;
use llzk::prelude::StructType;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use melior::dialect::arith;
use melior::dialect::scf;
use melior::ir::Block;
use melior::ir::BlockLike;
use melior::ir::Region;
use melior::ir::RegionLike;
use melior::ir::Type;
use num_traits::ToPrimitive;
use program_structure::ast::Access;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use std::borrow::Cow;
use std::cmp;
use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::TryFrom as _;
use std::fmt;
use std::iter::FromIterator as _;

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
    pub(crate) fn root_var(&self) -> &str {
        match self {
            Lvalue::Root { var, .. } => var,
            Lvalue::Array { prev, .. } | Lvalue::Subcmp { prev, .. } => prev.root_var(),
        }
    }

    /// Handle [Lvalue::Root] with [Root::Signal] case of [`Lvalue::get_value`].
    fn get_root_signal<'ctx, 'val>(
        &self,
        var: &str,
        block_gen: &mut BlockGenContext<'_, 'ctx, '_, 'val>,
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
        block_gen: &mut BlockGenContext<'_, 'ctx, '_, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        block_gen.block_ctx.get_named_value(var).copied()
    }

    /// Handle [Lvalue::Array] case of [`Lvalue::get_value`].
    ///
    /// The value read from the array is returned via the continuation.
    /// If the array is an actual LLZK array then the continuation is called only once.
    /// However, if the array is actual an array of mixed subcomponents, the continuation is
    /// called for each branch of the dispatch table.
    fn get_array_value<'decls, 'ctx, 'blk, 'val, 'cont, R, C>(
        &self,
        indices: &[&Expression],
        prev: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut C,
        location: Location<'ctx>,
        info: InfoProviders<'_, 'ctx>,
        cont: &'cont dyn Continuation<'ctx, 'val, R, C>,
    ) -> Result<R>
    where
        R: Combine<'ctx, 'val>,
        C: AsMut<BlockGenContext<'decls, 'ctx, 'blk, 'val>>,
        'ctx: 'cont + 'decls,
        'val: 'cont,
        'ctx: 'blk,
        'blk: 'val,
    {
        let indices =
            block_gen.as_mut().gen_index_ops(indices.iter().copied(), codegen, location, info)?;
        // Whatever I do on `WriteChain::write_array` I need to do a similar thing here for reading
        // the "arrays".
        let Ok(prev_pod_type) = PodType::try_from(prev.r#type()) else {
            let value = block_gen.as_mut().append_array_read(prev, &indices, location, None)?;
            return cont.cont(value, block_gen);
        };
        // Constant true used as starting point for concatenating the conditions for a particular
        // index set together with a fold.
        let true_value = {
            let attr = IntegerAttribute::new(codegen.bool_type().into(), 1);
            block_gen.as_mut().append_op_unnamed_result(arith::constant(
                codegen.context,
                attr.into(),
                location,
            ))
        }?;

        // I need the dimensions of the array. I need to know the number of dimensions and the size
        // of each dimension. Since this stuff happens in `--concrete` I don't need to worry about
        // arrays having a size that is unknown at compile time.
        let mixed_subcmp_layout = info.subcmp_info.mixed_subcmp_info(self.root_var())?;

        let entries = mixed_subcmp_layout
            .indices()
            .into_iter()
            .map(|entry_indices| {
                let cond = emit_condition(
                    entry_indices,
                    codegen,
                    block_gen.as_mut(),
                    location,
                    true_value,
                    &indices,
                )?;

                let (info, yield_value) = self.emit_mixed_subcmp_if_body(
                    prev,
                    entry_indices,
                    codegen,
                    block_gen,
                    location,
                    prev_pod_type,
                    info,
                    cont,
                )?;

                Ok(CombineEntry::new(cond, yield_value, info))
            })
            .collect::<Result<Vec<_>>>()?;

        if entries.is_empty() {
            anyhow::bail!("No indices for mixed subcomponent array '{}'", self.root_var());
        }

        R::combine(entries, block_gen.as_mut(), codegen, location)
    }

    /// Emits the IR for a conditional check for array indices in a mixed subcomponent.
    fn emit_mixed_subcmp_if_body<'decls, 'ctx, 'blk, 'val, 'cont, R, C>(
        &self,
        prev: Value<'ctx, 'val>,
        entry_indices: &[usize],
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut C,
        location: Location<'ctx>,
        prev_pod_type: PodType<'ctx>,
        info: InfoProviders<'_, 'ctx>,
        cont: &'cont dyn Continuation<'ctx, 'val, R, C>,
    ) -> Result<(NestedBlockInfo<'ctx, 'blk, 'val>, R)>
    where
        C: AsMut<BlockGenContext<'decls, 'ctx, 'blk, 'val>>,
        'ctx: 'cont + 'blk + 'decls,
        'val: 'cont,
        'blk: 'val,
    {
        NestedBlockInfo::with_scope(block_gen, |block_gen| {
            let record_name = info
                .subcmp_info
                .mixed_subcmp_record_for_indices(self.root_var(), entry_indices)
                .ok_or_else(|| {
                    anyhow::anyhow!(
                        "Mixed subcomponent entry for '{}'{entry_indices:?} not found",
                        self.root_var()
                    )
                })?;
            let record_type = prev_pod_type.get_type_of_record(record_name).ok_or_else(|| {
                anyhow::anyhow!("record {record_name} not found in mixed subcomponent pod: {prev}")
            })?;
            let read_value = block_gen.as_mut().append_op_unnamed_result(pod::read(
                location,
                prev,
                codegen.flat_sym(record_name),
                record_type,
            ))?;

            cont.cont(read_value, block_gen)
        })
    }

    /// Handle [Lvalue::Subcmp]  in [`Lvalue::get_value`] when the signal is an output of the
    /// subcomponent.
    fn get_subcmp_output<'ctx, 'val>(
        &self,
        signal_name: &str,
        subcmp_value: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut BlockGenContext<'_, 'ctx, '_, 'val>,
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
        block_gen: &mut BlockGenContext<'_, 'ctx, '_, 'val>,
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
    /// Uses continuation passing style for handling the returned value.
    ///
    /// CPS is necessary for handling mixed subcomponents since the actual MLIR types of the values
    /// returned could diverge. The continuation is represented by the [`Continuation`] trait, that
    /// is implemented by all function types that match the continuation's signature.
    pub fn get_value<'decls, 'ctx, 'blk, 'val, 'cont, R, C>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block_gen: &mut C,
        subcmp_info: &dyn SubcmpInfo<'ctx>,
        location: Location<'ctx>,
        ov: Option<&dyn OverrideVar>,
        cont: &'cont dyn Continuation<'ctx, 'val, R, C>,
    ) -> Result<R>
    where
        R: Combine<'ctx, 'val>,
        C: AsMut<BlockGenContext<'decls, 'ctx, 'blk, 'val>>,
        'ctx: 'cont + 'blk + 'decls,
        'val: 'cont,
        'blk: 'val,
    {
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
                let root_signal =
                    self.get_root_signal(var_name!(ov, var, Root::Signal), block_gen.as_mut())?;
                cont.cont(root_signal, block_gen)
            }
            Lvalue::Root { var, op: Root::Var } => {
                let root_value =
                    self.get_root_value(var_name!(ov, var, Root::Var), block_gen.as_mut())?;
                cont.cont(root_value, block_gen)
            }
            Lvalue::Array { indices, prev } => prev.get_value(
                codegen,
                block_gen,
                subcmp_info,
                location,
                ov,
                &|prev: Value<'ctx, 'val>, block_gen: &mut C| {
                    self.get_array_value(
                        indices,
                        prev,
                        codegen,
                        block_gen,
                        location,
                        InfoProviders { subcmp_info, ..Default::default() },
                        cont,
                    )
                },
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

                prev.get_value(
                    codegen,
                    block_gen,
                    subcmp_info,
                    location,
                    ov.or(Some(&ovii)),
                    &|subcmp_value: Value<'ctx, 'val>, block_gen: &mut C| {
                        let subcmp_member_value = if is_input {
                            self.get_subcmp_input(
                                signal_name,
                                subcmp_value,
                                codegen,
                                block_gen.as_mut(),
                                location,
                            )
                        } else {
                            self.get_subcmp_output(
                                signal_name,
                                subcmp_value,
                                codegen,
                                block_gen.as_mut(),
                                location,
                            )
                        }?;
                        cont.cont(subcmp_member_value, block_gen)
                    },
                )
            }
        }
    }
}

/// Converts an array access to concrete indices when every index is numeric.
pub(crate) fn concrete_indices(indices: &[&Expression]) -> Option<Vec<usize>> {
    indices
        .iter()
        .map(|index| match index {
            Expression::Number(_, n) => n.to_usize(),
            _ => None,
        })
        .collect()
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

/// Emits the IR for a conditional check for array indices in a mixed subcomponent.
fn emit_condition<'ctx, 'val>(
    entry_indices: &[usize],
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    block_gen: &mut BlockGenContext<'_, 'ctx, '_, 'val>,
    location: Location<'ctx>,
    true_value: Value<'ctx, 'val>,
    indices: &[Value<'ctx, 'val>],
) -> Result<Value<'ctx, 'val>> {
    let entry_indices_values = entry_indices
        .iter()
        .map(|idx| {
            let attr = IntegerAttribute::new(codegen.index_type(), *idx as i64);
            block_gen.append_op_unnamed_result(arith::constant(
                codegen.context,
                attr.into(),
                location,
            ))
        })
        .collect::<Result<Vec<_>>>()?;
    if entry_indices_values.len() != indices.len() {
        anyhow::bail!(
            "Array indices and mixed subcomponent indices len do not match: {} != {}",
            entry_indices_values.len(),
            indices.len()
        );
    }

    let eqs = std::iter::zip(indices, entry_indices_values)
        .map(|(lhs, rhs)| {
            block_gen.append_op_unnamed_result(arith::cmpi(
                codegen.context,
                arith::CmpiPredicate::Eq,
                *lhs,
                rhs,
                location,
            ))
        })
        .collect::<Result<Vec<_>>>()?;
    eqs.into_iter().try_fold(true_value, |acc, cmp| {
        block_gen.append_op_unnamed_result(llzk::dialect::bool::and(location, acc, cmp)?)
    })
}

mod sealed {
    pub trait CombineSealed {}
}

/// Helper struct aggregating the data required by the `Combine` trait.
pub struct CombineEntry<'ctx, 'blk, 'val, C> {
    /// Boolean condition for the if-then-else blocks.
    condition: Value<'ctx, 'val>,
    /// Payload that needs to be combined.
    data: C,
    /// Information about the region containing the emitted IR for the entry.
    info: NestedBlockInfo<'ctx, 'blk, 'val>,
}

impl<'ctx, 'blk, 'val, C> CombineEntry<'ctx, 'blk, 'val, C> {
    fn new(condition: Value<'ctx, 'val>, data: C, info: NestedBlockInfo<'ctx, 'blk, 'val>) -> Self {
        Self { condition, data, info }
    }
}

/// This trait is used for combining the output of multiple continuation results
/// when dealing with mixed subcomponents.
///
/// Only two implementations are included, one for `Value` and another for `()`.
/// Both create the if-then-else chain with the difference that the former returns the value and
/// the latter doesn't.
pub trait Combine<'ctx, 'val>: sealed::CombineSealed + Sized + Copy {
    fn make_tail<'blk>(
        entries: &[CombineEntry<'ctx, 'blk, 'val, Self>],
        block_gen: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<(NestedBlockInfo<'ctx, 'blk, 'val>, Self)>;

    fn data_as_value(self) -> Option<Value<'ctx, 'val>>;

    fn from_value(value: Option<Value<'ctx, 'val>>) -> Self;

    fn combine<'blk>(
        entries: Vec<CombineEntry<'ctx, 'blk, 'val, Self>>,
        block_gen: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<Self> {
        let (tail, tail_data) = Self::make_tail(&entries, block_gen, codegen, location)?;

        let (mut info, _, (values, overwrites_offset, vars)) = entries.into_iter().try_fold(
            (tail, tail_data, Default::default()),
            |(mut tail, tail_data, _), CombineEntry { condition, data, mut info }| -> Result<_> {
                let mut overwrites = combine_overwrites(info.var_overwrites, tail.var_overwrites);
                if codegen.config.stabilize {
                    // Sort by circom variable names to ensure a stable order.
                    overwrites.sort_by(|lhs, rhs| lhs.var().cmp(rhs.var()));
                }
                // Reset the overwrites
                info.var_overwrites = OverwriteMap::new();
                tail.var_overwrites = OverwriteMap::new();
                fill_missing_overwrites(
                    &mut info,
                    &mut tail,
                    &mut overwrites,
                    block_gen,
                    location,
                )?;

                let mut vars = Vec::with_capacity(overwrites.len());
                let mut then_values = Vec::with_capacity(overwrites.len() + 1);
                let mut else_values = Vec::with_capacity(overwrites.len() + 1);

                let overwrites_offset: usize =
                    match (tail_data.data_as_value(), data.data_as_value()) {
                        (None, None) => 0,
                        (Some(tail), Some(data)) => {
                            else_values.push(tail);
                            then_values.push(data);
                            1
                        }
                        _ => unreachable!(),
                    };
                for overwrite in overwrites {
                    let Overwrite::Both { var, then, r#else } = overwrite else {
                        unreachable!();
                    };
                    vars.push(var);
                    then_values.push(then);
                    else_values.push(r#else);
                }

                // Create the yield ops for the branches
                info.enter_scope(block_gen, |block_gen| {
                    block_gen.append_op_no_result(scf::r#yield(&then_values, location))
                })?;
                tail.enter_scope(block_gen, |block_gen| {
                    block_gen.append_op_no_result(scf::r#yield(&else_values, location))
                })?;

                let then_region = info.region;
                let else_region = tail.region;
                let (mut new_info, values) = NestedBlockInfo::with_scope(block_gen, |block_gen| {
                    block_gen.gen_safe_scf_multivalued_if(
                        codegen,
                        location,
                        condition,
                        (then_region, &then_values),
                        (else_region, &else_values),
                        None,
                    )
                })?;
                let overwrites = &values[overwrites_offset..];
                assert_eq!(vars.len(), overwrites.len());
                new_info.var_overwrites = OverwriteMap::from_iter(
                    std::iter::zip(&vars, overwrites).map(|(var, value)| (var.clone(), *value)),
                );

                Ok((
                    new_info,
                    Self::from_value(values.get(0).copied()),
                    (values, overwrites_offset, vars),
                ))
            },
        )?;

        // Wrap the region in a `scf.execute_region`. It's easier to add ops than to steal the ops
        // inside the region and the canonicalizer will get rid of it.
        // Create an empty scf.yield op to satisfy scf.execute_region's requirements.
        info.enter_scope(block_gen, |block_gen| {
            block_gen.append_op_no_result(scf::r#yield(&values, location))
        })?;
        let types = values.iter().map(|v| v.r#type()).collect::<Vec<_>>();
        let op = scf::execute_region(&types, info.region, location);

        let results = if !values.is_empty() {
            block_gen.append_op_many_unnamed_results(op)?
        } else {
            block_gen.append_op_no_result(op)?;
            vec![]
        };
        // Update the overwriten variables with the values emitted by the `scf.execute_region` op.
        std::iter::zip(vars, &results[overwrites_offset..])
            .into_iter()
            .try_for_each(|(var, value)| block_gen.block_ctx.set_named_value(var, *value))?;

        Ok(Self::from_value(results.get(0).copied()))
    }
}

impl sealed::CombineSealed for () {}
impl sealed::CombineSealed for Value<'_, '_> {}

type OverwriteMap<'ctx, 'val> = HashMap<String, Value<'ctx, 'val>>;

/// Cases for combining overwrites between two if-then-else branches.
enum Overwrite<'ctx, 'val> {
    /// Both cases have the variable
    Both { var: String, then: Value<'ctx, 'val>, r#else: Value<'ctx, 'val> },
    /// Only the then branch has this variable
    Then { var: String, value: Value<'ctx, 'val> },
    /// Only the else branch has this variable
    Else { var: String, value: Value<'ctx, 'val> },
}

impl Overwrite<'_, '_> {
    fn var(&self) -> &str {
        match self {
            Overwrite::Both { var, .. }
            | Overwrite::Then { var, .. }
            | Overwrite::Else { var, .. } => var,
        }
    }
}

/// Combines the overwrite maps into a list of [`Overwrite`].
fn combine_overwrites<'ctx, 'val>(
    then_map: OverwriteMap<'ctx, 'val>,
    else_map: OverwriteMap<'ctx, 'val>,
) -> Vec<Overwrite<'ctx, 'val>> {
    std::iter::chain(then_map.keys(), else_map.keys())
        .collect::<HashSet<_>>()
        .into_iter()
        .map(|var| {
            let then = then_map.get(var).copied();
            let r#else = else_map.get(var).copied();

            match (then, r#else) {
                (Some(then), Some(r#else)) => Overwrite::Both { var: var.clone(), then, r#else },
                (Some(value), None) => Overwrite::Then { var: var.clone(), value },
                (None, Some(value)) => Overwrite::Else { var: var.clone(), value },
                (None, None) => unreachable!(),
            }
        })
        .collect()
}

/// Creates `nondet` ops for the overwrites that are missing.
fn fill_missing_overwrites<'ctx, 'blk, 'val>(
    then_info: &mut NestedBlockInfo<'ctx, 'blk, 'val>,
    else_info: &mut NestedBlockInfo<'ctx, 'blk, 'val>,
    overwrites: &mut [Overwrite<'ctx, 'val>],
    block_gen: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
    location: Location<'ctx>,
) -> Result<()> {
    let (mut missing_in_then, mut missing_in_else): (Vec<_>, Vec<_>) = overwrites
        .iter_mut()
        .filter(|o| !matches!(o, Overwrite::Both { .. }))
        .partition(|o| matches!(o, Overwrite::Else { .. }));

    then_info.enter_scope(block_gen, |block_gen| {
        for overwrite in &mut missing_in_then {
            match overwrite {
                Overwrite::Else { var, value } => {
                    let other =
                        block_gen.append_op_unnamed_result(nondet(location, value.r#type()))?;
                    **overwrite = Overwrite::Both { var: var.clone(), then: other, r#else: *value };
                }
                _ => unreachable!(),
            }
        }
        Ok(())
    })?;

    else_info.enter_scope(block_gen, |block_gen| {
        for overwrite in &mut missing_in_else {
            match overwrite {
                Overwrite::Then { var, value } => {
                    let other =
                        block_gen.append_op_unnamed_result(nondet(location, value.r#type()))?;
                    **overwrite = Overwrite::Both { var: var.clone(), r#else: other, then: *value };
                }
                _ => unreachable!(),
            }
        }
        Ok(())
    })
}

impl<'ctx, 'val> Combine<'ctx, 'val> for () {
    fn make_tail<'blk>(
        _: &[CombineEntry<'ctx, 'blk, 'val, Self>],
        _: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        _: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        _: Location<'ctx>,
    ) -> Result<(NestedBlockInfo<'ctx, 'blk, 'val>, Self)> {
        Ok((NestedBlockInfo::new(), ()))
    }

    fn data_as_value(self) -> Option<Value<'ctx, 'val>> {
        None
    }

    fn from_value(_: Option<Value<'ctx, 'val>>) -> Self {
        ()
    }
}

impl<'ctx, 'val> Combine<'ctx, 'val> for Value<'ctx, 'val> {
    fn make_tail<'blk>(
        entries: &[CombineEntry<'ctx, 'blk, 'val, Self>],
        block_gen: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        _: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<(NestedBlockInfo<'ctx, 'blk, 'val>, Self)> {
        NestedBlockInfo::with_scope(block_gen, |block_gen| {
            block_gen.append_op_unnamed_result(nondet(location, entries[0].data.r#type()))
        })
    }

    fn data_as_value(self) -> Option<Value<'ctx, 'val>> {
        Some(self)
    }

    fn from_value(value: Option<Value<'ctx, 'val>>) -> Self {
        value.unwrap()
    }
}

/// Trait used for the continuation. Is implemented for all matching function types.
///
/// `impl Fn(...)` causes the rust compiler to enter an infinite loop of instantiations.
/// Using this trait as a `dyn` trait fixes the problem.
pub trait Continuation<'ctx, 'val, R, C> {
    fn cont<'decls, 'blk>(&self, value: Value<'ctx, 'val>, block_gen: &mut C) -> Result<R>
    where
        C: AsMut<BlockGenContext<'decls, 'ctx, 'blk, 'val>>,
        'ctx: 'blk + 'decls,
        'blk: 'val;
}

impl<'ctx, 'val, F, R, C> Continuation<'ctx, 'val, R, C> for F
where
    F: Fn(Value<'ctx, 'val>, &mut C) -> Result<R>,
{
    fn cont<'decls, 'blk>(&self, value: Value<'ctx, 'val>, block_gen: &mut C) -> Result<R>
    where
        C: AsMut<BlockGenContext<'decls, 'ctx, 'blk, 'val>>,
        'ctx: 'blk + 'decls,
        'blk: 'val,
    {
        self(value, block_gen)
    }
}
