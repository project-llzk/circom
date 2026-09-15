//! Handles function-level LLZK code generation for both free functions and functions within
//! structs. The [FunctionContext] carries information about the current LLZK function
//! being generated and some helpers related to generating code within the function. The
//! [GenerateLLZKInFunction] trait provides the visitor to generate LLZK IR for all circom
//! [Expression](program_structure::ast::Expression) and
//! [Statement](program_structure::ast::Statement) nodes.

use std::{
    collections::HashMap,
    convert::TryFrom,
    ops::{Deref, DerefMut},
};

use anyhow::{Context as _, Result};
use llzk::{
    builder::OpBuilder,
    dialect,
    dialect::{array, array::ArrayCtor, bool, function, global, poly},
    operation::{erase_op, WalkOperationMutLike as _},
    prelude::{
        is_type_variable,
        melior_dialects::{
            arith, scf,
            scf::{is_if_op, is_yield_op},
        },
        ArrayType, Attribute, BlockLike as _, BlockRef, FuncDefOpLike as _, FuncDefOpRefMut,
        IntegerAttribute, LlzkContext, Location, LoopBoundsAttribute, Operation,
        OperationLike as _, OperationMutLike, OperationRefMut, Type, Value, ValueLike as _,
        WalkOrder, WalkResult,
    },
    value_ext::has_uses,
};
use num_bigint_dig::BigInt;
use num_traits::ToPrimitive;
use program_structure::{
    ast::{Access, AssignOp, Expression, Meta, Statement, VariableType},
    error_code::ReportCode,
};

use crate::{
    gen_context::{
        BlockContextStack, BlockGenContext, GenWithCircomScopeHandling, GenerateLLZKInAnyBlock,
        NestedBlockInfo, CIRCOM_RETURN_MARKER_ATTR, OPERAND_VAL_NAMES, VAR_NAME_HAD_RETURN,
        VAR_NAME_RETURN_VAL,
    },
    program_ext::ProgramLike,
    shared::{
        new_region_and_block, new_region_empty, next_in_block_mut, no_results,
        parent_operation_mut, remove_from_parent, single_result_as_value, LlzkCodegen,
    },
    subcmp::{NoSubcmps, SubcmpInfo},
    template::TemplateContext,
    try_for_loop_heuristic,
    write_chain::{NoSignalsInfo, SignalWriteInfo},
};

/// Contains references to information providers.
///
/// This information is required by [`Lvalue`] for properly constructing the IR representing the
/// read in the case of subcomponents. The information it needs is:
/// - Is the variable a subcomponent?
/// - Is the field read with dot-notation an input or an output?
///
/// To answer that information it needs the [`TemplateContext`] since subcomponents can only occur
/// inside a template. However, the logic in this file lowers [expressions](Expression) in both
/// functions and templates so is necessary to provide that information in such a way that is
/// transparent to that.
///
/// This type holds dyn references to two traits that give just enough information necessary for
/// lowering using [`Lvalue`]. Both traits are implemented by [`TemplateContext`] and by a couple
/// [Null objects](https://en.wikipedia.org/wiki/Null_object_pattern). The former is used while
/// lowering expressions inside a template and the latter used while lowering inside a function.
#[derive(Copy, Clone, Debug)]
pub struct InfoProviders<'info, 'ctx> {
    /// Subcomponent information.
    pub subcmp_info: &'info dyn SubcmpInfo<'ctx>,
    /// Signals write information.
    ///
    /// TODO: We may be able to remove this field if the lowering in this file does not need to use
    /// `WriteChain`. Since that type aims to be generic it may be reusable in the context of
    /// lowering freestanding functions, in which case it needs an empty implementation of this
    /// interface. This field is already here in preparation for reusing WriteChain.
    pub signal_write_info: &'info dyn SignalWriteInfo,
}

impl Default for InfoProviders<'_, '_> {
    fn default() -> Self {
        Self { subcmp_info: &NoSubcmps, signal_write_info: &NoSignalsInfo }
    }
}

impl<'tmpl, 'ctx, 'str, 'func, 'blk, 'val>
    From<&'tmpl TemplateContext<'_, 'ctx, 'str, 'func, 'blk, 'val>> for InfoProviders<'tmpl, 'ctx>
{
    fn from(template: &'tmpl TemplateContext<'_, 'ctx, 'str, 'func, 'blk, 'val>) -> Self {
        Self { subcmp_info: template, signal_write_info: template }
    }
}

/// Stores ref to the current function while generating LLZK IR for the function.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// The function reference.
    pub(crate) func: FuncDefOpRefMut<'ctx, 'func>,
    /// Base block generation context.
    pub(crate) base: BlockGenContext<'decls, 'ctx, 'blk, 'val>,
}

/// Allows calling through to functions on the [`BlockGenContext`].
impl<'decls, 'ctx, 'blk, 'val> std::ops::Deref for FunctionContext<'decls, 'ctx, '_, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    type Target = BlockGenContext<'decls, 'ctx, 'blk, 'val>;

    fn deref(&self) -> &Self::Target {
        &self.base
    }
}

impl<'ctx, 'blk, 'val> std::ops::DerefMut for FunctionContext<'_, 'ctx, '_, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.base
    }
}

impl<'decls, 'ctx, 'blk, 'val> AsMut<BlockGenContext<'decls, 'ctx, 'blk, 'val>>
    for FunctionContext<'decls, 'ctx, '_, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    fn as_mut(&mut self) -> &mut BlockGenContext<'decls, 'ctx, 'blk, 'val> {
        self.deref_mut()
    }
}

impl<'decls, 'ctx, 'blk, 'val> AsRef<BlockGenContext<'decls, 'ctx, 'blk, 'val>>
    for FunctionContext<'decls, 'ctx, '_, 'blk, 'val>
where
    'ctx: 'blk,
    'blk: 'val,
{
    fn as_ref(&self) -> &BlockGenContext<'decls, 'ctx, 'blk, 'val> {
        self.deref()
    }
}

/// Cache block yield/return result value while performing early-return refactoring.
enum RefactoringBlockResultType<'ctx> {
    /// Single result value from the block.
    Single(Type<'ctx>),
    /// Multiple result values from the block with `OPERAND_VAL_NAMES` attribute.
    Multiple(Vec<Type<'ctx>>, Attribute<'ctx>),
}

impl<'ctx> RefactoringBlockResultType<'ctx> {
    /// Get the number of result values.
    fn len(&self) -> usize {
        match self {
            RefactoringBlockResultType::Single(_) => 1,
            RefactoringBlockResultType::Multiple(types, _) => types.len(),
        }
    }

    /// Get the result types.
    fn result_types(&self) -> &[Type<'ctx>] {
        match self {
            RefactoringBlockResultType::Single(ty) => std::slice::from_ref(ty),
            RefactoringBlockResultType::Multiple(types, _) => types,
        }
    }

