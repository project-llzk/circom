//! Represent fixed-shape array template parameters using scalar LLZK parameters.

use std::collections::{HashMap, HashSet};
use std::convert::TryFrom;

use anyhow::{ensure, Result};
use num_bigint_dig::BigUint;
use num_traits::Zero;
use program_structure::{
    ast::{Access, AssignOp, Expression, Meta, Statement, VariableType},
    function_data::FunctionInfo,
    program_archive::ProgramArchive,
    template_data::TemplateData,
};

use crate::template_recursion::{self, Constants};

/// Lexically visible variable shapes; `None` means the shape is not statically known.
type Shapes = HashMap<String, Option<Vec<usize>>>;
/// Original template name, array shapes, and bound scalar values in formal parameter order.
type Specialization = (String, Vec<Option<Vec<usize>>>, Vec<Option<BigUint>>);

/// Bound expansion before nonterminating recursion can exhaust the compiler's stack.
const MAX_RECURSIVE_DEPTH: usize = 128;

/// Request a fresh preparation with values bound along this recursive call path.
#[derive(Debug)]
struct ExpandRecursion(String);

impl std::fmt::Display for ExpandRecursion {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(formatter, "array recursion requires specialization of {}", self.0)
    }
}

impl std::error::Error for ExpandRecursion {}

/// Scalarize array arguments before collecting template declarations and types.
pub(crate) fn prepare(mut program: ProgramArchive, prime: &BigUint) -> Result<ProgramArchive> {
    let mut expanded = HashSet::new();
    loop {
        let mut preparation = Preparation {
            originals: &program.templates,
            functions: &program.functions,
            prime,
            templates: HashMap::new(),
            specializations: HashMap::new(),
            active: HashSet::new(),
            recursive_depth: 0,
            expanded: &expanded,
            next_elem_id: program.id_max,
        };
        let mut main = program.initial_template_call.clone();
        match preparation.call(&mut main, &Shapes::new(), &Constants::new()) {
            Ok(()) => {
                program.id_max = preparation.next_elem_id;
                program.templates = preparation.templates;
                program.initial_template_call = main;
                return Ok(program);
            }
            Err(error) => {
                if let Some(ExpandRecursion(id)) = error.downcast_ref::<ExpandRecursion>() {
                    // Discover array parameters from actual call shapes. Restart so scalar-only
                    // wrappers also bind values, without changing unrelated scalar recursion.
                    expanded.extend(template_recursion::callers_of(&program.templates, id));
                } else {
                    return Err(error);
                }
            }
        }
    }
}

/// Rebuild the reachable template graph with scalar parameters for each known array shape.
struct Preparation<'a> {
    /// Unmodified templates, used as the source for every specialization.
    originals: &'a HashMap<String, TemplateData>,
    /// Function definitions available to constant evaluation.
    functions: &'a FunctionInfo,
    /// Field modulus for evaluating constant dimensions.
    prime: &'a BigUint,
    /// Completed reachable template definitions.
    templates: HashMap<String, TemplateData>,
    /// Reuse definitions with equal shapes and recursion-controlling scalar bindings.
    specializations: HashMap<Specialization, String>,
    /// Incomplete expanded specializations must not be reused as circular struct members.
    active: HashSet<Specialization>,
    /// Active reentries into a template, excluding first visits through acyclic callers.
    recursive_depth: usize,
    /// Array recursion and its callers need scalar bindings to resolve a finite child graph.
    expanded: &'a HashSet<String>,
    /// Fresh AST IDs for rebuilt templates, starting after the original program's IDs.
    next_elem_id: usize,
}

