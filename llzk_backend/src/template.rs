#![allow(unused_variables)] // TODO: TEMP
use crate::{
    function::FunctionContext,
    shared::{new_felt_const_op, LlzkCodegen},
};
use anyhow::{anyhow, Result};
use llzk::{
    builder::OpBuilder,
    prelude::{constrain, function, r#struct, FeltType, StructDefOpRefMut},
};
use melior::ir::Value;
use program_structure::{
    ast::{AssignOp, Expression, Statement},
    error_code::ReportCode,
};
use std::{cell::RefCell, ops::Deref, rc::Rc};

/// Alias for `Option<T>` to make it clear what the meaning of the option is within the
/// [TemplateContext] below.
type ShouldGenerate<T> = Option<T>;

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
pub struct TemplateContext<'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Current LLZK `StructDefOp`
    struct_def: StructDefOpRefMut<'ctx, 'str>,
    /// Codegen refs for the "@compute" function within `struct_def`
    compute: ShouldGenerate<Rc<RefCell<FunctionContext<'ctx, 'func, 'blk, 'val>>>>,
    /// Codegen refs for the "@constrain" function within `struct_def`
    constrain: ShouldGenerate<Rc<RefCell<FunctionContext<'ctx, 'func, 'blk, 'val>>>>,
}

impl<'ctx, 'str, 'func, 'blk, 'val> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
    /// Creates a new [TemplateContext].
    #[inline]
    pub fn new(
        struct_def: StructDefOpRefMut<'ctx, 'str>,
        compute: FunctionContext<'ctx, 'func, 'blk, 'val>,
        constrain: FunctionContext<'ctx, 'func, 'blk, 'val>,
    ) -> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            struct_def,
            compute: Some(Rc::new(RefCell::new(compute))),
            constrain: Some(Rc::new(RefCell::new(constrain))),
        }
    }

    /// Creates a new [TemplateContext] that will only generate within the "@compute" function.
    #[inline]
    pub fn compute_only(&self) -> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            struct_def: self.struct_def,
            compute: self.compute.as_ref().map(Rc::clone),
            constrain: None,
        }
    }
}

/// For both the "@compute" and "@constrain" functions, holds the result (SSA Value or list thereof,
/// per the type aliases below) that comes from generating LLZK for a circom Expression within a
/// template.
#[derive(Debug)]
pub struct ExprGenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    /// Reference to the template context in which the expression was generated.
    template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    /// Result Value for the "@compute" function.
    compute_res: ShouldGenerate<ResultType>,
    /// Result Value for the "@constrain" function.
    constrain_res: ShouldGenerate<ResultType>,
}

/// Alias for [ExprGenResult] containing a single SSA Value result.
type ExprGenResultSingle<'ctx, 'str, 'func, 'blk, 'val, 'r> =
    ExprGenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, Value<'ctx, 'val>>;

/// Alias for [ExprGenResult] containing a list of SSA Value results.
type ExprGenResultMulti<'ctx, 'str, 'func, 'blk, 'val, 'r> =
    ExprGenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, Vec<Value<'ctx, 'val>>>;

/// Provides a common interface for the specializations of [ExprGenResult] (i.e.
/// [ExprGenResultSingle] and [ExprGenResultMulti]) to avoid duplication in later definitions.
trait ExprGenResultLike<'ctx, 'str, 'func, 'blk, 'val, 'r> {
    /// The type of result contained in the [ExprGenResult] for the "@compute"
    /// and "@constrain" functions.
    type ResultType;

    /// Get the [TemplateContext] from the [ExprGenResult].
    fn template(&self) -> &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>;

    /// Get the result for the "@compute" function from the [ExprGenResult].
    fn compute_res(&self) -> &ShouldGenerate<Self::ResultType>;

    /// Get the result for the "@constrain" function from the [ExprGenResult].
    fn constrain_res(&self) -> &ShouldGenerate<Self::ResultType>;
}

/// General implementation of [ExprGenResultLike] covering all specializations of [ExprGenResult].
impl<'ctx, 'str, 'func, 'blk, 'val, 'r, T> ExprGenResultLike<'ctx, 'str, 'func, 'blk, 'val, 'r>
    for ExprGenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, T>
{
    type ResultType = T;

    fn template(&self) -> &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
        self.template
    }

    fn compute_res(&self) -> &ShouldGenerate<Self::ResultType> {
        &self.compute_res
    }

    fn constrain_res(&self) -> &ShouldGenerate<Self::ResultType> {
        &self.constrain_res
    }
}

