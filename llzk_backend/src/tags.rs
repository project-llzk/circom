//! Compile-time tag analysis for the symbolic pipeline. Tags never become signal fields.

use anyhow::{anyhow, ensure, Context, Result};
use num_bigint_dig::BigUint;
use program_structure::{
    ast::{
        Access, AssignOp, Expression, ExpressionInfixOpcode, LogArgument, Meta, SignalType,
        Statement, VariableType,
    },
    program_archive::ProgramArchive,
    template_data::TemplateData,
};
use std::collections::{BTreeMap, HashMap, HashSet};
use std::convert::TryFrom;

/// Nominal identity remains independent of the structural POD representation.
#[derive(Clone, Debug)]
struct NominalBus {
    /// Bus definition name.
    definition: String,
    /// Constructor arguments in the enclosing template's scope.
    arguments: Vec<Expression>,
}

/// A tag's declaration, optional value, and assignment state.
#[derive(Clone, Debug)]
struct Tag {
    /// User-declared tags survive propagation with an unknown value.
    declared: bool,
    /// Explicit values take precedence over propagated values.
    explicit: bool,
    /// Optional compile-time value.
    value: Option<Expression>,
    /// Whether propagation has already initialized this tag.
    initialized: bool,
}

/// Summary consumed at component call sites before generating any types.
#[derive(Clone, Debug)]
struct Summary {
    /// Nominal identities of bus interfaces and their nested fields.
    buses: BTreeMap<String, NominalBus>,
    /// Source parameters, before adding tag parameters.
    params: Vec<String>,
    /// Required input tags and their additional compile-time parameter names.
    inputs: BTreeMap<String, String>,
    /// Input tag values that are actually read by the template.
    required_values: HashSet<String>,
    /// Derived output tags, including unknown values.
    outputs: BTreeMap<String, Tag>,
    /// Body with tag reads lowered and metadata assignments removed.
    body: Statement,
}

/// A component call whose tag parameters are determined by its input assignments.
#[derive(Clone, Debug)]
struct Component {
    /// Constructor location used by validation diagnostics.
    source: Meta,
    /// Template summary.
    summary: Summary,
    /// Ordinary arguments in caller scope.
    args: Vec<Expression>,
    /// Constructor source position for rewriting the call.
    position: usize,
}

/// Analysis state for one template.
struct Analysis<'a> {
    /// Program definitions.
    program: &'a ProgramArchive,
    /// Prime used to compare known tag expressions.
    prime: &'a BigUint,
    /// Available callee summaries.
    summaries: &'a HashMap<String, Summary>,
    /// Compile-time template parameters, including lowered input tags.
    params: Vec<String>,
    /// Tags indexed by component instance and array-wide field paths.
    tags: BTreeMap<String, Tag>,
    /// Bus paths, to distinguish bus-copy propagation from scalar assignment rules.
    buses: HashSet<String>,
    /// Initialized signal paths.
    initialized: HashSet<String>,
    /// Input tag parameter names.
    inputs: BTreeMap<String, String>,
    /// Input values used by metadata expressions.
    required: HashSet<String>,
    /// Component variable roots, whose indices distinguish metadata instances.
    component_roots: HashSet<String>,
    /// Component instances keyed by their indexed paths.
    components: HashMap<String, Component>,
    /// Nominal bus identities, including nested fields and component interfaces.
    identities: BTreeMap<String, NominalBus>,
    /// Known scalar-leaf capacities and remaining assignments for array-wide tags.
    capacities: BTreeMap<String, (Vec<usize>, usize, usize)>,
    /// Known local scalar values, used only to determine fixed loop trip counts.
    constants: HashMap<String, Expression>,
}

/// Whether a path is contained in a subtree.
fn below(path: &str, parent: &str) -> bool {
    path == parent || path.starts_with(&format!("{parent}."))
}

/// Source location for metadata diagnostics emitted before LLZK exists.
fn source_location(program: &ProgramArchive, meta: &Meta) -> String {
    let files = &program.file_library;
    let file = meta.get_file_id();
    format!(
        "{}:{}:{}",
        files.get_filename_or_default(&file),
        files.get_line(meta.start, file).unwrap_or(0),
        files.get_column(meta.start, file).unwrap_or(0)
    )
}

/// Visit every nested statement.
fn statements<'a>(stmt: &'a Statement, out: &mut Vec<&'a Statement>) {
    out.push(stmt);
    match stmt {
        Statement::Block { stmts, .. }
        | Statement::InitializationBlock { initializations: stmts, .. } => {
            for stmt in stmts {
                statements(stmt, out);
            }
        }
        Statement::IfThenElse { if_case, else_case, .. } => {
            statements(if_case, out);
            if let Some(stmt) = else_case {
                statements(stmt, out);
            }
        }
        Statement::While { stmt, .. } => statements(stmt, out),
        _ => {}
    }
}

/// Inspect a constructor beneath any parallel annotations, preserving the AST wrappers.
fn unwrap_parallel(expr: &Expression) -> &Expression {
    match expr {
        Expression::ParallelOp { rhe, .. } => unwrap_parallel(rhe),
        _ => expr,
    }
}

/// Rewrite a constructor beneath any parallel annotations, preserving the AST wrappers.
fn unwrap_parallel_mut(expr: &mut Expression) -> &mut Expression {
    match expr {
        Expression::ParallelOp { rhe, .. } => unwrap_parallel_mut(rhe),
        _ => expr,
    }
}

