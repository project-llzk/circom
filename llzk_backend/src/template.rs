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
use crate::lvalue::Lvalue;
use crate::lvalue::Root;
use crate::program_ext::ProgramInfo;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::comp_type;
use crate::shared::map_array_inner_type;
use crate::shared::ArrayDimensionResult;
use crate::shared::DimExprConverter;
use crate::shared::LlzkCodegen;
use crate::shared::TmplParamsInstance;
use crate::subcmp::names::COMP;
use crate::subcmp::names::COUNT;
use crate::subcmp::names::PARAMS;
use crate::subcmp::SubcmpInfo;
use crate::template_ext::SignalDeclarations;
use crate::template_ext::TemplateLike as _;
use crate::write_chain::WriteChain;
use crate::write_chain::WriteTarget;
use anyhow::anyhow;
use anyhow::Result;
use llzk::dialect::array::ArrayCtor;
use llzk::dialect::cast;
use llzk::dialect::constrain;
use llzk::dialect::pod;
use llzk::dialect::r#struct;
use llzk::prelude::is_felt_type;
use llzk::prelude::ArrayType;
use llzk::prelude::BlockRef;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::Location;
use llzk::prelude::LoopBoundsAttribute;
use llzk::prelude::MemberDefOpLike as _;
use llzk::prelude::PodType;
use llzk::prelude::RecordValue;
use llzk::prelude::StringRef;
use llzk::prelude::StructDefOpLike as _;
use llzk::prelude::StructDefOpRefMut;
use llzk::prelude::Type;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::Statement;
use program_structure::error_code::ReportCode;
use std::cell::RefCell;
use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::TryFrom;
use std::convert::TryInto as _;
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
    'val: 'blk,
{
    /// Current LLZK `StructDefOp`
    struct_def: StructDefOpRefMut<'ctx, 'str>,
    /// Codegen refs for the "@compute" function within `struct_def`
    compute: ShouldGenerate<Rc<RefCell<FunctionContext<'ctx, 'func, 'blk, 'val>>>>,
    /// Codegen refs for the "@constrain" function within `struct_def`
    constrain: ShouldGenerate<Rc<RefCell<FunctionContext<'ctx, 'func, 'blk, 'val>>>>,
    /// Map of subcomponent names to their types.
    subcmps: &'str HashMap<String, String>,
    /// Tracks for what component signals we have created their `struct.writem` op already.
    written_signals: Rc<RefCell<HashSet<String>>>,
}

impl<'ctx, 'str, 'func, 'blk, 'val> TemplateContext<'ctx, 'str, 'func, 'blk, 'val> {
    /// Creates a new [TemplateContext].
    #[inline]
    pub fn new(
        struct_def: StructDefOpRefMut<'ctx, 'str>,
        compute: FunctionContext<'ctx, 'func, 'blk, 'val>,
        constrain: FunctionContext<'ctx, 'func, 'blk, 'val>,
        subcmps: &'str HashMap<String, String>,
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

    /// Returns true if we already generated a `struct.writem` op for the given signal.
    pub fn signal_already_written(&self, name: &str) -> bool {
        self.written_signals.borrow().contains(name)
    }

    /// Marks the given signal as written.
    pub fn mark_signal_as_written(&self, name: String) {
        self.written_signals.borrow_mut().insert(name);
    }

    /// Get the type of the struct field with the given name.
    /// Errors if the field does not exist within the struct.
    pub fn get_signal_type(&self, name: &str) -> Result<Type<'ctx>> {
        Ok(self
            .struct_def
            .get_member_def(name)
            .ok_or_else(|| anyhow!("no field '{name}' in struct"))?
            .member_type())
    }

    /// Part of the finalization procedure that emits the pending operations in the queue.
    fn finalize_queue(self) -> Result<Self> {
        self.and_then_same::<_, GenResultUnit>(|fc, _| {
            if !fc.block_ctx.is_only_root() {
                anyhow::bail!("Template generation reached final step with more than one scope");
            }
            fc.block_ctx.append_queue();
            Ok(())
        })?;
        Ok(self)
    }

