//! Identify templates requiring finite recursion expansion and evaluate their scalar arguments.

use std::collections::{HashMap, HashSet};

use anyhow::{ensure, Result};
use num_bigint_dig::BigUint;
use num_traits::Zero;
use program_structure::{
    ast::{AssignOp, Expression, ExpressionInfixOpcode, Statement, VariableType},
    function_data::FunctionInfo,
    template_data::TemplateData,
};

/// Scalar variables whose current values are known during template preparation.
pub(super) type Constants = HashMap<String, BigUint>;

fn call_graph(templates: &HashMap<String, TemplateData>) -> HashMap<String, HashSet<String>> {
    let mut graph = HashMap::new();
    for (name, template) in templates {
        let mut calls = HashSet::new();
        collect_calls(template.get_body(), templates, &mut calls);
        graph.insert(name.clone(), calls);
    }
    graph
}

/// Include a template and all callers that must propagate its specialized scalar arguments.
pub(super) fn callers_of(
    templates: &HashMap<String, TemplateData>,
    target: &str,
) -> HashSet<String> {
    let mut callers: HashMap<String, Vec<String>> = HashMap::new();
    for (caller, callees) in call_graph(templates) {
        for callee in callees {
            callers.entry(callee).or_default().push(caller.clone());
        }
    }
    let mut result = HashSet::new();
    let mut pending = vec![target.to_owned()];
    while let Some(template) = pending.pop() {
        if result.insert(template.clone()) {
            if let Some(parents) = callers.get(&template) {
                pending.extend(parents.iter().cloned());
            }
        }
    }
    result
}

fn collect_calls(
    stmt: &Statement,
    templates: &HashMap<String, TemplateData>,
    calls: &mut HashSet<String>,
) {
    match stmt {
        Statement::Block { stmts, .. }
        | Statement::InitializationBlock { initializations: stmts, .. } => {
            for stmt in stmts {
                collect_calls(stmt, templates, calls);
            }
        }
        Statement::IfThenElse { if_case, else_case, .. } => {
            collect_calls(if_case, templates, calls);
            if let Some(stmt) = else_case {
                collect_calls(stmt, templates, calls);
            }
        }
        Statement::While { stmt, .. } => collect_calls(stmt, templates, calls),
        Statement::Substitution { rhe, .. } => {
            let mut expr = rhe;
            while let Expression::ParallelOp { rhe, .. } = expr {
                expr = rhe;
            }
            if let Expression::Call { id, .. } = expr {
                if templates.contains_key(id) {
                    calls.insert(id.clone());
                }
            }
        }
        _ => {}
    }
}

/// Evaluate scalar expressions using known variables and Circom's field arithmetic.
pub(super) fn value(
    expr: &Expression,
    constants: &Constants,
    prime: &BigUint,
    functions: &FunctionInfo,
) -> Result<Option<BigUint>> {
    Evaluator { prime, functions, depth: 0, remaining_steps: 10_000 }.value(expr, constants)
}

/// Bound speculative execution, including loops and recursive function calls. Unsupported
/// statements or exhausted limits leave the expression unknown instead of guessing a value.
struct Evaluator<'a> {
    prime: &'a BigUint,
    functions: &'a FunctionInfo,
    depth: usize,
    remaining_steps: usize,
}

enum Flow {
    Continue,
    Return(Option<BigUint>),
}

