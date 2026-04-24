//! Handles function-level LLZK code generation for both free functions and functions within
//! structs. The [FunctionContext] carries information about the current LLZK function
//! being generated and some helpers related to generating code within the function. The
//! [GenerateLLZKInFunction] trait provides the visitor to generate LLZK IR for all circom
//! [Expression](program_structure::ast::Expression) and
//! [Statement](program_structure::ast::Statement) nodes.

use crate::gen_context::BlockContextStack;
use crate::gen_context::BlockGenContext;
use crate::gen_context::GenWithCircomScopeHandling;
use crate::gen_context::GenerateLLZKInAnyBlock;
use crate::gen_context::NestedBlockInfo;
use crate::gen_context::CIRCOM_RETURN_MARKER_ATTR;
use crate::gen_context::OPERAND_VAL_NAMES;
use crate::gen_context::VAR_NAME_HAD_RETURN;
use crate::gen_context::VAR_NAME_RETURN_VAL;
use crate::program_ext::ProgramLike;
use crate::shared::next_in_block_mut;
use crate::shared::no_results;
use crate::shared::parent_operation_mut;
use crate::shared::region_with_block;
use crate::shared::remove_from_parent;
use crate::shared::single_result_as_value;
use crate::shared::LlzkCodegen;
use crate::subcmp::NoSubcmps;
use crate::subcmp::SubcmpInfo;
use crate::template::TemplateContext;
use crate::try_for_loop_heuristic;
use crate::write_chain::NoSignalsInfo;
use crate::write_chain::SignalWriteInfo;
use anyhow::Context as _;
use anyhow::Result;
use llzk::dialect;
use llzk::dialect::bool;
use llzk::dialect::function;
use llzk::operation::erase_op;
use llzk::operation::WalkOperationMutLike as _;
use llzk::prelude::melior_dialects::arith;
use llzk::prelude::melior_dialects::scf;
use llzk::prelude::melior_dialects::scf::is_scf_if;
use llzk::prelude::melior_dialects::scf::is_scf_yield;
use llzk::prelude::Attribute;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::BlockRef;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::Location;
use llzk::prelude::LoopBoundsAttribute;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::OperationMutLike;
use llzk::prelude::OperationRefMut;
use llzk::prelude::Region;
use llzk::prelude::RegionLike as _;
use llzk::prelude::Type;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use llzk::prelude::WalkOrder;
use llzk::prelude::WalkResult;
use llzk::value_ext::has_uses;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use program_structure::error_code::ReportCode;
use std::collections::HashMap;
use std::ops::Deref;
use std::ops::DerefMut;

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
pub struct InfoProviders<'info> {
    /// Subcomponent information.
    pub subcmp_info: &'info dyn SubcmpInfo,
    /// Signals write information.
    ///
    /// TODO: We may be able to remove this field if the lowering in this file does not need to use
    /// `WriteChain`. Since that type aims to be generic it may be reusable in the context of
    /// lowering freestanding functions, in which case it needs an empty implementation of this
    /// interface. This field is already here in preparation for reusing WriteChain.
    pub signal_write_info: &'info dyn SignalWriteInfo,
}

impl Default for InfoProviders<'_> {
    fn default() -> Self {
        Self { subcmp_info: &NoSubcmps, signal_write_info: &NoSignalsInfo }
    }
}

