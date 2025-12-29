//! Handles function-level LLZK code generation for both free functions and functions within
//! structs. The [function::FunctionContext] carries information about the current LLZK function
//! being generated and some helpers related to generating code within the function. The
//! [function::GenerateLLZKInFunction] trait provides the visitor to generate LLZK IR for all circom
//! [Expression](program_structure::abstract_syntax_tree::ast::Expression) and
//! [Statement](program_structure::abstract_syntax_tree::ast::Statement) nodes.

#![allow(unused_variables)] // TODO: TEMP
use crate::gen_context::BlockContextStack;
use crate::gen_context::GenWithCircomScopeHandling;
use crate::gen_context::NestedBlockInfo;
use crate::shared::erase_op;
use crate::shared::get_function_type_attribute;
use crate::shared::is_scf_yield;
use crate::shared::new_felt_const_op;
use crate::shared::no_results;
use crate::shared::single_result_as_value;
use crate::shared::LlzkCodegen;
use crate::shared::{self};
use anyhow::anyhow;
use anyhow::Result;
use llzk::builder::OpBuilder;
use llzk::prelude::bool;
use llzk::prelude::felt;
use llzk::prelude::function;
use llzk::prelude::Attribute;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::BlockRef;
use llzk::prelude::FeltType;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::IntegerType;
use llzk::prelude::Location;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::OperationMutLike;
use llzk::prelude::OperationRef;
use llzk::prelude::Region;
use llzk::prelude::RegionLike as _;
use llzk::prelude::Type;
use llzk::prelude::Value;
use melior::dialect::arith;
use melior::dialect::index;
use melior::dialect::ods::math;
use melior::dialect::scf;
use melior::ir::operation::OperationRefMut;
use melior::ir::operation::WalkOrder;
use melior::ir::operation::WalkResult;
use melior::ir::ValueLike;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use program_structure::ast::Meta;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use program_structure::error_code::ReportCode;
use std::collections::HashMap;
use std::ops::Deref;
use std::ops::DerefMut;

/// Special variable name used to reference the return Value throughout the
/// conversion of circom return locations to LLZK return locations.
const VAR_NAME_RETURN_VAL: &str = "**return_val**";
/// Special variable name used to reference the status of whether or not a circom block
/// had a `return` when translating to an LLZK block that cannot contain a `return`.
const VAR_NAME_NO_RETURN: &str = "**no_return**";
/// LLZK attribute used to mark yield/return ops generated from circom return statements.
const CIRCOM_RETURN_MARKER_ATTR: &str = "from_circom_return";

/// Stores ref to the current function while generating LLZK IR for the function.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct FunctionContext<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// The function reference.
    pub(crate) func: FuncDefOpRefMut<'ctx, 'func>,
    /// Nested block context within the function.
    pub(crate) block_ctx: BlockContextStack<'ctx, 'blk, 'val>,
}

