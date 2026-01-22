//! Handles template-level LLZK code generation. The [TemplateContext] carries information about the
//! current LLZK struct being generated and some helpers related to generating code within the
//! struct. The [GenerateLLZKInTemplate] trait provides the visitor to generate LLZK IR for all
//! circom [Expression](program_structure::abstract_syntax_tree::ast::Expression) and
//! [Statement](program_structure::abstract_syntax_tree::ast::Statement) nodes. There are also a few
//! helper traits like [GenResult] and [Chainable] that implement some boilerplate to make the
//! actual code generation within [GenerateLLZKInTemplate] a lot simpler.

use crate::function::FunctionContext;
use crate::gen_context::GenWithCircomScopeHandling;
use crate::gen_context::NestedBlockInfo;
use crate::program_ext::ProgramLike;
use crate::shared::get_constrain_call;
use crate::shared::op_result_owner;
use crate::shared::ArrayDimensionResult;
use crate::shared::DimExprConverter;
use crate::shared::LlzkCodegen;
use crate::template_ext::TemplateLike as _;
use crate::write_chain::RootWriteOp;
use crate::write_chain::WriteChain;
use crate::write_chain::WriteTarget;
use anyhow::anyhow;
use anyhow::Result;
use llzk::builder::OpBuilder;
use llzk::dialect::cast;
use llzk::prelude::constrain;
use llzk::prelude::function;
use llzk::prelude::is_felt_type;
use llzk::prelude::r#struct;
use llzk::prelude::r#struct::is_struct_readf;
use llzk::prelude::BlockRef;
use llzk::prelude::CallOpLike as _;
use llzk::prelude::CallOpRef;
use llzk::prelude::FeltType;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::Location;
use llzk::prelude::LoopBoundsAttribute;
use llzk::prelude::OperationLike;
use llzk::prelude::StructDefOpLike;
use llzk::prelude::StructDefOpRefMut;
use llzk::prelude::SymbolRefAttribute;
use llzk::prelude::Type;
use llzk::prelude::Value;
use llzk::prelude::ValueLike;
use llzk::value_ext::replace_all_uses;
use num_bigint_dig::BigUint;
use num_traits::ToPrimitive;
use program_structure::ast::Access;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::Statement;
use program_structure::error_code::ReportCode;
use std::cell::RefCell;
use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::TryFrom;
use std::ops::Deref;
use std::rc::Rc;

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
    pub fn new(template: &TemplateContext<'_, '_, '_, '_, '_>) -> Self {
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
    /// Set of subcomponent names.
    subcmps: &'str HashSet<String>,
    /// Tracks for what component signals we have created their `struct.writef` op already.
    written_signals: Rc<RefCell<HashSet<String>>>,
}