/// Whether an expression can be represented using only compile-time parameters.
fn depends_only_on(expr: &Expression, params: &[String]) -> bool {
    match expr {
        Expression::Number(..) => true,
        Expression::Variable { name, access, .. } => access.is_empty() && params.contains(name),
        Expression::InfixOp { lhe, rhe, .. } => {
            depends_only_on(lhe, params) && depends_only_on(rhe, params)
        }
        Expression::PrefixOp { rhe, .. } => depends_only_on(rhe, params),
        Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
            depends_only_on(cond, params)
                && depends_only_on(if_true, params)
                && depends_only_on(if_false, params)
        }
        _ => false,
    }
}

impl Analysis<'_> {
    /// Preserve component indices, but keep signal and bus tags array-wide.
    fn path(&self, name: &str, access: &[Access]) -> Result<String> {
        let mut path = name.to_owned();
        let mut component = self.component_roots.contains(name);
        for access in access {
            match access {
                Access::ComponentAccess(field) => {
                    component = false;
                    path.push('.');
                    path.push_str(field);
                }
                Access::ArrayAccess(index) if component => {
                    let index = self.normalize(index.clone())?;
                    path.push_str(&format!("[{}]", crate::bus::expression_key(&index)));
                }
                Access::ArrayAccess(_) => {}
            }
        }
        Ok(path)
    }

    /// Populate declared tags, recursively including bus fields in their source order.
    fn declare(
        &mut self,
        name: &str,
        xtype: &VariableType,
        input: bool,
        meta: &Meta,
        arguments: &[Expression],
        dimensions: &[Expression],
        parent_dimensions: Option<&[usize]>,
    ) -> Result<Option<usize>> {
        let tags = match xtype {
            VariableType::Signal(_, tags) | VariableType::Bus(_, _, tags) => tags,
            VariableType::Component | VariableType::AnonymousComponent => {
                self.component_roots.insert(name.to_owned());
                return Ok(Some(0));
            }
            _ => return Ok(Some(0)),
        };
        let dimensions = dimensions
            .iter()
            .map(|dim| {
                crate::shared::try_compute_as_i64(dim, self.prime)
                    .ok()
                    .flatten()
                    .and_then(|n| usize::try_from(n).ok())
            })
            .collect::<Option<Vec<_>>>();
        let all_dimensions = parent_dimensions
            .zip(dimensions.as_ref())
            .map(|(parent, dims)| parent.iter().chain(dims).copied().collect::<Vec<_>>());
        let mut leaves = Some(1usize);
        for tag in tags {
            let key = format!("{name}.{tag}");
            let value = if input {
                let param = format!("$tag${}", key.replace('.', "$"));
                self.inputs.insert(key.clone(), param.clone());
                self.params.push(param.clone());
                Some(Expression::Variable { meta: meta.clone(), name: param, access: vec![] })
            } else {
                None
            };
            self.tags
                .insert(key, Tag { declared: true, explicit: input, value, initialized: input });
        }
        if let VariableType::Bus(bus, ..) = xtype {
            leaves = Some(0usize);
            self.buses.insert(name.to_owned());
            self.identities.insert(
                name.to_owned(),
                NominalBus { definition: bus.clone(), arguments: arguments.to_vec() },
            );
            let bus = self.program.buses.get(bus).ok_or_else(|| anyhow!("unknown bus {bus}"))?;
            let bindings =
                bus.get_name_of_params().iter().cloned().zip(arguments.iter().cloned()).collect();
            let mut decls = Vec::new();
            statements(bus.get_body(), &mut decls);
            for stmt in decls {
                if let Statement::Declaration { name: field, xtype, meta, dimensions, .. } = stmt {
                    let args = crate::bus::constructor(bus.get_body_as_vec(), field)
                        .map_or(&[][..], |(_, args)| args);
                    let args = args
                        .iter()
                        .map(|arg| crate::bus::substitute(arg, &bindings))
                        .collect::<Vec<_>>();
                    let dimensions = dimensions
                        .iter()
                        .map(|dim| crate::bus::substitute(dim, &bindings))
                        .collect::<Vec<_>>();
                    let field = self.declare(
                        &format!("{name}.{field}"),
                        xtype,
                        input,
                        meta,
                        &args,
                        &dimensions,
                        all_dimensions.as_deref(),
                    )?;
                    leaves = leaves.zip(field).and_then(|(a, b)| a.checked_add(b));
                }
            }
        }
        if let Some((dims, leaves)) = all_dimensions.zip(leaves) {
            let total = dims
                .iter()
                .try_fold(leaves, |n, d| n.checked_mul(*d))
                .ok_or_else(|| anyhow!("bus signal size overflow"))?;
            self.capacities.insert(name.to_owned(), (dims, leaves, if input { 0 } else { total }));
        }
        Ok(dimensions
            .as_ref()
            .zip(leaves)
            .and_then(|(dims, leaves)| dims.iter().try_fold(leaves, |n, d| n.checked_mul(*d))))
    }

    /// Canonicalize constant tag expressions for propagation comparisons.
    fn normalize(&self, expr: Expression) -> Result<Expression> {
        if let Some(value) = crate::shared::try_compute_biguint(&expr, self.prime)? {
            Ok(Expression::Number(expr.get_meta().clone(), value.into()))
        } else {
            Ok(expr)
        }
    }

    /// Compare expressions without source-position metadata.
    fn same(&self, lhs: &Option<Expression>, rhs: &Option<Expression>) -> bool {
        match (lhs, rhs) {
            (None, None) => true,
            (Some(a), Some(b)) => crate::bus::expression_key(a) == crate::bus::expression_key(b),
            _ => false,
        }
    }

    /// Resolve a tag read before ordinary field-access generation.
    fn expression(&mut self, expr: &mut Expression) -> Result<()> {
        match expr {
            Expression::Variable { name, access, .. } => {
                for access in access.iter_mut() {
                    if let Access::ArrayAccess(index) = access {
                        self.expression(index)?;
                    }
                }
                let key = self.path(name, access)?;
                if let Some(tag) = self.tags.get(&key) {
                    let owner = key.rsplit_once('.').expect("tag path").0;
                    ensure!(
                        tag.explicit
                            || self
                                .capacities
                                .get(owner)
                                .is_none_or(|(_, _, remaining)| *remaining == 0),
                        "tag {key} read before all array elements are initialized"
                    );
                    let value =
                        tag.value.clone().ok_or_else(|| anyhow!("tag {key} has no value"))?;
                    self.mark_required(&value);
                    *expr = value;
                    return Ok(());
                }
            }
            Expression::InfixOp { lhe, rhe, .. } => {
                self.expression(lhe)?;
                self.expression(rhe)?;
            }
            Expression::PrefixOp { rhe, .. } | Expression::ParallelOp { rhe, .. } => {
                self.expression(rhe)?
            }
            Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
                self.expression(cond)?;
                self.expression(if_true)?;
                self.expression(if_false)?;
            }
            Expression::Call { args, .. } | Expression::BusCall { args, .. } => {
                for arg in args {
                    self.expression(arg)?;
                }
            }
            Expression::ArrayInLine { values, .. } | Expression::Tuple { values, .. } => {
                for value in values {
                    self.expression(value)?;
                }
            }
            Expression::UniformArray { value, dimension, .. } => {
                self.expression(value)?;
                self.expression(dimension)?;
            }
            _ => {}
        }
        Ok(())
    }

    /// Record dependencies on input tag values, including derived expressions.
    fn mark_required(&mut self, expr: &Expression) {
        match expr {
            Expression::Variable { name, .. } => {
                for (path, param) in &self.inputs {
                    if name == param {
                        self.required.insert(path.clone());
                    }
                }
            }
            Expression::InfixOp { lhe, rhe, .. } => {
                self.mark_required(lhe);
                self.mark_required(rhe);
            }
            Expression::PrefixOp { rhe, .. } => self.mark_required(rhe),
            Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
                self.mark_required(cond);
                self.mark_required(if_true);
                self.mark_required(if_false);
            }
            _ => {}
        }
    }

    /// Obtain the tags of a data expression; arithmetic deliberately drops tags.
    fn source_tags(&self, expr: &Expression) -> Result<BTreeMap<String, Tag>> {
        Ok(match expr {
            Expression::Variable { name, access, .. } => {
                let prefix = format!("{}.", self.path(name, access)?);
                self.tags
                    .iter()
                    .filter_map(|(key, tag)| {
                        let suffix = key.strip_prefix(&prefix)?;
                        let owner = key.rsplit_once('.').expect("tag path").0;
                        let complete = self
                            .capacities
                            .get(owner)
                            .is_none_or(|(_, _, remaining)| *remaining == 0);
                        if tag.explicit || complete {
                            Some((suffix.to_owned(), tag.clone()))
                        } else if tag.declared {
                            let mut tag = tag.clone();
                            tag.value = None;
                            Some((suffix.to_owned(), tag))
                        } else {
                            None
                        }
                    })
                    .collect()
            }
            Expression::UniformArray { value, .. } => self.source_tags(value)?,
            Expression::ArrayInLine { values, .. } => {
                let mut tags =
                    values.first().map(|v| self.source_tags(v)).transpose()?.unwrap_or_default();
                for value in values.iter().skip(1) {
                    let other = self.source_tags(value)?;
                    tags.retain(|key, tag| {
                        other.get(key).is_some_and(|t| self.same(&tag.value, &t.value))
                    });
                }
                tags
            }
            _ => BTreeMap::new(),
        })
    }

    /// Consume scalar leaves once, updating array-wide tag completion of enclosing buses.
    fn initialize(&mut self, dst: &str, access: &[Access]) {
        let indices = access.iter().filter(|a| matches!(a, Access::ArrayAccess(_))).count();
        let assigned = self
            .capacities
            .get(dst)
            .map(|(dims, leaves, _)| dims.iter().skip(indices).product::<usize>() * leaves);
        for (owner, (dims, leaves, remaining)) in &mut self.capacities {
            if below(owner, dst) {
                *remaining = remaining
                    .saturating_sub(dims.iter().skip(indices).product::<usize>() * *leaves);
            } else if below(dst, owner) {
                if let Some(assigned) = assigned {
                    *remaining = remaining.saturating_sub(assigned);
                }
            }
        }
    }

    /// Check nominal compatibility even when two instantiated buses have identical PODs.
    /// Unknown parameter equalities remain compile-time assertions for specialization.
    fn compatibility(
        &self,
        dst: &str,
        expr: &Expression,
        checks: &mut Vec<Statement>,
    ) -> Result<()> {
        match expr {
            Expression::Variable { name, access, meta } => {
                if let (Some(lhs), Some(rhs)) =
                    (self.identities.get(dst), self.identities.get(&self.path(name, access)?))
                {
                    ensure!(
                        lhs.definition == rhs.definition,
                        "incompatible bus identities {} and {}",
                        lhs.definition,
                        rhs.definition
                    );
                    for (a, b) in lhs.arguments.iter().zip(&rhs.arguments) {
                        let a = self.normalize(a.clone())?;
                        let b = self.normalize(b.clone())?;
                        if self.same(&Some(a.clone()), &Some(b.clone())) {
                            continue;
                        }
                        if let (Expression::Number(_, a), Expression::Number(_, b)) = (&a, &b) {
                            ensure!(
                                a == b,
                                "incompatible parameters for bus {}: {a} and {b}",
                                lhs.definition
                            );
                        } else {
                            checks.push(Statement::Assert {
                                meta: meta.clone(),
                                arg: Expression::InfixOp {
                                    meta: meta.clone(),
                                    infix_op: ExpressionInfixOpcode::Eq,
                                    lhe: Box::new(a),
                                    rhe: Box::new(b),
                                },
                            });
                        }
                    }
                }
            }
            Expression::ArrayInLine { values, .. } => {
                for value in values {
                    self.compatibility(dst, value, checks)?;
                }
            }
            Expression::UniformArray { value, .. } => self.compatibility(dst, value, checks)?,
            _ => {}
        }
        Ok(())
    }

    /// Propagate tags with Circom's declared/explicit/initialized rules.
    fn assign(&mut self, dst: &str, source: BTreeMap<String, Tag>) {
        let prefix = format!("{dst}.");
        let keys =
            self.tags.keys().filter(|key| key.starts_with(&prefix)).cloned().collect::<Vec<_>>();
        for key in keys {
            let mut tag = self.tags.remove(&key).expect("collected key");
            let incoming = source.get(&key[prefix.len()..]);
            if !tag.explicit {
                if !tag.initialized {
                    tag.value = incoming.and_then(|t| t.value.clone());
                } else if incoming.is_none_or(|t| !self.same(&tag.value, &t.value)) {
                    if !tag.declared {
                        continue;
                    }
                    tag.value = None;
                }
            }
            tag.initialized = true;
            self.tags.insert(key, tag);
        }
        if !self.initialized.contains(dst) {
            for (suffix, mut tag) in source {
                tag.declared = false;
                tag.explicit = false;
                tag.initialized = true;
                self.tags.entry(format!("{prefix}{suffix}")).or_insert(tag);
            }
        }
        self.initialized.insert(dst.to_owned());
    }

    /// Substitute actual tag values into a callee's derived output tags.
    fn refresh_components(&mut self) -> Result<()> {
        for (name, component) in &self.components {
            let mut bindings = component
                .summary
                .params
                .iter()
                .cloned()
                .zip(component.args.iter().cloned())
                .collect::<HashMap<_, _>>();
            let mut missing = HashSet::new();
            for (path, param) in &component.summary.inputs {
                if let Some(value) =
                    self.tags.get(&format!("{name}.{path}")).and_then(|t| t.value.clone())
                {
                    bindings.insert(param.clone(), value);
                } else {
                    missing.insert(param.clone());
                }
            }
            for (path, bus) in &component.summary.buses {
                self.identities.insert(
                    format!("{name}.{path}"),
                    NominalBus {
                        definition: bus.definition.clone(),
                        arguments: bus
                            .arguments
                            .iter()
                            .map(|arg| crate::bus::substitute(arg, &bindings))
                            .collect(),
                    },
                );
                self.buses.insert(format!("{name}.{path}"));
            }
            for (path, tag) in &component.summary.outputs {
                let mut tag = tag.clone();
                tag.value = tag
                    .value
                    .and_then(|value| {
                        let value = crate::bus::substitute(&value, &bindings);
                        let text = crate::shared::gen_poly_expr_name(&value);
                        (!missing.iter().any(|param| text.contains(param))).then_some(value)
                    })
                    .map(|value| self.normalize(value))
                    .transpose()?;
                self.tags.insert(format!("{name}.{path}"), tag);
            }
        }
        Ok(())
    }

    /// Process statements in source order and remove metadata-only assignments.
    fn statement(&mut self, stmt: &mut Statement) -> Result<()> {
        let meta = stmt.get_meta().clone();
        let location = source_location(self.program, &meta);
        self.statement_impl(stmt).with_context(|| location)
    }

    /// Transfer tag and nominal-identity state for one statement.
    fn statement_impl(&mut self, stmt: &mut Statement) -> Result<()> {
        let meta = stmt.get_meta().clone();
        let mut checks = Vec::new();
        match stmt {
            Statement::Block { stmts, .. }
            | Statement::InitializationBlock { initializations: stmts, .. } => {
                for stmt in stmts {
                    self.statement(stmt)?;
                }
            }
            Statement::Declaration { dimensions, .. } => {
                for dim in dimensions {
                    self.expression(dim)?;
                }
            }
            Statement::Substitution { var, access, op, rhe, .. } => {
                for access in access.iter_mut() {
                    if let Access::ArrayAccess(index) = access {
                        self.expression(index)?;
                    }
                }
                let dst = self.path(var, access)?;
                if *op == AssignOp::AssignVar && self.tags.contains_key(&dst) {
                    self.expression(rhe)?;
                    let value = self.normalize(rhe.clone())?;
                    let owner = dst.rsplit_once('.').expect("tag path").0;
                    ensure!(
                        !self
                            .initialized
                            .iter()
                            .any(|path| below(path, owner) || below(owner, path)),
                        "tag {dst} assigned after signal initialization"
                    );
                    let tag = self.tags.get_mut(&dst).expect("tag exists");
                    ensure!(
                        tag.declared && !tag.explicit,
                        "tag {dst} is not assignable or was assigned twice"
                    );
                    tag.explicit = true;
                    tag.value = Some(value);
                    *stmt = Statement::Block { meta, stmts: vec![] };
                    return Ok(());
                }
                self.expression(rhe)?;
                if let Expression::Call { id, args, meta } = unwrap_parallel(rhe) {
                    if let Some(summary) = self.summaries.get(id) {
                        self.components.insert(
                            dst,
                            Component {
                                source: meta.clone(),
                                summary: summary.clone(),
                                args: args.clone(),
                                position: meta.start,
                            },
                        );
                        self.refresh_components()?;
                        return Ok(());
                    }
                }
                if op.is_signal_operator() {
                    self.compatibility(&dst, rhe, &mut checks)?;
                    let tags =
                        if *op == AssignOp::AssignConstraintSignal || self.buses.contains(&dst) {
                            self.source_tags(rhe)?
                        } else {
                            BTreeMap::new()
                        };
                    self.assign(&dst, tags);
                    self.initialize(&dst, access);
                    self.refresh_components()?;
                } else if access.is_empty() && !crate::bus::is_constructor(rhe) {
                    let value = crate::bus::substitute(rhe, &self.constants);
                    if let Some(value) = crate::shared::try_compute_biguint(&value, self.prime)? {
                        self.constants
                            .insert(var.clone(), Expression::Number(meta.clone(), value.into()));
                    } else {
                        self.constants.remove(var);
                    }
                }
            }
            Statement::ConstraintEquality { lhe, rhe, .. } => {
                self.expression(lhe)?;
                self.expression(rhe)?;
                if let Expression::Variable { name, access, .. } = lhe {
                    self.compatibility(&self.path(name, access)?, rhe, &mut checks)?;
                }
            }
            Statement::IfThenElse { cond, if_case, else_case, .. } => {
                self.expression(cond)?;
                if let Some(value) = crate::shared::try_compute_biguint(cond, self.prime)? {
                    let mut chosen = if value != 0u32.into() {
                        (**if_case).clone()
                    } else {
                        else_case.as_ref().map(|s| (**s).clone()).unwrap_or_else(|| {
                            Statement::Block { meta: meta.clone(), stmts: vec![] }
                        })
                    };
                    self.statement(&mut chosen)?;
                    *stmt = chosen;
                    return Ok(());
                }
                let old_tags = self.tags.clone();
                let old_initialized = self.initialized.clone();
                let old_capacities = self.capacities.clone();
                self.statement(if_case)?;
                let then_tags = self.tags.clone();
                let then_init = self.initialized.clone();
                let then_capacities = self.capacities.clone();
                self.tags = old_tags;
                self.initialized = old_initialized;
                self.capacities = old_capacities;
                if let Some(other) = else_case {
                    self.statement(other)?;
                }
                let else_tags = self.tags.clone();
                let compile_time = depends_only_on(cond, &self.params);
                for (key, mut tag) in then_tags {
                    if let Some(other) = else_tags.get(&key) {
                        if !self.same(&tag.value, &other.value) {
                            // Divergent runtime tags cannot become hidden layout parameters.
                            tag.value =
                                tag.value.zip(other.value.clone()).filter(|_| compile_time).map(
                                    |(a, b)| Expression::InlineSwitchOp {
                                        meta: meta.clone(),
                                        cond: Box::new(cond.clone()),
                                        if_true: Box::new(a),
                                        if_false: Box::new(b),
                                    },
                                );
                        }
                        self.tags.insert(key, tag);
                    }
                }
                self.initialized.extend(then_init);
                for (owner, (_, _, remaining)) in &mut self.capacities {
                    if let Some((_, _, other)) = then_capacities.get(owner) {
                        *remaining = (*remaining).max(*other);
                    }
                }
            }
            Statement::While { cond, stmt, .. } => {
                self.expression(cond)?;
                // The parser represents a for-loop as initialization plus while, with the
                // increment at the end. Fixed increasing loops consume their leaves on
                // every iteration, while retaining the original symbolic loop in the IR.
                let trips = if let Expression::InfixOp {
                    lhe,
                    infix_op: ExpressionInfixOpcode::Lesser,
                    rhe,
                    ..
                } = cond
                {
                    if let Expression::Variable { name, access, .. } = lhe.as_ref() {
                        let start = self
                            .constants
                            .get(name)
                            .map(|e| crate::shared::try_compute_as_i64(e, self.prime))
                            .transpose()?
                            .flatten();
                        let end = crate::shared::try_compute_as_i64(
                            &crate::bus::substitute(rhe, &self.constants),
                            self.prime,
                        )?;
                        let mut body = Vec::new();
                        statements(stmt, &mut body);
                        let unit_step = body.iter().rev().find_map(|stmt| if let Statement::Substitution { var, rhe, .. } = stmt { (var == name).then_some(rhe) } else { None })
                            .is_some_and(|expr| matches!(expr, Expression::InfixOp { lhe, infix_op: ExpressionInfixOpcode::Add, rhe, .. } if matches!(lhe.as_ref(), Expression::Variable { name: n, .. } if n == name) && matches!(rhe.as_ref(), Expression::Number(_, n) if n == &1.into())));
                        start
                            .zip(end)
                            .filter(|_| access.is_empty() && unit_step)
                            .map(|(start, end)| usize::try_from((end - start).max(0)))
                            .transpose()?
                    } else {
                        None
                    }
                } else {
                    None
                };
                if trips == Some(0) {
                    **stmt = Statement::Block { meta: meta.clone(), stmts: vec![] };
                    return Ok(());
                }
                let before = self.capacities.clone();
                let constants = self.constants.clone();
                self.statement(stmt)?;
                for (owner, (_, _, remaining)) in &mut self.capacities {
                    if let Some((_, _, initial)) = before.get(owner) {
                        if let Some(trips) = trips {
                            *remaining = initial.saturating_sub(
                                initial.saturating_sub(*remaining).saturating_mul(trips),
                            );
                        }
                    }
                }
                self.constants.retain(|name, value| {
                    constants.get(name).is_some_and(|old| {
                        crate::shared::gen_poly_expr_name(old)
                            == crate::shared::gen_poly_expr_name(value)
                    })
                });
            }
            Statement::Assert { arg, .. } => self.expression(arg)?,
            Statement::LogCall { args, .. } => {
                for arg in args {
                    if let LogArgument::LogExp(expr) = arg {
                        self.expression(expr)?;
                    }
                }
            }
            Statement::UnderscoreSubstitution { rhe, .. } => self.expression(rhe)?,
            _ => {}
        }
        if !checks.is_empty() {
            checks.push(stmt.clone());
            *stmt = Statement::Block { meta, stmts: checks };
        }
        Ok(())
    }
}