impl<'ctx, 'func, 'blk, 'val> FunctionContext<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Create a new [FunctionContext] for the given function with an initial name-to-value mapping.
    pub fn new<'ast, const FREE_FUNC: bool>(
        codegen: &LlzkCodegen<'ast, 'ctx>,
        func: FuncDefOpRefMut<'ctx, 'func>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Result<Self> {
        let mut block_ctx = BlockContextStack::new(func.deref(), param_name_to_value)?;
        if FREE_FUNC {
            // Ensure the specially-named values are declared in free functions.
            block_ctx.declare_name_if_not_present(VAR_NAME_RETURN_VAL, || {
                // Get the result type from the free function. It supports exactly 1.
                let ty = get_function_type_attribute(func)?;
                assert_eq!(ty.result_count(), 1);
                codegen.new_nondet_at_location(Location::unknown(codegen.context), ty.result(0)?)
            })?;
            block_ctx.declare_name_if_not_present(VAR_NAME_NO_RETURN, || {
                codegen.new_nondet_at_location(
                    Location::unknown(codegen.context),
                    IntegerType::new(codegen.context, 1).into(),
                )
            })?;
        }
        Ok(Self { func, block_ctx })
    }

    /// Append an operation.
    pub fn append_op(&mut self, op: Operation<'ctx>) -> OperationRef<'ctx, 'val> {
        self.block_ctx.append_current_block(op)
    }

    /// Append an operation that must produce no results.
    pub fn append_op_no_result(&mut self, op: Operation<'ctx>) -> Result<()> {
        no_results(self.append_op(op))
    }

    /// Append an operation that must produce a single result and is NOT associated with a variable
    /// name in the circom code.
    pub fn append_op_unnamed_result(&mut self, op: Operation<'ctx>) -> Result<Value<'ctx, 'val>> {
        single_result_as_value(self.append_op(op))
    }

    /// Append an operation that must produce a single result and store the mapping of the circom
    /// variable name to the result Value.
    pub fn append_op_named_result(
        &mut self,
        op: Operation<'ctx>,
        name: String,
    ) -> Result<Value<'ctx, 'val>> {
        let v = self.append_op_unnamed_result(op)?;
        self.block_ctx.set_named_value(name, v)?;
        Ok(v)
    }

    /// Generate and append an op to carry the value from a circom return statement. It will
    /// generate a return op if the context stack height is 1, otherwise a yield op. In either
    /// case, it is marked with the [CIRCOM_RETURN_MARKER_ATTR] attribute.
    pub fn append_circom_return<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        location: Location<'ctx>,
        value: Value<'ctx, 'val>,
    ) -> Result<()> {
        let mut op = if self.block_ctx.is_only_root() {
            function::r#return(location, &[value])
        } else {
            scf::r#yield(&[value], location)
        };
        op.set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
        self.append_op_no_result(op)
    }

    /// Generate LLZK code in the current function for a circom prefix operation.
    pub fn gen_prefix_op<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        meta: &Meta,
        op: &ExpressionPrefixOpcode,
        rhs: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        match op {
            ExpressionPrefixOpcode::Sub => {
                if shared::is_felt(rhs.r#type()) {
                    return self.append_op_unnamed_result(felt::neg(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
                // For index negation, we need to subtract from zero.
                if shared::is_index(rhs.r#type()) {
                    let zero = self.append_op_unnamed_result(index::constant(
                        codegen.context,
                        IntegerAttribute::new(rhs.r#type(), 0),
                        codegen.location_from_meta(meta),
                    ))?;
                    return self.append_op_unnamed_result(index::sub(
                        zero,
                        rhs,
                        codegen.location_from_meta(meta),
                    ));
                }
            }
            ExpressionPrefixOpcode::BoolNot => {
                if shared::is_bool(rhs.r#type()) {
                    return self.append_op_unnamed_result(bool::not(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
            }
            ExpressionPrefixOpcode::Complement => {
                // This op is defined as:
                // Complement to the number of bits of the prime number.
                todo!("Handle complement prefix op")
            }
        }
        let err_msg = format!(
            "Cannot generate LLZK for prefix {:?} with operand type '{}'",
            self,
            rhs.r#type()
        );
        codegen.emit_circom_error(meta, err_msg.as_str(), ReportCode::PrefixOperatorWithWrongTypes);
        Err(anyhow!(err_msg))
    }

    /// If both operands have types that match the respective filter predicates, generate the
    /// operation using the provided generator function and return the result, otherwise None.
    #[inline]
    fn gen_infix_op_if_types_are(
        &mut self,
        lhs_type_filter: impl FnOnce(Type) -> bool,
        rhs_type_filter: impl FnOnce(Type) -> bool,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
        op_gen_fn: impl FnOnce() -> Result<Operation<'ctx>>,
    ) -> Result<Option<Value<'ctx, 'val>>> {
        if lhs_type_filter(lhs.r#type()) && rhs_type_filter(rhs.r#type()) {
            self.append_op_unnamed_result(op_gen_fn()?).map(Option::Some)
        } else {
            Ok(None)
        }
    }

    /// Generate LLZK code in the current function for an infix operation.
    pub fn gen_infix_op<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        meta: &Meta,
        op: &ExpressionInfixOpcode,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // Macro to handle the common pattern for type checks for op selection.
        macro_rules! try_callback_for_type {
            ($type_check:path, $cb:expr) => {{
                if let Some(result) =
                    self.gen_infix_op_if_types_are($type_check, $type_check, lhs, rhs, $cb)?
                {
                    return Ok(result);
                }
            }};
        }

        macro_rules! generic_op_callback {
            ($op_path:path) => {{
                || {
                    let loc = codegen.location_from_meta(meta);
                    $op_path(loc, lhs, rhs).map_err(Into::into)
                }
            }};
        }

        macro_rules! try_felt_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_felt, generic_op_callback!($op_path));
            }};
        }

        macro_rules! try_bool_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_bool, generic_op_callback!($op_path));
            }};
        }

        macro_rules! try_index_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_index, || {
                    let loc = codegen.location_from_meta(meta);
                    Ok($op_path(lhs, rhs, loc))
                });
            }};
        }

        macro_rules! try_math_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_index, || {
                    let loc = codegen.location_from_meta(meta);
                    Ok(Operation::from($op_path(codegen.context, lhs, rhs, loc)))
                });
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For index operations that use felt:: module and simple index operations.
        macro_rules! try_felt_or_index_op {
            ($felt_op:path, $index_op:path) => {{
                try_felt_op!($felt_op);
                try_index_op!($index_op);
            }};
        }

        macro_rules! try_felt_or_math_op {
            ($felt_op:path, $math_op:path) => {{
                try_felt_op!($felt_op);
                try_math_op!($math_op);
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For comparison operations that use bool:: module and index::cmpi.
        macro_rules! try_bool_cmp_op {
            ($bool_op:path, $cmp:ident) => {{
                try_felt_op!($bool_op);
                try_callback_for_type!(shared::is_index, || {
                    let loc = codegen.location_from_meta(meta);
                    Ok(index::cmp(codegen.context, arith::CmpiPredicate::$cmp, lhs, rhs, loc))
                });
            }};
        }

        match op {
            ExpressionInfixOpcode::Add => {
                try_felt_or_index_op!(felt::add, index::add);
            }
            ExpressionInfixOpcode::Sub => {
                try_felt_or_index_op!(felt::sub, index::sub);
            }
            ExpressionInfixOpcode::Mul => {
                try_felt_or_index_op!(felt::mul, index::mul);
            }
            ExpressionInfixOpcode::Div => {
                try_felt_or_index_op!(felt::div, index::divu);
            }
            ExpressionInfixOpcode::IntDiv => {
                todo!("Handle IntDiv infix op")
            }
            ExpressionInfixOpcode::Mod => {
                try_felt_or_index_op!(felt::r#mod, index::remu);
            }
            ExpressionInfixOpcode::Pow => {
                try_felt_or_math_op!(felt::pow, math::ipowi);
            }
            ExpressionInfixOpcode::ShiftL => {
                try_felt_or_index_op!(felt::shl, index::shl);
            }
            ExpressionInfixOpcode::ShiftR => {
                try_felt_or_index_op!(felt::shr, index::shru);
            }
            ExpressionInfixOpcode::LesserEq => {
                try_bool_cmp_op!(bool::le, Ule);
            }
            ExpressionInfixOpcode::GreaterEq => {
                try_bool_cmp_op!(bool::ge, Uge);
            }
            ExpressionInfixOpcode::Lesser => {
                try_bool_cmp_op!(bool::lt, Ult);
            }
            ExpressionInfixOpcode::Greater => {
                try_bool_cmp_op!(bool::gt, Ugt);
            }
            ExpressionInfixOpcode::Eq => {
                try_bool_cmp_op!(bool::eq, Eq);
            }
            ExpressionInfixOpcode::NotEq => {
                try_bool_cmp_op!(bool::ne, Ne);
            }
            ExpressionInfixOpcode::BoolOr => {
                try_bool_op!(bool::or);
            }
            ExpressionInfixOpcode::BoolAnd => {
                try_bool_op!(bool::and);
            }
            ExpressionInfixOpcode::BitOr => {
                try_felt_or_index_op!(felt::bit_or, index::or);
            }
            ExpressionInfixOpcode::BitAnd => {
                try_felt_or_index_op!(felt::bit_and, index::and);
            }
            ExpressionInfixOpcode::BitXor => {
                try_felt_or_index_op!(felt::bit_xor, index::xor);
            }
        }
        let err_msg = format!(
            "Cannot generate LLZK for infix {:?} with LHS type '{}' and RHS type '{}'",
            self,
            lhs.r#type(),
            rhs.r#type()
        );
        codegen.emit_circom_error(meta, err_msg.as_str(), ReportCode::InfixOperatorWithWrongTypes);
        Err(anyhow!(err_msg))
    }
}

/// The [FunctionContext] directly accesses a single [BlockContextStack] for circom scope handling.
impl<'ctx, 'func, 'blk, 'val> GenWithCircomScopeHandling<'ctx, 'func, 'blk, 'val>
    for FunctionContext<'ctx, 'func, 'blk, 'val>
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
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &mut NestedBlockInfo<'ctx, 'blk, 'val>,
            HashMap<String, Value<'ctx, 'val>>,
        ) -> Result<()>,
    {
        let popped = self.block_ctx.pop();
        overwrite_handler(self, overwrite_data, popped)
    }
}