impl<'ctx, 'str, 'func, 'blk, 'val> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
    /// Creates a new [TemplateContext].
    #[inline]
    pub fn new(
        struct_def: StructDefOpRefMut<'ctx, 'str>,
        compute: FunctionContext<'ctx, 'func, 'blk, 'val>,
        constrain: FunctionContext<'ctx, 'func, 'blk, 'val>,
        subcmps: &'str HashSet<String>,
    ) -> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            struct_def,
            compute: Some(Rc::new(RefCell::new(compute))),
            constrain: Some(Rc::new(RefCell::new(constrain))),
            subcmps,
            written_signals: Default::default(),
        }
    }

    /// Creates a new [TemplateContext] that will only generate within the "@compute" function.
    #[inline]
    pub fn compute_only(&self) -> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            struct_def: self.struct_def,
            compute: self.compute.as_ref().map(Rc::clone),
            constrain: None,
            subcmps: self.subcmps,
            written_signals: self.written_signals.clone(),
        }
    }

    /// Creates a new [TemplateContext] that will only generate within the "@constrain" function.
    #[inline]
    pub fn constrain_only(&self) -> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
        Self {
            struct_def: self.struct_def,
            compute: None,
            constrain: self.constrain.as_ref().map(Rc::clone),
            subcmps: self.subcmps,
            written_signals: self.written_signals.clone(),
        }
    }

    /// Returns true if we already generated a `struct.writef` op for the given signal.
    pub fn signal_already_written(&self, name: &str) -> bool {
        self.written_signals.borrow().contains(name)
    }

    /// Marks the given signal as written.
    pub fn mark_signal_as_written(&self, name: String) {
        self.written_signals.borrow_mut().insert(name);
    }

    /// Finalizes the context by emitting the final write operations that write subcomponent
    /// declarations to the declaring component.
    pub fn finalize(self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Result<()> {
        let subcmps = self.subcmps;
        self.and_then::<_, _, GenResultUnit>(
            |fc, _| {
                // Write the subcomponent declarations to self.
                let self_value = fc.func.self_value_of_compute()?;
                for name in subcmps {
                    let val = fc.block_ctx.get_named_value(name)?;
                    fc.append_op_no_result(r#struct::writef(
                        Location::unknown(codegen.context),
                        self_value,
                        name,
                        *val,
                    )?)?;
                }
                if !fc.block_ctx.is_only_root() {
                    anyhow::bail!(
                        "Template generation reached final step with more than one scope"
                    );
                }
                fc.block_ctx.append_queue();
                Ok(())
            },
            |fc, _| {
                fc.block_ctx.append_queue();
                if !fc.block_ctx.is_only_root() {
                    anyhow::bail!(
                        "Template generation reached final step with more than one scope"
                    );
                }
                Ok(())
            },
        )?
        .and_then_same(|fc, _| fc.finalize(codegen))
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
    for &TemplateContext<'ctx, 'str, 'func, 'blk, 'val>
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
        overwrite_handler: H,
        overwrite_data: &mut Self::HandlerDataType,
    ) -> Result<()>
    where
        H: Fn(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
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
            let popped = fc.block_ctx.pop();
            overwrite_handler(
                &mut fc,
                overwrite_data.compute.get_or_insert_with(NestedBlockInfo::default),
                popped,
            )?;
        }
        if let Some(rc) = self.constrain.as_ref() {
            let mut fc = rc.borrow_mut();
            let popped = fc.block_ctx.pop();
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
pub struct GenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    /// Reference to the template context in which the expression was generated.
    template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    /// Result for the "@compute" function.
    compute_res: ShouldGenerate<ResultType>,
    /// Result for the "@constrain" function.
    constrain_res: ShouldGenerate<ResultType>,
}

/// Alias for [GenResult] containing a single SSA Value result.
type GenResultSingleVal<'ctx, 'str, 'func, 'blk, 'val, 'r> =
    GenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, Value<'ctx, 'val>>;

/// Alias for [GenResult] containing a list of SSA Value results.
type GenResultMultiVal<'ctx, 'str, 'func, 'blk, 'val, 'r> =
    GenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, Vec<Value<'ctx, 'val>>>;

/// Alias for [GenResult] containing the unit type (i.e. nothing).
type GenResultUnit<'ctx, 'str, 'func, 'blk, 'val, 'r> =
    GenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, ()>;

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

/// Support [Chainable::and_then] producing a [GenResult]. This allows for chaining another
/// generator function on this result whose input is `ResultType`.
impl<'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType> ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>
    for GenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerOutput = ResultType;

    fn produce(
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
        compute_res: ShouldGenerate<Self::HandlerOutput>,
        constrain_res: ShouldGenerate<Self::HandlerOutput>,
    ) -> Self {
        GenResult::<'ctx, 'str, 'func, 'blk, 'val, 'r, ResultType> {
            template,
            compute_res,
            constrain_res,
        }
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
/// [GenResult] containing optional results for both "@compute" and "@constrain" functions.
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
        self,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>;

    /// Delegates to [Self::and_then] with the same handler for both compute and constrain.
    #[inline]
    fn and_then_same<'ast, F, CR: ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        self,
        handle: F,
    ) -> Result<CR>
    where
        Self: Sized,
        F: Fn(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
    {
        self.and_then::<&F, &F, CR>(&handle, &handle)
    }
}