impl Evaluator<'_> {
    fn value(&mut self, expr: &Expression, constants: &Constants) -> Result<Option<BigUint>> {
        let prime = self.prime;
        match expr {
            Expression::Number(..) => crate::shared::try_compute_biguint(expr, prime),
            Expression::Variable { name, access, .. } if access.is_empty() => {
                Ok(constants.get(name).cloned())
            }
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                let Some(lhs) = self.value(lhe, constants)? else {
                    return Ok(None);
                };
                let Some(rhs) = self.value(rhe, constants)? else {
                    return Ok(None);
                };
                ensure!(
                    !matches!(infix_op, ExpressionInfixOpcode::IntDiv | ExpressionInfixOpcode::Mod)
                        || !rhs.is_zero(),
                    "division by zero in constant template expression"
                );
                crate::shared::try_compute_biguint(
                    &Expression::InfixOp {
                        meta: meta.clone(),
                        lhe: Box::new(Expression::Number(lhe.get_meta().clone(), lhs.into())),
                        infix_op: *infix_op,
                        rhe: Box::new(Expression::Number(rhe.get_meta().clone(), rhs.into())),
                    },
                    prime,
                )
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                let Some(rhs) = self.value(rhe, constants)? else {
                    return Ok(None);
                };
                crate::shared::try_compute_biguint(
                    &Expression::PrefixOp {
                        meta: meta.clone(),
                        prefix_op: *prefix_op,
                        rhe: Box::new(Expression::Number(rhe.get_meta().clone(), rhs.into())),
                    },
                    prime,
                )
            }
            Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
                let Some(condition) = self.value(cond, constants)? else {
                    return Ok(None);
                };
                self.value(if condition.is_zero() { if_false } else { if_true }, constants)
            }
            Expression::Call { id, args, .. } => {
                let Some(function) = self.functions.get(id) else {
                    return Ok(None);
                };
                if self.depth >= 128 || args.len() != function.get_num_of_params() {
                    return Ok(None);
                }
                let mut parameters = Constants::new();
                for (name, arg) in function.get_name_of_params().iter().zip(args) {
                    let Some(value) = self.value(arg, constants)? else {
                        return Ok(None);
                    };
                    parameters.insert(name.clone(), value);
                }
                self.depth += 1;
                let result = self.scoped_statement(function.get_body(), &mut parameters);
                self.depth -= 1;
                match result? {
                    Flow::Return(value) => Ok(value),
                    Flow::Continue => Ok(None),
                }
            }
            _ => Ok(None),
        }
    }

    fn scoped_statement(&mut self, stmt: &Statement, constants: &mut Constants) -> Result<Flow> {
        let mut shadowed = HashMap::new();
        let result = self.statement(stmt, constants, &mut shadowed);
        for (name, value) in shadowed {
            if let Some(value) = value {
                constants.insert(name, value);
            } else {
                constants.remove(&name);
            }
        }
        result
    }

    fn statement(
        &mut self,
        stmt: &Statement,
        constants: &mut Constants,
        shadowed: &mut HashMap<String, Option<BigUint>>,
    ) -> Result<Flow> {
        if self.remaining_steps == 0 {
            return Ok(Flow::Return(None));
        }
        self.remaining_steps -= 1;
        match stmt {
            Statement::Block { stmts, .. } => {
                let mut locals = HashMap::new();
                let mut result = Flow::Continue;
                for stmt in stmts {
                    result = self.statement(stmt, constants, &mut locals)?;
                    if matches!(result, Flow::Return(_)) {
                        break;
                    }
                }
                for (name, value) in locals {
                    if let Some(value) = value {
                        constants.insert(name, value);
                    } else {
                        constants.remove(&name);
                    }
                }
                Ok(result)
            }
            Statement::InitializationBlock { initializations, .. } => {
                for stmt in initializations {
                    let result = self.statement(stmt, constants, shadowed)?;
                    if matches!(result, Flow::Return(_)) {
                        return Ok(result);
                    }
                }
                Ok(Flow::Continue)
            }
            Statement::Declaration { name, xtype: VariableType::Var, dimensions, .. }
                if dimensions.is_empty() =>
            {
                shadowed.entry(name.clone()).or_insert_with(|| constants.get(name).cloned());
                constants.remove(name);
                Ok(Flow::Continue)
            }
            Statement::Substitution { var, access, op: AssignOp::AssignVar, rhe, .. }
                if access.is_empty() =>
            {
                let Some(value) = self.value(rhe, constants)? else {
                    return Ok(Flow::Return(None));
                };
                constants.insert(var.clone(), value);
                Ok(Flow::Continue)
            }
            Statement::IfThenElse { cond, if_case, else_case, .. } => {
                let Some(condition) = self.value(cond, constants)? else {
                    return Ok(Flow::Return(None));
                };
                if !condition.is_zero() {
                    self.scoped_statement(if_case, constants)
                } else if let Some(stmt) = else_case {
                    self.scoped_statement(stmt, constants)
                } else {
                    Ok(Flow::Continue)
                }
            }
            Statement::While { cond, stmt, .. } => loop {
                let Some(condition) = self.value(cond, constants)? else {
                    return Ok(Flow::Return(None));
                };
                if condition.is_zero() {
                    return Ok(Flow::Continue);
                }
                let result = self.scoped_statement(stmt, constants)?;
                if matches!(result, Flow::Return(_)) {
                    return Ok(result);
                }
            },
            Statement::Return { value, .. } => Ok(Flow::Return(self.value(value, constants)?)),
            Statement::Assert { arg, .. } => {
                if self.value(arg, constants)?.is_some_and(|value| !value.is_zero()) {
                    Ok(Flow::Continue)
                } else {
                    Ok(Flow::Return(None))
                }
            }
            _ => Ok(Flow::Return(None)),
        }
    }
}