/// Append the compile-time tag arguments at the original constructor locations.
fn append_arguments(stmt: &mut Statement, arguments: &HashMap<usize, Vec<Expression>>) {
    match stmt {
        Statement::Block { stmts, .. }
        | Statement::InitializationBlock { initializations: stmts, .. } => {
            for stmt in stmts {
                append_arguments(stmt, arguments);
            }
        }
        Statement::Substitution { rhe, .. } => {
            if let Expression::Call { meta, args, .. } = unwrap_parallel_mut(rhe) {
                if let Some(extra) = arguments.get(&meta.start) {
                    args.extend(extra.iter().cloned());
                }
            }
        }
        Statement::IfThenElse { if_case, else_case, .. } => {
            append_arguments(if_case, arguments);
            if let Some(stmt) = else_case {
                append_arguments(stmt, arguments);
            }
        }
        Statement::While { stmt, .. } => append_arguments(stmt, arguments),
        _ => {}
    }
}

/// Analyze callees first, so callers can use symbolic summaries of their output tags.
fn analyze(
    name: &str,
    program: &ProgramArchive,
    prime: &BigUint,
    summaries: &mut HashMap<String, Summary>,
    active: &mut HashSet<String>,
) -> Result<()> {
    if summaries.contains_key(name) {
        return Ok(());
    }
    ensure!(active.insert(name.to_owned()), "recursive component tag dependency at {name}");
    let template = &program.templates[name];
    let mut all = Vec::new();
    statements(template.get_body(), &mut all);
    for stmt in &all {
        if let Statement::Substitution { rhe, .. } = stmt {
            if let Expression::Call { id, .. } = unwrap_parallel(rhe) {
                if program.templates.contains_key(id) {
                    analyze(id, program, prime, summaries, active)?;
                }
            }
        }
    }
    let mut analysis = Analysis {
        program,
        prime,
        summaries,
        params: template.get_name_of_params().clone(),
        tags: BTreeMap::new(),
        buses: HashSet::new(),
        initialized: HashSet::new(),
        inputs: BTreeMap::new(),
        required: HashSet::new(),
        component_roots: HashSet::new(),
        components: HashMap::new(),
        identities: BTreeMap::new(),
        capacities: BTreeMap::new(),
        constants: HashMap::new(),
    };
    for stmt in &all {
        if let Statement::Declaration { name, xtype, meta, dimensions, .. } = stmt {
            let input = matches!(
                xtype,
                VariableType::Signal(SignalType::Input, _)
                    | VariableType::Bus(_, SignalType::Input, _)
            );
            let args = crate::bus::constructor(template.get_body_as_vec(), name)
                .map_or(&[][..], |(_, args)| args);
            analysis.declare(name, xtype, input, meta, args, dimensions, Some(&[]))?;
        }
    }
    let mut body = template.get_body().clone();
    analysis
        .statement(&mut body)
        .with_context(|| format!("template {name}, source {:?}", template.get_param_location()))?;
    let mut arguments = HashMap::new();
    for (component_name, component) in &analysis.components {
        let mut args = Vec::new();
        for path in component.summary.inputs.keys() {
            let key = format!("{component_name}.{path}");
            let location = source_location(program, &component.source);
            let tag = analysis.tags.get(&key).ok_or_else(|| {
                anyhow!("{location}: component {component_name} requires input tag {path}")
            })?;
            if component.summary.required_values.contains(path) {
                ensure!(
                    tag.value.is_some(),
                    "{location}: component {component_name} requires a value for tag {path}"
                );
            }
            args.push(tag.value.clone().unwrap_or_else(|| {
                Expression::Number(template.get_body().get_meta().clone(), 0.into())
            }));
        }
        arguments.insert(component.position, args);
    }
    for args in arguments.values() {
        for expr in args {
            analysis.mark_required(expr);
        }
    }
    append_arguments(&mut body, &arguments);
    let outputs = analysis
        .tags
        .into_iter()
        .filter(|(key, _)| template.get_outputs().keys().any(|output| below(key, output)))
        .collect();
    let buses = analysis
        .identities
        .into_iter()
        .filter(|(key, _)| {
            template
                .get_inputs()
                .keys()
                .chain(template.get_outputs().keys())
                .any(|root| below(key, root))
        })
        .collect();
    let summary = Summary {
        buses,
        params: template.get_name_of_params().clone(),
        inputs: analysis.inputs,
        required_values: analysis.required,
        outputs,
        body,
    };
    summaries.insert(name.to_owned(), summary);
    active.remove(name);
    Ok(())
}

