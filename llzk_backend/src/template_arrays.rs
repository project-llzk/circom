//! Represent fixed-shape array template parameters using scalar LLZK parameters.

use std::collections::{HashMap, HashSet};
use std::convert::TryFrom;

use anyhow::{ensure, Result};
use num_bigint_dig::BigUint;
use num_traits::{ToPrimitive, Zero};
use program_structure::{
    ast::{Access, AssignOp, Expression, ExpressionInfixOpcode, Meta, Statement, VariableType},
    function_data::FunctionInfo,
    program_archive::ProgramArchive,
    template_data::TemplateData,
};

use crate::template_recursion::{self, ConstantValue, Constants};

/// Lexically visible variable shapes; `None` means the shape is not statically known.
type Shapes = HashMap<String, Option<Vec<usize>>>;
/// Original template name, array shapes, and bound values in formal parameter order.
type Specialization = (String, Vec<Option<Vec<usize>>>, Vec<Option<ConstantValue>>);

/// Bound expansion before nonterminating recursion can exhaust the compiler's stack.
const MAX_RECURSIVE_DEPTH: usize = 128;
/// Bound speculative loop expansion, including nested iterations.
const MAX_LOOP_STEPS: usize = 10_000;

/// Stop speculative unrolling when a condition or its finite iteration count is unknown.
#[derive(Debug)]
struct UnresolvedLoop;

impl std::fmt::Display for UnresolvedLoop {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(formatter, "loop cannot be statically unrolled within the expansion budget")
    }
}

impl std::error::Error for UnresolvedLoop {}

/// Request a fresh preparation with values bound along this recursive call path.
#[derive(Debug)]
struct ExpandRecursion(String);

impl std::fmt::Display for ExpandRecursion {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(formatter, "array recursion requires specialization of {}", self.0)
    }
}

impl std::error::Error for ExpandRecursion {}

/// Retry unresolved recursion with known array contents included in specialization keys.
#[derive(Debug)]
struct BindArrayValues(String);

impl std::fmt::Display for BindArrayValues {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(formatter, "array recursion requires constant array arguments for {}", self.0)
    }
}

impl std::error::Error for BindArrayValues {}

/// Scalarize after layout parameters have been forwarded: reconstructed array locals must
/// retain their original names so bus dimensions still find their `$layout$` aliases.
pub(crate) fn prepare(program: ProgramArchive, prime: &BigUint) -> Result<ProgramArchive> {
    prepare_phase(program, prime, false)
}

/// Give metadata analysis a finite callee graph without removing the original formals:
/// tag summaries and derived bus dimensions still need their symbolic parameter names.
pub(crate) fn prepare_recursion(
    program: ProgramArchive,
    prime: &BigUint,
) -> Result<ProgramArchive> {
    if !template_recursion::has_recursion(&program.templates) {
        return Ok(program);
    }
    prepare_phase(program, prime, true)
}

fn prepare_phase(
    mut program: ProgramArchive,
    prime: &BigUint,
    preserve_formals: bool,
) -> Result<ProgramArchive> {
    let mut expanded = HashSet::new();
    let mut bound_arrays = HashSet::new();
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
            bound_arrays: &bound_arrays,
            next_elem_id: program.id_max,
            loop_budget: None,
            preserve_formals,
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
                } else if let Some(BindArrayValues(id)) = error.downcast_ref::<BindArrayValues>() {
                    // Keep array payloads parameterized when scalar bindings suffice. Only
                    // retry the unresolved recursive chain and callers that supply its values.
                    bound_arrays.extend(template_recursion::callers_of(&program.templates, id));
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
    /// Reuse definitions with equal shapes and recursion-controlling bindings.
    specializations: HashMap<Specialization, String>,
    /// Incomplete expanded specializations must not be reused as circular struct members.
    active: HashSet<Specialization>,
    /// Active reentries into a template, excluding first visits through acyclic callers.
    recursive_depth: usize,
    /// Array recursion and its callers need scalar bindings to resolve a finite child graph.
    expanded: &'a HashSet<String>,
    /// Bind known array contents only when scalar expansion could not resolve recursion.
    bound_arrays: &'a HashSet<String>,
    /// Fresh AST IDs for rebuilt templates, starting after the original program's IDs.
    next_elem_id: usize,
    /// Speculative loop expansion defers constructors and shares one budget across nested loops.
    loop_budget: Option<usize>,
    /// Expand recursion before tag analysis, deferring argument lowering until afterwards.
    preserve_formals: bool,
}

