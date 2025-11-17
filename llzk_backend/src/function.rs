#![allow(unused_variables)] // TODO: TEMP
use crate::shared::{new_felt_const_op, single_result_as_value, BlockContextStack, LlzkCodegen};
use anyhow::{anyhow, Ok, Result};
use llzk::prelude::{function, FuncDefOpRefMut, OperationMutLike};
use melior::ir::{
    operation::{OperationLike as _, OperationRefMut, WalkOrder, WalkResult},
    Operation, Value,
};
use program_structure::{
    ast::{Expression, Statement, VariableType},
    error_code::ReportCode,
};
use std::{
    collections::HashMap,
    convert::TryInto as _,
    ops::{Deref, DerefMut},
};

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
    func: FuncDefOpRefMut<'ctx, 'func>,
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
                let rhv = rhe.gen_llzk_in_function(codegen, function)?;
                if access.is_empty() {
                    // Since there's no simple assignment in LLZK, just update the mapped Value
                    // which essentially propagates the assignment.
                    function.name_to_value.insert(var.clone(), rhv);
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
                todo!("Handle if-then-else statement in function")
            }
            Statement::While { meta, cond, stmt } => {
                todo!("Handle while statement in function")
            }
            Statement::Return { meta, value } => {
                let value = value.gen_llzk_in_function(codegen, function)?;
                let location = codegen.location_from_meta(meta);
                function.block_ctx.append_current(function::r#return(location, &[value]));
            }
            Statement::Assert { meta, arg } => {
                todo!("Handle assert statement in function")
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
                todo!("Handle InfixOp expression in function")
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                todo!("Handle PrefixOp expression in function")
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