impl Preparation<'_> {
    /// Return a statically known shape; an empty shape denotes a scalar.
    fn shape(&self, expr: &Expression, shapes: &Shapes) -> Result<Option<Vec<usize>>> {
        Ok(match expr {
            Expression::Number(..) | Expression::InfixOp { .. } | Expression::PrefixOp { .. } => {
                Some(vec![])
            }
            Expression::Variable { name, access, .. } => {
                let Some(Some(shape)) = shapes.get(name) else {
                    return Ok(None);
                };
                if access.iter().all(|item| matches!(item, Access::ArrayAccess(_))) {
                    shape.get(access.len()..).map(<[usize]>::to_vec)
                } else {
                    None
                }
            }
            Expression::ArrayInLine { values, .. } => {
                let mut element_shape = None;
                for value in values {
                    let Some(shape) = self.shape(value, shapes)? else {
                        return Ok(None);
                    };
                    if element_shape.as_ref().is_some_and(|previous| previous != &shape) {
                        return Ok(None);
                    }
                    element_shape = Some(shape);
                }
                let mut shape = vec![values.len()];
                shape.extend(element_shape.unwrap_or_default());
                Some(shape)
            }
            Expression::UniformArray { value, dimension, .. } => {
                let length = crate::shared::try_compute_as_i64(dimension, self.prime)?
                    .and_then(|n| usize::try_from(n).ok());
                length
                    .zip(self.shape(value, shapes)?)
                    .map(|(length, element)| std::iter::once(length).chain(element).collect())
            }
            Expression::InlineSwitchOp { if_true, if_false, .. } => {
                let first = self.shape(if_true, shapes)?;
                (first == self.shape(if_false, shapes)?).then_some(first).flatten()
            }
            _ => None,
        })
    }

    /// Rewrite a component constructor and flatten its known array arguments in caller scope.
    fn call(
        &mut self,
        expr: &mut Expression,
        shapes: &Shapes,
        constants: &Constants,
    ) -> Result<()> {
        if let Expression::ParallelOp { rhe, .. } = expr {
            return self.call(rhe, shapes, constants);
        }
        let Expression::Call { id, args, .. } = expr else {
            return Ok(());
        };
        if !self.originals.contains_key(id) {
            return Ok(());
        }
        let parameter_shapes = args
            .iter()
            .map(|arg| Ok(self.shape(arg, shapes)?.filter(|shape| !shape.is_empty())))
            .collect::<Result<Vec<_>>>()?;
        if !self.expanded.contains(id)
            && self.active.iter().any(|(active_id, active_shapes, _)| {
                active_id == id
                    && (parameter_shapes.iter().any(Option::is_some)
                        || active_shapes.iter().any(Option::is_some))
            })
        {
            return Err(ExpandRecursion(id.clone()).into());
        }
        let parameter_values = args
            .iter()
            .zip(&parameter_shapes)
            .map(|(arg, shape)| {
                if self.expanded.contains(id) && shape.is_none() {
                    template_recursion::value(arg, constants, self.prime, self.functions)
                } else {
                    Ok(None)
                }
            })
            .collect::<Result<Vec<_>>>()?;
        let name = self.specialize(id, &parameter_shapes, &parameter_values)?;
        let mut scalar_args = Vec::new();
        for ((arg, shape), value) in args.iter().zip(&parameter_shapes).zip(&parameter_values) {
            if let Some(shape) = shape {
                for indices in indices(shape)? {
                    scalar_args.push(array_element(arg, &indices)?);
                }
            } else if value.is_none() {
                scalar_args.push(arg.clone());
            }
        }
        *id = name;
        *args = scalar_args;
        Ok(())
    }

    /// Create or reuse a template with scalar element formals and reconstructed array locals.
    fn specialize(
        &mut self,
        id: &str,
        parameter_shapes: &[Option<Vec<usize>>],
        parameter_values: &[Option<BigUint>],
    ) -> Result<String> {
        let key = (id.to_owned(), parameter_shapes.to_vec(), parameter_values.to_vec());
        let resolve_recursion = self.expanded.contains(id);
        ensure!(
            !resolve_recursion || !self.active.contains(&key),
            "recursive template specialization repeats at {id}; \
             recursion needs a statically resolvable terminating base case"
        );
        if let Some(name) = self.specializations.get(&key) {
            return Ok(name.clone());
        }
        let recursive = resolve_recursion && self.active.iter().any(|(name, _, _)| name == id);
        ensure!(
            !recursive || self.recursive_depth < MAX_RECURSIVE_DEPTH,
            "recursive template specialization depth limit ({MAX_RECURSIVE_DEPTH}) exceeded at {id}"
        );
        self.recursive_depth += usize::from(recursive);
        self.active.insert(key.clone());
        let old = self.originals[id].clone();
        ensure!(
            old.get_name_of_params().len() == parameter_shapes.len(),
            "incorrect parameter count for template {id}"
        );
        let mut name = id.to_owned();
        if parameter_shapes.iter().any(Option::is_some) {
            name.push_str("$arrays");
            for (position, shape) in parameter_shapes.iter().enumerate() {
                if let Some(shape) = shape {
                    name.push_str(&format!("${position}"));
                    for dimension in shape {
                        name.push_str(&format!("_{dimension}"));
                    }
                }
            }
        }
        if parameter_values.iter().any(Option::is_some) {
            name.push_str("$values");
            for (position, value) in parameter_values.iter().enumerate() {
                if let Some(value) = value {
                    name.push_str(&format!("${position}_{value}"));
                }
            }
        }
        ensure!(
            name == id || !self.originals.contains_key(&name),
            "template specialization name collision: {name}"
        );
        self.specializations.insert(key.clone(), name.clone());
        let mut params = Vec::new();
        let mut prefix = Vec::new();
        let mut shapes = Shapes::new();
        let mut constants = Constants::new();
        let meta = old.get_body().get_meta();
        for ((formal, shape), value) in
            old.get_name_of_params().iter().zip(parameter_shapes).zip(parameter_values)
        {
            shapes.insert(formal.clone(), Some(shape.clone().unwrap_or_default()));
            if let Some(shape) = shape {
                let scalar_names = (0..element_count(shape)?)
                    .map(|element| format!("$array${formal}${element}"))
                    .collect::<Vec<_>>();
                prefix.push(Statement::Declaration {
                    meta: meta.clone(),
                    xtype: VariableType::Var,
                    name: formal.clone(),
                    dimensions: shape
                        .iter()
                        .map(|dimension| Expression::Number(meta.clone(), (*dimension).into()))
                        .collect(),
                    is_constant: false,
                    is_anonymous: false,
                });
                prefix.push(Statement::Substitution {
                    meta: meta.clone(),
                    var: formal.clone(),
                    access: vec![],
                    op: AssignOp::AssignVar,
                    rhe: array_initializer(meta, shape, &mut scalar_names.iter()),
                });
                params.extend(scalar_names);
            } else if let Some(value) = value {
                // Keep a mutable local for the original formal, but remove the fixed value
                // from the generated signature so callers cannot override the specialization.
                constants.insert(formal.clone(), value.clone());
                prefix.push(Statement::Declaration {
                    meta: meta.clone(),
                    xtype: VariableType::Var,
                    name: formal.clone(),
                    dimensions: vec![],
                    is_constant: false,
                    is_anonymous: false,
                });
                prefix.push(Statement::Substitution {
                    meta: meta.clone(),
                    var: formal.clone(),
                    access: vec![],
                    op: AssignOp::AssignVar,
                    rhe: Expression::Number(meta.clone(), value.clone().into()),
                });
            } else {
                params.push(formal.clone());
            }
        }
        let mut body = old.get_body().clone();
        self.statement(&mut body, &mut shapes, &mut constants, resolve_recursion)?;
        let Statement::Block { stmts, .. } = &mut body else {
            anyhow::bail!("template {id} body is not a block");
        };
        prefix.append(stmts);
        *stmts = prefix;
        // Recollect wire metadata and declaration order after pruning resolved branches.
        let template = TemplateData::new(
            name.clone(),
            old.get_file_id(),
            body,
            params.len(),
            params,
            old.get_param_location(),
            &mut self.next_elem_id,
            old.is_parallel(),
            old.is_custom_gate(),
            old.is_extern_c(),
        );
        self.templates.insert(name.clone(), template);
        self.active.remove(&key);
        self.recursive_depth -= usize::from(recursive);
        Ok(name)
    }

    /// Track declaration shapes while rewriting constructors without leaking nested bindings.
    fn statement(
        &mut self,
        stmt: &mut Statement,
        shapes: &mut Shapes,
        constants: &mut Constants,
        resolve_recursion: bool,
    ) -> Result<()> {
        match stmt {
            Statement::Block { stmts, .. } => {
                let mut nested = shapes.clone();
                let mut nested_constants = constants.clone();
                let mut shadowed = HashMap::new();
                for stmt in stmts {
                    let mut declarations = HashSet::new();
                    local_declarations(stmt, &mut declarations);
                    for name in declarations {
                        // A block may write an outer variable before declaring a shadow.
                        // Save its value at the declaration, not at entry to the block.
                        shadowed
                            .entry(name.clone())
                            .or_insert_with(|| nested_constants.get(&name).cloned());
                    }
                    self.statement(stmt, &mut nested, &mut nested_constants, resolve_recursion)?;
                }
                // Preserve assignments to enclosing bindings without leaking local shadows.
                for name in shapes.keys() {
                    let value = match shadowed.get(name) {
                        Some(value) => value.as_ref(),
                        None => nested_constants.get(name),
                    };
                    if let Some(value) = value {
                        constants.insert(name.clone(), value.clone());
                    } else {
                        constants.remove(name);
                    }
                }
            }
            Statement::InitializationBlock { initializations, .. } => {
                for stmt in initializations {
                    self.statement(stmt, shapes, constants, resolve_recursion)?;
                }
            }
            Statement::Declaration { name, xtype, dimensions, .. } => {
                let shape = if *xtype == VariableType::Var {
                    dimensions
                        .iter()
                        .map(|dimension| {
                            Ok(crate::shared::try_compute_as_i64(dimension, self.prime)?
                                .and_then(|n| usize::try_from(n).ok()))
                        })
                        .collect::<Result<Option<Vec<_>>>>()?
                } else {
                    None
                };
                shapes.insert(name.clone(), shape);
                constants.remove(name);
            }
            Statement::Substitution { var, access, op, rhe, .. } => {
                self.call(rhe, shapes, constants)?;
                if resolve_recursion && *op == AssignOp::AssignVar {
                    let value = if access.is_empty() {
                        template_recursion::value(rhe, constants, self.prime, self.functions)?
                    } else {
                        None
                    };
                    if let Some(value) = value {
                        constants.insert(var.clone(), value);
                    } else {
                        constants.remove(var);
                    }
                }
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                let condition = if resolve_recursion {
                    template_recursion::value(cond, constants, self.prime, self.functions)?
                } else {
                    None
                };
                if let Some(condition) = condition {
                    let selected = if !condition.is_zero() {
                        Some(*if_case.clone())
                    } else {
                        else_case.as_deref().cloned()
                    };
                    // An if branch introduces a scope even without explicit braces.
                    *stmt = Statement::Block {
                        meta: meta.clone(),
                        stmts: selected.into_iter().collect(),
                    };
                    self.statement(stmt, shapes, constants, resolve_recursion)?;
                } else {
                    let mut then_constants = constants.clone();
                    let mut else_constants = constants.clone();
                    self.statement(
                        if_case,
                        &mut shapes.clone(),
                        &mut then_constants,
                        resolve_recursion,
                    )?;
                    if let Some(stmt) = else_case {
                        self.statement(
                            stmt,
                            &mut shapes.clone(),
                            &mut else_constants,
                            resolve_recursion,
                        )?;
                    }
                    constants.retain(|name, value| {
                        then_constants.get(name) == Some(value)
                            && else_constants.get(name) == Some(value)
                    });
                }
            }
            Statement::While { meta, cond, stmt: body } => {
                // A loop that cannot run neither writes bindings nor creates children.
                if resolve_recursion
                    && template_recursion::value(cond, constants, self.prime, self.functions)?
                        .is_some_and(|condition| condition.is_zero())
                {
                    *stmt = Statement::Block { meta: meta.clone(), stmts: vec![] };
                    return Ok(());
                }
                // The body can execute more than once. Never specialize calls using a
                // value that is only known before the first iteration.
                invalidate_writes(body, constants, &mut HashSet::new());
                self.statement(
                    body,
                    &mut shapes.clone(),
                    &mut constants.clone(),
                    resolve_recursion,
                )?;
            }
            _ => {}
        }
        Ok(())
    }
}