    /// Get name [Attribute] if multiple result types.
    fn name_attr(&self) -> Option<Attribute<'ctx>> {
        match self {
            RefactoringBlockResultType::Single(_) => None,
            RefactoringBlockResultType::Multiple(_, attr) => Some(*attr),
        }
    }

    /// Generate an [scf::yield] operation with the given values and location, propagating the
    /// `name_attr` from `self` if applicable.
    fn gen_yield(&self, values: &[Value<'ctx, '_>], location: Location<'ctx>) -> Operation<'ctx> {
        assert_eq!(values.len(), self.len(), "requires one value per result");
        let mut new_yield = scf::r#yield(values, location);
        if let Some(names_attr) = self.name_attr() {
            new_yield.set_attribute(OPERAND_VAL_NAMES, names_attr);
        }
        new_yield
    }
}

impl<'decls, 'ctx, 'func, 'blk, 'val> FunctionContext<'decls, 'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Create a new [FunctionContext] for the given function with an initial name-to-value mapping,
    /// mapping of `var` declaration names to their declared LLZK types, and set of visible
    /// `poly.param` and `poly.expr` names.
    pub fn new<const FREE_FUNC: bool>(
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        func: FuncDefOpRefMut<'ctx, 'func>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
        var_decl_types: &'decls HashMap<String, Type<'ctx>>,
        poly_template_binding_names: impl IntoIterator<Item = (String, Option<Type<'ctx>>)>,
    ) -> Result<Self> {
        let mut block_ctx = BlockContextStack::from_function(func.deref(), param_name_to_value)?;
        if FREE_FUNC {
            // Ensure the specially-named values are declared in free functions.
            block_ctx.declare_value_if_not_present(
                VAR_NAME_RETURN_VAL,
                |builder| {
                    // Get the result type from the free function. It supports exactly 1.
                    let ty = func.function_type()?;
                    assert_eq!(ty.result_count(), 1);
                    single_result_as_value(codegen.new_nondet_at_location(
                        builder,
                        codegen.location_unknown(),
                        ty.result(0)?,
                    ))
                },
                codegen.context,
            )?;
            block_ctx.declare_value_if_not_present(
                VAR_NAME_HAD_RETURN,
                |builder| {
                    single_result_as_value(codegen.new_nondet_at_location(
                        builder,
                        codegen.location_unknown(),
                        codegen.bool_type().into(),
                    ))
                },
                codegen.context,
            )?;
        }
        Ok(Self {
            func,
            base: BlockGenContext::new(block_ctx, var_decl_types, poly_template_binding_names)
                .with_poly_template_binding_locals(codegen, codegen.location_unknown())?,
        })
    }

    /// Get the return type of the function.
    pub fn return_type(&self) -> Type<'ctx> {
        self.func
            .function_type()
            .expect("`function_type` attr must exist")
            .result(0)
            .expect("LLZK function must return a single result")
    }

    /// Generate and append an op to carry the value from a circom return statement. It will
    /// generate a return op if the context stack height is 1, otherwise a yield op. In either
    /// case, it is marked with the [CIRCOM_RETURN_MARKER_ATTR] attribute.
    pub fn append_circom_return(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        location: Location<'ctx>,
        value: Value<'ctx, 'val>,
    ) -> Result<()> {
        if self.block_ctx.is_only_root() {
            let value = self.cast_to_return_type_if_needed(codegen, location, value)?;
            let builder = self.builder_at_current_insertion_point(codegen.context);
            let op = function::r#return(&builder, location, &[value]);
            unsafe { OperationRefMut::from_raw(op.to_raw()) }
                .set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
            no_results(op)
        } else {
            let mut op = scf::r#yield(&[value], location);
            op.set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
            self.append_op_no_result(op)
        }
    }

    /// Create an op to cast `val` to match the return type of the function.
    #[inline]
    pub fn cast_to_return_type_if_needed(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        let return_ty = self.return_type();
        self.cast_to_expected_type_if_needed(codegen, location, val, return_ty)
    }

    /// Generates a `scf.if` block that runs the 'then' branch if the given value is 0.
    pub fn gen_scf_if_is_zero(
        &mut self,
        value: Value<'ctx, 'val>,
        location: Location<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        body: impl FnOnce(&mut Self) -> Result<()>,
    ) -> Result<()> {
        let zero = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
        let cmp = self.append_op_unnamed_result(arith::cmpi(
            codegen.context,
            arith::CmpiPredicate::Eq,
            value,
            zero,
            location,
        ))?;

        let (then_region, then_block) = new_region_and_block(&[]);
        self.block_ctx.push(then_block);
        body(self)?;
        self.append_op_no_result(scf::r#yield(&[], location))?;
        self.block_ctx.pop(codegen.context)?;

        // No need to use `gen_safe_scf_if()` here since there's no result value.
        self.append_op_no_result(scf::r#if(cmp, &[], then_region, new_region_empty(), location))
    }

    /// Finalizes the context.
    pub fn finalize(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Result<()> {
        self.func.walk_mut(WalkOrder::PreOrder, |mut op| {
            // Remove any `llzk.nondet` ops from the function whose result value is unused. These
            // were added, for example, when visiting [Statement::Declaration] but their uses were
            // later replaced with actual values when visiting [Statement::Substitution], etc.
            if dialect::llzk::is_nondet_op(&op) && !has_uses(single_result_as_value(op).unwrap()) {
                OperationMutLike::remove_from_parent(op.deref_mut());
                return WalkResult::Skip;
            }
            WalkResult::Advance
        });

        // Use a bottom-up (i.e. PostOrder) traversal that also walks blocks in reverse order to
        // remove `CIRCOM_RETURN_MARKER_ATTR` and find `scf.return` ops located within `scf.if` ops.
        let mut rets_in_if: Vec<_> = vec![];
        self.func.walk_rev_mut(WalkOrder::PostOrder, |mut op| {
            if op.has_attribute(CIRCOM_RETURN_MARKER_ATTR) {
                // Perform replacement of "if(..) return" pattern.
                if function::is_return_op(&op) {
                    if let Some(parent) = parent_operation_mut(&op) {
                        if is_if_op(&parent) {
                            // Cannot directly do the refactor here because it will invalidate the
                            // walk iterator. Instead, collect the pairs to process after the walk.
                            // But, must use raw objects since `op` is invalid outside this closure.
                            rets_in_if.push((op.to_raw(), parent.to_raw()));
                            return WalkResult::Skip;
                        }
                    }
                }

                // Remove the `CIRCOM_RETURN_MARKER_ATTR` attribute because it is a temporary marker
                // used to adjust the location of return statements to match LLZK requirements.
                let r = op.remove_attribute(CIRCOM_RETURN_MARKER_ATTR);
                assert!(r.is_ok(), "Must succeed due to the has_attribute check above");
            }
            WalkResult::Advance
        });
        for (ret, parent) in rets_in_if {
            let ret_op = unsafe { OperationRefMut::from_raw(ret) };
            let parent_if_op = unsafe { OperationRefMut::from_raw(parent) };
            Self::refactor_return_in_if(codegen, ret_op, parent_if_op)?;
        }
        // One more pass to remove remaining `OPERAND_VAL_NAMES` attributes
        self.func.walk_mut(WalkOrder::PreOrder, |mut op| {
            let _ = op.remove_attribute(OPERAND_VAL_NAMES);
            WalkResult::Advance
        });
        Ok(())
    }

    /// Replace `parent_if_op` with a new `scf.if` op where the existing `ret_op` is changed to a
    /// yield and all operations in the same block following `parent_if_op` are moved into the else
    /// branch (with return op there also converted to a yield op). The new `scf.if` op result is
    /// used in a new `scf.return` op added after the new `scf.if`.
    fn refactor_return_in_if(
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        ret_op: OperationRefMut<'ctx, '_>,
        mut parent_if_op: OperationRefMut<'ctx, '_>,
    ) -> Result<()> {
        assert!(function::is_return_op(&ret_op)); // precondition
        assert!(is_if_op(&parent_if_op)); // precondition

        // Move all ops after the `scf.if` into a new block for "else" branch of new `scf.if`.
        let (new_else_region, new_else_block) = new_region_and_block(&[]);
        let new_else_result_info: RefactoringBlockResultType;
        {
            // Collect all ops before removing any to avoid invalidating references.
            let mut following_ops = Vec::new();
            let mut cur = next_in_block_mut(&parent_if_op);
            while let Some(op_ref) = cur {
                following_ops.push(op_ref);
                cur = next_in_block_mut(&op_ref);
            }
            let mut tail = following_ops.pop().context("expected at least a yield/return")?;
            for op_ref in following_ops.iter_mut() {
                new_else_block.append_operation(remove_from_parent(op_ref));
            }
            // Special handling for the tail op: yield is just added, return is converted to yield.
            let tail = remove_from_parent(&mut tail);
            if is_yield_op(&tail) {
                let result_types = tail.operands().map(|v| v.r#type()).collect();
                let names = tail
                    .attribute(OPERAND_VAL_NAMES)
                    .expect("multi-value yield op must have names");
                new_else_result_info = RefactoringBlockResultType::Multiple(result_types, names);
                no_results(new_else_block.append_operation(tail))?;
            } else if function::is_return_op(&tail) {
                assert_eq!(tail.operand_count(), 1, "circom functions must return a single value");
                let ret_val = tail.operand(0).unwrap();
                new_else_result_info = RefactoringBlockResultType::Single(ret_val.r#type());
                no_results(
                    new_else_block.append_operation(scf::r#yield(&[ret_val], tail.location())),
                )?;
            } else {
                anyhow::bail!("expected either yield or return at end of block");
            }
        }

        // Create "then" block for new `scf.if` and add yield converted from `ret_op`.
        let (new_then_region, new_then_block) = new_region_and_block(&[]);
        {
            assert_eq!(ret_op.operand_count(), 1, "circom functions must return a single value");
            let ret_val = ret_op.operand(0).unwrap();
            let mut yield_values = Vec::with_capacity(new_else_result_info.len());

            // The blocks must yield the same number and type of values. So if the "else" block
            // yields more than one value, need to add additional operands to yield here.
            match &new_else_result_info {
                RefactoringBlockResultType::Single(t) => {
                    if ret_val.r#type() != *t {
                        anyhow::bail!("type mismatch in return value between branches");
                    }
                    yield_values.push(ret_val);
                }
                RefactoringBlockResultType::Multiple(result_types, names) => {
                    let location = ret_op.location();
                    for (i, s) in codegen.attribute_to_list(*names)?.enumerate() {
                        if s == VAR_NAME_RETURN_VAL {
                            yield_values.push(ret_val);
                        } else if s == VAR_NAME_HAD_RETURN {
                            // Gen true constant since this case has a return.
                            yield_values.push(single_result_as_value(
                                new_then_block
                                    .append_operation(codegen.new_bool_const_op(true, location)),
                            )?);
                        } else {
                            assert!(i <= result_types.len(), "more names than result types");
                            // Fill other positions with `llzk.nondet` values of the expected type.
                            let builder = OpBuilder::at_block_end(codegen.context, new_then_block);
                            yield_values.push(single_result_as_value(
                                codegen.new_nondet_at_location(&builder, location, result_types[i]),
                            )?);
                        }
                    }
                }
            }
            let new_yield = new_else_result_info.gen_yield(&yield_values, ret_op.location());
            no_results(new_then_block.append_operation(new_yield))?;
        }

        // Create new `scf.if` op using the new "then" and "else" blocks.
        let blk = parent_if_op.block().context("expected parent block for original `if`")?;
        let empty_var_decl_types = Default::default();
        let mut gen_ctx_in_parent_if_op_block = BlockGenContext::new(
            BlockContextStack::new(blk),
            &empty_var_decl_types,
            std::iter::empty(),
        );
        let result_values = gen_ctx_in_parent_if_op_block.gen_safe_scf_if_multi(
            codegen,
            parent_if_op.location(),
            parent_if_op.operand(0)?,
            new_then_region,
            None,
            new_else_region,
            None,
            Some(new_else_result_info.result_types()),
        )?;

        // Replace `parent_if_op` with the new `scf.if` and then append a return/yield with the new
        // `scf.if` results. If the destination block is the function body use return, else yield.
        if blk.parent_operation().is_some_and(|r| function::is_def_op(&r)) {
            let builder = OpBuilder::at_block_end(codegen.context, blk);
            no_results(function::r#return(&builder, parent_if_op.location(), &result_values))?;
        } else {
            no_results(blk.append_operation(
                new_else_result_info.gen_yield(&result_values, parent_if_op.location()),
            ))?;
        }

        // Finally, remove and drop the original `parent_if_op`.
        let _drop = remove_from_parent(&mut parent_if_op);

        Ok(())
    }
}

/// The [FunctionContext] directly accesses a single [BlockContextStack] for circom scope handling.
impl<'ctx, 'func, 'blk, 'val> GenWithCircomScopeHandling<'ctx, 'func, 'blk, 'val>
    for FunctionContext<'_, 'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type BlockType = BlockRef<'ctx, 'blk>;
    type HandlerDataType = NestedBlockInfo<'ctx, 'blk, 'val>;

    fn stack_top(&self) -> Self::BlockType {
        *self.block_ctx.top_block()
    }

    fn stack_push(&mut self, block: Self::BlockType) {
        self.block_ctx.push(block)
    }

    fn stack_pop<H>(
        &mut self,
        context: &'ctx LlzkContext,
        overwrite_handler: H,
        overwrite_data: &mut Self::HandlerDataType,
    ) -> Result<()>
    where
        H: Fn(
            &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
            &mut NestedBlockInfo<'ctx, 'blk, 'val>,
            HashMap<String, Value<'ctx, 'val>>,
        ) -> Result<()>,
    {
        let popped = self.block_ctx.pop(context)?;
        overwrite_handler(&mut self.base, overwrite_data, popped)
    }
}

/// A trait to generate LLZK IR from the body of a circom function.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
pub trait GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Output type of the generator function.
    type Output;

    /// Generates LLZK IR from [Statement] nodes in a circom function.
    fn gen_llzk_in_function<'info>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info, 'ctx>,
    ) -> Result<Self::Output>;
}

/// Output type of [GenerateLLZKInFunction] implemented for [Statement] indicating whether the
/// current statement causes abrupt termination of the current block (in other words, whether
/// the remaining statements in the same block should be skipped).
type SkipRestOfBlock = bool;

/// Enumerate all N-dimensional index tuples for the given constant dimension sizes.
/// E.g., `[2, 3]` → `[[0,0], [0,1], [0,2], [1,0], [1,1], [1,2]]`.
fn cartesian_product_indices(dims: &[i64]) -> Vec<Vec<i64>> {
    dims.iter().fold(vec![vec![]], |acc, &dim| {
        acc.into_iter()
            .flat_map(|prefix| {
                (0..dim).map(move |i| {
                    let mut p = prefix.clone();
                    p.push(i);
                    p
                })
            })
            .collect()
    })
}

/// For two concrete array types with the same number of dimensions, generate inline copy code
/// that copies elements from `src` (type `src_ty`) into a newly allocated empty array of type
/// `dst_ty`, appending all generated ops directly to `block`. Only elements within the min
/// bounds of each dimension are copied; elements beyond the source bounds are not modified.
/// All dimension attributes in `src_ty` and `dst_ty` must be constant integer indices (true
/// for all VCF concrete types).
fn copy_concrete_array_to_type_in_block<'ctx, 'blk, 'val>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    location: Location<'ctx>,
    block: BlockRef<'ctx, 'blk>,
    src: Value<'ctx, 'val>,
    src_ty: ArrayType<'ctx>,
    dst_ty: ArrayType<'ctx>,
) -> Result<Value<'ctx, 'val>>
where
    'ctx: 'blk,
    'blk: 'val,
{
    fn const_dims(arr_ty: ArrayType<'_>) -> Result<Vec<i64>> {
        arr_ty
            .dims()
            .iter()
            .map(|d| {
                let int_attr = IntegerAttribute::try_from(*d)
                    .map_err(|_| anyhow::anyhow!("non-constant array dimension"))?;
                let dim = int_attr.value();
                anyhow::ensure!(dim >= 0, "negative array dimension");
                Ok(dim)
            })
            .collect()
    }

    let src_dims = const_dims(src_ty)?;
    let dst_dims = const_dims(dst_ty)?;
    assert_eq!(
        src_dims.len(),
        dst_dims.len(),
        "src and dst must have the same number of dimensions"
    );

    // Allocate a new uninitialized array of the destination type.
    let builder = OpBuilder::at_block_end(codegen.context, block);
    let dst = single_result_as_value(codegen.new_array_new_op(
        &builder,
        location,
        dst_ty,
        ArrayCtor::Empty,
    ))?;

    // Copy elements within the min bounds of each dimension pair.
    let min_dims: Vec<i64> = src_dims.iter().zip(&dst_dims).map(|(s, d)| *s.min(d)).collect();
    for indices in cartesian_product_indices(&min_dims) {
        let idx_vals: Vec<Value> = indices
            .into_iter()
            .map(|i| {
                single_result_as_value(
                    block.append_operation(codegen.new_index_const_op(i, location)),
                )
            })
            .collect::<Result<_>>()?;
        let read = array::read(&builder, location, src_ty.element_type(), src, &idx_vals);
        let elem = single_result_as_value(read)?;
        let write = array::write(&builder, location, dst, &idx_vals, elem);
        no_results(write)?;
    }

    Ok(dst)
}

/// Append a `poly.unifiable_cast` to cast `value` to `target_ty` directly on `block` if the
/// types differ. Returns `value` unchanged if the types are already equal.
fn cast_to_type_in_block<'ctx, 'blk, 'val>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    location: Location<'ctx>,
    block: BlockRef<'ctx, 'blk>,
    value: Value<'ctx, 'val>,
    target_ty: Type<'ctx>,
) -> Result<Value<'ctx, 'val>>
where
    'ctx: 'blk,
    'blk: 'val,
{
    if value.r#type() == target_ty {
        return Ok(value);
    }
    let builder = OpBuilder::at_block_end(codegen.context, block);
    let cast = poly::unifiable_cast(&builder, location, value, target_ty);
    single_result_as_value(cast)
}