/// Implement [Drop] on [FunctionContext] to:
///
/// 1. Remove any `undef.undef` ops from the function whose result value is unused. These were
///    added, for example, when visiting [Statement::Declaration] but their uses were later replaced
///    with actual values when visiting [Statement::Substitution] (and others).
/// 2. Remove any uses of the [CIRCOM_RETURN_MARKER_ATTR] attribute because it is a temporary marker
///    used to properly adjust the location of return statements to match LLZK requirements.
impl Drop for FunctionContext<'_, '_, '_, '_> {
    fn drop(&mut self) {
        fn undef_has_uses(op: OperationRef) -> bool {
            shared::has_uses(single_result_as_value(op).unwrap())
        }
        self.func.walk(WalkOrder::PreOrder, |op| {
            let mut op_ref_mut = unsafe { OperationRefMut::from_raw(op.to_raw()) };
            if llzk::dialect::undef::is_undef_op(op) && !undef_has_uses(op) {
                OperationMutLike::remove_from_parent(op_ref_mut.deref_mut());
                WalkResult::Skip
            } else {
                // Result ignored because we don't care if the attribute was there or not.
                let _ = op_ref_mut.remove_attribute(CIRCOM_RETURN_MARKER_ATTR);
                WalkResult::Advance
            }
        });
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
    /// Output type of the generator function. [Statement] nodes do not produce a value so this
    /// should be the unit type whereas [Expression] nodes produce a Value.
    type Output;

    /// Generates LLZK IR from [Statement] and [Expression] nodes in a circom function.
    ///
    /// 'ast: lifetime of the circom AST element
    fn gen_llzk_in_function<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    ) -> Result<Self::Output>;
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for [Statement]
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output = ();