/// Collect declarations in this lexical scope (initialization groups do not open a scope).
fn local_declarations(stmt: &Statement, names: &mut HashSet<String>) {
    match stmt {
        Statement::Declaration { name, .. } => {
            names.insert(name.clone());
        }
        Statement::InitializationBlock { initializations, .. } => {
            for stmt in initializations {
                local_declarations(stmt, names);
            }
        }
        _ => {}
    }
}

/// Conservatively forget enclosing bindings written on any path through a loop.
fn invalidate_writes(stmt: &Statement, constants: &mut Constants, locals: &mut HashSet<String>) {
    match stmt {
        Statement::Declaration { name, .. } => {
            locals.insert(name.clone());
        }
        Statement::Substitution { var, op: AssignOp::AssignVar, .. } => {
            if !locals.contains(var) {
                constants.remove(var);
            }
        }
        Statement::Block { stmts, .. } => {
            let mut nested = locals.clone();
            for stmt in stmts {
                invalidate_writes(stmt, constants, &mut nested);
            }
        }
        Statement::InitializationBlock { initializations, .. } => {
            for stmt in initializations {
                invalidate_writes(stmt, constants, locals);
            }
        }
        Statement::IfThenElse { if_case, else_case, .. } => {
            invalidate_writes(if_case, constants, &mut locals.clone());
            if let Some(stmt) = else_case {
                invalidate_writes(stmt, constants, &mut locals.clone());
            }
        }
        Statement::While { stmt, .. } => {
            invalidate_writes(stmt, constants, &mut locals.clone());
        }
        _ => {}
    }
}