impl Preparation<'_> {
    /// Resolve dimensions using the scalar bindings available at this point in the caller.
    fn dimension(&self, expr: &Expression, constants: &Constants) -> Result<Option<usize>> {
        Ok(template_recursion::value(expr, constants, self.prime, self.functions)?
            .and_then(|value| value.to_i64())
            .and_then(|value| usize::try_from(value).ok()))
    }

    /// Give synthesized array initializers the fixed dimensions of their declarations.
    fn bind_uniform_dimensions(&self, expr: &mut Expression, constants: &Constants) -> Result<()> {
        if let Expression::UniformArray { value, dimension, .. } = expr {
            if let Some(length) = self.dimension(dimension, constants)? {
                **dimension = Expression::Number(dimension.get_meta().clone(), length.into());
            }
            self.bind_uniform_dimensions(value, constants)?;
        }
        Ok(())
    }

    /// Return a statically known shape; an empty shape denotes a scalar.
    fn shape(
        &self,
        expr: &Expression,
        shapes: &Shapes,
        constants: &Constants,
    ) -> Result<Option<Vec<usize>>> {
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
                    let Some(shape) = self.shape(value, shapes, constants)? else {
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
                let length = self.dimension(dimension, constants)?;
                length
                    .zip(self.shape(value, shapes, constants)?)
                    .map(|(length, element)| std::iter::once(length).chain(element).collect())
            }
            Expression::InlineSwitchOp { if_true, if_false, .. } => {
                let first = self.shape(if_true, shapes, constants)?;
                (first == self.shape(if_false, shapes, constants)?).then_some(first).flatten()
            }
            Expression::Call { id, args, .. } if id == crate::bus::ARRAY_ACCESS => self
                .shape(&args[0], shapes, constants)?
                .and_then(|shape| shape.get(args.len() - 1..).map(<[usize]>::to_vec)),
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
            .map(|arg| Ok(self.shape(arg, shapes, constants)?.filter(|shape| !shape.is_empty())))
            .collect::<Result<Vec<_>>>()?;
        if !self.expanded.contains(id)
            && self.active.iter().any(|(active_id, active_shapes, _)| {
                active_id == id
                    && (self.preserve_formals
                        || parameter_shapes.iter().any(Option::is_some)
                        || active_shapes.iter().any(Option::is_some))
            })
        {
            return Err(ExpandRecursion(id.clone()).into());
        }
        let parameter_values = args
            .iter()
            .zip(&parameter_shapes)
            .map(|(arg, shape)| {
                if !self.expanded.contains(id) {
                    Ok(None)
                } else if shape.is_none() {
                    Ok(template_recursion::value(arg, constants, self.prime, self.functions)?
                        .map(ConstantValue::from))
                } else if self.bound_arrays.contains(id) {
                    template_recursion::known_value(arg, constants, self.prime, self.functions)
                } else {
                    Ok(None)
                }
            })
            .collect::<Result<Vec<_>>>()?;
        let name = self.specialize(id, &parameter_shapes, &parameter_values)?;
        if self.preserve_formals {
            *id = name;
            return Ok(());
        }
        let mut scalar_args = Vec::new();
        for ((arg, shape), value) in args.iter().zip(&parameter_shapes).zip(&parameter_values) {
            if value.is_some() {
                continue;
            }
            if let Some(shape) = shape {
                for indices in indices(shape)? {
                    scalar_args.push(array_element(arg, &indices)?);
                }
            } else {
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
        parameter_values: &[Option<ConstantValue>],
    ) -> Result<String> {
        let key = (id.to_owned(), parameter_shapes.to_vec(), parameter_values.to_vec());
        let resolve_recursion = self.expanded.contains(id);
        if resolve_recursion && self.active.contains(&key) && !self.bound_arrays.contains(id) {
            return Err(BindArrayValues(id.to_owned()).into());
        }
        ensure!(
            !resolve_recursion || !self.active.contains(&key),
            "recursive template specialization repeats at {id}; \
             recursion needs a statically resolvable terminating base case"
        );
        if let Some(name) = self.specializations.get(&key) {
            return Ok(name.clone());
        }
        let recursive = resolve_recursion && self.active.iter().any(|(name, _, _)| name == id);
        if recursive
            && self.recursive_depth >= MAX_RECURSIVE_DEPTH
            && !self.bound_arrays.contains(id)
        {
            return Err(BindArrayValues(id.to_owned()).into());
        }
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
            name.push_str(if self.preserve_formals { "$shapes" } else { "$arrays" });
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
                match value {
                    Some(ConstantValue::Scalar(value)) => {
                        name.push_str(&format!("${position}_{value}"));
                    }
                    Some(value @ ConstantValue::Array(_)) => {
                        let shape = parameter_shapes[position].as_deref().ok_or_else(|| {
                            anyhow::anyhow!("constant array argument has no known shape")
                        })?;
                        name.push_str(&format!("${position}_array"));
                        for scalar in array_scalars(value, shape)? {
                            name.push_str(&format!("_{scalar}"));
                        }
                    }
                    None => {}
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
            if self.preserve_formals {
                params.push(formal.clone());
                if let Some(value) = value {
                    constants.insert(formal.clone(), value.clone());
                }
                continue;
            }
            if let Some(shape) = shape {
                let elements = if let Some(value) = value {
                    let elements = array_scalars(value, shape)?
                        .into_iter()
                        .map(|value| Expression::Number(meta.clone(), value.clone().into()))
                        .collect::<Vec<_>>();
                    constants.insert(formal.clone(), value.clone());
                    elements
                } else {
                    let scalar_names = (0..element_count(shape)?)
                        .map(|element| format!("$array${formal}${element}"))
                        .collect::<Vec<_>>();
                    let elements = scalar_names
                        .iter()
                        .map(|name| Expression::Variable {
                            meta: meta.clone(),
                            name: name.clone(),
                            access: vec![],
                        })
                        .collect::<Vec<_>>();
                    params.extend(scalar_names);
                    elements
                };
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
                    rhe: array_initializer(meta, shape, &mut elements.into_iter())?,
                });
            } else if let Some(ConstantValue::Scalar(value)) = value {
                // Keep a mutable local for the original formal, but remove the fixed value
                // from the generated signature so callers cannot override the specialization.
                constants.insert(formal.clone(), value.clone().into());
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
        mut stmt: &mut Statement,
        shapes: &mut Shapes,
        constants: &mut Constants,
        resolve_recursion: bool,
    ) -> Result<()> {
        loop {
            if let Some(remaining) = &mut self.loop_budget {
                if *remaining == 0 {
                    return Err(UnresolvedLoop.into());
                }
                *remaining -= 1;
            }
            match stmt {
                Statement::Block { stmts, .. } => {
                    // These single statements already preserve enclosing bindings; keep the AST
                    // scopes but avoid another walker frame for each synthetic loop wrapper.
                    if stmts.len() == 1
                        && matches!(
                            &stmts[0],
                            Statement::Block { .. } | Statement::Substitution { .. }
                        )
                    {
                        stmt = &mut stmts[0];
                        continue;
                    }
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
                        self.statement(
                            stmt,
                            &mut nested,
                            &mut nested_constants,
                            resolve_recursion,
                        )?;
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
                            .iter_mut()
                            .map(|dimension| {
                                if resolve_recursion {
                                    let length = self.dimension(dimension, constants)?;
                                    if let Some(length) = length {
                                        *dimension = Expression::Number(
                                            dimension.get_meta().clone(),
                                            length.into(),
                                        );
                                    }
                                    Ok(length)
                                } else {
                                    Ok(crate::shared::try_compute_as_i64(dimension, self.prime)?
                                        .and_then(|n| usize::try_from(n).ok()))
                                }
                            })
                            .collect::<Result<Option<Vec<_>>>>()?
                    } else {
                        None
                    };
                    shapes.insert(name.clone(), shape);
                    constants.remove(name);
                }
                Statement::Substitution { var, access, op, rhe, .. } => {
                    if resolve_recursion {
                        self.bind_uniform_dimensions(rhe, constants)?;
                    }
                    if self.loop_budget.is_none() {
                        self.call(rhe, shapes, constants)?;
                    }
                    if resolve_recursion && *op == AssignOp::AssignVar {
                        template_recursion::assign(
                            var,
                            access,
                            rhe,
                            constants,
                            self.prime,
                            self.functions,
                        )?;
                    }
                }
                Statement::Assert {
                    meta,
                    arg: Expression::InfixOp { infix_op: ExpressionInfixOpcode::Eq, lhe, rhe, .. },
                } => {
                    // Tag analysis can inject equality between array-valued bus parameters
                    // before their shapes are known. LLZK comparisons require scalar operands.
                    let lhs = self.shape(lhe, shapes, constants)?;
                    let rhs = self.shape(rhe, shapes, constants)?;
                    if lhs.as_ref().is_some_and(|shape| !shape.is_empty())
                        || rhs.as_ref().is_some_and(|shape| !shape.is_empty())
                    {
                        ensure!(
                            lhs == rhs,
                            "incompatible array shapes for bus parameters: {lhs:?} and {rhs:?}"
                        );
                        let stmts = indices(lhs.as_ref().expect("known array shape"))?
                            .iter()
                            .map(|indices| {
                                Ok(Statement::Assert {
                                    meta: meta.clone(),
                                    arg: Expression::InfixOp {
                                        meta: meta.clone(),
                                        infix_op: ExpressionInfixOpcode::Eq,
                                        lhe: Box::new(array_element(lhe, indices)?),
                                        rhe: Box::new(array_element(rhe, indices)?),
                                    },
                                })
                            })
                            .collect::<Result<Vec<_>>>()?;
                        *stmt = Statement::Block { meta: meta.clone(), stmts };
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
                        continue;
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
                        // Both paths can establish a new constant for an enclosing binding.
                        then_constants.retain(|name, value| {
                            shapes.contains_key(name) && else_constants.get(name) == Some(value)
                        });
                        *constants = then_constants;
                    }
                }
                Statement::While { .. } => {
                    if !self.while_statement(stmt, shapes, constants, resolve_recursion)? {
                        return Ok(());
                    }
                    continue;
                }
                _ => {}
            }
            return Ok(());
        }
    }

    /// Return whether the expanded loop needs replay after its temporary ASTs leave the stack.
    #[inline(never)]
    fn while_statement(
        &mut self,
        stmt: &mut Statement,
        shapes: &mut Shapes,
        constants: &mut Constants,
        resolve_recursion: bool,
    ) -> Result<bool> {
        let Statement::While { meta, cond, stmt: body } = stmt else {
            unreachable!("loop handling requires a while statement");
        };
        if resolve_recursion {
            if self.loop_budget.is_some() {
                let mut iterations = Vec::new();
                loop {
                    let Some(condition) =
                        template_recursion::value(cond, constants, self.prime, self.functions)?
                    else {
                        return Err(UnresolvedLoop.into());
                    };
                    if condition.is_zero() {
                        break;
                    }
                    let mut iteration = Statement::Block {
                        meta: body.get_meta().clone(),
                        stmts: vec![*body.clone()],
                    };
                    self.statement(&mut iteration, &mut shapes.clone(), constants, true)?;
                    iterations.push(iteration);
                }
                *stmt = Statement::Block { meta: meta.clone(), stmts: iterations };
                return Ok(false);
            }

            // Prove termination and expand nested loops before specializing any calls.
            // Failed probes leave both the original AST and specialization state intact.
            let mut expanded =
                Statement::While { meta: meta.clone(), cond: cond.clone(), stmt: body.clone() };
            self.loop_budget = Some(MAX_LOOP_STEPS);
            let result =
                self.statement(&mut expanded, &mut shapes.clone(), &mut constants.clone(), true);
            self.loop_budget = None;
            match result {
                Ok(()) => {
                    *stmt = expanded;
                    return Ok(true);
                }
                Err(error) if error.is::<UnresolvedLoop>() => {}
                Err(error) => return Err(error),
            }
        }
        // The body can execute more than once. Never specialize calls using a
        // value that is only known before the first iteration.
        invalidate_writes(body, constants, &mut HashSet::new());
        self.statement(body, &mut shapes.clone(), &mut constants.clone(), resolve_recursion)?;
        Ok(false)
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
        Expression::Call { id, .. } if id == crate::bus::ARRAY_ACCESS => {
            let indices = indices
                .iter()
                .map(|index| Expression::Number(expr.get_meta().clone(), (*index).into()))
                .collect::<Vec<_>>();
            Ok(crate::bus::index_expression(expr, &indices))
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

/// Flatten a constant array after checking its declared shape, including empty dimensions.
fn array_scalars<'a>(value: &'a ConstantValue, shape: &[usize]) -> Result<Vec<&'a BigUint>> {
    match (value, shape.split_first()) {
        (ConstantValue::Scalar(value), None) => Ok(vec![value]),
        (ConstantValue::Array(values), Some((dimension, rest))) if values.len() == *dimension => {
            let mut scalars = Vec::new();
            for value in values {
                scalars.extend(array_scalars(value, rest)?);
            }
            Ok(scalars)
        }
        _ => anyhow::bail!("constant array argument does not match its known shape"),
    }
}

/// Reconstruct an array from row-major scalar expressions, preserving zero-sized dimensions.
fn array_initializer(
    meta: &Meta,
    shape: &[usize],
    elements: &mut impl Iterator<Item = Expression>,
) -> Result<Expression> {
    let Some((dimension, rest)) = shape.split_first() else {
        return elements.next().ok_or_else(|| anyhow::anyhow!("missing constant array element"));
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
        return Ok(Expression::UniformArray {
            meta: meta.clone(),
            value: Box::new(zero),
            dimension: Box::new(Expression::Number(meta.clone(), 0.into())),
        });
    }
    Ok(Expression::ArrayInLine {
        meta: meta.clone(),
        values: (0..*dimension)
            .map(|_| array_initializer(meta, rest, elements))
            .collect::<Result<_>>()?,
    })
}