impl<'tmpl, 'ctx, 'str, 'func, 'blk, 'val>
    From<&'tmpl TemplateContext<'_, 'ctx, 'str, 'func, 'blk, 'val>> for InfoProviders<'tmpl>
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
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        func: FuncDefOpRefMut<'ctx, 'func>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
        var_decl_types: &'decls HashMap<String, Type<'ctx>>,
        poly_template_binding_names: impl IntoIterator<Item = (String, Option<Type<'ctx>>)>,
    ) -> Result<Self> {
        let mut block_ctx = BlockContextStack::from_function(func.deref(), param_name_to_value)?;
        if FREE_FUNC {
            // Ensure the specially-named values are declared in free functions.
            block_ctx.declare_name_if_not_present(VAR_NAME_RETURN_VAL, || {
                // Get the result type from the free function. It supports exactly 1.
                let ty = func.get_function_type_attribute()?;
                assert_eq!(ty.result_count(), 1);
                codegen.new_nondet_at_location(codegen.location_unknown(), ty.result(0)?)
            })?;
            block_ctx.declare_name_if_not_present(VAR_NAME_HAD_RETURN, || {
                codegen
                    .new_nondet_at_location(codegen.location_unknown(), codegen.bool_type().into())
            })?;
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
            .get_function_type_attribute()
            .expect("`function_type` attr must exist")
            .result(0)
            .expect("LLZK function must return a single result")
    }

    /// Generate and append an op to carry the value from a circom return statement. It will
    /// generate a return op if the context stack height is 1, otherwise a yield op. In either
    /// case, it is marked with the [CIRCOM_RETURN_MARKER_ATTR] attribute.
    pub fn append_circom_return(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        value: Value<'ctx, 'val>,
    ) -> Result<()> {
        let mut op = if self.block_ctx.is_only_root() {
            let value = self.cast_to_return_type_if_needed(codegen, location, value)?;
            function::r#return(location, &[value])
        } else {
            scf::r#yield(&[value], location)
        };
        op.set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
        self.append_op_no_result(op)
    }

    /// Create an op to cast `val` to match the return type of the function.
    #[inline]
    pub fn cast_to_return_type_if_needed(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
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
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
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
        let then_region = region_with_block(&[]);
        self.block_ctx.push(then_region.first_block().unwrap());
        body(self)?;
        self.append_op_no_result(scf::r#yield(&[], location))?;
        self.block_ctx.pop();
        let else_region = region_with_block(&[]);
        else_region.first_block().unwrap().append_operation(scf::r#yield(&[], location));

        self.append_op_no_result(scf::r#if(cmp, &[], then_region, else_region, location))
    }

    /// Finalizes the context.
    pub fn finalize(&mut self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Result<()> {
        self.func.walk_mut(WalkOrder::PreOrder, |mut op| {
            // Remove any `llzk.nondet` ops from the function whose result value is unused. These
            // were added, for example, when visiting [Statement::Declaration] but their uses were
            // later replaced with actual values when visiting [Statement::Substitution], etc.
            if dialect::llzk::is_nondet(&op) && !has_uses(single_result_as_value(op).unwrap()) {
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
                if function::is_func_return(&op) {
                    if let Some(parent) = parent_operation_mut(&op) {
                        if is_scf_if(&parent) {
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
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        ret_op: OperationRefMut<'ctx, '_>,
        mut parent_if_op: OperationRefMut<'ctx, '_>,
    ) -> Result<()> {
        assert!(function::is_func_return(&ret_op)); // precondition
        assert!(is_scf_if(&parent_if_op)); // precondition

        // Move all ops after the `scf.if` into a new block for "else" branch of new `scf.if`.
        let new_else_block = Block::new(&[]);
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
            if is_scf_yield(&tail) {
                let result_types = tail.operands().map(|v| v.r#type()).collect();
                let names = tail
                    .attribute(OPERAND_VAL_NAMES)
                    .expect("multi-value yield op must have names");
                new_else_result_info = RefactoringBlockResultType::Multiple(result_types, names);
                no_results(new_else_block.append_operation(tail))?;
            } else if function::is_func_return(&tail) {
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
        let new_then_block = Block::new(&[]);
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
                            yield_values.push(single_result_as_value(
                                new_then_block.append_operation(
                                    codegen.new_nondet_at_location(location, result_types[i])?,
                                ),
                            )?);
                        }
                    }
                }
            }
            let new_yield = new_else_result_info.gen_yield(&yield_values, ret_op.location());
            no_results(new_then_block.append_operation(new_yield))?;
        }

        // Create new `scf.if` op using the new "then" and "else" blocks. Replace `parent_if_op`
        // with this new `scf.if` and then append a return/yield with the new `scf.if` results.
        let blk = parent_if_op.block().context("expected parent block for original `if`")?;
        let else_region = Region::new();
        else_region.append_block(new_else_block);
        let then_region = Region::new();
        then_region.append_block(new_then_block);
        let new_if_ref = blk.append_operation(scf::r#if(
            parent_if_op.operand(0)?,
            new_else_result_info.result_types(),
            then_region,
            else_region,
            parent_if_op.location(),
        ));

        // Add return if the destination block is the function def body, else yield.
        let result_values: Vec<_> = new_if_ref.results().map(Value::from).collect();
        let op = if blk.parent_operation().is_some_and(|r| function::is_func_def(&r)) {
            function::r#return(parent_if_op.location(), &result_values)
        } else {
            new_else_result_info.gen_yield(&result_values, parent_if_op.location())
        };
        no_results(blk.append_operation(op))?;

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
        let popped = self.block_ctx.pop();
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
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Self::Output>;
}

/// Output type of [GenerateLLZKInFunction] implemented for [Statement] indicating whether the
/// current statement causes abrupt termination of the current block (in other words, whether
/// the remaining statements in the same block should be skipped).
type SkipRestOfBlock = bool;

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
            assert!(is_scf_yield(&term));
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
#[allow(clippy::too_many_arguments)]
fn handle_unbalanced_return<'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
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
            single_result_as_value(
                nonreturning_block.append_operation(
                    codegen.new_nondet_at_location(location, return_val.r#type())?,
                ),
            )
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
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    let then_region = Region::new();
    let then_block = then_region.append_block(Block::new(&[]));
    function.gen_in_given_block_with_new_circom_scope_and_merge_overwrites(then_block, |fc| {
        let ret_val = fc.block_ctx.get_named_value(VAR_NAME_RETURN_VAL)?;
        let value = fc.cast_to_return_type_if_needed(codegen, location, *ret_val)?;
        let mut op = function::r#return(location, &[value]);
        op.set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
        fc.append_op_no_result(op)
    })?;

    let condition = *function.block_ctx.get_named_value(VAR_NAME_HAD_RETURN)?;
    function.append_op_no_result(scf::r#if(condition, &[], then_region, Region::new(), location))
}

/// Generate LLZK code for a circom [Statement::IfThenElse].
fn gen_if_then_else<'ctx, 'func, 'blk, 'val, 'info>(
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'info>,
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
        then_info.block,
        |function| if_case.gen_llzk_in_function(codegen, function, info),
        &mut then_info,
    )?;
    let mut else_info = NestedBlockInfo::default();
    if let Some(else_case) = else_case {
        function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
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
            // Both return, just add the return value to both overwrite maps.
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

    function.gen_scf_if(codegen, location, condition, then_info, else_info)?;

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
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'info>,
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
        loop_cond_info.block,
        |fc| cond.gen_llzk_in_block(codegen, fc, info),
        &mut loop_cond_info,
    )?;
    let mut loop_body_info = NestedBlockInfo::default();
    function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
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
            function.append_op_named_result(
                codegen.new_nondet_at_location(location, early_return.r#type())?,
                VAR_NAME_RETURN_VAL.to_string(),
            )?;
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
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'_>,
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
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info>,
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
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        function: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Self::Output> {
        for s in self {
            let skip_rest_of_block = s.gen_llzk_in_function(codegen, function, info)?;
            if skip_rest_of_block {
                break;
            }
        }
        Ok(())
    }
}
