//! Identify templates requiring finite recursion expansion and evaluate their scalar arguments.

use std::collections::{HashMap, HashSet};

use anyhow::{ensure, Result};
use num_bigint_dig::BigUint;
use num_traits::{ToPrimitive, Zero};
use program_structure::{
    ast::{Access, AssignOp, Expression, ExpressionInfixOpcode, Statement, VariableType},
    function_data::FunctionInfo,
    template_data::TemplateData,
};

/// Values known during template preparation and speculative function execution.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub(super) enum ConstantValue {
    Scalar(BigUint),
    Array(Vec<ConstantValue>),
}

impl From<BigUint> for ConstantValue {
    fn from(value: BigUint) -> Self {
        Self::Scalar(value)
    }
}

impl ConstantValue {
    pub(super) fn into_scalar(self) -> Option<BigUint> {
        match self {
            Self::Scalar(value) => Some(value),
            Self::Array(_) => None,
        }
    }

    fn size(&self) -> Option<usize> {
        match self {
            Self::Scalar(_) => Some(1),
            Self::Array(values) => {
                values.iter().try_fold(1usize, |size, value| size.checked_add(value.size()?))
            }
        }
    }

    fn same_shape(&self, other: &Self) -> bool {
        match (self, other) {
            (Self::Scalar(_), Self::Scalar(_)) => true,
            (Self::Array(lhs), Self::Array(rhs)) => {
                lhs.len() == rhs.len() && lhs.iter().zip(rhs).all(|(lhs, rhs)| lhs.same_shape(rhs))
            }
            _ => false,
        }
    }
}

/// Variables whose scalar or array values are known at the current point.
pub(super) type Constants = HashMap<String, ConstantValue>;

fn call_graph(templates: &HashMap<String, TemplateData>) -> HashMap<String, HashSet<String>> {
    let mut graph = HashMap::new();
    for (name, template) in templates {
        let mut calls = HashSet::new();
        collect_calls(template.get_body(), templates, &mut calls);
        graph.insert(name.clone(), calls);
    }
    graph
}

/// Acyclic programs need no early specialization before their metadata is lowered.
pub(super) fn has_recursion(templates: &HashMap<String, TemplateData>) -> bool {
    let graph = call_graph(templates);
    let mut callers: HashMap<&str, Vec<&str>> = HashMap::new();
    let mut remaining = HashMap::new();
    let mut leaves = Vec::new();
    for (name, callees) in &graph {
        remaining.insert(name.as_str(), callees.len());
        if callees.is_empty() {
            leaves.push(name.as_str());
        }
        for callee in callees {
            callers.entry(callee).or_default().push(name);
        }
    }
    let mut completed = 0;
    while let Some(name) = leaves.pop() {
        completed += 1;
        for caller in callers.get(name).into_iter().flatten() {
            let count = remaining.get_mut(caller).expect("caller belongs to the graph");
            *count -= 1;
            if *count == 0 {
                leaves.push(caller);
            }
        }
    }
    completed != graph.len()
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
    Evaluator::new(prime, functions).value(expr, constants)
}

/// Evaluate an expression that may produce a known array as well as a scalar.
pub(super) fn known_value(
    expr: &Expression,
    constants: &Constants,
    prime: &BigUint,
    functions: &FunctionInfo,
) -> Result<Option<ConstantValue>> {
    Evaluator::new(prime, functions).known_value(expr, constants)
}

/// Apply a known assignment, forgetting the binding if its value or access is unresolved.
pub(super) fn assign(
    var: &str,
    access: &[Access],
    expr: &Expression,
    constants: &mut Constants,
    prime: &BigUint,
    functions: &FunctionInfo,
) -> Result<bool> {
    Evaluator::new(prime, functions).assign(var, access, expr, constants)
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
    Return(Option<ConstantValue>),
}

impl<'a> Evaluator<'a> {
    fn new(prime: &'a BigUint, functions: &'a FunctionInfo) -> Self {
        Self { prime, functions, depth: 0, remaining_steps: 10_000 }
    }