    fn gen_llzk_in_function<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    ) -> Result<Self::Output> {
        for s in self {
            s.gen_llzk_in_function(codegen, function)?;
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
            // ASSERT: This must be a `yield` not a `return` since it's generated within
            // the `else` or `then` block of an `if` statement.
            assert!(is_scf_yield(term));
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
fn handle_early_return<'ast, 'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'ast, 'ctx>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
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
    // Set `VAR_NAME_NO_RETURN` in both maps: `false` in returning block, `true` in other.
    returning_block_overwrites.insert(
        VAR_NAME_NO_RETURN.to_string(),
        single_result_as_value(
            returning_block.append_operation(codegen.new_bool_const_op(false, location)),
        )?,
    );
    nonreturning_block_overwrites.insert(
        VAR_NAME_NO_RETURN.to_string(),
        single_result_as_value(
            nonreturning_block.append_operation(codegen.new_bool_const_op(true, location)),
        )?,
    );

    // Set return value in both maps. In the non-returning block, use the existing value in the
    // block context, if present, otherwise create a new non-det value.
    returning_block_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), return_val);
    nonreturning_block_overwrites.insert(
        VAR_NAME_RETURN_VAL.to_string(),
        function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL).cloned().or_else(|_| {
            single_result_as_value(nonreturning_block.append_operation(
                // TODO: just like `gen_llzk()` for `FunctionData`, this must use an array type
                // if applicable but is currently implemented for scalar `felt.type` only.
                // In this case, the correct solution (once nondet op is supported for any type)
                // is to just create the nondet op using `return_val.getType()`
                codegen.new_nondet_felt_of_dimensions_at_location(location, &[])?,
            ))
        })?,
    );
    Ok(())
}