/// Within a nested (i.e. non-root) block, get the Value wrapped within an `scf.yield` op that was
/// created from a circom return op.
fn get_val_of_circom_return_and_erase<'ctx, 'blk, 'val>(
    block: BlockRef<'ctx, 'blk>,
) -> Option<Value<'ctx, 'val>>
where
    'ctx: 'blk,
    'blk: 'val,
{
    if let Some(mut term) = block.terminator_mut() {
        // Per `append_circom_return()`, the op generated from a circom return
        // statement has the special attribute `CIRCOM_RETURN_MARKER_ATTR`.
        if term.has_attribute(CIRCOM_RETURN_MARKER_ATTR) {
            // ASSERT: This must be a `yield` not a `return` since it's generated
            // within a nested block of an `if` or `while` statement.
            assert!(is_yield_op(&term));
            // ASSERT: Per `append_circom_return()` it has exactly one operand.
            assert_eq!(term.operand_count(), 1);
            let result = term.operand(0).unwrap();
            term.remove_from_parent();
            // To avoid "still has uses" native errors, must perform an explicit erase
            // since there's no way to get the owned `Operation` out of the block.
            erase_op(term);
            return Some(result);
        }
    }
    None
}

/// Helper for [gen_if_then_else] to mangage the special return-related variables needed
/// when a circom [Statement::IfThenElse] contains a return statement.
fn handle_unbalanced_return<'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
    return_val: Value<'ctx, 'val>,
    returning_block: BlockRef<'ctx, 'blk>,
    returning_block_overwrites: &mut HashMap<String, Value<'ctx, 'val>>,
    nonreturning_block: BlockRef<'ctx, 'blk>,
    nonreturning_block_overwrites: &mut HashMap<String, Value<'ctx, 'val>>,
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    // Set `VAR_NAME_HAD_RETURN` in both maps: `true` in returning block, `false` in other.
    returning_block_overwrites.insert(
        VAR_NAME_HAD_RETURN.to_string(),
        single_result_as_value(
            returning_block.append_operation(codegen.new_bool_const_op(true, location)),
        )?,
    );
    nonreturning_block_overwrites.insert(
        VAR_NAME_HAD_RETURN.to_string(),
        single_result_as_value(
            nonreturning_block.append_operation(codegen.new_bool_const_op(false, location)),
        )?,
    );

    // Set return value in both maps. In the non-returning block, use the existing value in the
    // block context, if present, otherwise create a new non-det value.
    returning_block_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), return_val);
    nonreturning_block_overwrites.insert(
        VAR_NAME_RETURN_VAL.to_string(),
        function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL).cloned().or_else(|_| {
            let builder = OpBuilder::at_block_end(codegen.context, nonreturning_block);
            single_result_as_value(codegen.new_nondet_at_location(
                &builder,
                location,
                return_val.r#type(),
            ))
        })?,
    );
    Ok(())
}

