//! Handles function-level LLZK code generation for both free functions and functions within
//! structs. The [function::FunctionContext] carries information about the current LLZK function
//! being generated and some helpers related to generating code within the function. The
//! [function::GenerateLLZKInFunction] trait provides the visitor to generate LLZK IR for all circom
//! [Expression](program_structure::abstract_syntax_tree::ast::Expression) and
//! [Statement](program_structure::abstract_syntax_tree::ast::Statement) nodes.

use crate::gen_context::BlockContextStack;
use crate::gen_context::GenWithCircomScopeHandling;
use crate::shared::new_felt_const_op;
use crate::shared::single_result_as_value;
use crate::shared::IsA;
use crate::shared::LlzkCodegen;
use crate::shared::{self};
use anyhow::anyhow;
use anyhow::Result;
use llzk::prelude::bool;
use llzk::prelude::felt;
use llzk::prelude::function;
use llzk::prelude::FeltType;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::Operation;
use llzk::prelude::OperationMutLike;
use llzk::prelude::OperationRef;
use melior::dialect::arith;
use melior::dialect::index;
use melior::ir::operation::OperationLike as _;
use melior::ir::operation::OperationRefMut;
use melior::ir::operation::WalkOrder;
use melior::ir::operation::WalkResult;
use melior::ir::BlockRef;
use melior::ir::Type;
use melior::ir::Value;
use melior::ir::ValueLike as _;
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
    pub fn new(
        func: FuncDefOpRefMut<'ctx, 'func>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Result<Self> {
        Ok(Self { func, block_ctx: BlockContextStack::new(func.deref(), param_name_to_value)? })
    }

    /// Append an operation that must produce no results.
    pub fn append_op_no_result(&mut self, op: Operation<'ctx>) -> Result<()> {
        let op_ref = self.block_ctx.append_current_block(op);
        if op_ref.result_count() != 0 {
            return Err(anyhow!(
                "Expected operation to have no results, found {}",
                op_ref.result_count()
            ));
        }
        Ok(())
    }

    /// Append an operation that must produce a single result and is NOT associated with a variable
    /// name in the circom code.
    pub fn append_op_unnamed_result(&mut self, op: Operation<'ctx>) -> Result<Value<'ctx, 'val>> {
        single_result_as_value(self.block_ctx.append_current_block(op))
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
                if rhs.r#type().isa::<FeltType>() {
                    return self.append_op_unnamed_result(felt::neg(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
                // TODO: this can also handle MLIR `index` type operand but otherwise should
                // fall through to the error case.
                todo!("Handle Sub prefix op with RHS type '{}'", rhs.r#type());
            }
            ExpressionPrefixOpcode::BoolNot => {
                todo!("Handle BoolNot prefix op")
            }
            ExpressionPrefixOpcode::Complement => {
                todo!("Handle Complement prefix op")
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
        // Macro to handle the common pattern for felt and index type checks.
        // For index operations that use felt:: module and simple index operations.
        macro_rules! try_felt_index_op {
            ($felt_op:ident, $index_op:ident) => {{
                if let Some(result) = self.gen_infix_op_if_types_are(
                    shared::is_felt,
                    shared::is_felt,
                    lhs,
                    rhs,
                    || {
                        let loc = codegen.location_from_meta(meta);
                        felt::$felt_op(loc, lhs, rhs).map_err(Into::into)
                    },
                )? {
                    return Ok(result);
                }
                if let Some(result) = self.gen_infix_op_if_types_are(
                    shared::is_index,
                    shared::is_index,
                    lhs,
                    rhs,
                    || {
                        let loc = codegen.location_from_meta(meta);
                        Ok(index::$index_op(lhs, rhs, loc))
                    },
                )? {
                    return Ok(result);
                }
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For comparison operations that use bool:: module and index::cmpi.
        macro_rules! try_bool_cmp_op {
            ($bool_op:ident, $cmp:ident) => {{
                if let Some(result) = self.gen_infix_op_if_types_are(
                    shared::is_felt,
                    shared::is_felt,
                    lhs,
                    rhs,
                    || {
                        let loc = codegen.location_from_meta(meta);
                        bool::$bool_op(loc, lhs, rhs).map_err(Into::into)
                    },
                )? {
                    return Ok(result);
                }
                if let Some(result) = self.gen_infix_op_if_types_are(
                    shared::is_index,
                    shared::is_index,
                    lhs,
                    rhs,
                    || {
                        let loc = codegen.location_from_meta(meta);
                        Ok(index::cmp(codegen.context, arith::CmpiPredicate::$cmp, lhs, rhs, loc))
                    },
                )? {
                    return Ok(result);
                }
            }};
        }

        match op {
            ExpressionInfixOpcode::Add => {
                try_felt_index_op!(add, add);
            }
            ExpressionInfixOpcode::Sub => {
                try_felt_index_op!(sub, sub);
            }
            ExpressionInfixOpcode::Mul => {
                try_felt_index_op!(mul, mul);
            }
            ExpressionInfixOpcode::Div => {
                todo!("Handle Div infix op")
            }
            ExpressionInfixOpcode::IntDiv => {
                todo!("Handle IntDiv infix op")
            }
            ExpressionInfixOpcode::Mod => {
                try_felt_index_op!(r#mod, remu);
            }
            ExpressionInfixOpcode::Pow => {
                todo!("Handle Pow infix op")
            }
            ExpressionInfixOpcode::ShiftL => {
                todo!("Handle ShiftL infix op")
            }
            ExpressionInfixOpcode::ShiftR => {
                todo!("Handle ShiftR infix op")
            }
            ExpressionInfixOpcode::LesserEq => {
                try_bool_cmp_op!(le, Ule);
            }
            ExpressionInfixOpcode::GreaterEq => {
                try_bool_cmp_op!(ge, Uge);
            }
            ExpressionInfixOpcode::Lesser => {
                try_bool_cmp_op!(lt, Ult);
            }
            ExpressionInfixOpcode::Greater => {
                try_bool_cmp_op!(gt, Ugt);
            }
            ExpressionInfixOpcode::Eq => {
                try_bool_cmp_op!(eq, Eq);
            }
            ExpressionInfixOpcode::NotEq => {
                try_bool_cmp_op!(ne, Ne);
            }
            ExpressionInfixOpcode::BoolOr => {
                todo!("Handle BoolOr infix op")
            }
            ExpressionInfixOpcode::BoolAnd => {
                todo!("Handle BoolAnd infix op")
            }
            ExpressionInfixOpcode::BitOr => {
                try_felt_index_op!(bit_or, or);
            }
            ExpressionInfixOpcode::BitAnd => {
                try_felt_index_op!(bit_and, and);
            }
            ExpressionInfixOpcode::BitXor => {
                try_felt_index_op!(bit_xor, xor);
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
    type NewBlock = BlockRef<'ctx, 'blk>;

    fn stack_top(&self) -> Self::NewBlock {
        *self.block_ctx.top_block()
    }

    fn stack_push(&mut self, block: Self::NewBlock) {
        self.block_ctx.push(block)
    }

    fn stack_pop<H>(&mut self, mut handle_overwrites: H) -> Result<()>
    where
        H: FnMut(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            HashMap<String, Value<'ctx, 'val>>,
        ) -> Result<()>,
    {
        let popped = self.block_ctx.pop();
        handle_overwrites(self, popped)
    }
}

/// Implement [Drop] on [FunctionContext] to remove any remaining `undef.undef` ops from the
/// function. These were added when visiting the Declaration statements and their uses were
/// replaced with actual values when visiting Assignment statements.
impl Drop for FunctionContext<'_, '_, '_, '_> {
    fn drop(&mut self) {
        fn undef_has_uses(op: OperationRef) -> bool {
            shared::has_uses(single_result_as_value(op).unwrap())
        }
        self.func.walk(WalkOrder::PreOrder, |op| {
            if llzk::dialect::undef::is_undef_op(op) && !undef_has_uses(op) {
                let mut op_ref_mut = unsafe { OperationRefMut::from_raw(op.to_raw()) };
                OperationMutLike::remove_from_parent(op_ref_mut.deref_mut());
                WalkResult::Skip
            } else {
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
                .gen_in_current_block_with_new_circom_scope_and_merge_overwrites(|function, _| {
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
                let cond = cond.gen_llzk_in_function(codegen, function)?;
                /*
                // Generate LLZK for both blocks and then generate an `scf.if`.
                // TODO: The 'return' ops generated within the blocks need to be converted to
                // `scf.yield` ops. If both blocks contain a return, then the `scf.if` itself needs
                // to be followed by a return of the yielded value. If only one block contains a
                // return, then the `scf.if` needs to yield an additional boolean value `isReturn`
                // indicating whether a return occurred, and the code following the `scf.if` needs
                // to be guarded another `scf.if` checking `!isReturn`.
                //
                // TODO: Do these blocks need arguments to pass SSA Values from the outer scope?
                let if_block = Block::new(&[]);
                function.block_ctx.push(unsafe { BlockRef::from_raw(if_block.to_raw()) });
                if_case.gen_llzk_in_function(codegen, function)?;
                function.block_ctx.pop();
                println!("Generated if block {}", if_block); // TODO:TEMP

                if let Some(else_case) = else_case {
                    let else_block = Block::new(&[]);
                    function.block_ctx.push(unsafe { BlockRef::from_raw(else_block.to_raw()) });
                    else_case.gen_llzk_in_function(codegen, function)?;
                    function.block_ctx.pop();
                    println!("Generated else block {}", else_block); // TODO:TEMP
                }
                 */
                todo!("Handle if-then-else statement in function")
            }
            Statement::While { meta, cond, stmt } => {
                todo!("Handle while statement in function")
            }
            Statement::Return { meta, value } => {
                let value = value.gen_llzk_in_function(codegen, function)?;
                let location = codegen.location_from_meta(meta);
                function.append_op_no_result(function::r#return(location, &[value]))
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
                        let v = function
                            .block_ctx
                            .get_named_value(name)
                            .ok_or_else(|| anyhow!("variable {name} not found"))?;
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
                todo!("Handle Call expression in function")
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