/// Generate LLZK code that follows a circom `if-then-else` statement that has an unbalanced return
/// (i.e. one branch returns and the other does not). Generates the following LLZK code:
/// ```llzk
///  VAR_NAME_RETURN_VAL = scf.if VAR_NAME_NO_RETURN {
///      /* Leave block context stack in this scope for remaining code */
///  } else {
///      scf.yield VAR_NAME_RETURN_VAL
///  }
///  function.return VAR_NAME_RETURN_VAL
/// ```
fn gen_if_then_else_unbalanced_return_extra<'ast, 'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'ast, 'ctx>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    let condition = function.block_ctx.get_named_value(VAR_NAME_NO_RETURN)?;
    let ret_val = function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL)?;

    let then_region = Region::new();
    let then_block = then_region.append_block(Block::new(&[]));

    let else_region = Region::new();
    let else_block = else_region.append_block(Block::new(&[]));
    no_results(else_block.append_operation(scf::r#yield(&[*ret_val], location)))?;

    let ret_val = function.append_op_named_result(
        scf::r#if(*condition, &[ret_val.r#type()], then_region, else_region, location),
        VAR_NAME_RETURN_VAL.to_string(),
    )?;
    function.append_circom_return(codegen, location, ret_val)?;

    // After adding everything above in the current block context, push the `then_block`
    // so translation of the remaining circom code continues within this block.
    function.block_ctx.push(then_block);
    Ok(())
}

/// Generate LLZK code for a circom [Statement::IfThenElse].
fn gen_if_then_else<'ast, 'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'ast, 'ctx>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    meta: &Meta,
    cond: &Expression,
    if_case: &Box<Statement>,
    else_case: &Option<Box<Statement>>,
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    // Initially, generate the blocks for the 'then' and 'else' cases naively.
    let mut then_info = NestedBlockInfo::default();
    function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        then_info.block,
        |function| if_case.gen_llzk_in_function(codegen, function),
        &mut then_info,
    )?;
    let mut else_info = NestedBlockInfo::default();
    if let Some(else_case) = else_case {
        function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
            else_info.block,
            |function| else_case.gen_llzk_in_function(codegen, function),
            &mut else_info,
        )?;
    }

    let location = codegen.location_from_meta(meta);
    let condition = cond.gen_llzk_in_function(codegen, function)?;

    // Check if one or both blocks end with a return in circom. The `scf.if` op used in LLZK cannot
    // have returns nested within other blocks like circom allows. Use of `append_circom_return()`
    // already ensures `scf.yield` is used instead of `function.return` when not in the root
    // block but the `scf.if` additionally requires that both blocks yield the same number and type
    // of values. Additionally, if one block returns and the other does not (in the circom code),
    // an additional return state must be added to the values to be yielded from both branches.
    let then_return_opt = get_val_of_circom_return_and_erase(then_info.block);
    let else_return_opt = get_val_of_circom_return_and_erase(else_info.block);
    if let Some(then_return) = then_return_opt {
        if let Some(else_return) = else_return_opt {
            // Both return, just add the return value to both overwrite maps.
            then_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), then_return);
            else_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), else_return);
        } else {
            // Return in `then` block but not `else` block.
            handle_early_return(
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
        handle_early_return(
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

    // Update `then_block_info.var_overwrites` to ensure it has all keys from
    // `else_block_info.var_overwrites`, using current-scope values for missing keys. This
    // ensures that both blocks will yield the same set of variables.
    for name in else_info.var_overwrites.keys() {
        if !then_info.var_overwrites.contains_key(name) {
            then_info
                .var_overwrites
                .insert(name.clone(), *function.block_ctx.get_named_value(name)?);
        }
    }

    // Split `then_block_info.var_overwrites` into ordered lists of names and values. The ordering
    // of names here defines the ordering of results from the `scf.if` op and thus the ordering
    // of operands to `scf.yield` ops in both branches. Sort by circom variable names to ensure
    // a stable order.
    let mut overwrites_sorted: Vec<_> = then_info.var_overwrites.into_iter().collect();
    overwrites_sorted.sort_by(|(name_a, _), (name_b, _)| name_a.cmp(name_b));
    let (overwrite_names, then_values): (Vec<_>, Vec<_>) = overwrites_sorted.into_iter().unzip();

    // Insert `scf.yield` at the end of the `then` block.
    no_results(then_info.block.append_operation(scf::r#yield(&then_values, location)))?;

    // Create list of values to yield from the `else` block in the same order
    // as `overwrite_names`, again using current-scope values for missing keys.
    let else_values = overwrite_names
        .iter()
        .map(|name| {
            else_info
                .var_overwrites
                .get(name)
                .map_or_else(|| function.block_ctx.get_named_value(name).cloned(), |v| Ok(*v))
        })
        .collect::<Result<Vec<_>, _>>()?;

    // Insert `scf.yield` at the end of the `else` block.
    no_results(else_info.block.append_operation(scf::r#yield(&else_values, location)))?;

    // Use the `overwrite_names` and the current block context to get the types of the named values
    // to define the result types of the `scf.if` op. Then generate the `scf.if` op itself for
    // the circom `IfThenElse` statement.
    let result_types = overwrite_names
        .iter()
        .map(|name| {
            function
                .block_ctx
                .get_named_value(name)
                .inspect_err(|e| eprintln!("\nERROR: {:?}", e))
                .map(|v| v.r#type())
        })
        .collect::<Result<Vec<_>, _>>()?;
    let scf_if_op = function.append_op(scf::r#if(
        condition,
        &result_types,
        then_info.region,
        else_info.region,
        location,
    ));

    // Update the current block context with results from the `scf.if` op.
    overwrite_names
        .into_iter()
        .zip(scf_if_op.results())
        .try_for_each(|(name, result)| function.block_ctx.set_named_value(name, result.into()))?;

    // Finally, if both blocks ended with a return, then add a new return here. Else, if
    // only one block returned, the code following the `scf.if` needs to be wrapped in
    // another `scf.if` checking `VAR_NAME_NO_RETURN` before generating remaining code.
    if then_return_opt.is_some() && else_return_opt.is_some() {
        let ret_val = function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL)?;
        function.append_circom_return(codegen, location, *ret_val)?;
    } else if then_return_opt.is_some() || else_return_opt.is_some() {
        gen_if_then_else_unbalanced_return_extra(codegen, function, location)?;
    }
    Ok(())
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for Statement
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output = ();

    #[allow(unused_variables)] // TODO: TEMP
    fn gen_llzk_in_function<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    ) -> Result<Self::Output> {
        match self {
            Statement::InitializationBlock { xtype, initializations, .. } => {
                if let VariableType::Signal(..) = xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                initializations.gen_llzk_in_function(codegen, function)
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                if VariableType::Var != *xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                function.block_ctx.declare_name_if_not_present(name, || {
                    codegen.new_nondet_felt_of_dimensions(meta, dimensions)
                })
            }
            Statement::Block { stmts, .. } => function
                .gen_in_current_block_with_new_circom_scope_and_merge_overwrites(|function| {
                    stmts.gen_llzk_in_function(codegen, function)
                }),
            Statement::Substitution { meta, var, access, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                let rhs = rhe.gen_llzk_in_function(codegen, function)?;
                if access.is_empty() {
                    // Since there's no simple assignment in LLZK, just update the mapped Value
                    // which essentially propagates the assignment.
                    function.block_ctx.set_named_value(var.clone(), rhs)
                } else {
                    todo!("Generate array write operation in function");
                }
            }
            Statement::UnderscoreSubstitution { meta, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                // Just visit and drop the resulting Value since it's unused.
                rhe.gen_llzk_in_function(codegen, function).map(drop)
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                gen_if_then_else(codegen, function, meta, cond, if_case, else_case)
            }
            Statement::While { meta, cond, stmt } => {
                todo!("Handle while statement in function")
            }
            Statement::Return { meta, value } => {
                let value = value.gen_llzk_in_function(codegen, function)?;
                let location = codegen.location_from_meta(meta);
                function.append_circom_return(codegen, location, value)
            }
            Statement::Assert { meta, arg } => {
                let value = arg.gen_llzk_in_function(codegen, function)?;
                let location = codegen.location_from_meta(meta);
                function.append_op_no_result(llzk::dialect::bool::assert(
                    location,
                    value,
                    Some("assertion failed"),
                )?)
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
            Statement::ConstraintEquality { .. } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Function uses template operators");
            }
        }
    }
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for Expression
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output = Value<'ctx, 'val>;

    #[allow(unused_variables)] // TODO: TEMP
    fn gen_llzk_in_function<'ast>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    ) -> Result<Self::Output> {
        match self {
            Expression::Number(meta, big_int) => {
                // Convert the BigInt to an LLZK `felt.const` op. The user of the Expression is
                // responsible for converting this `felt.type` value to another type if needed.
                function.append_op_unnamed_result(new_felt_const_op(codegen, meta, big_int)?)
            }
            Expression::Variable { meta, name, access } => {
                match access.as_slice() {
                    [] => {
                        let v = function.block_ctx.get_named_value(name)?;
                        Ok(*v)
                    }
                    a => {
                        // Note: `Access::ComponentAccess` is not legal in functions per
                        // `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                        // so each must be `Access::ArrayAccess` only.
                        todo!("Handle accesses in variable expression in function")
                    }
                }
            }
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                let lhs = lhe.gen_llzk_in_function(codegen, function)?;
                let rhs = rhe.gen_llzk_in_function(codegen, function)?;
                function.gen_infix_op(codegen, meta, infix_op, lhs, rhs)
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                let rhs = rhe.gen_llzk_in_function(codegen, function)?;
                function.gen_prefix_op(codegen, meta, prefix_op, rhs)
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                todo!("Handle InlineSwitchOp expression in function")
            }
            Expression::ParallelOp { meta, rhe } => {
                todo!("Handle ParallelOp expression in function")
            }
            Expression::ArrayInLine { meta, values } => {
                todo!("Handle ArrayInLine expression in function")
            }
            Expression::UniformArray { meta, value, dimension } => {
                todo!("Handle UniformArray expression in function")
            }
            Expression::Call { meta, id, args } => {
                let builder = OpBuilder::new(codegen.context.deref());
                // Visit each argument and collect the resulting LLZK Values for both functions.
                let call_operands = args
                    .iter()
                    .map(|arg| arg.gen_llzk_in_function(codegen, function))
                    .collect::<Result<Vec<Value>>>()?;
                // Create the CallOp in each function using the collected args.

                // TODO: Currently, the LLZK function will always return a `felt.type` but
                // eventually, this gen function may need an "expected result type"
                // parameter or use `poly.tvar` with function templates.
                // See template.rs for Expression::Call generation there.
                let return_types = &[FeltType::new(codegen.context)];
                function.append_op_unnamed_result(
                    function::call(
                        &builder,
                        codegen.location_from_meta(meta),
                        FlatSymbolRefAttribute::new(codegen.context, id),
                        &call_operands,
                        return_types,
                    )?
                    .into(),
                )
            }
            Expression::BusCall { meta, id, args } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Template elements declared inside the function")
            }
            Expression::AnonymousComp { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::Tuple { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
        }
    }
}