/// Resolve symbolic metadata before declaration/type collection.
pub(crate) fn prepare(program: &ProgramArchive, prime: &BigUint) -> Result<ProgramArchive> {
    let program = prepare_main_arrays(program)?;
    let program = &program;
    let mut summaries = HashMap::new();
    let mut names = program.templates.keys().cloned().collect::<Vec<_>>();
    names.sort();
    for name in names {
        analyze(&name, program, prime, &mut summaries, &mut HashSet::new())?;
    }
    let mut result = program.clone();
    for (name, summary) in summaries {
        let old = &program.templates[&name];
        let mut params = summary.params;
        params.extend(summary.inputs.values().cloned());
        let template = TemplateData::copy(
            name.clone(),
            old.get_file_id(),
            summary.body,
            params.len(),
            params,
            old.get_param_location(),
            old.get_inputs().clone(),
            old.get_outputs().clone(),
            old.is_parallel(),
            old.is_custom_gate(),
            old.is_extern_c(),
            old.get_declaration_inputs().clone(),
            old.get_declaration_outputs().clone(),
        );
        if let Expression::Call { id, args, meta } = &mut result.initial_template_call {
            if id == &name {
                ensure!(
                    summary.inputs.is_empty(),
                    "{}: main component cannot have inputs with tags",
                    source_location(program, meta)
                );
                args.extend(
                    summary.inputs.values().map(|_| Expression::Number(meta.clone(), 0.into())),
                );
            }
        }
        result.templates.insert(name, template);
    }
    prepare_layout_params(result, prime)
}