    /// Part of the finalization procedure that emits the operations related to the subcomponents.
    ///
    /// For `@compute` emits the write operations for the results of calling the `@compute`
    /// functions of the subcomponents and the values of the inputs.
    ///
    /// For `@constrain` emits calls to `@constrain` for each subcomponent.
    fn finalize_subcmps(self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Result<Self>
    where
        // Required by `loop_nest`
        'val: 'blk,
    {
        let mut subcmps: Vec<_> = self.subcmps.keys().collect();
        if codegen.config.stabilize {
            // Sort by circom subcomponent names to ensure a stable order of operations.
            subcmps.sort_by(Ord::cmp);
        }
        let location = codegen.location_unknown();
        let comp_sym = codegen.flat_sym(COMP);

        self.and_then::<_, _, GenResultUnit>(|fc, _| {
                // Write the subcomponent declarations to self.
                let self_value = fc.func.self_value_of_compute()?;
                subcmps.iter().try_for_each(|name| {
                    // Write the inputs of the subcomponent.
                    let name_inputs = crate::subcmp::names::inputs(name);
                    let name_inputs_val = *fc.block_ctx.get_named_value(&name_inputs)?;
                    fc.append_op_no_result(r#struct::writem(
                        location,
                        self_value,
                        &name_inputs,
                        name_inputs_val,
                    )?)?;

                    // This value is the memory SSA value. We need to extract the component from
                    // it.
                    let mem = *fc.block_ctx.get_named_value(name)?;
                    let value = type_switch! { ty = mem.r#type(),
                        ArrayType => {
                            // Copy the components into an array of the same dimensions.
                            let struct_type = comp_type(ty.element_type().try_into()?)?;

                            let comp_array = fc.append_op_unnamed_result(codegen.new_array_new_op(
                                location,
                                map_array_inner_type(ty.into(), struct_type).try_into()?,
                                ArrayCtor::Empty
                            ))?;

                            fc.gen_loop_nest_from_attrs(codegen, codegen.location_unknown(), &ty.dims(), |fc, indices| {
                                let comp_memory = fc.append_array_read(
                                    mem,
                                    indices,
                                    location,
                                    None
                                )?;
                                let comp_instance = fc.append_op_unnamed_result(pod::read(
                                    location,
                                    comp_memory,
                                    comp_sym,
                                    struct_type
                                ))?;
                                fc.append_array_write(
                                    codegen,
                                    comp_array,
                                    indices,
                                    location,
                                    comp_instance,
                                    None
                                )
                            })?;

                            comp_array
                        }
                        PodType => {
                            fc.append_op_unnamed_result(pod::read(
                                location,
                                mem,
                                comp_sym,
                                comp_type(ty)?
                            ))?
                        }
                    };

                    fc.append_op_no_result(r#struct::writem(
                        location,
                        self_value,
                        name,
                        value,
                    )?)

                })

        }, |fc, _| {
                subcmps.iter().try_for_each(|name| {
                    // Read the subcomponent
                    let subcmp = *fc.block_ctx.get_named_value(name)?;

                    // Read the subcomponent inputs. The pod records are in declaration order,
                    // which matches the order of the `@constrain` function.
                    let inputs = *fc.block_ctx.get_named_value(&crate::subcmp::names::inputs(name))?;
                    // Call `@constrain`
                    type_switch! { inputs_type = inputs.r#type(),
                        ArrayType => {
                            let dims = inputs_type.dims();
                            let subcmp_type = ArrayType::try_from(subcmp.r#type())?;
                            assert_eq!(dims, subcmp_type.dims());

                            fc.gen_loop_nest_from_attrs(codegen, location, &dims, |fc, indices| {
                                let subcmp_instance = fc.append_array_read(
                                        subcmp,
                                        indices,
                                        location,
                                        None
                                    )?;
                                let subcmp_inputs = fc.append_array_read(
                                        inputs,
                                        indices,
                                        location,
                                        None
                                    )?;
                                fc.gen_constrain_call(
                                   subcmp_instance,
                                    subcmp_inputs,
                                    location,
                                    codegen
                                )
                            })
                        }
                        PodType as _ => fc.gen_constrain_call(subcmp, inputs,  location, codegen),
                    }
                })
        })?;
        Ok(self)
    }

    /// Finalizes the context by emitting the final write operations that write subcomponent
    /// declarations to the declaring component.
    pub fn finalize(self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Result<()>
    where
        // Required by `finalize_subcmps`
        'val: 'blk,
    {
        self.finalize_subcmps(codegen)?
            .finalize_queue()?
            .and_then_same(|fc, _| fc.finalize(codegen))
    }
}

impl SubcmpInfo for TemplateContext<'_, '_, '_, '_, '_> {
    fn is_subcmp(&self, var: &str) -> bool {
        self.subcmps.contains_key(var)
    }