/// Generate LLZK code that follows a circom `if-then-else` statement that has an unbalanced return
/// (i.e. one branch returns and the other does not) or `while`. Generates the following LLZK code:
/// ```llzk
///  VAR_NAME_RETURN_VAL = scf.if VAR_NAME_HAD_RETURN {
///      function.return VAR_NAME_RETURN_VAL
///  }
/// ```
fn gen_unbalanced_return_extra<'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    let (then_region, then_block) = new_region_and_block(&[]);
    function.gen_in_given_block_with_new_circom_scope_and_merge_overwrites(
        codegen.context,
        then_block,
        |fc| {
            let ret_val = fc.block_ctx.get_named_value(VAR_NAME_RETURN_VAL)?;
            let value = fc.cast_to_return_type_if_needed(codegen, location, *ret_val)?;
            let builder = fc.builder_at_current_insertion_point(codegen.context);
            let op = function::r#return(&builder, location, &[value]);
            unsafe { OperationRefMut::from_raw(op.to_raw()) }
                .set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
            no_results(op)
        },
    )?;

    let condition = *function.block_ctx.get_named_value(VAR_NAME_HAD_RETURN)?;
    // No need to use `gen_safe_scf_if()` here since there's no result value.
    function.append_op_no_result(scf::r#if(
        condition,
        &[],
        then_region,
        new_region_empty(),
        location,
    ))
}