/// Make derived dimensions explicit parameters so substitution can cross component boundaries
/// without referring to a `poly.expr` owned by another template.
fn prepare_layout_params(mut program: ProgramArchive, prime: &BigUint) -> Result<ProgramArchive> {
    let mut extras = HashMap::<String, BTreeMap<String, Expression>>::new();
    for (name, template) in &program.templates {
        let mut all = Vec::new();
        statements(template.get_body(), &mut all);
        let mut expressions = Vec::new();
        for stmt in all {
            if let Statement::Declaration { name, xtype, dimensions, .. } = stmt {
                if matches!(xtype, VariableType::Signal(..) | VariableType::Bus(..)) {
                    expressions.extend(dimensions.iter().cloned());
                }
                if let VariableType::Bus(bus, ..) = xtype {
                    let args = crate::bus::constructor(template.get_body_as_vec(), name)
                        .map_or(&[][..], |(_, args)| args);
                    expressions.extend(crate::bus::dimensions(&program, bus, args)?);
                }
            }
        }
        let mut derived = BTreeMap::new();
        for expr in expressions {
            if !matches!(expr, Expression::Variable { ref access, .. } if access.is_empty())
                && depends_only_on(&expr, template.get_name_of_params())
                && crate::shared::try_compute_biguint(&expr, prime)?.is_none()
            {
                derived.insert(crate::bus::layout_param_name(&expr), expr);
            }
        }
        extras.insert(name.clone(), derived);
    }
    // Forward derived dimensions through intermediate components even when the caller
    // does not itself declare a bus with that shape.
    loop {
        let previous = extras.clone();
        for (name, template) in &program.templates {
            let mut all = Vec::new();
            statements(template.get_body(), &mut all);
            for stmt in all {
                if let Statement::Substitution { rhe, .. } = stmt {
                    let Expression::Call { id, args, .. } = unwrap_parallel(rhe) else {
                        continue;
                    };
                    if let Some(callee) = previous.get(id) {
                        let bindings = program.templates[id]
                            .get_name_of_params()
                            .iter()
                            .cloned()
                            .zip(args.iter().cloned())
                            .collect();
                        for expr in callee.values() {
                            let expr = crate::bus::substitute(expr, &bindings);
                            if !matches!(expr, Expression::Variable { ref access, .. } if access.is_empty())
                                && depends_only_on(&expr, template.get_name_of_params())
                                && crate::shared::try_compute_biguint(&expr, prime)?.is_none()
                            {
                                extras
                                    .get_mut(name)
                                    .expect("template exists")
                                    .insert(crate::bus::layout_param_name(&expr), expr);
                            }
                        }
                    }
                }
            }
        }
        if extras.iter().all(|(name, values)| values.len() == previous[name].len()) {
            break;
        }
    }
    fn rewrite(
        stmt: &mut Statement,
        extras: &HashMap<String, BTreeMap<String, Expression>>,
        templates: &HashMap<String, TemplateData>,
        own: &BTreeMap<String, Expression>,
    ) {
        match stmt {
            Statement::Block { stmts, .. }
            | Statement::InitializationBlock { initializations: stmts, .. } => {
                for stmt in stmts {
                    rewrite(stmt, extras, templates, own);
                }
            }
            Statement::Declaration {
                dimensions,
                xtype: VariableType::Signal(..) | VariableType::Bus(..),
                ..
            } => {
                for dim in dimensions {
                    let alias = crate::bus::layout_param_name(dim);
                    if own.contains_key(&alias) {
                        *dim = Expression::Variable {
                            meta: dim.get_meta().clone(),
                            name: alias,
                            access: vec![],
                        };
                    }
                }
            }
            Statement::Substitution { rhe, .. } => {
                let Expression::Call { id, args, .. } = unwrap_parallel_mut(rhe) else {
                    return;
                };
                if let Some(derived) = extras.get(id) {
                    let bindings = templates[id]
                        .get_name_of_params()
                        .iter()
                        .cloned()
                        .zip(args.iter().cloned())
                        .collect();
                    args.extend(derived.values().map(|expr| {
                        let expr = crate::bus::substitute(expr, &bindings);
                        let alias = crate::bus::layout_param_name(&expr);
                        if own.contains_key(&alias) {
                            Expression::Variable {
                                meta: expr.get_meta().clone(),
                                name: alias,
                                access: vec![],
                            }
                        } else {
                            expr
                        }
                    }));
                }
            }
            Statement::IfThenElse { if_case, else_case, .. } => {
                rewrite(if_case, extras, templates, own);
                if let Some(stmt) = else_case {
                    rewrite(stmt, extras, templates, own);
                }
            }
            Statement::While { stmt, .. } => rewrite(stmt, extras, templates, own),
            _ => {}
        }
    }
    let old_templates = program.templates.clone();
    for (name, old) in &old_templates {
        let derived = &extras[name];
        let mut body = old.get_body().clone();
        rewrite(&mut body, &extras, &old_templates, derived);
        let mut params = old.get_name_of_params().clone();
        params.extend(derived.keys().cloned());
        program.templates.insert(
            name.clone(),
            TemplateData::copy(
                name.clone(),
                old.get_file_id(),
                body,
                params.len(),
                params,
                old.get_param_location(),
                old.get_inputs().clone(),
                old.get_outputs().clone(),
                old.is_parallel(),
                old.is_custom_gate(),
                old.is_extern_c(),
                old.get_declaration_inputs().clone(),
                old.get_declaration_outputs().clone(),
            ),
        );
    }
    if let Expression::Call { id, args, .. } = &mut program.initial_template_call {
        let bindings = old_templates[id]
            .get_name_of_params()
            .iter()
            .cloned()
            .zip(args.iter().cloned())
            .collect();
        args.extend(extras[id].values().map(|expr| crate::bus::substitute(expr, &bindings)));
    }
    Ok(program)
}

