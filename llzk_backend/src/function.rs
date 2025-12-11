#![allow(unused_variables)] // TODO: TEMP
use crate::shared::{self, new_felt_const_op, single_result_as_value, IsA, LlzkCodegen};
use anyhow::{anyhow, Ok, Result};
use llzk::prelude::{bool, felt, function, FeltType, FuncDefOp, FuncDefOpRefMut, OperationMutLike};
use melior::{
    dialect::{arith, index},
    ir::{
        operation::{OperationLike as _, OperationRefMut, WalkOrder, WalkResult},
        BlockLike as _, BlockRef, Operation, OperationRef, RegionLike as _, Type, Value,
        ValueLike as _,
    },
};
use program_structure::{
    ast::{
        Expression, ExpressionInfixOpcode, ExpressionPrefixOpcode, Meta, Statement, VariableType,
    },
    error_code::ReportCode,
};
use std::{
    collections::HashMap,
    convert::{TryFrom, TryInto as _},
    ops::{Deref, DerefMut},
};

/// Stack of blocks where the top block is the current block where code should be appended and the
/// previous block in the list is the parent of the block after it. When an op containing nested
/// blocks is encountered, the current block within that op is pushed to the stack so that any code
/// generated will be placed inside that block and when the nested block is complete, it is popped.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'blk: lifetime of the generated `Block` instances within functions
#[derive(Debug)]
pub struct BlockContextStack<'ctx, 'blk>
where
    'ctx: 'blk,
{
    /// The function entry block.
    initial_block: BlockRef<'ctx, 'blk>,
    /// Additional nesting of blocks within the function representing the current insertion point.
    other_blocks: Vec<BlockRef<'ctx, 'blk>>,
}

impl<'ctx, 'blk> BlockContextStack<'ctx, 'blk>
where
    'ctx: 'blk,
{
    /// Push a new block onto the stack to make it the current block.
    pub fn push(&mut self, item: BlockRef<'ctx, 'blk>) {
        self.other_blocks.push(item);
    }

    /// Pop the current block off the stack to return to the previous block.
    pub fn pop(&mut self) {
        self.other_blocks.pop().expect("There is no block to pop!");
    }

    /// Append an operation to the current block (i.e. the top of the stack).
    ///
    /// 'op: lifetime of the `Operation` instance for the reference returned
    pub fn append_current<'op>(&mut self, operation: Operation<'ctx>) -> OperationRef<'ctx, 'op>
    where
        'blk: 'op,
    {
        let current = match self.other_blocks.last() {
            Some(block) => block,
            None => &self.initial_block,
        };
        // Account for possible terminator in the current block. For example, the `compute_fn()`
        // and `constrain_fn()` helpers automatically add a return op at the end of the block
        // so new ops must be inserted before that terminator.
        match current.terminator() {
            Some(terminator) => current.insert_operation_before(terminator, operation),
            None => current.append_operation(operation),
        }
    }
}

impl<'ctx> TryFrom<&FuncDefOp<'ctx>> for BlockContextStack<'ctx, '_> {
    type Error = anyhow::Error;

    /// Create a BlockContextStack starting with the function entry block.
    fn try_from(func: &FuncDefOp<'ctx>) -> Result<Self, Self::Error> {
        let initial_block =
            func.region(0)?.first_block().ok_or_else(|| anyhow!("missing function entry block"))?;
        Ok(BlockContextStack { initial_block, other_blocks: Default::default() })
    }
}

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
    block_ctx: BlockContextStack<'ctx, 'blk>,
    /// Local name mapped to the SSA Value with that name. Initialized with function
    /// parameters and extended with any variable-to-variable assignments found.
    pub(crate) name_to_value: HashMap<String, Value<'ctx, 'val>>,
}