/// This trait abstracts over the output type of [Chainable::and_then] to allow a single
/// implementation of that function to produce different result types depending on the callback
/// function type provided.
trait ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r> {
    /// Output type of the generator callback functions.
    type HandlerOutput;

    /// Combines results from the "@compute" and "@constrain" generator functions into the final
    /// result of [Chainable::and_then].
    fn produce(
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
        compute_res: ShouldGenerate<Self::HandlerOutput>,
        constrain_res: ShouldGenerate<Self::HandlerOutput>,
    ) -> Self;
}

/// Support [Chainable::and_then] producing [ExprGenResultSingle] which allows for chaining another
/// generator function on this result.
impl<'ctx, 'str, 'func, 'blk, 'val, 'r> ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>
    for ExprGenResultSingle<'ctx, 'str, 'func, 'blk, 'val, 'r>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerOutput = Value<'ctx, 'val>;

    fn produce(
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
        compute_res: ShouldGenerate<Self::HandlerOutput>,
        constrain_res: ShouldGenerate<Self::HandlerOutput>,
    ) -> Self {
        ExprGenResultSingle { template, compute_res, constrain_res }
    }
}

/// Support [Chainable::and_then] producing `()` which can be used when nothing further is generated
/// from the result and there is no [Value] available to return within the generator function.
impl<'ctx, 'str, 'func, 'blk, 'val, 'r> ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r> for ()
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerOutput = ();

    fn produce(
        _: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
        _: ShouldGenerate<Self::HandlerOutput>,
        _: ShouldGenerate<Self::HandlerOutput>,
    ) -> Self {
    }
}

/// This trait provides a clean interface for chaining multiple code generation steps. It abstracts
/// away most of the complexity (unwrapping, is_some assertions, etc.) that result from
/// [ExprGenResult] containing optional results for both "@compute" and "@constrain" functions.
trait Chainable<'ctx, 'str, 'func, 'blk, 'val, 'r>
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
    fn and_then<'ast, F1, F2, CR: ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>;

    /// Delegates to [Self::and_then] with the same handler for both compute and constrain.
    #[inline]
    fn and_then_same<'ast, F, CR: ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        handle: F,
    ) -> Result<CR>
    where
        F: Fn(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
    {
        self.and_then::<&F, &F, CR>(codegen, &handle, &handle)
    }
}

impl<'ctx, 'str, 'func, 'blk, 'val, 'r> ExprGenResultMulti<'ctx, 'str, 'func, 'blk, 'val, 'r>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    /// Create an empty [ExprGenResultMulti] (i.e. an [ExprGenResult] where the result
    /// is a vector of SSA Values).
    #[inline]
    fn new(template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>) -> Self {
        ExprGenResult {
            template,
            // This construction ensures that the result vectors are only created
            // if the corresponding template functions "ShouldGenerate".
            compute_res: template.compute.as_ref().map(|_| Vec::new()),
            constrain_res: template.constrain.as_ref().map(|_| Vec::new()),
        }
    }

    /// Create an [ExprGenResultMulti] populated by generating LLZK for each [Expression] given.
    #[inline]
    fn gen_exprs<'ast, I>(
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
        codegen: &LlzkCodegen<'ast, 'ctx>,
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

/// Implementation of [Chainable] for any type implementing [ExprGenResultLike] trait.
impl<'ctx, 'str, 'func, 'blk, 'val, 'r, T> Chainable<'ctx, 'str, 'func, 'blk, 'val, 'r> for T
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
    T: ExprGenResultLike<'ctx, 'str, 'func, 'blk, 'val, 'r>,
{
    type HandlerInput = T::ResultType;

    fn and_then<'ast, F1, F2, CR: ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
    {
        let compute_res: ShouldGenerate<CR::HandlerOutput> = self
            .compute_res()
            .as_ref()
            .map(|v| {
                // Note: `unwrap()` is safe so long as the contract is followed that
                // `self.X_res` is None if and only if `self.template.X` is also None.
                gen_compute(&mut self.template().compute.as_ref().unwrap().borrow_mut(), v)
            })
            .transpose()?;
        let constrain_res: ShouldGenerate<CR::HandlerOutput> = self
            .constrain_res()
            .as_ref()
            .map(|v| {
                // Note: `unwrap()` is safe so long as the contract is followed that
                // `self.X_res` is None if and only if `self.template.X` is also None.
                gen_constrain(&mut self.template().constrain.as_ref().unwrap().borrow_mut(), v)
            })
            .transpose()?;
        Ok(CR::produce(self.template(), compute_res, constrain_res))
    }
}