/// Bind literal array parameters of the main template as immutable source-level constants.
/// LLZK's main attribute accepts scalar template arguments; array literals use the existing
/// global-constant path when the generated declaration is lowered.
fn prepare_main_arrays(program: &ProgramArchive) -> Result<ProgramArchive> {
    let mut result = program.clone();
    let Expression::Call { id, args, .. } = &program.initial_template_call else {
        return Ok(result);
    };
    if !args
        .iter()
        .any(|arg| matches!(arg, Expression::ArrayInLine { .. } | Expression::UniformArray { .. }))
    {
        return Ok(result);
    }
    let old = &program.templates[id];
    let reused = program.templates.values().any(|template| {
        let mut all = Vec::new();
        statements(template.get_body(), &mut all);
        all.iter().any(|stmt| match stmt {
            Statement::Substitution { rhe, .. } => {
                matches!(unwrap_parallel(rhe), Expression::Call { id: callee, .. } if callee == id)
            }
            _ => false,
        })
    });
    let destination = if reused { format!("{id}$main_arrays") } else { id.clone() };
    let mut params = Vec::new();
    let mut actuals = Vec::new();
    let mut prefix = Vec::new();
    for (name, arg) in old.get_name_of_params().iter().zip(args) {
        if let Some((dims, _)) = crate::gen_context::literal_array_dimensions_and_values(arg)
            .filter(|(dims, _)| !dims.is_empty())
        {
            let meta = arg.get_meta().clone();
            prefix.push(Statement::Declaration {
                meta: meta.clone(),
                xtype: VariableType::Var,
                name: name.clone(),
                dimensions: dims
                    .into_iter()
                    .map(|n| Expression::Number(meta.clone(), n.into()))
                    .collect(),
                is_constant: true,
                is_anonymous: false,
            });
            prefix.push(Statement::Substitution {
                meta,
                var: name.clone(),
                access: vec![],
                op: AssignOp::AssignVar,
                rhe: arg.clone(),
            });
        } else {
            params.push(name.clone());
            actuals.push(arg.clone());
        }
    }
    let mut body = old.get_body().clone();
    if let Statement::Block { stmts, .. } = &mut body {
        prefix.append(stmts);
        *stmts = prefix;
    }
    let template = TemplateData::copy(
        destination.clone(),
        old.get_file_id(),
        body,
        params.len(),
        params,
        old.get_param_location(),
        old.get_inputs().clone(),
        old.get_outputs().clone(),
        old.is_parallel(),
        old.is_custom_gate(),
        old.is_extern_c(),
        old.get_declaration_inputs().clone(),
        old.get_declaration_outputs().clone(),
    );
    result.templates.insert(destination.clone(), template);
    if let Expression::Call { id, args, .. } = &mut result.initial_template_call {
        *id = destination;
        *args = actuals;
    }
    Ok(result)
}