    fn subcmp_info<'i>(
        &self,
        var: &str,
        info: &'i dyn ProgramInfo,
    ) -> Result<&'i dyn SignalDeclarations> {
        let template_name =
            self.subcmps.get(var).ok_or_else(|| anyhow!("subcomponent '{var}' not found"))?;
        info.find_template(template_name)
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
    fn convert_dim_expr(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ArrayDimensionResult<'ctx, 'val>> {
        // First try to compute statically, falling back to literal computation if all values are
        // not compile-time constants or if the final result does not properly convert to i64.
        if let Some(integer) = shared::try_compute_as_i64(expr, codegen.prime())? {
            ArrayDimensionResult::new(codegen.index_attr(integer).into(), &[])
        } else {
            #[allow(unused_variables)] // TODO: TEMP
            match expr {
                Expression::Number(_, _) => {
                    unreachable!("handled by try_compute_as_i64")
                }
                Expression::Variable { meta, name, access } => match access.as_slice() {
                    [] => {
                        // Grab the parameter name if it exists, else, defer to function generation.
                        if self.struct_def.has_param_name(name) {
                            ArrayDimensionResult::new(codegen.flat_sym(name).into(), &[])
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
        'val: 'r,
        'val: 'blk;

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
    'val: 'blk,
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
    let mut to_felt = |val: Value<'ctx, 'val>| {
        fc.append_op_unnamed_result(cast::tofelt(location, val, None).into())
    };

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
    'val: 'blk,
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
                template.and_then_same(|fc, _| fc.gen_declaration(codegen, meta, name, dimensions))
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
                            if template.is_subcmp(var) {
                                // Do nothing.
                                Ok(())
                            } else {
                                rhe.gen_llzk_in_template(codegen, template)?.and_then_same(
                                    |fc, val| fc.handle_simple_assignment(codegen, meta, var, val),
                                )
                            }
                        } else {
                            let location = codegen.location_from_meta(meta);
                            rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                |fc, val| {
                                    WriteChain::new(var, Root::Var, access).write(
                                        val,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        location,
                                        template,
                                        template,
                                    )
                                },
                                |fc, val| {
                                    WriteChain::new(var, Root::Var, access).write(
                                        val,
                                        WriteTarget::Constrain,
                                        codegen,
                                        fc,
                                        location,
                                        template,
                                        template,
                                    )
                                },
                            )
                        }
                    }
                    AssignOp::AssignSignal => {
                        match &access[..] {
                            [] => {
                                // The `<--` operator is witness generation only so code for the RHS
                                // expression should only be generated in the compute function.
                                // The constrain function just reads that field from "self" struct.
                                // However, we already inserted these reads at the beginning of the
                                // constrain function in `gen_template_llzk`.
                                let signal_type = template.get_signal_type(var)?;
                                rhe.gen_llzk_in_template(codegen, &template.compute_only())?
                                    .and_then_same(|fc, val| {
                                        let location = codegen.location_from_meta(meta);
                                        // Cast value to signal type if needed.
                                        let value = fc.cast_to_expected_type_if_needed(
                                            codegen,
                                            location,
                                            val,
                                            signal_type,
                                        )?;
                                        // Write value to field of "self" struct.
                                        fc.append_op_no_result(
                                            r#struct::writem(
                                                location,
                                                fc.func.self_value_of_compute()?,
                                                var,
                                                value,
                                            )?
                                            .into(),
                                        )?;
                                        fc.block_ctx.set_named_value(var.clone(), value)
                                    })
                            }
                            access => rhe
                                .gen_llzk_in_template(codegen, &template.compute_only())?
                                .and_then_same(|fc, rhe| {
                                    WriteChain::new(var, Root::Signal, access).write(
                                        rhe,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        codegen.location_from_meta(meta),
                                        template,
                                        template,
                                    )
                                }),
                        }
                    }
                    AssignOp::AssignConstraintSignal => {
                        match &access[..] {
                            [] => {
                                let signal_type = template.get_signal_type(var)?;
                                rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                    |fc, val| {
                                        let location = codegen.location_from_meta(meta);
                                        // Cast value to field type if needed.
                                        let value = fc.cast_to_expected_type_if_needed(
                                            codegen,
                                            location,
                                            val,
                                            signal_type,
                                        )?;
                                        // Write value to field of "self" struct.
                                        fc.append_op_no_result(
                                            r#struct::writem(
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
                                        // Get value of field from "self" struct (already generated
                                        // at the beginning of the constrain function, see
                                        // `gen_template_llzk`) and generate equality constraint
                                        // with 'val'.
                                        let location = codegen.location_from_meta(meta);
                                        let signal_val = fc.block_ctx.get_named_value(var)?;
                                        let (lhs, rhs) = unify_constrain_eq_types(
                                            fc,
                                            location,
                                            *signal_val,
                                            val,
                                        )?;
                                        fc.append_op_no_result(
                                            constrain::eq(location, lhs, rhs).into(),
                                        )
                                    },
                                )
                            }
                            access => rhe.gen_llzk_in_template(codegen, template)?.and_then(
                                |fc, rhv| {
                                    WriteChain::new(var, Root::Signal, access).write(
                                        rhv,
                                        WriteTarget::Compute,
                                        codegen,
                                        fc,
                                        codegen.location_from_meta(meta),
                                        template,
                                        template,
                                    )
                                },
                                |fc, rhv| {
                                    let location = codegen.location_from_meta(meta);
                                    let lhv = Lvalue::new(var, Root::Signal, access)
                                        .get_value(codegen, fc, template, location, None)?;
                                    fc.append_op_no_result(constrain::eq(location, lhv, rhv).into())
                                },
                            ),
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
                    let location = codegen.location_from_meta(meta);
                    let cond = fc.cast_to_bool_if_needed(codegen, location, val)?;
                    let msg = Some("assertion failed");
                    fc.append_op_no_result(llzk::dialect::bool::assert(location, cond, msg)?.into())
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
    'val: 'blk,
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
                // We don't handle template parameters until the general structure of the procedure
                // is done.
                if !args.is_empty() {
                    todo!("subcomponents with template parameters");
                }
                let location = codegen.location_from_meta(meta);
                let dimensions = template.get_dimensions(codegen, args)?;

                // Names of the template parameters
                let params_formals = codegen.program.get_template_data(id).get_name_of_params();
                let subcmp_type = dimensions.struct_type_with_concrete_dimensions(codegen, id);
                let count = codegen.count_input_signals(subcmp_type.into())?;
                let records = [
                    // Counts the number of inputs pending an assignment. When it reaches 0 it's
                    // safe to call the corresponding `@compute` function.
                    (COUNT, codegen.index_type()),
                    // Holds the output of calling `@compute`. Before the call, this value is
                    // undefined and should not be read from.
                    (COMP, subcmp_type.into()),
                    // Holds the affine map operands of the subcomponents, if any.
                    (PARAMS, codegen.pod_type(&[]).into()),
                ];

                // Create a `pod.new` operation with the memory for the subcomponent.
                template.and_then_same(|fc, _| {
                    let pod_type = Some(codegen.pod_type(&records));
                    // If the count == 0 means that the subcomponent has no inputs. In that case we
                    // call `@compute` here directly and store it into COMP.
                    let (name, value) = if count.is_const_zero() {
                        let empty_inputs = fc.append_op_unnamed_result(pod::new(
                            codegen.op_builder(),
                            location,
                            &[],
                            Some(codegen.pod_type(&[])),
                        ))?;
                        let instance =
                            fc.gen_compute_call(subcmp_type, empty_inputs, location, codegen)?;
                        (COMP, instance)
                    } else {
                        (
                            COUNT,
                            count.to_index_value(
                                codegen,
                                fc,
                                location,
                                Some(&TmplParamsInstance::new(params_formals, &dimensions)),
                            )?,
                        )
                    };

                    fc.append_op_unnamed_result(pod::new(
                        codegen.op_builder(),
                        location,
                        &[RecordValue::new(StringRef::new(name), value)],
                        pod_type,
                    ))
                })
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
                            &Option::from(fc.convert_dim_expr(codegen, dimension)?)
                                .ok_or_else(||
                                    anyhow!("missing data required to compute uniform array dimensions in template"))?
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
                    expr.gen_llzk_in_function(codegen, fc, template.into())
                })
            }
        }
    }
}