/// Generate LLZK code for a circom [Statement::IfThenElse].
fn gen_if_then_else<'ctx, 'func, 'blk, 'val, 'info>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'info, 'ctx>,
    meta: &Meta,
    cond: &Expression,
    if_case: &Statement,
    else_case: &Option<Box<Statement>>,
) -> Result<SkipRestOfBlock>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    // Initially, generate the blocks for the 'then' and 'else' cases naively.
    let mut then_info = NestedBlockInfo::default();
    function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        codegen.context,
        then_info.block,
        |function| if_case.gen_llzk_in_function(codegen, function, info),
        &mut then_info,
    )?;
    let mut else_info = NestedBlockInfo::default();
    if let Some(else_case) = else_case {
        function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
            codegen.context,
            else_info.block,
            |function| else_case.gen_llzk_in_function(codegen, function, info),
            &mut else_info,
        )?;
    }

    let location = codegen.location_from_meta(meta);
    let condition = cond.gen_llzk_in_block(codegen, function, info)?;

    // Check if one or both blocks end with a return in circom. The `scf.if` op used in LLZK cannot
    // have returns nested within other blocks like circom allows. Use of `append_circom_return()`
    // already ensures `scf.yield` is used instead of `function.return` when not in the root
    // block but the `scf.if` additionally requires that both blocks yield the same number and type
    // of values. Additionally, if one block returns and the other does not (in the circom code),
    // an additional return state must be added to the values to be yielded from both branches and
    // an additional `scf.if` must be added after the main `scf.if` to check the return state flag.
    let then_return_opt = get_val_of_circom_return_and_erase(then_info.block);
    let else_return_opt = get_val_of_circom_return_and_erase(else_info.block);
    if let Some(then_return) = then_return_opt {
        if let Some(else_return) = else_return_opt {
            // Both return. If the branch types differ and would not be correctly unified by
            // `gen_scf_if_with_var_overwrites`, coerce each branch to the function's declared
            // return type so that all scf.if branches yield the same type.
            //
            // This is only needed when both branches produce different *concrete* (non-tvar) types.
            // If either side is a type variable, `unify_scf_branch_types` handles it correctly.
            //
            // For concrete array types with the same number of dimensions, `poly.unifiable_cast`
            // is not applicable (concrete arrays of different sizes do not unify), so we instead
            // generate inline element-wise copy code to produce an array of the return type,
            // following circom's truncation/extension semantics.
            let then_ty = then_return.r#type();
            let else_ty = else_return.r#type();
            let (then_return, else_return) = if then_ty != else_ty {
                let then_is_tvar = is_type_variable(then_ty);
                let else_is_tvar = is_type_variable(else_ty);
                let return_ty = function.return_type();
                if !then_is_tvar && !else_is_tvar {
                    // Both branches produce different concrete types. Coerce each to the
                    // function's declared return type so all scf.if branches yield the same
                    // type. For concrete arrays with the same number of dimensions where the
                    // return type is also a concrete array, generate inline element-wise copy
                    // code (poly.unifiable_cast is not applicable to concrete arrays of
                    // different sizes); in all other cases use unifiable_cast.
                    match (
                        ArrayType::try_from(then_ty),
                        ArrayType::try_from(else_ty),
                        ArrayType::try_from(return_ty),
                    ) {
                        (Ok(then_arr_ty), Ok(else_arr_ty), Ok(return_arr_ty))
                            if then_arr_ty.num_dims() == else_arr_ty.num_dims() =>
                        {
                            (
                                if then_arr_ty == return_arr_ty {
                                    then_return
                                } else {
                                    copy_concrete_array_to_type_in_block(
                                        codegen,
                                        location,
                                        then_info.block,
                                        then_return,
                                        then_arr_ty,
                                        return_arr_ty,
                                    )?
                                },
                                if else_arr_ty == return_arr_ty {
                                    else_return
                                } else {
                                    copy_concrete_array_to_type_in_block(
                                        codegen,
                                        location,
                                        else_info.block,
                                        else_return,
                                        else_arr_ty,
                                        return_arr_ty,
                                    )?
                                },
                            )
                        }
                        // Non-array mismatch, dimension mismatch, or tvar return type:
                        // use unifiable_cast to coerce each branch to the return type.
                        _ => (
                            cast_to_type_in_block(
                                codegen,
                                location,
                                then_info.block,
                                then_return,
                                return_ty,
                            )?,
                            cast_to_type_in_block(
                                codegen,
                                location,
                                else_info.block,
                                else_return,
                                return_ty,
                            )?,
                        ),
                    }
                } else if then_is_tvar && !else_is_tvar && then_ty == return_ty {
                    // Then branch already yields the function's T_return tvar; cast the
                    // concrete else branch to match, avoiding a round-trip
                    // (concrete -> T_return -> concrete) that would otherwise be added by
                    // unify_scf_branch_types.
                    (
                        then_return,
                        cast_to_type_in_block(
                            codegen,
                            location,
                            else_info.block,
                            else_return,
                            return_ty,
                        )?,
                    )
                } else if !then_is_tvar && else_is_tvar && else_ty == return_ty {
                    // Else branch already yields the function's T_return tvar; cast the
                    // concrete then branch to match for the same reason.
                    (
                        cast_to_type_in_block(
                            codegen,
                            location,
                            then_info.block,
                            then_return,
                            return_ty,
                        )?,
                        else_return,
                    )
                } else {
                    // Both are type variables or the tvar is not T_return; let
                    // unify_scf_branch_types handle unification correctly.
                    (then_return, else_return)
                }
            } else {
                (then_return, else_return)
            };
            then_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), then_return);
            else_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), else_return);
        } else {
            // Return in `then` block but not `else` block.
            handle_unbalanced_return(
                codegen,
                function,
                location,
                then_return,
                then_info.block,
                &mut then_info.var_overwrites,
                else_info.block,
                &mut else_info.var_overwrites,
            )?;
        }
    } else if let Some(else_return) = else_return_opt {
        // Return in `else` block but not `then` block.
        handle_unbalanced_return(
            codegen,
            function,
            location,
            else_return,
            else_info.block,
            &mut else_info.var_overwrites,
            then_info.block,
            &mut then_info.var_overwrites,
        )?;
    }

    function.gen_scf_if_with_var_overwrites(codegen, location, condition, then_info, else_info)?;

    // Finally, if both blocks ended with a return, then add a new return/yield here. Else,
    // if only one block returned, gen additional code to handle the unbalanced return.
    if then_return_opt.is_some() && else_return_opt.is_some() {
        let ret_val = function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL)?;
        function.append_circom_return(codegen, location, *ret_val)?;
        // Since we added a return/yield here, the rest of current block is unreachable.
        return Ok(true);
    } else if then_return_opt.is_some() || else_return_opt.is_some() {
        gen_unbalanced_return_extra(codegen, function, location)?;
    }
    Ok(false)
}