/// Implementation of [Chainable] for a [TemplateContext]. Useful when there is no initial
/// [ExprGenResult] to chain onto.
impl<'ctx, 'str, 'func, 'blk, 'val, 'r> Chainable<'ctx, 'str, 'func, 'blk, 'val, 'r>
    for &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerInput = ();

    fn and_then<'ast, F1, F2, CR: ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
    {
        let compute_res: ShouldGenerate<CR::HandlerOutput> =
            self.compute.as_ref().map(|fc| gen_compute(&mut fc.borrow_mut(), &())).transpose()?;
        let constrain_res: ShouldGenerate<CR::HandlerOutput> = self
            .constrain
            .as_ref()
            .map(|fc| gen_constrain(&mut fc.borrow_mut(), &()))
            .transpose()?;
        Ok(CR::produce(self, compute_res, constrain_res))
    }
}

/// A trait to generate LLZK IR from the body of a circom template.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'str: lifetime of the generated `StructDefOp`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
pub trait GenerateLLZKInTemplate<'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Output type of the generator function. [Statement] nodes do not produce a value so this
    /// should be the unit type whereas [Expression] nodes produce a Value.
    type Output<'r>
    where
        'val: 'r;

    /// Generates LLZK IR from [Statement] and [Expression] nodes in a circom template.
    ///
    /// 'ast: lifetime of the circom AST element
    fn gen_llzk_in_template<'ast, 'r>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r;
}

impl<'ctx, 'str, 'func, 'blk, 'val> GenerateLLZKInTemplate<'ctx, 'str, 'func, 'blk, 'val>
    for Statement
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output<'r>
        = ()
    where
        'val: 'r;

    fn gen_llzk_in_template<'ast, 'r>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r,
    {
        match self {
            Statement::InitializationBlock { initializations, .. } => {
                for init in initializations {
                    init.gen_llzk_in_template(codegen, template)?;
                }
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                // TODO: we've already handled declarations to create struct fields and function
                // parameters. Is there any reason to visit them again? If not, then
                // we don't need the InitializationBlock above either.
                println!("TODO: anything else to do with declaration? {name} of type {xtype:?}");
            }
            Statement::Block { stmts, .. } => {
                for s in stmts {
                    s.gen_llzk_in_template(codegen, template)?;
                }
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                if access.is_empty() {
                    // Since there's no simple assignment in LLZK, just update the mapped Value
                    // which essentially propagates the assignment.
                    match op {
                        AssignOp::AssignVar => {
                            // Note: Typed underscore binding shows we're not dropping a Result.
                            let _: () = rhe
                                .gen_llzk_in_template(codegen, template)?
                                .and_then_same(codegen, |fc, val| {
                                    fc.name_to_value.insert(var.clone(), *val);
                                    Ok(())
                                })?;
                        }
                        AssignOp::AssignSignal => {
                            // The `<--` operator is witness generation only so this should not
                            // generate any code in the constrain function.
                            let template = template.compute_only();
                            // Note: Typed underscore binding shows we're not dropping a Result.
                            let _: () = rhe
                                .gen_llzk_in_template(codegen, &template)?
                                .and_then_same(codegen, |fc, val| {
                                    // Write value to field of "self" struct.
                                    fc.append_op_no_result(
                                        r#struct::writef(
                                            codegen.location_from_meta(meta),
                                            todo!("needs llzkCallOpGetSelfValueFromCompute() Rust wrapper"),
                                            var,
                                            *val,
                                        )?
                                        .into(),
                                    )
                                })?;
                        }
                        AssignOp::AssignConstraintSignal => {
                            let _: () = rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                codegen,
                                |fc, val| {
                                    // Write value to field of "self" struct.
                                    fc.append_op_no_result(
                                        r#struct::writef(
                                            codegen.location_from_meta(meta),
                                            todo!("needs llzkCallOpGetSelfValueFromCompute() Rust wrapper"),
                                            var,
                                            *val,
                                        )?
                                        .into(),
                                    )
                                },
                                |fc, val| {
                                    // Read value of field from "self" struct and generate
                                    // equality constraint with 'val'.
                                    let builder = OpBuilder::new(codegen.context.deref());
                                    let felt_type = FeltType::new(codegen.context).into();
                                    let val_from_read = fc.append_op_unnamed_result(
                                        r#struct::readf(
                                            &builder,
                                            codegen.location_from_meta(meta),
                                            felt_type,
                                            todo!("needs llzkCallOpGetSelfValueFromConstrain() Rust wrapper"),
                                            var,
                                        )?
                                        .into(),
                                    )?;
                                    fc.append_op_no_result(
                                        constrain::eq(
                                            codegen.location_from_meta(meta),
                                            val_from_read,
                                            *val,
                                        )
                                        .into(),
                                    )
                                },
                            )?;
                        }
                    }
                } else {
                    todo!("Generate array write operation in template");
                }
            }
            Statement::UnderscoreSubstitution { meta, op, rhe } => {
                // The `<--` operator is witness generation only so this should not
                // generate any code in the constrain function.
                let template =
                    if AssignOp::AssignSignal == *op { &template.compute_only() } else { template };
                // Just visit and drop the result since the value is unused.
                // Note: Typed underscore binding shows we're not dropping a Result.
                let _: ExprGenResultSingle = rhe.gen_llzk_in_template(codegen, template)?;
            }
            Statement::ConstraintEquality { meta, lhe, rhe } => {
                todo!("Handle constraint equality in template")
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                todo!("Handle if-then-else statement in template")
            }
            Statement::While { meta, cond, stmt } => {
                todo!("Handle while statement in template")
            }
            Statement::Assert { meta, arg } => {
                todo!("Handle assert statement in template")
            }
            Statement::LogCall { meta, .. } => {
                codegen.emit_circom_warning(
                    meta,
                    "log calls are not currently supported in LLZK",
                    ReportCode::NotAllowedOperation,
                );
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
            }
            Statement::Return { .. } => {
                // per `type_analysis/src/analyzers/no_returns_in_template.rs`
                unreachable!("return statements are not allowed in templates")
            }
        }
        Ok(())
    }
}