impl<'ctx, 'str, 'func, 'blk, 'val, 'r> GenResultMultiVal<'ctx, 'str, 'func, 'blk, 'val, 'r>
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
    fn new(template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>) -> Self {
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
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
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
impl<'ctx, 'str, 'func, 'blk, 'val, 'r, T> Chainable<'ctx, 'str, 'func, 'blk, 'val, 'r>
    for GenResult<'ctx, 'str, 'func, 'blk, 'val, 'r, T>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'r,
{
    type HandlerInput = T;

    fn and_then<'ast, F1, F2, CR: ChainResult<'ctx, 'str, 'func, 'blk, 'val, 'r>>(
        self,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
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
        self,
        gen_compute: F1,
        gen_constrain: F2,
    ) -> Result<CR>
    where
        F1: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            Self::HandlerInput,
        ) -> Result<CR::HandlerOutput>,
        F2: FnOnce(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
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

impl<'ast, 'ctx, 'func, 'blk, 'val, 'str> DimExprConverter<'ctx, 'ast, 'val>
    for TemplateContext<'ctx, 'str, 'func, 'blk, 'val>
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    #[allow(unused_variables)] // TODO: TEMP
    fn convert_dim_expr(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ArrayDimensionResult<'ctx, 'val>> {
        // First try to compute statically, falling back to literal computation
        // if all values are not compile-time constants or if the final result
        // does not properly convert to i64.
        if let Some(integer) =
            codegen.try_compute_dim_expr(expr)?.as_ref().and_then(BigUint::to_i64)
        {
            let int_attr = codegen.index_attr(integer);
            ArrayDimensionResult::new(int_attr.into(), &[])
        } else {
            match expr {
                Expression::Number(_, _) => {
                    unreachable!("handled by try_compute_dim_expr")
                }
                Expression::Variable { meta, name, access } => match access.as_slice() {
                    [] => {
                        // Grab the parameter name if it exists, else, defer to function generation.
                        if self.struct_def.has_param_name(name) {
                            ArrayDimensionResult::new(
                                FlatSymbolRefAttribute::new(codegen.context, name).into(),
                                &[],
                            )
                        } else {
                            // Other variables are unsupported, defer to function context
                            ArrayDimensionResult::insufficient_data_result()
                        }
                    }
                    a => {
                        todo!("Handle Variable expression in dimension for non-integer attributes")
                    }
                },
                Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                    todo!("Handle Infix expression in dimension for non-integer attributes")
                }
                Expression::PrefixOp { meta, prefix_op, rhe } => {
                    todo!("Handle Prefix expression in dimension for non-integer attributes")
                }
                Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                    todo!(
                        "Handle InlineSwitchOp expression in dimension for non-integer attributes"
                    )
                }
                Expression::Call { meta, id, args } => {
                    todo!("Handle Call expression in dimension")
                }
                // The remaining cases do not produce a scalar value.
                // i.e. ParallelOp, ArrayInLine, UniformArray, BusCall, AnonymousComp, Tuple
                // Give the same error that the circom type checker gives. The type checker ran
                // earlier so this should technically be unreachable.
                _ => {
                    unreachable!("Array indexes and lengths must be single arithmetic expressions")
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
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r;
}

impl<'ctx, 'str, 'func, 'blk, 'val> GenerateLLZKInTemplate<'ctx, 'str, 'func, 'blk, 'val>
    for [Statement]
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
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
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
fn gen_if_then_else<'ast, 'ctx, 'str, 'func, 'blk, 'val, 'r>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
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
        then_info.block(),
        |template| if_case.gen_llzk_in_template(codegen, template),
        &mut then_info,
    )?;
    let mut else_info = TemplateFuncPair::new(template);
    if let Some(else_case) = else_case {
        template.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
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
        fc.gen_scf_if(codegen, codegen.location_from_meta(meta), condition, then_info, else_info)
    })
}

/// Generate LLZK code for a circom [Statement::While].
fn gen_while<'ast, 'ctx, 'str, 'func, 'blk, 'val, 'r>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
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
        loop_cond_info.block(),
        |template| cond.gen_llzk_in_template(codegen, template),
        &mut loop_cond_info,
    )?;
    let mut loop_body_info = TemplateFuncPair::new(template);
    template.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
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
fn gen_init_block<'ast, 'ctx, 'str, 'func, 'blk, 'val, 'r>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    initializations: &[Statement],
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    initializations.gen_llzk_in_template(codegen, template)
}