/// Generate LLZK code for a circom [Statement::While].
fn gen_while<'ctx, 'func, 'blk, 'val, 'info>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'info, 'ctx>,
    meta: &Meta,
    cond: &Expression,
    body_stmt: &Statement,
    loop_bounds: Option<LoopBoundsAttribute<'ctx>>,
) -> Result<SkipRestOfBlock>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    // Generate the loop condition (i.e. "before") and body (i.e. "after") blocks naively.
    let mut loop_cond_info = NestedBlockInfo::default();
    let cond_result = function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        codegen.context,
        loop_cond_info.block,
        |fc| cond.gen_llzk_in_block(codegen, fc, info),
        &mut loop_cond_info,
    )?;
    let mut loop_body_info = NestedBlockInfo::default();
    function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        codegen.context,
        loop_body_info.block,
        |fc| body_stmt.gen_llzk_in_function(codegen, fc, info),
        &mut loop_body_info,
    )?;

    let location = codegen.location_from_meta(meta);

    // Check if loop body block ends with a return in circom. The `scf.while` op used in LLZK cannot
    // have returns nested within other blocks like circom allows. Use of `append_circom_return()`
    // already ensures `scf.yield` is used instead of `function.return` when not in the root block
    // but the `scf.while` additionally requires that both blocks yield the same number and type
    // of values. Additionally, if the loop body block returns (in the circom code), an additional
    // return state must be added to the values to be yielded and an additional `scf.if` must be
    // added after the `scf.while` to check the return state flag.
    if let Some(early_return) = get_val_of_circom_return_and_erase(loop_body_info.block) {
        // Within the loop body, set `VAR_NAME_HAD_RETURN` to `true` since a return occurs.
        loop_body_info.var_overwrites.insert(
            VAR_NAME_HAD_RETURN.to_string(),
            single_result_as_value(
                loop_body_info.block.append_operation(codegen.new_bool_const_op(true, location)),
            )?,
        );
        // In the current block, initialize the `VAR_NAME_HAD_RETURN` flag to `false` to capture the
        // scenario where the loop body does not execute and thus the return within does not occur.
        function.append_op_named_result(
            codegen.new_bool_const_op(false, location),
            VAR_NAME_HAD_RETURN.to_string(),
        )?;

        // Add the return value to the overwrite map of the loop body.
        loop_body_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), early_return);
        // In the current block, ensure the return value variable is initialized, default to nondet.
        if function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL).is_err() {
            let builder = function.builder_at_current_insertion_point(codegen.context);
            let value = function.append_op_ref_unnamed_result(codegen.new_nondet_at_location(
                &builder,
                location,
                early_return.r#type(),
            ))?;
            function.block_ctx.set_named_value(VAR_NAME_RETURN_VAL.to_string(), value)?;
        }
    }

    // Generate the loop op.
    let had_return = function.gen_scf_while(
        codegen,
        location,
        cond_result,
        loop_cond_info,
        loop_body_info,
        loop_bounds,
    )?;

    // Finally, if the loop body contained a return statement, gen additional code to handle it.
    if had_return {
        gen_unbalanced_return_extra(codegen, function, location)?;
    }
    Ok(false)
}

/// Generate LLZK code for a circom [Statement::InitializationBlock].
/// This is needed to support the `try_for_loop_heuristic` macro.
#[inline]
fn gen_init_block<'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'_, 'ctx>,
    initializations: &[Statement],
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    initializations.gen_llzk_in_function(codegen, function, info)
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for Statement
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    type Output = SkipRestOfBlock;

    fn gen_llzk_in_function<'info>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info, 'ctx>,
    ) -> Result<Self::Output> {
        let _guard = codegen.trace_statement(self);
        match self {
            Statement::InitializationBlock { xtype, initializations, .. } => {
                if let VariableType::Signal(..) = xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                gen_init_block(codegen, function, info, initializations)?;
                Ok(false)
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                if VariableType::Var != *xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                function.gen_declaration(codegen, meta, name, dimensions)?;
                Ok(false)
            }
            Statement::Block { meta, stmts } => {
                function.gen_in_current_block_with_new_circom_scope_and_merge_overwrites(
                    codegen.context,
                    |function| {
                        try_for_loop_heuristic!(codegen, function, meta, stmts, info);
                        // Fallback to standard block handling.
                        stmts.gen_llzk_in_function(codegen, function, info)?;
                        Ok(false)
                    },
                )?;
                Ok(false)
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                function.handle_substitution_stmt_nonsignal(
                    codegen, info, meta, var, access, op, rhe,
                )?;
                Ok(false)
            }
            Statement::UnderscoreSubstitution { op, rhe, .. } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                // Just visit and drop the resulting Value since it's unused.
                rhe.gen_llzk_in_block(codegen, function, info).map(drop)?;
                Ok(false)
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                gen_if_then_else(codegen, function, info, meta, cond, if_case, else_case)
            }
            Statement::While { meta, cond, stmt } => {
                gen_while(codegen, function, info, meta, cond, stmt, None)
            }
            Statement::Return { meta, value } => {
                let value = value.gen_llzk_in_block(codegen, function, info)?;
                let location = codegen.location_from_meta(meta);
                function.append_circom_return(codegen, location, value)?;
                // circom allows unreachable code after a return but it is not processed
                // (e.g. `assert(1 == 0)` after a return does not cause an error as it normally
                // would) so replicate the same behavior here by stopping processing after a
                // return (which is also what MLIR expects, no code after a terminator op).
                Ok(true)
            }
            Statement::Assert { meta, arg } => {
                let cond = arg.gen_llzk_in_block(codegen, function, info)?;
                function.append_assert(codegen, codegen.location_from_meta(meta), cond)?;
                Ok(false)
            }
            Statement::LogCall { meta, .. } => {
                codegen.emit_circom_warning(
                    meta,
                    "log calls are not currently supported in LLZK",
                    ReportCode::NotAllowedOperation,
                );
                Ok(false)
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
            }
            Statement::ConstraintEquality { .. } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Function uses template operators");
            }
        }
    }
}