impl<'ctx, 'str, 'func, 'blk, 'val> GenerateLLZKInTemplate<'ctx, 'str, 'func, 'blk, 'val>
    for Expression
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output<'r>
        = ExprGenResultSingle<'ctx, 'str, 'func, 'blk, 'val, 'r>
    where
        'val: 'r;

    fn gen_llzk_in_template<'ast, 'r>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r,
    {
        match self {
            Expression::Number(meta, big_int) => {
                template.and_then_same(codegen, |fc, _| {
                    // Convert the BigInt to an LLZK `felt.const` op. The user of the Expression is
                    // responsible for converting this `felt.type` value to another type if needed.
                    // This is done in both functions (if the result is unused in one, dce can
                    // remove it).
                    fc.append_op_unnamed_result(new_felt_const_op(codegen, meta, big_int)?)
                })
            }
            Expression::Variable { meta, name, access } => match access.as_slice() {
                [] => template.and_then_same(codegen, |fc, _| {
                    fc.name_to_value
                        .get(name)
                        .copied()
                        .ok_or_else(|| anyhow!("variable {name} not found"))
                }),
                a => {
                    todo!("Handle accesses in Variable expression in template")
                }
            },
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                // Generate Value for both sides and then generate the infix op.
                ExprGenResultMulti::gen_exprs(template, codegen, [&**lhe, &**rhe])?
                    .and_then_same(codegen, |fc, vals| {
                        fc.gen_infix_op(codegen, meta, infix_op, vals[0], vals[1])
                    })
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                // Generate Value for operand and then generate the prefix op.
                rhe.gen_llzk_in_template(codegen, template)?
                    .and_then_same(codegen, |fc, v| fc.gen_prefix_op(codegen, meta, prefix_op, *v))
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                todo!("Handle InlineSwitchOp expression in template")
            }
            Expression::ParallelOp { meta, rhe } => {
                todo!("Handle ParallelOp expression in template")
            }
            Expression::ArrayInLine { meta, values } => {
                todo!("Handle ArrayInLine expression in template")
            }
            Expression::UniformArray { meta, value, dimension } => {
                todo!("Handle UniformArray expression in template")
            }
            Expression::Call { meta, id, args } => {
                let builder = OpBuilder::new(codegen.context.deref());
                // Visit each argument and collect the resulting LLZK Values for both functions.
                let res = ExprGenResultMulti::gen_exprs(template, codegen, args)?;
                // Create the CallOp in each function using the collected args.
                res.and_then_same(codegen, |fc, vals| {
                    // TODO: Currently, the LLZK function will always return a `felt.type` but
                    // eventually, this gen function may need an "expected result type"
                    // parameter or use `poly.tvar` with function templates.
                    let return_types = &[FeltType::new(codegen.context)];
                    fc.append_op_unnamed_result(
                        function::call(
                            &builder,
                            codegen.location_from_meta(meta),
                            id,
                            vals,
                            return_types,
                        )?
                        .into(),
                    )
                })
            }
            Expression::BusCall { meta, id, args } => {
                todo!("Handle BusCall expression in template")
            }
            Expression::AnonymousComp { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::Tuple { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
        }
    }
}