/// Select an element of a known-shape argument in the caller's scope.
fn array_element(expr: &Expression, indices: &[usize]) -> Result<Expression> {
    let Some((index, rest)) = indices.split_first() else {
        return Ok(expr.clone());
    };
    match expr {
        Expression::Variable { meta, name, access } => {
            let mut access = access.clone();
            access.extend(indices.iter().map(|index| {
                Access::ArrayAccess(Expression::Number(meta.clone(), (*index).into()))
            }));
            Ok(Expression::Variable { meta: meta.clone(), name: name.clone(), access })
        }
        Expression::ArrayInLine { values, .. } => {
            let value = values.get(*index).ok_or_else(|| {
                anyhow::anyhow!("array template argument index {index} is out of bounds")
            })?;
            array_element(value, rest)
        }
        Expression::UniformArray { value, .. } => array_element(value, rest),
        Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
            Ok(Expression::InlineSwitchOp {
                meta: meta.clone(),
                cond: cond.clone(),
                if_true: Box::new(array_element(if_true, indices)?),
                if_false: Box::new(array_element(if_false, indices)?),
            })
        }
        _ => anyhow::bail!("cannot index array template argument"),
    }
}

/// Count elements without materializing coordinates, preserving zero-sized dimensions.
fn element_count(shape: &[usize]) -> Result<usize> {
    if shape.contains(&0) {
        return Ok(0);
    }
    shape
        .iter()
        .try_fold(1usize, |size, dimension| size.checked_mul(*dimension))
        .ok_or_else(|| anyhow::anyhow!("array template parameter size overflow"))
}