/// Insert cast operations as needed to make `lhs` and `rhs` have compatible types for equality
/// constraints.
fn unify_constrain_eq_types<'ctx, 'func, 'blk, 'val>(
    fc: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
    lhs: Value<'ctx, 'val>,
    rhs: Value<'ctx, 'val>,
) -> Result<(Value<'ctx, 'val>, Value<'ctx, 'val>)> {
    // May need to cast between scalar types
    let mut to_felt =
        |val: Value<'ctx, 'val>| fc.append_op_unnamed_result(cast::tofelt(location, val).into());

    match (lhs.r#type(), rhs.r#type()) {
        (t0, t1) if is_felt_type(t0) && !is_felt_type(t1) => Ok((lhs, to_felt(rhs)?)),
        (t0, t1) if !is_felt_type(t0) && is_felt_type(t1) => Ok((to_felt(lhs)?, rhs)),
        _ => Ok((lhs, rhs)),
    }
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
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r,
    {
        match self {
            Statement::InitializationBlock { initializations, .. } => {
                gen_init_block(codegen, template, initializations)
            }
            Statement::Declaration { meta, name, dimensions, .. } => {
                template.and_then_same(|fc, _| {
                    if !fc.block_ctx.is_name_present(name) {
                        let dimensions = fc.get_dimensions(codegen, dimensions)?;
                        let op = dimensions.new_nondet_felt_of_dimensions(codegen, meta)?;
                        fc.block_ctx.declare_name_ensure_not_present(name, op)
                    } else {
                        Ok(())
                    }
                })
            }
            Statement::Block { meta, stmts } => {
                let mut template = template; // satisfy the &mut in `GenWithCircomScopeHandling`
                template.gen_in_current_block_with_new_circom_scope_and_merge_overwrites(
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
                            if template.subcmps.contains(var) {
                                rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                    |fc, rhe| {
                                        if let Ok(current) = fc.block_ctx.get_named_value(var) {
                                            replace_all_uses(*current, rhe);
                                        }

                                        fc.block_ctx.set_named_value(var.clone(), rhe)
                                    },
                                    |fc, rhe| {
                                        // Replace value
                                        let field_read = fc.block_ctx.get_named_value(var)?;
                                        // ASSERT: value comes from a `struct.readf`
                                        assert!(is_struct_readf(
                                            &op_result_owner(*field_read).unwrap()
                                        ));
                                        replace_all_uses(rhe, *field_read);
                                        fc.subcmp_calls.update_keys(rhe, *field_read);
                                        Ok(())
                                    },
                                )
                            } else {
                                rhe.gen_llzk_in_template(codegen, template)?.and_then_same(
                                    |fc, val| fc.block_ctx.set_named_value(var.clone(), val),
                                )
                            }
                        } else {
                            let write_op = if template.subcmps.contains(var) {
                                RootWriteOp::Subcmp
                            } else {
                                RootWriteOp::Var
                            };
                            let location = codegen.location_from_meta(meta);
                            rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                |fc, val| {
                                    let chain = WriteChain::new(var, write_op, access);
                                    chain.write(
                                        val,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        location,
                                        template,
                                    )?;
                                    Ok(())
                                },
                                |fc, val| {
                                    let chain = WriteChain::new(var, write_op, access);
                                    chain.write(
                                        val,
                                        WriteTarget::Constrain,
                                        codegen,
                                        fc,
                                        location,
                                        template,
                                    )?;
                                    Ok(())
                                },
                            )
                        }
                    }
                    AssignOp::AssignSignal => {
                        match &access[..] {
                            [] => {
                                // The `<--` operator is witness generation only so code for the RHS
                                // expression should only be generated in the compute function.
                                let compute_only = template.compute_only();
                                let _: () = rhe
                                    .gen_llzk_in_template(codegen, &compute_only)?
                                    .and_then_same(|fc, val| {
                                        let location = codegen.location_from_meta(meta);
                                        // Cast value to field type if needed.
                                        let value = fc.cast_to_felt_if_needed(location, val)?;
                                        // Write value to field of "self" struct.
                                        fc.append_op_no_result(
                                            r#struct::writef(
                                                location,
                                                fc.func.self_value_of_compute()?,
                                                var,
                                                value,
                                            )?
                                            .into(),
                                        )?;
                                        fc.block_ctx.set_named_value(var.clone(), value)
                                    })?;
                                // The constrain function just reads that field from "self" struct.
                                let constrain_only = template.constrain_only();
                                (&constrain_only).and_then_same(|fc, _| {
                                    let val = fc.append_op_unnamed_result(
                                        r#struct::readf(
                                            &OpBuilder::new(codegen.context.deref()),
                                            codegen.location_from_meta(meta),
                                            FeltType::new(codegen.context).into(),
                                            fc.func.self_value_of_constrain()?,
                                            var,
                                        )?
                                        .into(),
                                    )?;
                                    fc.block_ctx.set_named_value(var.clone(), val)
                                })
                            }
                            [Access::ComponentAccess(subcmp_signal)] => {
                                // Assigning to a subcomponent signal is translated into replacing
                                // the corresponding argument of the `@compute`
                                // call. Since the value was not constrained the argument is left
                                // as `undef.undef` in the call to `@constrain`.
                                //
                                // The value representing the call is mapped to the name of
                                // the subcomponent and mapped to the name of
                                // the subcomponent's template. For `@compute` that value is the
                                // call op to `@compute` and in `@constrain` is the first operand
                                // to the `@constrain` call.
                                //
                                // We use that name to look for the signal's declaration index and
                                // use it to locate the corresponding operand and
                                // replace it with the given `rhe`.
                                rhe.gen_llzk_in_template(codegen, &template.compute_only())?
                                    .and_then_same(|fc, rhe| {
                                        fc.assign_subcmp(
                                            rhe,
                                            var,
                                            subcmp_signal,
                                            codegen,
                                            0,
                                            op_result_owner,
                                        )
                                    })
                            }
                            access => rhe
                                .gen_llzk_in_template(codegen, &template.compute_only())?
                                .and_then_same(|fc, rhe| {
                                    let chain = WriteChain::new(var, RootWriteOp::Signal, access);
                                    chain.write(
                                        rhe,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        codegen.location_from_meta(meta),
                                        template,
                                    )
                                }),
                        }
                    }
                    AssignOp::AssignConstraintSignal => {
                        match &access[..] {
                            [] => {
                                rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                    |fc, val| {
                                        let location = codegen.location_from_meta(meta);
                                        // Cast value to field type if needed.
                                        let value = fc.cast_to_felt_if_needed(location, val)?;
                                        // Write value to field of "self" struct.
                                        fc.append_op_no_result(
                                            r#struct::writef(
                                                location,
                                                fc.func.self_value_of_compute()?,
                                                var,
                                                value,
                                            )?
                                            .into(),
                                        )?;
                                        fc.block_ctx.set_named_value(var.clone(), value)
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
                                                fc.func.self_value_of_constrain()?,
                                                var,
                                            )?
                                            .into(),
                                        )?;
                                        let (lhs, rhs) = unify_constrain_eq_types(
                                            fc,
                                            codegen.location_from_meta(meta),
                                            val_from_read,
                                            val,
                                        )?;
                                        fc.append_op_no_result(
                                            constrain::eq(
                                                codegen.location_from_meta(meta),
                                                lhs,
                                                rhs,
                                            )
                                            .into(),
                                        )?;
                                        fc.block_ctx.set_named_value(var.clone(), rhs)
                                    },
                                )
                            }
                            [Access::ComponentAccess(subcmp_signal)] => {
                                // Assigning to a subcomponent signal is translated into replacing
                                // the corresponding argument of the `@compute` and `@constrain`
                                // calls.
                                //
                                // The value representing the call is mapped to the name of
                                // the subcomponent and mapped to the name of
                                // the subcomponent's template. For `@compute` that value is the
                                // call op to `@compute` and in `@constrain` is the first operand
                                // to the `@constrain` call.
                                //
                                // We use that name to look for the signal's declaration index and
                                // use it to locate the corresponding operand and
                                // replace it with the given `rhe`.
                                rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                    |fc, rhe| {
                                        fc.assign_subcmp(
                                            rhe,
                                            var,
                                            subcmp_signal,
                                            codegen,
                                            0,
                                            op_result_owner,
                                        )
                                    },
                                    |fc, rhe| {
                                        fc.assign_subcmp(
                                            rhe,
                                            var,
                                            subcmp_signal,
                                            codegen,
                                            1,
                                            get_constrain_call,
                                        )
                                    },
                                )
                            }
                            access => {
                                rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                    |fc, rhe| {
                                        let chain = WriteChain::new(
                                            var,
                                            RootWriteOp::Signal,
                                            access,
                                        );
                                        chain.write(
                                            rhe,
                                            WriteTarget::Compute,
                                            codegen,
                                            fc,
                                            codegen.location_from_meta(meta),
                                            template,
                                        )
                                    },
                                    |_fc, _rhe| {
                                        anyhow::bail!("Generate array write operation in template (constrain): \n{access:?}")
                                    },
                                )
                            }
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
                        let (lhs, rhs) = unify_constrain_eq_types(
                            fc,
                            codegen.location_from_meta(meta),
                            vals[0],
                            vals[1],
                        )?;
                        fc.append_op_no_result(
                            constrain::eq(codegen.location_from_meta(meta), lhs, rhs).into(),
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
                    fc.append_op_no_result(
                        llzk::dialect::bool::assert(
                            codegen.location_from_meta(meta),
                            val,
                            Some("assertion failed"),
                        )?
                        .into(),
                    )
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

impl<'ctx, 'str, 'func, 'blk, 'val> GenerateLLZKInTemplate<'ctx, 'str, 'func, 'blk, 'val>
    for Expression
where
    'ctx: 'str,
    'str: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output<'r>
        = GenResultSingleVal<'ctx, 'str, 'func, 'blk, 'val, 'r>
    where
        'val: 'r;

    fn gen_llzk_in_template<'ast, 'r>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        template: &'r TemplateContext<'ctx, 'str, 'func, 'blk, 'val>,
    ) -> Result<Self::Output<'r>>
    where
        'val: 'r,
    {
        // This function handles the special cases that happen in templates and any other kind of
        // expression is delegated.
        match self {
            Expression::Variable { meta, name, access }
                if { matches!(access[..], [Access::ComponentAccess(_)]) } =>
            {
                match access.as_slice() {
                    [Access::ComponentAccess(signal_name)] => template.and_then(
                        |fc, _| {
                            let subcmp_value = fc.block_ctx.get_named_value(name)?;
                            let template_data = fc
                                .subcmp_calls
                                .get(subcmp_value)
                                .ok_or_else(|| {
                                    anyhow::anyhow!(
                                        "subcomponent call for {subcmp_value} not found"
                                    )
                                })
                                .and_then(|name| {
                                    codegen.find_template_data(name).ok_or_else(|| {
                                        anyhow::anyhow!("template {name:?} not found")
                                    })
                                })?;
                            if template_data.get_outputs().contains_key(signal_name) {
                                fc.append_op_unnamed_result(r#struct::readf(
                                    &OpBuilder::new(codegen.context),
                                    codegen.location_from_meta(meta),
                                    FeltType::new(codegen.context).into(),
                                    *subcmp_value,
                                    signal_name,
                                )?)
                            } else if template_data.get_inputs().contains_key(signal_name) {
                                let idx = template_data
                                    .get_declaration_inputs()
                                    .iter()
                                    .find_map(|(s, idx)| (signal_name == s).then_some(*idx))
                                    .expect("signal in mapping but not in declaration list");
                                let call = CallOpRef::try_from(op_result_owner(*subcmp_value)?)?;
                                assert!(call.callee_is_struct_compute());
                                Ok(call.operand(idx)?)
                            } else {
                                anyhow::bail!(
                                    "signal {signal_name} of subcomponent {name} is internal"
                                );
                            }
                        },
                        |fc, _| {
                            let subcmp_value = fc.block_ctx.get_named_value(name)?;
                            let template_data = fc
                                .subcmp_calls
                                .get(subcmp_value)
                                .ok_or_else(|| {
                                    anyhow::anyhow!(
                                        "subcomponent call for {subcmp_value} not found"
                                    )
                                })
                                .and_then(|name| {
                                    codegen.find_template_data(name).ok_or_else(|| {
                                        anyhow::anyhow!("template {name:?} not found")
                                    })
                                })?;
                            if template_data.get_outputs().contains_key(signal_name) {
                                fc.append_op_unnamed_result(r#struct::readf(
                                    &OpBuilder::new(codegen.context),
                                    codegen.location_from_meta(meta),
                                    FeltType::new(codegen.context).into(),
                                    *subcmp_value,
                                    signal_name,
                                )?)
                            } else if template_data.get_inputs().contains_key(signal_name) {
                                let idx = template_data
                                    .get_declaration_inputs()
                                    .iter()
                                    .find_map(|(s, idx)| (signal_name == s).then_some(*idx))
                                    .expect("signal in mapping but not in declaration list");
                                let call = get_constrain_call(*subcmp_value)?;
                                Ok(call.operand(idx + 1)?)
                            } else {
                                anyhow::bail!(
                                    "signal {signal_name} of subcomponent {name} is internal"
                                );
                            }
                        },
                    ),
                    _ => {
                        unreachable!()
                    }
                }
            }
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
                let location = codegen.location_from_meta(meta);
                let dimensions = template.get_dimensions(codegen, args)?;
                let subcmp_type = dimensions.struct_type_with_concrete_dimensions(codegen, id);
                let arg_types = std::iter::once(Type::from(subcmp_type))
                    .chain(codegen.get_template_input_types(id)?)
                    .collect::<Vec<_>>();
                // Undefs have unknown locations at creation and we set it when we encounter
                // the corresponding write.
                let unk = Location::unknown(codegen.context);
                let builder = OpBuilder::new(codegen.context);

                // Generate here the call to @compute and @constrain.
                // Passing undefs to the methods. These undefs get associated with the
                // signals of the subcomponent s.t. when we encounter an assignment
                // to one of the signals we replace the undef with the actual value,
                // similar to how we do for variables assignment.
                template.and_then(
                    |fc, _| {
                        let undefs = fc.gen_arg_undefs(&arg_types[1..], unk)?;
                        let val = fc.append_op_unnamed_result(
                            function::call(
                                &builder,
                                location,
                                SymbolRefAttribute::new(codegen.context, id, &["compute"]),
                                &undefs,
                                &[subcmp_type],
                            )?
                            .into(),
                        )?;
                        fc.subcmp_calls.insert(&val, id.clone());
                        Ok(val)
                    },
                    |fc, _| {
                        let undefs = fc.gen_arg_undefs(&arg_types, unk)?;
                        let empty_result: [Type<'ctx>; 0] = [];
                        fc.append_op_no_result(
                            function::call(
                                &builder,
                                location,
                                SymbolRefAttribute::new(codegen.context, id, &["constrain"]),
                                &undefs,
                                &empty_result,
                            )?
                            .into(),
                        )?;
                        fc.subcmp_calls.insert(&undefs[0], id.clone());
                        // Return the reference to the subcomponent to match the result of
                        // compute.
                        Ok(undefs[0])
                    },
                )
            }
            Expression::UniformArray { meta, value, dimension } => {
                let location = codegen.location_from_meta(meta);
                let template_dim_res = template.convert_dim_expr(codegen, dimension)?;
                let value = value.gen_llzk_in_template(codegen, template)?;
                value.and_then_same(|fc, value| {
                    // Try to convert in template first, or defer to function context if unsuccessful.
                    let final_dim = match &template_dim_res {
                        ArrayDimensionResult::Computed(array_dimension) => array_dimension,
                        ArrayDimensionResult::InsufficientData => {
                            &Option::from(fc.convert_dim_expr(codegen, dimension)?).ok_or_else(|| anyhow!("missing data required to compute uniform array dimensions in template"))?
                        },
                    };
                    fc.generate_uniform_array(codegen, location, value, final_dim)
                })
            }
            // Delegate any other kind of expression to the implementation in `function.rs`.
            expr => {
                template.and_then_same(|fc, _| {
                    // The import is here rather than top level because it is very important that
                    // `gen_llzk_in_function()` is not used while translating statements.
                    use crate::function::GenerateLLZKInFunction;
                    expr.gen_llzk_in_function(codegen, fc)
                })
            }
        }
    }
}