impl<'ctx, 'func, 'blk, 'val> FunctionContext<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Create a new [FunctionContext] for the given function and name-to-value map.
    pub fn new(
        func: FuncDefOpRefMut<'ctx, 'func>,
        name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Result<Self> {
        Ok(Self { func, block_ctx: func.deref().try_into()?, name_to_value })
    }

    /// Append an operation that must produce no results.
    pub fn append_op_no_result(&mut self, op: Operation<'ctx>) -> Result<()> {
        let op_ref = self.block_ctx.append_current(op);
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
        single_result_as_value(self.block_ctx.append_current(op))
    }

    /// Append an operation that must produce a single result and store the mapping of the circom
    /// variable name to the result Value.
    pub fn append_op_named_result(&mut self, op: Operation<'ctx>, name: String) {
        let v = self.append_op_unnamed_result(op).expect("Expected op to produce a single result");
        self.name_to_value.insert(name, v);
    }

    /// Generate LLZK code in the current function for a prefix operation.
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
        // Macro to handle the common pattern for type checks for op selection.
        macro_rules! try_callback_for_type {
            ($type_check:path, $cb:expr) => {{
                if let Some(result) = self.gen_infix_op_if_types_are(
                    $type_check,
                    $type_check,
                    lhs,
                    rhs,
                    $cb,
                )? {
                    return Ok(result);
                }
            }};
        }

        macro_rules! try_felt_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_felt, || {
                    let loc = codegen.location_from_meta(meta);
                    $op_path(loc, lhs, rhs).map_err(Into::into)
                });
            }};
        }

        macro_rules! try_index_op {
            ($op:ident) => {{
                try_callback_for_type!(shared::is_index, || {
                    let loc = codegen.location_from_meta(meta);
                    Ok(index::$op(lhs, rhs, loc))
                });
            }};
        }

        macro_rules! try_math_op {
            ($op:ident) => {{
                try_callback_for_type!(shared::is_index, || {
                    let loc = codegen.location_from_meta(meta);
                    Ok(math::$op(lhs, rhs, loc))
                });
            }};
        }


        // Macro to handle the common pattern for felt and index type checks.
        // For index operations that use felt:: module and simple index operations.
        macro_rules! try_felt_index_op {
            ($felt_op:ident, $index_op:ident) => {{
                try_felt_op!(felt::$felt_op);
                try_index_op!($index_op);
            }};
        }

        macro_rules! try_felt_math_op {
            ($felt_op:ident, $math_op:ident) => {{
                try_felt_op!(felt::$felt_op);
                try_math_op!($math_op);
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For comparison operations that use bool:: module and index::cmpi.
        macro_rules! try_bool_cmp_op {
            ($bool_op:ident, $cmp:ident) => {{
                try_felt_op!(bool::$bool_op);
                try_callback_for_type!(shared::is_index, || {
                    let loc = codegen.location_from_meta(meta);
                    Ok(index::cmp(codegen.context, arith::CmpiPredicate::$cmp, lhs, rhs, loc))
                });
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
                try_felt_index_op!(div, divu);
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
                try_felt_index_op!(shl, shl);
            }
            ExpressionInfixOpcode::ShiftR => {
                try_felt_index_op!(shr, shru);
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

/// Implement [Drop] on [FunctionContext] to remove any remaining `undef.undef` ops from the
/// function. These were added when visiting the Declaration statements and their uses were
/// replaced with actual values when visiting Assignment statements.
impl Drop for FunctionContext<'_, '_, '_, '_> {
    fn drop(&mut self) {
        self.func.walk(WalkOrder::PreOrder, |op| {
            if llzk::dialect::undef::is_undef_op(op) {
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

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for Statement
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
        match self {
            Statement::InitializationBlock { xtype, initializations, .. } => {
                if let VariableType::Signal(..) = xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                for init in initializations {
                    init.gen_llzk_in_function(codegen, function)?;
                }
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                if VariableType::Var != *xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                // TODO: I don't think there's actually anything to do here, unless we
                //  need to store some info about the declared dimensions of the var.
            }
            Statement::Block { stmts, .. } => {
                for s in stmts {
                    s.gen_llzk_in_function(codegen, function)?;
                }
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                let rhs = rhe.gen_llzk_in_function(codegen, function)?;
                if access.is_empty() {
                    // Since there's no simple assignment in LLZK, just update the mapped Value
                    // which essentially propagates the assignment.
                    function.name_to_value.insert(var.clone(), rhs);
                } else {
                    todo!("Generate array write operation in function");
                }
            }
            Statement::UnderscoreSubstitution { meta, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                // Just visit and drop the result since the value is unused.
                let _ = rhe.gen_llzk_in_function(codegen, function)?;
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
                // Note: Typed underscore binding shows we're not dropping a Result.
                let _: () = function.append_op_no_result(function::r#return(location, &[value]))?;
            }
            Statement::Assert { meta, arg } => {
                let value = arg.gen_llzk_in_function(codegen, function)?;
                let location = codegen.location_from_meta(meta);
                // Note: Typed underscore binding shows we're not dropping a Result.
                let _: () = function.append_op_no_result(llzk::dialect::bool::assert(
                    location,
                    value,
                    Some("assertion failed"),
                )?)?;
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
            Statement::ConstraintEquality { .. } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Function uses template operators");
            }
        }
        Ok(())
    }
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for Expression
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output = Value<'ctx, 'val>;

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
                            .name_to_value
                            .get(name)
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