/// A concrete numeric array literal recovered from the temporary declarations and writes emitted
/// by the concrete-program sugar cleaner.
///
/// The cleaner does not always preserve an `ArrayInLine` expression: it can create a local array
/// and write each element. Retaining the declaration for the recovered outer array preserves
/// normal scope handling; all initializer operations are omitted in favor of a `global.read`.
#[derive(Clone)]
pub(crate) struct ConcreteArrayLiteral<'a> {
    /// Source location of the declaration retained by lowering.
    pub(crate) meta: &'a Meta,
    /// Name of the array declaration replaced by a `global.read`.
    pub(crate) name: &'a str,
    /// Fully concrete array shape, in outermost-to-innermost order.
    pub(crate) dimensions: Vec<usize>,
    /// Flattened row-major field values for the global initializer.
    pub(crate) values: Vec<BigInt>,
    /// Offset of the declaration to retain within the matched statement sequence.
    pub(crate) declaration_offset: usize,
    /// Number of statements covered by the recovered initializer sequence.
    pub(crate) consumed: usize,
}

/// Extract the concrete dimensions of a declaration, including synthetic declarations emitted by
/// the concrete-program sugar cleaner.
fn concrete_array_dimensions(meta: &Meta, dimensions: &[Expression]) -> Option<Vec<usize>> {
    if dimensions.is_empty() {
        let memory_knowledge = meta.get_memory_knowledge();
        if !memory_knowledge.has_concrete_dimensions() {
            return None;
        }
        return Some(memory_knowledge.get_concrete_dimensions().to_vec());
    }

    dimensions
        .iter()
        .map(|dimension| match dimension {
            Expression::Number(_, value) => value.to_usize(),
            _ => None,
        })
        .collect()
}

/// Extract a one-dimensional array literal whose elements are all numeric constants.
///
/// Synthetic declarations created by the cleaner sometimes store their dimension only in
/// initialized `MemoryKnowledge`, so use that as a fallback when the AST `dimensions` list is
/// empty. A dimension-less ordinary AST declaration is not an array literal and is ignored.
fn direct_concrete_array_literal_initializer(
    statements: &[Statement],
) -> Option<ConcreteArrayLiteral<'_>> {
    let Statement::Declaration { meta, name, dimensions, .. } = statements.first()? else {
        return None;
    };
    let dimensions = concrete_array_dimensions(meta, dimensions)?;
    if dimensions.len() != 1 {
        return None;
    }
    let element_count = dimensions[0];
    if element_count == 0 {
        return None;
    }

    // A declaration may be followed by more than one complete constant initialization pass.
    // This is how the concrete cleaner represents an array's default zero initialization before
    // its literal initializer. No intervening statement can observe the intermediate values, so
    // retain only the final complete pass.
    let mut consumed = 1;
    let mut values = None;
    while statements.len() >= consumed + element_count {
        let pass_values = statements[consumed..consumed + element_count]
            .iter()
            .enumerate()
            .map(|(flat_index, statement)| {
                let Statement::Substitution { var, access, op, rhe, .. } = statement else {
                    return None;
                };
                if var != name || *op != AssignOp::AssignVar || access.len() != dimensions.len() {
                    return None;
                }

                let mut expected_index = flat_index;
                for (access, dimension) in access.iter().rev().zip(dimensions.iter().rev()) {
                    let Access::ArrayAccess(Expression::Number(_, value)) = access else {
                        return None;
                    };
                    if value.to_usize()? != expected_index % dimension {
                        return None;
                    }
                    expected_index /= dimension;
                }
                if expected_index != 0 {
                    return None;
                }

                let Expression::Number(_, value) = rhe else {
                    return None;
                };
                Some(value.clone())
            })
            .collect::<Option<Vec<_>>>();

        let Some(pass_values) = pass_values else {
            break;
        };
        values = Some(pass_values);
        consumed += element_count;
    }
    let values = values?;
    Some(ConcreteArrayLiteral { meta, name, dimensions, values, declaration_offset: 0, consumed })
}

/// Recovers one complete initialization pass following an already-declared parent array.
///
/// The concrete-program sugar cleaner may create leaves and intermediate arrays in a different
/// order from their nesting: sibling children can be declared before either enclosing temporary
/// is assembled. This scans the contiguous initializer sequence, retaining a pool of resolved
/// constant arrays. A declaration is added to that pool once its following inserts select only
/// values already in the pool. The pass ends at ordered inserts into `parent_name`.
///
/// Returns the parent's flattened row-major values and the number of consumed statements. It
/// rejects partial, dynamic, non-rectangular, and out-of-order initialization, leaving normal
/// lowering responsible for those cases.
fn constant_child_initialization_pass(
    statements: &[Statement],
    parent_name: &str,
    outer_dimension: usize,
    child_dimensions: &[usize],
) -> Option<(Vec<BigInt>, usize)> {
    let mut children = Vec::new();
    let mut consumed = 0;
    loop {
        if let Some(values) = constant_values_from_inserts(
            &statements[consumed..],
            parent_name,
            outer_dimension,
            child_dimensions,
            &children,
            false,
        ) {
            return Some((values, consumed + outer_dimension));
        }

        if let Some(child) = direct_concrete_array_literal_initializer(&statements[consumed..])
            .or_else(|| parent_first_concrete_array_literal_initializer(&statements[consumed..]))
        {
            consumed += child.consumed;
            children.push(child);
            continue;
        }
        if let Some(child) =
            child_first_concrete_array_literal_initializer(statements, &children, consumed, false)
        {
            consumed = child.consumed;
            children.push(child);
            continue;
        }

        return None;
    }
}