/// Enumerate row-major coordinates, checking the size before materializing parameters.
fn indices(shape: &[usize]) -> Result<Vec<Vec<usize>>> {
    if element_count(shape)? == 0 {
        return Ok(vec![]);
    }
    let mut indices = vec![vec![]];
    for dimension in shape {
        indices = indices
            .into_iter()
            .flat_map(|prefix| {
                (0..*dimension).map(move |index| {
                    let mut indices = prefix.clone();
                    indices.push(index);
                    indices
                })
            })
            .collect();
    }
    Ok(indices)
}

/// Reconstruct an array from row-major scalar parameters, preserving zero-sized dimensions.
fn array_initializer<'a>(
    meta: &Meta,
    shape: &[usize],
    names: &mut impl Iterator<Item = &'a String>,
) -> Expression {
    let Some((dimension, rest)) = shape.split_first() else {
        return Expression::Variable {
            meta: meta.clone(),
            name: names.next().expect("one parameter per array element").clone(),
            access: vec![],
        };
    };
    if *dimension == 0 {
        let zero =
            rest.iter().rev().fold(Expression::Number(meta.clone(), 0.into()), |value, dim| {
                Expression::UniformArray {
                    meta: meta.clone(),
                    value: Box::new(value),
                    dimension: Box::new(Expression::Number(meta.clone(), (*dim).into())),
                }
            });
        return Expression::UniformArray {
            meta: meta.clone(),
            value: Box::new(zero),
            dimension: Box::new(Expression::Number(meta.clone(), 0.into())),
        };
    }
    Expression::ArrayInLine {
        meta: meta.clone(),
        values: (0..*dimension).map(|_| array_initializer(meta, rest, names)).collect(),
    }
}