    /// Charge array allocation and copying as well as execution to the same finite budget.
    fn charge(&mut self, steps: usize) -> bool {
        if let Some(remaining) = self.remaining_steps.checked_sub(steps) {
            self.remaining_steps = remaining;
            true
        } else {
            self.remaining_steps = 0;
            false
        }
    }

    fn value(&mut self, expr: &Expression, constants: &Constants) -> Result<Option<BigUint>> {
        Ok(self.known_value(expr, constants)?.and_then(ConstantValue::into_scalar))
    }

    fn known_value(
        &mut self,
        expr: &Expression,
        constants: &Constants,
    ) -> Result<Option<ConstantValue>> {
        if !self.charge(1) {
            return Ok(None);
        }
        let prime = self.prime;
        match expr {
            Expression::Number(..) => {
                Ok(crate::shared::try_compute_biguint(expr, prime)?.map(ConstantValue::Scalar))
            }
            Expression::Variable { name, access, .. } => {
                let Some(indices) = self.access_indices(access, constants)? else {
                    return Ok(None);
                };
                let Some(mut value) = constants.get(name) else {
                    return Ok(None);
                };
                for index in indices {
                    let ConstantValue::Array(values) = value else {
                        return Ok(None);
                    };
                    let Some(element) = values.get(index) else {
                        return Ok(None);
                    };
                    value = element;
                }
                if !value.size().is_some_and(|size| self.charge(size)) {
                    return Ok(None);
                }
                Ok(Some(value.clone()))
            }
            Expression::ArrayInLine { values, .. } => {
                if values.len() > self.remaining_steps {
                    return Ok(None);
                }
                let mut elements: Vec<ConstantValue> = Vec::with_capacity(values.len());
                for value in values {
                    let Some(value) = self.known_value(value, constants)? else {
                        return Ok(None);
                    };
                    if elements.first().is_some_and(|first| !first.same_shape(&value)) {
                        return Ok(None);
                    }
                    elements.push(value);
                }
                Ok(Some(ConstantValue::Array(elements)))
            }
            Expression::UniformArray { value, dimension, .. } => {
                let Some(length) = self.value(dimension, constants)?.and_then(|n| n.to_usize())
                else {
                    return Ok(None);
                };
                if length > self.remaining_steps {
                    return Ok(None);
                }
                let Some(value) = self.known_value(value, constants)? else {
                    return Ok(None);
                };
                let cost = value.size().and_then(|size| size.checked_mul(length));
                if !cost.is_some_and(|size| self.charge(size)) {
                    return Ok(None);
                }
                Ok(Some(ConstantValue::Array(vec![value; length])))
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
                Ok(crate::shared::try_compute_biguint(
                    &Expression::InfixOp {
                        meta: meta.clone(),
                        lhe: Box::new(Expression::Number(lhe.get_meta().clone(), lhs.into())),
                        infix_op: *infix_op,
                        rhe: Box::new(Expression::Number(rhe.get_meta().clone(), rhs.into())),
                    },
                    prime,
                )?
                .map(ConstantValue::Scalar))
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                let Some(rhs) = self.value(rhe, constants)? else {
                    return Ok(None);
                };
                Ok(crate::shared::try_compute_biguint(
                    &Expression::PrefixOp {
                        meta: meta.clone(),
                        prefix_op: *prefix_op,
                        rhe: Box::new(Expression::Number(rhe.get_meta().clone(), rhs.into())),
                    },
                    prime,
                )?
                .map(ConstantValue::Scalar))
            }
            Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
                let Some(condition) = self.value(cond, constants)? else {
                    return Ok(None);
                };
                self.known_value(if condition.is_zero() { if_false } else { if_true }, constants)
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
                    let Some(value) = self.known_value(arg, constants)? else {
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

    fn access_indices(
        &mut self,
        access: &[Access],
        constants: &Constants,
    ) -> Result<Option<Vec<usize>>> {
        let mut indices = Vec::new();
        for item in access {
            let Access::ArrayAccess(index) = item else {
                return Ok(None);
            };
            let Some(index) = self.value(index, constants)?.and_then(|index| index.to_usize())
            else {
                return Ok(None);
            };
            indices.push(index);
        }
        Ok(Some(indices))
    }

    fn assign(
        &mut self,
        var: &str,
        access: &[Access],
        expr: &Expression,
        constants: &mut Constants,
    ) -> Result<bool> {
        let value = self.known_value(expr, constants)?;
        let indices = self.access_indices(access, constants)?;
        let updated = match (value, indices) {
            (Some(value), Some(indices)) if indices.is_empty() => {
                if constants.get(var).is_some_and(|old| !old.same_shape(&value)) {
                    false
                } else {
                    constants.insert(var.to_owned(), value);
                    true
                }
            }
            (Some(value), Some(indices)) => {
                let mut target = constants.get_mut(var);
                for index in indices {
                    target = match target {
                        Some(ConstantValue::Array(values)) => values.get_mut(index),
                        _ => None,
                    };
                }
                match target {
                    Some(target) if target.same_shape(&value) => {
                        *target = value;
                        true
                    }
                    _ => false,
                }
            }
            _ => false,
        };
        if !updated {
            constants.remove(var);
        }
        Ok(updated)
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
        shadowed: &mut HashMap<String, Option<ConstantValue>>,
    ) -> Result<Flow> {
        if !self.charge(1) {
            return Ok(Flow::Return(None));
        }
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
                for (position, stmt) in initializations.iter().enumerate() {
                    if let Statement::Declaration {
                        name,
                        xtype: VariableType::Var,
                        dimensions,
                        ..
                    } = stmt
                    {
                        if !dimensions.is_empty() {
                            // Normal parsing establishes the declared shape with a zero initializer.
                            // With --no_init it is absent: do not infer a different shape from a
                            // later assignment, or assume uninitialized elements are zero.
                            let Some(Statement::Substitution {
                                var,
                                access,
                                op: AssignOp::AssignVar,
                                rhe,
                                ..
                            }) = initializations.get(position + 1)
                            else {
                                return Ok(Flow::Return(None));
                            };
                            if var != name || !access.is_empty() {
                                return Ok(Flow::Return(None));
                            }
                            let mut initializer = rhe;
                            for declared in dimensions {
                                let Expression::UniformArray { value, dimension, .. } = initializer
                                else {
                                    return Ok(Flow::Return(None));
                                };
                                let Some(length) = self.value(declared, constants)? else {
                                    return Ok(Flow::Return(None));
                                };
                                if self.value(dimension, constants)? != Some(length) {
                                    return Ok(Flow::Return(None));
                                }
                                initializer = value;
                            }
                            if !matches!(initializer, Expression::Number(_, value) if value.is_zero())
                            {
                                return Ok(Flow::Return(None));
                            }
                        }
                    }
                    let result = self.statement(stmt, constants, shadowed)?;
                    if matches!(result, Flow::Return(_)) {
                        return Ok(result);
                    }
                }
                Ok(Flow::Continue)
            }
            Statement::Declaration { name, xtype: VariableType::Var, .. } => {
                if !shadowed.contains_key(name) {
                    if let Some(value) = constants.get(name) {
                        if !value.size().is_some_and(|size| self.charge(size)) {
                            return Ok(Flow::Return(None));
                        }
                    }
                    shadowed.insert(name.clone(), constants.get(name).cloned());
                }
                constants.remove(name);
                Ok(Flow::Continue)
            }
            Statement::Substitution { var, access, op: AssignOp::AssignVar, rhe, .. } => {
                if self.assign(var, access, rhe, constants)? {
                    Ok(Flow::Continue)
                } else {
                    Ok(Flow::Return(None))
                }
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
            Statement::Return { value, .. } => {
                Ok(Flow::Return(self.known_value(value, constants)?))
            }
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