/// Recovers a multi-dimensional literal whose outer declaration comes before its temporary
/// children, which is the normal layout produced for a source-level array declaration.
///
/// A declaration can have consecutive complete initialization passes: a default-zero pass and a
/// later literal pass, for example. Because this matcher admits no intervening observation of
/// the parent, it keeps the values from the final pass and consumes all of them.
fn parent_first_concrete_array_literal_initializer(
    statements: &[Statement],
) -> Option<ConcreteArrayLiteral<'_>> {
    let Statement::Declaration { meta, name, dimensions, .. } = statements.first()? else {
        return None;
    };
    let dimensions = concrete_array_dimensions(meta, dimensions)?;
    let (&outer_dimension, child_dimensions) = dimensions.split_first()?;
    if child_dimensions.is_empty() || outer_dimension == 0 {
        return None;
    }

    // A default zero initialization may be immediately followed by a full literal assignment.
    // Since no statement observes the intermediate state, retain only the last complete pass.
    let mut consumed = 1;
    let mut values = None;
    while let Some((pass_values, pass_consumed)) = constant_child_initialization_pass(
        &statements[consumed..],
        name,
        outer_dimension,
        child_dimensions,
    ) {
        values = Some(pass_values);
        consumed += pass_consumed;
    }
    let values = values?;

    Some(ConcreteArrayLiteral { meta, name, dimensions, values, declaration_offset: 0, consumed })
}

/// Validates an ordered prefix of `array[index] = child` substitutions and flattens their values.
///
/// Every outer index must be assigned exactly once in ascending order, and each RHS must name a
/// resolved child of `child_dimensions`. `require_all_children` is used for the child-first form
/// to ensure the matcher cannot discard an unrelated temporary; the parent-first scanner keeps a
/// broader pool of nested and sibling arrays, so it permits unused entries there.
fn constant_values_from_inserts(
    statements: &[Statement],
    parent_name: &str,
    outer_dimension: usize,
    child_dimensions: &[usize],
    children: &[ConcreteArrayLiteral<'_>],
    require_all_children: bool,
) -> Option<Vec<BigInt>> {
    if children.is_empty() || statements.len() < outer_dimension {
        return None;
    }

    let mut values = Vec::with_capacity(outer_dimension.checked_mul(children[0].values.len())?);
    let mut used_children = vec![false; children.len()];
    for (index, statement) in statements[..outer_dimension].iter().enumerate() {
        let Statement::Substitution { var, access, op, rhe, .. } = statement else {
            return None;
        };
        if var != parent_name || *op != AssignOp::AssignVar {
            return None;
        }
        let [Access::ArrayAccess(Expression::Number(_, array_index))] = access.as_slice() else {
            return None;
        };
        let Expression::Variable { name: value_name, access, .. } = rhe else {
            return None;
        };
        if array_index.to_usize()? != index || !access.is_empty() {
            return None;
        }
        let child_index = children
            .iter()
            .position(|child| child.name == value_name && child.dimensions == child_dimensions)?;
        used_children[child_index] = true;
        values.extend_from_slice(&children[child_index].values);
    }
    if require_all_children && used_children.iter().any(|used| !used) {
        return None;
    }

    Some(values)
}

/// Recovers a multi-dimensional literal whose constant children occur before its declaration.
///
/// `declaration_offset` identifies the candidate parent declaration in `statements`; `children`
/// contains resolved literals preceding it. With `require_all_children`, every supplied child
/// must be referenced by the parent's inserts. The parent-first scanner disables that requirement
/// because its pool can also hold children for later sibling declarations.
fn child_first_concrete_array_literal_initializer<'a>(
    statements: &'a [Statement],
    children: &[ConcreteArrayLiteral<'a>],
    declaration_offset: usize,
    require_all_children: bool,
) -> Option<ConcreteArrayLiteral<'a>> {
    let Some(Statement::Declaration { meta, name, dimensions, .. }) =
        statements.get(declaration_offset)
    else {
        return None;
    };
    let dimensions = concrete_array_dimensions(meta, dimensions)?;
    let (&outer_dimension, child_dimensions) = dimensions.split_first()?;
    if children.is_empty() || (require_all_children && children.len() > outer_dimension) {
        return None;
    }

    let values = constant_values_from_inserts(
        &statements[declaration_offset + 1..],
        name,
        outer_dimension,
        child_dimensions,
        children,
        require_all_children,
    )?;

    Some(ConcreteArrayLiteral {
        meta,
        name,
        dimensions,
        values,
        declaration_offset,
        consumed: declaration_offset + outer_dimension + 1,
    })
}

/// Recovers a fully initialized, concrete numeric array in either cleaner layout.
///
/// It first handles the common parent-first layout, including arbitrary nesting through
/// [`constant_child_initialization_pass`]. It then recognizes child-first chains, promoting each
/// resolved parent so nested arrays can be reconstructed from the leaves upward. Only complete
/// constant initializers are returned; any unrecognized statement sequence falls back to normal
/// code generation.
pub(crate) fn concrete_array_literal_initializer(
    statements: &[Statement],
) -> Option<ConcreteArrayLiteral<'_>> {
    if let Some(literal) = parent_first_concrete_array_literal_initializer(statements) {
        return Some(literal);
    }

    let mut children = Vec::new();
    let mut consumed = 0;
    let mut last_literal = None;
    loop {
        if let Some(literal) =
            child_first_concrete_array_literal_initializer(statements, &children, consumed, true)
        {
            consumed = literal.consumed;
            last_literal = Some(literal.clone());
            children.clear();
            children.push(literal);
            continue;
        }

        let Some(child) = direct_concrete_array_literal_initializer(&statements[consumed..])
            .or_else(|| parent_first_concrete_array_literal_initializer(&statements[consumed..]))
        else {
            break;
        };
        consumed += child.consumed;
        children.push(child);
    }

    last_literal.or_else(|| direct_concrete_array_literal_initializer(statements))
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for [Statement]
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
    'val: 'blk,
{
    type Output = ();

    fn gen_llzk_in_function<'info>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info, 'ctx>,
    ) -> Result<Self::Output> {
        let mut index = 0;
        while index < self.len() {
            if let Some(literal) = concrete_array_literal_initializer(&self[index..]) {
                // Keep the outer declaration for scope bookkeeping, then replace its
                // uninitialized value with a read of the deduplicated global literal. For a
                // recovered multi-dimensional literal, `declaration_offset` skips any child
                // temporaries and selects the parent declaration.
                self[index + literal.declaration_offset]
                    .gen_llzk_in_function(codegen, function, info)?;
                let location = codegen.location_from_meta(literal.meta);
                let (global_name, array_type) = codegen.get_or_create_array_literal_const_global(
                    location,
                    &literal.dimensions,
                    &literal.values,
                )?;
                let builder = function.builder_at_current_insertion_point(codegen.context);
                let value = function.append_op_ref_unnamed_result(global::read(
                    &builder,
                    location,
                    codegen.global_symbol_ref(&global_name),
                    true,
                    array_type,
                ))?;
                function.block_ctx.set_named_value(literal.name.to_owned(), value)?;
                index += literal.consumed;
                continue;
            }

            let s = &self[index];
            let skip_rest_of_block = s.gen_llzk_in_function(codegen, function, info)?;
            if skip_rest_of_block {
                break;
            }
            index += 1;
        }
        Ok(())
    }
}
