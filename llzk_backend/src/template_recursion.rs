//! Identify templates requiring finite recursion expansion and evaluate their scalar arguments.

use std::collections::{HashMap, HashSet};

use anyhow::{ensure, Result};
use num_bigint_dig::BigUint;
use num_traits::Zero;
use program_structure::{
    ast::{Expression, ExpressionInfixOpcode, Statement},
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
) -> Result<Option<BigUint>> {
    match expr {
        Expression::Number(..) => crate::shared::try_compute_biguint(expr, prime),
        Expression::Variable { name, access, .. } if access.is_empty() => {
            Ok(constants.get(name).cloned())
        }
        Expression::InfixOp { meta, lhe, infix_op, rhe } => {
            let Some(lhs) = value(lhe, constants, prime)? else {
                return Ok(None);
            };
            let Some(rhs) = value(rhe, constants, prime)? else {
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
            let Some(rhs) = value(rhe, constants, prime)? else {
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
            let Some(condition) = value(cond, constants, prime)? else {
                return Ok(None);
            };
            value(if condition.is_zero() { if_false } else { if_true }, constants, prime)
        }
        _ => Ok(None),
    }
}
