//! Compile-time tag analysis for the symbolic pipeline. Tags never become signal fields.

use anyhow::{anyhow, ensure, Context, Result};
use num_bigint_dig::BigUint;
use num_traits::ToPrimitive;
use program_structure::{
    ast::{
        Access, AssignOp, Expression, ExpressionInfixOpcode, LogArgument, Meta, SignalType,
        Statement, VariableType,
    },
    program_archive::ProgramArchive,
    template_data::TemplateData,
};
use std::collections::{BTreeMap, HashMap, HashSet, VecDeque};
use std::convert::TryFrom;

use crate::bus::{InstantiatedBus, NominalBus};
use crate::template_ext::rebuild_template;

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

/// Assignment completion, independent of whether scalar leaves can be counted.
#[derive(Clone, Debug)]
struct Capacity {
    /// Whole-value assignments prove completion even with symbolic dimensions.
    complete: bool,
    /// Numeric accounting for partial assignments, absent for symbolic sizes.
    leaves: Option<LeafCapacity>,
}

/// Scalar-leaf accounting for array-wide tag completion.
#[derive(Clone, Debug)]
struct LeafCapacity {
    /// All enclosing array dimensions, from outermost to innermost.
    dimensions: Vec<usize>,
    /// Scalar leaves in one element, including nested bus fields.
    scalar_leaves: usize,
    /// Scalar leaves still awaiting assignment.
    remaining: usize,
}

impl Capacity {
    fn is_complete(&self) -> bool {
        self.complete || self.leaves.as_ref().is_some_and(|leaves| leaves.remaining == 0)
    }

    /// Leaves covered by an assignment after indexing the outer dimensions.
    fn assigned_leaves(&self, indices: usize) -> Option<usize> {
        self.leaves.as_ref().map(|leaves| {
            leaves.dimensions.iter().skip(indices).product::<usize>() * leaves.scalar_leaves
        })
    }

    fn consume(&mut self, assigned: usize) {
        if let Some(leaves) = &mut self.leaves {
            leaves.remaining = leaves.remaining.saturating_sub(assigned);
        }
    }

    /// Completion must hold on both paths, whether proven by whole or partial writes.
    fn merge(&mut self, other: &Self) {
        self.complete = self.is_complete() && other.is_complete();
        match (&mut self.leaves, &other.leaves) {
            (Some(leaves), Some(other)) => {
                leaves.remaining = leaves.remaining.max(other.remaining);
            }
            (leaves, _) => *leaves = None,
        }
    }

    /// Account for all iterations after analyzing one fixed-loop body.
    fn repeat(&mut self, before: &Self, trips: usize) {
        if let (Some(leaves), Some(initial)) = (&mut self.leaves, &before.leaves) {
            leaves.remaining = initial.remaining.saturating_sub(
                initial.remaining.saturating_sub(leaves.remaining).saturating_mul(trips),
            );
        }
    }
}

/// Facts that must be forked when analyzing alternative control-flow paths.
/// Constructor occurrences deliberately live outside this state: every analyzed
/// occurrence must survive so the final rewrite can add its hidden tag arguments.
#[derive(Clone, Default)]
struct FlowState {
    /// Tags indexed by component instance and array-wide field paths.
    tags: BTreeMap<String, Tag>,
    /// Paths assigned on any analyzed path, preventing late tag assignments.
    initialized: HashSet<String>,
    /// Whole-value completion and optional scalar-leaf accounting for array-wide tags.
    capacities: BTreeMap<String, Capacity>,
    /// Local scalar and array snapshots expressed only in compile-time parameters.
    constants: HashMap<String, Expression>,
    /// Constructor arguments and occurrences that reach the current control-flow path.
    component_states: HashMap<String, ComponentState>,
}

/// Constructors that can initialize a component on the current path.
#[derive(Clone)]
struct ComponentState {
    /// Constructor-time argument snapshots; missing values represent divergent runtime choices.
    args: Vec<Option<Expression>>,
    /// Indices into the component path's constructor occurrences.
    occurrences: Vec<usize>,
}

impl FlowState {
    /// Start an alternative path with exactly the same incoming facts.
    fn fork(&self) -> Self {
        self.clone()
    }

    /// Join an analyzed path into its alternative. An absent else branch or a
    /// possibly empty loop uses the incoming state as the alternative.
    fn merge(&mut self, then_state: Self, cond: &Expression, params: &[String], meta: &Meta) {
        let Self { tags, initialized, capacities, constants, component_states } = then_state;
        let compile_time = depends_only_on(cond, params);
        // A propagated tag must exist on both paths to survive the join.
        self.tags.retain(|key, _| tags.contains_key(key));
        for (key, mut tag) in tags {
            if let Some(other) = self.tags.get(&key) {
                tag.value = merge_value(tag.value, &other.value, cond, compile_time, meta);
                self.tags.insert(key, tag);
            }
        }
        // Type checking guarantees the same callee on both paths. Keep its ordinary
        // arguments conditional so later input-tag writes refresh the joined instance.
        self.component_states.retain(|name, state| {
            let Some(then_component) = component_states.get(name) else {
                return false;
            };
            for (arg, then_arg) in state.args.iter_mut().zip(&then_component.args) {
                *arg = merge_value(then_arg.clone(), arg, cond, compile_time, meta);
            }
            for occurrence in &then_component.occurrences {
                if !state.occurrences.contains(occurrence) {
                    state.occurrences.push(*occurrence);
                }
            }
            true
        });
        // A write on either path prevents a later explicit tag assignment.
        self.initialized.extend(initialized);
        for (owner, capacity) in &mut self.capacities {
            if let Some(other) = capacities.get(owner) {
                capacity.merge(other);
            }
        }
        // A local remains constant only when both paths agree on its value.
        self.constants.retain(|name, value| {
            constants.get(name).is_some_and(|other| {
                crate::bus::expression_key(other) == crate::bus::expression_key(value)
            })
        });
    }

    /// Only proven completion permits reading a propagated tag value.
    fn is_complete(&self, owner: &str) -> bool {
        self.capacities.get(owner).is_some_and(Capacity::is_complete)
    }

    /// Record whole-value writes and consume known leaves of enclosing and nested buses.
    fn initialize(&mut self, dst: &str, access: &[Access]) {
        let indices = access.iter().filter(|a| matches!(a, Access::ArrayAccess(_))).count();
        let assigned = self.capacities.get(dst).and_then(|c| c.assigned_leaves(indices));
        if indices == 0 {
            if let Some(capacity) = self.capacities.get_mut(dst) {
                capacity.complete = true;
            }
        }
        let prefix = format!("{dst}.");
        for (_, capacity) in self
            .capacities
            .range_mut(prefix.clone()..)
            .take_while(|(owner, _)| owner.starts_with(&prefix))
        {
            if indices == 0 {
                capacity.complete = true;
            }
            if let Some(count) = capacity.assigned_leaves(indices) {
                capacity.consume(count);
            }
        }
        if let Some(count) = assigned {
            let mut owner = dst;
            loop {
                if let Some(capacity) = self.capacities.get_mut(owner) {
                    capacity.consume(count);
                }
                match owner.rsplit_once('.') {
                    Some((parent, _)) => owner = parent,
                    None => break,
                }
            }
        }
    }
}

/// Reverse input-tag dependencies and a deduplicated component refresh worklist.
/// Tag copies are snapshots at the assignment, not live edges between signals.
#[derive(Default)]
struct ComponentWorklist {
    /// Components whose summaries consume each fully qualified input tag.
    dependents: HashMap<String, HashSet<String>>,
    /// Components awaiting substitution of their current input tag values.
    pending: VecDeque<String>,
    /// Membership of `pending`, preventing duplicate work for bus assignments.
    queued: HashSet<String>,
}

impl ComponentWorklist {
    /// Retain dependencies of all constructor occurrences, including branches.
    fn register(&mut self, name: &str, summary: &Summary) {
        for path in summary.inputs.keys() {
            self.dependents.entry(format!("{name}.{path}")).or_default().insert(name.to_owned());
        }
        self.enqueue(name);
    }

    /// Schedule a component at most once until its pending refresh runs.
    fn enqueue(&mut self, name: &str) {
        if self.queued.insert(name.to_owned()) {
            self.pending.push_back(name.to_owned());
        }
    }

    /// Propagate a changed tag binding to just the summaries that read it.
    fn changed(&mut self, path: &str) {
        if let Some(names) = self.dependents.get(path) {
            for name in names {
                if self.queued.insert(name.clone()) {
                    self.pending.push_back(name.clone());
                }
            }
        }
    }

    /// Remove an item before refreshing so downstream changes can enqueue it again.
    fn pop(&mut self) -> Option<String> {
        let name = self.pending.pop_front()?;
        self.queued.remove(&name);
        Some(name)
    }
}

/// Shared interface facts consumed at component call sites before generating any types.
#[derive(Debug)]
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
    /// Output capacities, preserving completion evidence at component call sites.
    output_capacities: BTreeMap<String, Capacity>,
}

/// Per-template analysis result, keeping the rewritten body out of the interface summary.
struct AnalyzedTemplate {
    /// Immutable interface facts shared by all component instances of this template.
    summary: Summary,
    /// Body with tag reads lowered and metadata assignments removed.
    body: Statement,
}

/// A component call whose tag parameters are determined by its input assignments.
#[derive(Clone, Debug)]
struct Component<'a> {
    /// Component root and constructor-time index snapshots, independent of path spelling.
    name: String,
    indices: Vec<Expression>,
    /// Ordinary arguments retained when a possibly empty loop discards its live state.
    args: Vec<Option<Expression>>,
    /// Constructor location used by validation diagnostics.
    source: Meta,
    /// Shared template interface; component instances never own a callee body.
    summary: &'a Summary,
    /// Source position and occurrence, distinguishing copies made for fixed loops.
    position: (usize, usize),
    /// Final input tags for an occurrence whose component exists on only one joined path.
    input_tags: Option<BTreeMap<String, Tag>>,
}

/// Analysis state for one template.
struct Analysis<'a> {
    /// Program definitions.
    program: &'a ProgramArchive,
    /// Prime used to compare known tag expressions.
    prime: &'a BigUint,
    /// Available callee summaries.
    summaries: &'a HashMap<String, AnalyzedTemplate>,
    /// Compile-time template parameters, including lowered input tags.
    params: Vec<String>,
    /// Parameters never reassigned, safe to retain in local snapshots across shadowing scopes.
    constant_params: Vec<String>,
    /// Facts local to the current control-flow path.
    flow: FlowState,
    /// Bindings hidden by declarations in each active lexical block.
    constant_scopes: Vec<HashMap<String, Option<Expression>>>,
    /// Bus paths, to distinguish bus-copy propagation from scalar assignment rules.
    buses: HashSet<String>,
    /// Input tag parameter names.
    inputs: BTreeMap<String, String>,
    /// Input values used by metadata expressions.
    required: HashSet<String>,
    /// Component variable roots, whose indices distinguish metadata instances.
    component_roots: HashSet<String>,
    /// Component roots whose interfaces carry tags and require per-instance analysis.
    tagged_components: HashSet<String>,
    /// All constructor occurrences, accumulated across branches and fixed loops.
    /// Keyed by their indexed component paths; never restored with `flow`.
    components: HashMap<String, Vec<Component<'a>>>,
    /// Pending summary substitutions, drained before the next statement or flow fork.
    component_worklist: ComponentWorklist,
    /// Number of analyzed constructor occurrences at each source position.
    constructors: HashMap<usize, usize>,
    /// Nominal bus identities of local fields; component identities are instantiated on use.
    identities: BTreeMap<String, NominalBus>,
    /// Induction values substituted while expanding fixed loops that access tags.
    iterations: HashMap<String, Expression>,
    /// Fresh identities for declarations copied into expanded loop iterations.
    next_declaration: usize,
}

/// Whether a path is contained in a subtree.
fn below(path: &str, parent: &str) -> bool {
    path == parent || path.starts_with(&format!("{parent}."))
}

/// Snapshots may reference immutable parameters, but never other mutable locals.
fn is_constant_value(expr: &Expression, params: &[String]) -> bool {
    match expr {
        Expression::ArrayInLine { values, .. } => {
            values.iter().all(|value| is_constant_value(value, params))
        }
        Expression::UniformArray { value, dimension, .. } => {
            is_constant_value(value, params) && depends_only_on(dimension, params)
        }
        _ => depends_only_on(expr, params),
    }
}

/// Update a known literal element or subarray. Unsupported writes invalidate the root.
fn update_constant(value: &mut Expression, indices: &[usize], replacement: Expression) -> bool {
    let Some((index, rest)) = indices.split_first() else {
        *value = replacement;
        return true;
    };
    match value {
        Expression::ArrayInLine { values, .. } => {
            values.get_mut(*index).is_some_and(|value| update_constant(value, rest, replacement))
        }
        // Do not expand a potentially large uniform array just to track a write.
        _ => false,
    }
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

/// Detect writes to a parameter's binding, excluding locals that shadow its name.
fn assigns_parameter(stmt: &Statement, param: &str, shadowed: &mut bool) -> bool {
    match stmt {
        Statement::Block { stmts, .. } => {
            let mut shadowed = *shadowed;
            stmts.iter().any(|stmt| assigns_parameter(stmt, param, &mut shadowed))
        }
        Statement::InitializationBlock { initializations, .. } => {
            // Declaration groups introduce bindings in the enclosing lexical block.
            initializations.iter().any(|stmt| assigns_parameter(stmt, param, shadowed))
        }
        Statement::Declaration { name, .. } => {
            *shadowed |= name == param;
            false
        }
        Statement::Substitution { var, .. } => var == param && !*shadowed,
        Statement::IfThenElse { if_case, else_case, .. } => {
            assigns_parameter(if_case, param, shadowed)
                || else_case.as_ref().is_some_and(|stmt| assigns_parameter(stmt, param, shadowed))
        }
        Statement::While { stmt, .. } => assigns_parameter(stmt, param, shadowed),
        _ => false,
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
        Expression::Variable { name, access, .. } => {
            params.contains(name)
                && access.iter().all(|access| match access {
                    Access::ArrayAccess(index) => depends_only_on(index, params),
                    Access::ComponentAccess(_) => false,
                })
        }
        Expression::InfixOp { lhe, rhe, .. } => {
            depends_only_on(lhe, params) && depends_only_on(rhe, params)
        }
        Expression::PrefixOp { rhe, .. } => depends_only_on(rhe, params),
        Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
            depends_only_on(cond, params)
                && depends_only_on(if_true, params)
                && depends_only_on(if_false, params)
        }
        Expression::Call { args, .. } => args.iter().all(|arg| depends_only_on(arg, params)),
        _ => false,
    }
}

/// Whether an expression references any of the exact variable names in `names`.
fn references_any(expr: &Expression, names: &HashSet<String>) -> bool {
    references_matching(expr, &|_, name| names.contains(name))
}

/// Inspect variable accesses, including accesses inside array indices.
fn references_matching(expr: &Expression, predicate: &impl Fn(&Meta, &str) -> bool) -> bool {
    match expr {
        Expression::Variable { meta, name, access, .. } => {
            predicate(meta, name)
                || access.iter().any(|access| match access {
                    Access::ArrayAccess(index) => references_matching(index, predicate),
                    Access::ComponentAccess(_) => false,
                })
        }
        Expression::InfixOp { lhe, rhe, .. } => {
            references_matching(lhe, predicate) || references_matching(rhe, predicate)
        }
        Expression::PrefixOp { rhe, .. } | Expression::ParallelOp { rhe, .. } => {
            references_matching(rhe, predicate)
        }
        Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
            references_matching(cond, predicate)
                || references_matching(if_true, predicate)
                || references_matching(if_false, predicate)
        }
        Expression::Call { args, .. } | Expression::BusCall { args, .. } => {
            args.iter().any(|arg| references_matching(arg, predicate))
        }
        Expression::AnonymousComp { params, signals, .. } => {
            params.iter().chain(signals).any(|expr| references_matching(expr, predicate))
        }
        Expression::ArrayInLine { values, .. } | Expression::Tuple { values, .. } => {
            values.iter().any(|value| references_matching(value, predicate))
        }
        Expression::UniformArray { value, dimension, .. } => {
            references_matching(value, predicate) || references_matching(dimension, predicate)
        }
        Expression::Number(..) => false,
    }
}

/// Whether any statement reads or writes one of the given variable roots.
fn uses_variables(stmt: &Statement, names: &HashSet<String>) -> bool {
    uses_matching(stmt, &|_, name| names.contains(name))
}

/// Inspect every variable read or assignment destination in a statement tree.
fn uses_matching(stmt: &Statement, predicate: &impl Fn(&Meta, &str) -> bool) -> bool {
    let mut all = Vec::new();
    statements(stmt, &mut all);
    all.into_iter().any(|stmt| match stmt {
        Statement::Substitution { meta, var, access, rhe, .. } => {
            predicate(meta, var)
                || references_matching(rhe, predicate)
                || access.iter().any(|access| match access {
                    Access::ArrayAccess(index) => references_matching(index, predicate),
                    Access::ComponentAccess(_) => false,
                })
        }
        Statement::Declaration { dimensions, .. } => {
            dimensions.iter().any(|expr| references_matching(expr, predicate))
        }
        Statement::IfThenElse { cond, .. } | Statement::While { cond, .. } => {
            references_matching(cond, predicate)
        }
        Statement::ConstraintEquality { lhe, rhe, .. }
        | Statement::MultSubstitution { lhe, rhe, .. } => {
            references_matching(lhe, predicate) || references_matching(rhe, predicate)
        }
        Statement::Assert { arg, .. }
        | Statement::Return { value: arg, .. }
        | Statement::UnderscoreSubstitution { rhe: arg, .. } => references_matching(arg, predicate),
        Statement::LogCall { args, .. } => args.iter().any(|arg| match arg {
            LogArgument::LogExp(expr) => references_matching(expr, predicate),
            LogArgument::LogStr(_) => false,
        }),
        _ => false,
    })
}

/// Compare expressions without source-position metadata.
fn same_value(lhs: &Option<Expression>, rhs: &Option<Expression>) -> bool {
    match (lhs, rhs) {
        (None, None) => true,
        (Some(a), Some(b)) => crate::bus::expression_key(a) == crate::bus::expression_key(b),
        _ => false,
    }
}

/// Preserve branch-dependent metadata only when the condition is compile-time.
fn merge_value(
    then_value: Option<Expression>,
    else_value: &Option<Expression>,
    cond: &Expression,
    compile_time: bool,
    meta: &Meta,
) -> Option<Expression> {
    if same_value(&then_value, else_value) {
        then_value
    } else {
        then_value.zip(else_value.clone()).filter(|_| compile_time).map(|(a, b)| {
            Expression::InlineSwitchOp {
                meta: meta.clone(),
                cond: Box::new(cond.clone()),
                if_true: Box::new(a),
                if_false: Box::new(b),
            }
        })
    }
}

impl Analysis<'_> {
    /// Preserve constructor inputs before discarding facts unavailable on both paths.
    fn merge_flow(&mut self, then_state: FlowState, cond: &Expression, meta: &Meta) {
        for (branch, alternative) in [(&then_state, &self.flow), (&self.flow, &then_state)] {
            for (name, state) in &branch.component_states {
                if alternative.component_states.contains_key(name) {
                    continue;
                }
                for occurrence in &state.occurrences {
                    let component =
                        &mut self.components.get_mut(name).expect("component exists")[*occurrence];
                    component.input_tags = Some(
                        component
                            .summary
                            .inputs
                            .keys()
                            .filter_map(|path| {
                                branch
                                    .tags
                                    .get(&format!("{name}.{path}"))
                                    .map(|tag| (path.clone(), tag.clone()))
                            })
                            .collect(),
                    );
                }
            }
        }
        self.flow.merge(then_state, cond, &self.params, meta);
    }

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
                    let index = self.constant_expression(index)?;
                    path.push_str(&format!("[{}]", crate::bus::expression_key(&index)));
                }
                Access::ArrayAccess(_) => {}
            }
        }
        Ok(path)
    }

    /// Snapshot only component indices; indices after the first field select bus data.
    fn component_indices(&self, access: &[Access]) -> Result<Vec<Expression>> {
        access
            .iter()
            .take_while(|access| matches!(access, Access::ArrayAccess(_)))
            .map(|access| match access {
                Access::ArrayAccess(index) => self.constant_expression(index),
                Access::ComponentAccess(_) => unreachable!("component indices precede fields"),
            })
            .collect()
    }

    /// Instantiate bus metadata once before populating declared tags and capacities.
    fn declare(
        &mut self,
        name: &str,
        xtype: &VariableType,
        input: bool,
        meta: &Meta,
        arguments: &[Expression],
        dimensions: &[Expression],
    ) -> Result<()> {
        let tags = match xtype {
            VariableType::Signal(_, tags) | VariableType::Bus(_, _, tags) => tags,
            VariableType::Component | VariableType::AnonymousComponent => {
                self.component_roots.insert(name.to_owned());
                return Ok(());
            }
            _ => return Ok(()),
        };
        let bus = match xtype {
            VariableType::Bus(bus, ..) => {
                Some(InstantiatedBus::instantiate(self.program, bus, arguments)?)
            }
            _ => None,
        };
        self.declare_field(name, tags, input, meta, bus.as_ref(), dimensions, Some(&[]))?;
        Ok(())
    }

    /// Populate tags and scalar-leaf capacities from the shared instantiated fields.
    fn declare_field(
        &mut self,
        name: &str,
        tags: &[String],
        input: bool,
        meta: &Meta,
        bus: Option<&InstantiatedBus>,
        dimensions: &[Expression],
        parent_dimensions: Option<&[usize]>,
    ) -> Result<Option<usize>> {
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
                self.constant_params.push(param.clone());
                Some(Expression::Variable { meta: meta.clone(), name: param, access: vec![] })
            } else {
                None
            };
            self.flow
                .tags
                .insert(key, Tag { declared: true, explicit: input, value, initialized: input });
        }
        if let Some(bus) = bus {
            leaves = Some(0usize);
            self.buses.insert(name.to_owned());
            self.identities.insert(name.to_owned(), bus.identity.clone());
            for field in &bus.fields {
                let field = self.declare_field(
                    &format!("{name}.{}", field.name),
                    &field.tags,
                    input,
                    field.source.as_ref().expect("generic source"),
                    field.nested.as_deref(),
                    &field.dimensions,
                    all_dimensions.as_deref(),
                )?;
                leaves = leaves.zip(field).and_then(|(a, b)| a.checked_add(b));
            }
        }
        let capacity = if let Some((dims, leaves)) = all_dimensions.zip(leaves) {
            let total = dims
                .iter()
                .try_fold(leaves, |n, d| n.checked_mul(*d))
                .ok_or_else(|| anyhow!("bus signal size overflow"))?;
            Some(LeafCapacity {
                dimensions: dims,
                scalar_leaves: leaves,
                remaining: if input { 0 } else { total },
            })
        } else {
            None
        };
        self.flow
            .capacities
            .insert(name.to_owned(), Capacity { complete: input, leaves: capacity });
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

    /// Fold local values from the leaves up so computed indices select known elements.
    /// Keep this separate from expression rewriting: these facts select control flow
    /// and capture tag values, while ordinary reads use the original declarations.
    fn constant_expression(&self, expr: &Expression) -> Result<Expression> {
        let mut expr = expr.clone();
        match &mut expr {
            Expression::Variable { name, access, .. } => {
                for item in access.iter_mut() {
                    if let Access::ArrayAccess(index) = item {
                        *index = self.constant_expression(index)?;
                    }
                }
                if let Some(value) = self.flow.constants.get(name) {
                    let indices = access
                        .iter()
                        .map(|item| match item {
                            Access::ArrayAccess(index) => Some(index.clone()),
                            Access::ComponentAccess(_) => None,
                        })
                        .collect::<Option<Vec<_>>>();
                    if let Some(indices) = indices {
                        return self.normalize(crate::bus::index_expression(value, &indices));
                    }
                }
            }
            Expression::InfixOp { lhe, rhe, .. } => {
                **lhe = self.constant_expression(lhe)?;
                **rhe = self.constant_expression(rhe)?;
            }
            Expression::PrefixOp { rhe, .. } => **rhe = self.constant_expression(rhe)?,
            Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
                **cond = self.constant_expression(cond)?;
                if let Expression::Number(_, value) = cond.as_ref() {
                    return self.constant_expression(if value != &0.into() {
                        if_true
                    } else {
                        if_false
                    });
                }
                **if_true = self.constant_expression(if_true)?;
                **if_false = self.constant_expression(if_false)?;
            }
            Expression::ArrayInLine { values, .. } => {
                for value in values {
                    *value = self.constant_expression(value)?;
                }
            }
            Expression::UniformArray { value, dimension, .. } => {
                **value = self.constant_expression(value)?;
                **dimension = self.constant_expression(dimension)?;
            }
            _ => return self.normalize(crate::bus::substitute(&expr, &self.flow.constants)),
        }
        // Children already contain snapshots. Substituting them again could bind
        // a captured parameter to a same-named local in the current scope.
        self.normalize(expr)
    }

    /// Capture whole-array copies and indexed writes without retaining stale local reads.
    fn assign_constant(&mut self, name: &str, access: &[Access], rhs: &Expression) -> Result<()> {
        // An unresolved local must not pass the parameter whitelist just because
        // it shadows that name. Check before substitution so saved outer values
        // remain valid even while their original parameter name is shadowed.
        if references_matching(rhs, &|_, name| {
            self.constant_params.iter().any(|param| param == name)
                && !self.flow.constants.contains_key(name)
                && self.constant_scopes.iter().any(|scope| scope.contains_key(name))
        }) {
            self.flow.constants.remove(name);
            return Ok(());
        }
        let value = self.constant_expression(rhs)?;
        let mut indices = Vec::new();
        for item in access {
            let index = match item {
                Access::ArrayAccess(index) => match self.constant_expression(index)? {
                    Expression::Number(_, value) => value.to_usize(),
                    _ => None,
                },
                Access::ComponentAccess(_) => None,
            };
            let Some(index) = index else {
                self.flow.constants.remove(name);
                return Ok(());
            };
            indices.push(index);
        }
        if is_constant_value(&value, &self.constant_params) {
            if indices.is_empty() {
                self.flow.constants.insert(name.to_owned(), value);
                return Ok(());
            }
            if self
                .flow
                .constants
                .get_mut(name)
                .is_some_and(|old| update_constant(old, &indices, value))
            {
                return Ok(());
            }
        }
        self.flow.constants.remove(name);
        Ok(())
    }

    /// Resolve a tag read before ordinary field-access generation.
    fn expression(&mut self, expr: &mut Expression) -> Result<()> {
        match expr {
            Expression::Variable { name, access, .. } => {
                if access.is_empty() {
                    if let Some(value) = self.iterations.get(name) {
                        *expr = value.clone();
                        return Ok(());
                    }
                }
                for access in access.iter_mut() {
                    if let Access::ArrayAccess(index) = access {
                        self.expression(index)?;
                    }
                }
                let key = self.path(name, access)?;
                if let Some(tag) = self.flow.tags.get(&key) {
                    let owner = key.rsplit_once('.').expect("tag path").0;
                    ensure!(
                        tag.explicit || self.flow.is_complete(owner),
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
                self.flow
                    .tags
                    .range(prefix.clone()..)
                    .take_while(|(key, _)| key.starts_with(&prefix))
                    .filter_map(|(key, tag)| {
                        let suffix = key.strip_prefix(&prefix)?;
                        let owner = key.rsplit_once('.').expect("tag path").0;
                        if tag.explicit || self.flow.is_complete(owner) {
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
            Expression::InlineSwitchOp { if_true, if_false, .. } => {
                let mut tags = self.source_tags(if_true)?;
                let other = self.source_tags(if_false)?;
                tags.retain(|key, tag| {
                    other.get(key).is_some_and(|t| same_value(&tag.value, &t.value))
                });
                tags
            }
            Expression::ArrayInLine { values, .. } => {
                let mut tags =
                    values.first().map(|v| self.source_tags(v)).transpose()?.unwrap_or_default();
                for value in values.iter().skip(1) {
                    let other = self.source_tags(value)?;
                    tags.retain(|key, tag| {
                        other.get(key).is_some_and(|t| same_value(&tag.value, &t.value))
                    });
                }
                tags
            }
            _ => BTreeMap::new(),
        })
    }

    /// Check nominal compatibility even when two instantiated buses have identical PODs.
    /// Unknown parameter equalities remain compile-time assertions for specialization.
    /// The array-parameter pass expands array equalities once their shapes are known.
    fn compatibility(
        &self,
        destinations: &[NominalBus],
        expr: &Expression,
        checks: &mut Vec<Statement>,
    ) -> Result<()> {
        if destinations.is_empty() {
            return Ok(());
        }
        match expr {
            Expression::Variable { name, access, meta } => {
                let sources = self.bus_identities(name, access)?;
                for (lhs, rhs) in
                    destinations.iter().flat_map(|lhs| sources.iter().map(move |rhs| (lhs, rhs)))
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
                        if same_value(&Some(a.clone()), &Some(b.clone())) {
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
                    self.compatibility(destinations, value, checks)?;
                }
            }
            Expression::UniformArray { value, .. } => {
                self.compatibility(destinations, value, checks)?;
            }
            Expression::InlineSwitchOp { if_true, if_false, .. } => {
                self.compatibility(destinations, if_true, checks)?;
                self.compatibility(destinations, if_false, checks)?;
            }
            _ => {}
        }
        Ok(())
    }

    /// Check corresponding array elements and every conditional bus alternative.
    fn equality_compatibility(
        &self,
        lhe: &Expression,
        rhe: &Expression,
        checks: &mut Vec<Statement>,
    ) -> Result<()> {
        if let (
            Expression::ArrayInLine { values: lhs, .. },
            Expression::ArrayInLine { values: rhs, .. },
        ) = (lhe, rhe)
        {
            if lhs.len() == rhs.len() {
                for (lhs, rhs) in lhs.iter().zip(rhs) {
                    self.equality_compatibility(lhs, rhs, checks)?;
                }
                return Ok(());
            }
        }
        match lhe {
            Expression::Variable { name, access, .. } => {
                self.compatibility(&self.bus_identities(name, access)?, rhe, checks)?;
            }
            Expression::ArrayInLine { values, .. } => {
                for value in values {
                    self.equality_compatibility(value, rhe, checks)?;
                }
            }
            Expression::UniformArray { value, .. } => {
                self.equality_compatibility(value, rhe, checks)?;
            }
            Expression::InlineSwitchOp { if_true, if_false, .. } => {
                self.equality_compatibility(if_true, rhe, checks)?;
                self.equality_compatibility(if_false, rhe, checks)?;
            }
            _ => {}
        }
        Ok(())
    }

    /// Propagate tags with Circom's declared/explicit/initialized rules.
    fn assign(&mut self, dst: &str, source: BTreeMap<String, Tag>) {
        let prefix = format!("{dst}.");
        let keys = self
            .flow
            .tags
            .range(prefix.clone()..)
            .take_while(|(key, _)| key.starts_with(&prefix))
            .map(|(key, _)| key.clone())
            .collect::<Vec<_>>();
        for key in keys {
            let mut tag = self.flow.tags.remove(&key).expect("collected key");
            let previous = tag.value.clone();
            let incoming = source.get(&key[prefix.len()..]);
            if !tag.explicit {
                if !tag.initialized {
                    tag.value = incoming.and_then(|t| t.value.clone());
                } else if incoming.is_none_or(|t| !same_value(&tag.value, &t.value)) {
                    if !tag.declared {
                        self.component_worklist.changed(&key);
                        continue;
                    }
                    tag.value = None;
                }
            }
            tag.initialized = true;
            if !same_value(&previous, &tag.value) {
                self.component_worklist.changed(&key);
            }
            self.flow.tags.insert(key, tag);
        }
        if !self.flow.initialized.contains(dst) {
            for (suffix, mut tag) in source {
                tag.declared = false;
                tag.explicit = false;
                tag.initialized = true;
                if let std::collections::btree_map::Entry::Vacant(entry) =
                    self.flow.tags.entry(format!("{prefix}{suffix}"))
                {
                    self.component_worklist.changed(entry.key());
                    entry.insert(tag);
                }
            }
        }
        self.flow.initialized.insert(dst.to_owned());
    }

    /// Bind an instance's ordinary arguments and currently known input tag values.
    fn component_bindings(
        &self,
        name: &str,
        component: &Component<'_>,
    ) -> (HashMap<String, Expression>, HashSet<String>) {
        let state = self.flow.component_states.get(name);
        let args = state.map_or(&component.args, |state| &state.args);
        let mut bindings = HashMap::new();
        let mut missing = HashSet::new();
        for (param, value) in component.summary.params.iter().zip(args) {
            if let Some(value) = value {
                bindings.insert(param.clone(), value.clone());
            } else {
                missing.insert(param.clone());
            }
        }
        for (path, param) in &component.summary.inputs {
            let tag = if state.is_some() {
                self.flow.tags.get(&format!("{name}.{path}"))
            } else {
                component.input_tags.as_ref().and_then(|tags| tags.get(path))
            };
            if let Some(value) = tag.and_then(|t| t.value.clone()) {
                bindings.insert(param.clone(), value);
            } else {
                missing.insert(param.clone());
            }
        }
        (bindings, missing)
    }

    /// Resolve every selectable component using its own bindings. Symbolic indices
    /// may select concrete constructors or constructors with different index spellings.
    /// Instantiate on use so flow joins cannot leave stale input tag arguments.
    fn bus_identities(&self, name: &str, access: &[Access]) -> Result<Vec<NominalBus>> {
        if !self.component_roots.contains(name) {
            return Ok(self
                .identities
                .get(&self.path(name, access)?)
                .cloned()
                .into_iter()
                .collect());
        }
        let indices = self.component_indices(access)?;
        let field = access
            .iter()
            .filter_map(|access| match access {
                Access::ComponentAccess(field) => Some(field.as_str()),
                Access::ArrayAccess(_) => None,
            })
            .collect::<Vec<_>>()
            .join(".");
        let mut candidates = Vec::new();
        for (path, constructors) in &self.components {
            // Live state already joins the reaching occurrences. Otherwise inspect
            // each saved constructor without reviving possibly absent tag state.
            let constructors = if self.flow.component_states.contains_key(path) {
                &constructors[constructors.len() - 1..]
            } else {
                constructors.as_slice()
            };
            for component in constructors {
                if component.name != name
                    || component.indices.len() != indices.len()
                    || component.indices.iter().zip(&indices).any(|(a, b)| {
                        matches!((a, b), (Expression::Number(_, a), Expression::Number(_, b)) if a != b)
                    })
                {
                    continue;
                }
                if let Some(bus) = component.summary.buses.get(&field) {
                    candidates.push((path, component, bus));
                }
            }
        }
        candidates.sort_unstable_by_key(|(path, component, _)| (*path, component.position));
        let mut buses = Vec::new();
        let mut seen = HashSet::new();
        for (path, component, bus) in candidates {
            let (bindings, missing) = self.component_bindings(path, component);
            let arguments = bus
                .arguments
                .iter()
                .map(|arg| self.normalize(crate::bus::substitute(arg, &bindings)))
                .collect::<Result<Vec<_>>>()?;
            if !self.flow.component_states.contains_key(path) {
                ensure!(
                    arguments.iter().all(|arg| {
                        !references_any(arg, &missing) && is_constant_value(arg, &self.params)
                    }),
                    "cannot resolve parameters for bus {} of component {path}",
                    bus.definition
                );
            }
            let key = (
                &bus.definition,
                arguments.iter().map(crate::bus::expression_key).collect::<Vec<_>>(),
            );
            if seen.insert(key) {
                buses.push(NominalBus { definition: bus.definition.clone(), arguments });
            }
        }
        Ok(buses)
    }

    /// Substitute only affected summaries, notifying dependents when outputs change.
    fn refresh_components(&mut self) -> Result<()> {
        while let Some(name) = self.component_worklist.pop() {
            // All occurrences have the same callee, but ordinary arguments belong to
            // the current flow state rather than the last constructor visited.
            let component = self.components[&name].last().expect("component has a constructor");
            if !self.flow.component_states.contains_key(&name) {
                continue;
            }
            let (bindings, missing) = self.component_bindings(&name, component);
            for (path, tag) in &component.summary.outputs {
                let mut tag = tag.clone();
                tag.value = tag
                    .value
                    .and_then(|value| {
                        let value = crate::bus::substitute(&value, &bindings);
                        (!references_any(&value, &missing)).then_some(value)
                    })
                    .map(|value| self.normalize(value))
                    .transpose()?;
                let key = format!("{name}.{path}");
                let changed = self
                    .flow
                    .tags
                    .get(&key)
                    .is_none_or(|previous| !same_value(&previous.value, &tag.value));
                self.flow.tags.insert(key.clone(), tag);
                if changed {
                    self.component_worklist.changed(&key);
                }
            }
        }
        Ok(())
    }

    /// Keep simple array-wide transfers compact; analyze varying metadata per iteration.
    fn needs_iteration_analysis(&self, stmt: &Statement, induction: &str) -> bool {
        if uses_variables(stmt, &self.tagged_components) {
            return true;
        }
        let mut all = Vec::new();
        statements(stmt, &mut all);
        // Signal and bus tag paths are array-wide, so straight-line signal writes
        // can repeat their leaf counts. Branches, nested loops, and local or tag
        // assignments can change the transfer from one induction value to the next.
        // fixed_loop has already verified the sole write to the induction variable.
        if all.iter().all(|stmt| match stmt {
            Statement::Block { .. } | Statement::InitializationBlock { .. } => true,
            Statement::Substitution { var, op, .. } => op.is_signal_operator() || var == induction,
            _ => false,
        }) {
            return false;
        }
        let roots = self
            .flow
            .tags
            .keys()
            .filter_map(|path| path.split_once('.').map(|(root, _)| root.to_owned()))
            .collect();
        uses_variables(stmt, &roots)
    }

    /// Recognize a fixed increasing loop with an invariant bound and one trailing step.
    fn fixed_loop(
        &self,
        cond: &Expression,
        stmt: &Statement,
    ) -> Result<Option<(String, i64, i64)>> {
        let Expression::InfixOp { lhe, infix_op: ExpressionInfixOpcode::Lesser, rhe, .. } = cond
        else {
            return Ok(None);
        };
        let Expression::Variable { name, access, .. } = lhe.as_ref() else {
            return Ok(None);
        };
        let Statement::Block { stmts, .. } = stmt else {
            return Ok(None);
        };
        let Some(Statement::Substitution {
            var,
            access: step_access,
            op: AssignOp::AssignVar,
            rhe: step,
            ..
        }) = stmts.last()
        else {
            return Ok(None);
        };
        let unit_step = matches!(step, Expression::InfixOp { lhe, infix_op: ExpressionInfixOpcode::Add, rhe, .. }
            if matches!(lhe.as_ref(), Expression::Variable { name: n, access, .. } if n == name && access.is_empty())
                && matches!(rhe.as_ref(), Expression::Number(_, n) if n == &1.into()));
        if !access.is_empty() || var != name || !step_access.is_empty() || !unit_step {
            return Ok(None);
        }
        let mut all = Vec::new();
        statements(stmt, &mut all);
        let writes = all
            .iter()
            .filter_map(|stmt| match stmt {
                Statement::Substitution { var, .. } => Some(var.clone()),
                Statement::Declaration { name, .. } => Some(name.clone()),
                _ => None,
            })
            .collect::<Vec<_>>();
        if writes.iter().filter(|var| *var == name).count() != 1
            || references_any(rhe, &writes.into_iter().collect())
        {
            return Ok(None);
        }
        let start = self
            .flow
            .constants
            .get(name)
            .map(|expr| crate::shared::try_compute_as_i64(expr, self.prime))
            .transpose()?
            .flatten();
        let end = crate::shared::try_compute_as_i64(&self.constant_expression(rhe)?, self.prime)?;
        Ok(start.zip(end).map(|(start, end)| (name.clone(), start, end)))
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
            Statement::Block { stmts, .. } => {
                self.constant_scopes.push(HashMap::new());
                let result = stmts.iter_mut().try_for_each(|stmt| self.statement(stmt));
                for (name, value) in self.constant_scopes.pop().expect("active block scope") {
                    if let Some(value) = value {
                        self.flow.constants.insert(name, value);
                    } else {
                        self.flow.constants.remove(&name);
                    }
                }
                result?;
            }
            Statement::InitializationBlock { initializations: stmts, .. } => {
                // Declaration groups belong to the enclosing lexical block.
                for stmt in stmts {
                    self.statement(stmt)?;
                }
            }
            Statement::Declaration { meta, name, dimensions, .. } => {
                if !self.iterations.is_empty() {
                    meta.elem_id = self.next_declaration;
                    self.next_declaration += 1;
                }
                for dim in dimensions {
                    self.expression(dim)?;
                }
                // Save at the declaration, preserving any preceding outer writes.
                let previous = self.flow.constants.remove(name);
                self.constant_scopes
                    .last_mut()
                    .expect("declaration inside a block")
                    .insert(name.clone(), previous);
            }
            Statement::Substitution { var, access, op, rhe, .. } => {
                for access in access.iter_mut() {
                    if let Access::ArrayAccess(index) = access {
                        self.expression(index)?;
                    }
                }
                let dst = self.path(var, access)?;
                if *op == AssignOp::AssignVar && self.flow.tags.contains_key(&dst) {
                    self.expression(rhe)?;
                    let value =
                        self.normalize(crate::bus::substitute(rhe, &self.flow.constants))?;
                    let owner = dst.rsplit_once('.').expect("tag path").0;
                    ensure!(
                        !self
                            .flow
                            .initialized
                            .iter()
                            .any(|path| below(path, owner) || below(owner, path)),
                        "tag {dst} assigned after signal initialization"
                    );
                    let tag = self.flow.tags.get_mut(&dst).expect("tag exists");
                    ensure!(
                        tag.declared && !tag.explicit,
                        "tag {dst} is not assignable or was assigned twice"
                    );
                    tag.explicit = true;
                    tag.value = Some(value);
                    self.component_worklist.changed(&dst);
                    self.refresh_components()?;
                    *stmt = Statement::Block { meta, stmts: vec![] };
                    return Ok(());
                }
                self.expression(rhe)?;
                if let Expression::Call { id, args, meta } = unwrap_parallel(rhe) {
                    if let Some(callee) = self.summaries.get(id) {
                        let occurrence = self.constructors.entry(meta.start).or_default();
                        let position = (meta.start, *occurrence);
                        *occurrence += 1;
                        self.component_worklist.register(&dst, &callee.summary);
                        // Completion is an immutable callee fact, independent of input tags.
                        for (path, capacity) in &callee.summary.output_capacities {
                            self.flow.capacities.insert(format!("{dst}.{path}"), capacity.clone());
                        }
                        for path in callee.summary.buses.keys() {
                            self.buses.insert(format!("{dst}.{path}"));
                        }
                        // Output tags may be read or refreshed after argument locals change.
                        let args = args
                            .iter()
                            .map(|arg| self.constant_expression(arg).map(Some))
                            .collect::<Result<Vec<_>>>()?;
                        let indices = self.component_indices(access)?;
                        let components = self.components.entry(dst.clone()).or_default();
                        self.flow.component_states.insert(
                            dst,
                            ComponentState {
                                args: args.clone(),
                                occurrences: vec![components.len()],
                            },
                        );
                        components.push(Component {
                            name: var.clone(),
                            indices,
                            args,
                            source: meta.clone(),
                            summary: &callee.summary,
                            position,
                            input_tags: None,
                        });
                        self.refresh_components()?;
                        return Ok(());
                    }
                }
                if op.is_signal_operator() {
                    self.compatibility(&self.bus_identities(var, access)?, rhe, &mut checks)?;
                    let tags =
                        if *op == AssignOp::AssignConstraintSignal || self.buses.contains(&dst) {
                            self.source_tags(rhe)?
                        } else {
                            BTreeMap::new()
                        };
                    self.assign(&dst, tags);
                    self.flow.initialize(&dst, access);
                    self.refresh_components()?;
                } else if !crate::bus::is_constructor(rhe) {
                    self.assign_constant(var, access, rhe)?;
                }
            }
            Statement::ConstraintEquality { lhe, rhe, .. } => {
                self.expression(lhe)?;
                self.expression(rhe)?;
                self.equality_compatibility(lhe, rhe, &mut checks)?;
            }
            Statement::IfThenElse { cond, if_case, else_case, .. } => {
                self.expression(cond)?;
                let condition = self.constant_expression(cond)?;
                if let Some(value) = crate::shared::try_compute_biguint(&condition, self.prime)? {
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
                let incoming = self.flow.fork();
                self.statement(if_case)?;
                let then_state = std::mem::replace(&mut self.flow, incoming);
                if let Some(other) = else_case {
                    self.statement(other)?;
                }
                self.merge_flow(then_state, &condition, &meta);
            }
            Statement::While { cond, stmt: loop_body, .. } => {
                self.expression(cond)?;
                let fixed = self.fixed_loop(cond, loop_body)?;
                let trips = fixed
                    .as_ref()
                    .map(|(_, start, end)| usize::try_from(end.saturating_sub(*start).max(0)))
                    .transpose()?;
                if trips == Some(0) {
                    **loop_body = Statement::Block { meta: meta.clone(), stmts: vec![] };
                    return Ok(());
                }
                if let Some((ref name, start, end)) = fixed {
                    if self.needs_iteration_analysis(loop_body, name) {
                        // Resolve each iteration before merging branches: tag propagation and
                        // completion can depend on the induction value even without components.
                        // This also gives components concrete paths and separate constructors.
                        // Keep the source metadata for accurate diagnostics.
                        let mut iterations = Vec::new();
                        for value in start..end {
                            self.iterations.insert(
                                name.clone(),
                                Expression::Number(meta.clone(), value.into()),
                            );
                            let mut iteration = (**loop_body).clone();
                            self.statement(&mut iteration)?;
                            iterations.push(iteration);
                        }
                        self.iterations.remove(name);
                        *stmt = Statement::Block { meta, stmts: iterations };
                        return Ok(());
                    }
                }
                let incoming = self.flow.fork();
                // A retained loop body must be valid for every iteration, so its
                // writes invalidate incoming constants before branch selection.
                let mut body_statements = Vec::new();
                statements(loop_body, &mut body_statements);
                for stmt in body_statements {
                    match stmt {
                        Statement::Substitution { var, .. }
                        | Statement::Declaration { name: var, .. } => {
                            self.flow.constants.remove(var);
                        }
                        _ => {}
                    }
                }
                self.statement(loop_body)?;
                if let Some(trips) = trips {
                    // Other fixed loops account for all leaves without expanding the IR.
                    for (owner, capacity) in &mut self.flow.capacities {
                        if let Some(initial) = incoming.capacities.get(owner) {
                            capacity.repeat(initial, trips);
                        }
                    }
                    self.flow.constants.retain(|name, value| {
                        incoming.constants.get(name).is_some_and(|old| {
                            crate::bus::expression_key(old) == crate::bus::expression_key(value)
                        })
                    });
                    // The recognized unit step reaches the bound after a positive loop.
                    if let Some((name, _, end)) = fixed {
                        self.flow
                            .constants
                            .insert(name, Expression::Number(meta.clone(), end.into()));
                    }
                } else {
                    // An unknown trip count may be zero, so body effects are conditional.
                    let body_state = std::mem::replace(&mut self.flow, incoming);
                    self.merge_flow(body_state, cond, &meta);
                }
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
fn append_arguments(
    stmt: &mut Statement,
    arguments: &HashMap<(usize, usize), Vec<Expression>>,
    occurrences: &mut HashMap<usize, usize>,
) {
    match stmt {
        Statement::Block { stmts, .. }
        | Statement::InitializationBlock { initializations: stmts, .. } => {
            for stmt in stmts {
                append_arguments(stmt, arguments, occurrences);
            }
        }
        Statement::Substitution { rhe, .. } => {
            if let Expression::Call { meta, args, .. } = unwrap_parallel_mut(rhe) {
                let occurrence = occurrences.entry(meta.start).or_default();
                if let Some(extra) = arguments.get(&(meta.start, *occurrence)) {
                    args.extend(extra.iter().cloned());
                }
                *occurrence += 1;
            }
        }
        Statement::IfThenElse { if_case, else_case, .. } => {
            append_arguments(if_case, arguments, occurrences);
            if let Some(stmt) = else_case {
                append_arguments(stmt, arguments, occurrences);
            }
        }
        Statement::While { stmt, .. } => append_arguments(stmt, arguments, occurrences),
        _ => {}
    }
}

/// Analyze callees first, so callers can use symbolic summaries of their output tags.
fn analyze(
    name: &str,
    program: &ProgramArchive,
    prime: &BigUint,
    summaries: &mut HashMap<String, AnalyzedTemplate>,
    active: &mut HashSet<String>,
    callee_first: &mut Vec<String>,
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
                    analyze(id, program, prime, summaries, active, callee_first)?;
                }
            }
        }
    }
    let mut analysis = Analysis {
        program,
        prime,
        summaries,
        params: template.get_name_of_params().clone(),
        constant_params: template
            .get_name_of_params()
            .iter()
            .filter(|param| !assigns_parameter(template.get_body(), param, &mut false))
            .cloned()
            .collect(),
        flow: FlowState::default(),
        constant_scopes: Vec::new(),
        buses: HashSet::new(),
        inputs: BTreeMap::new(),
        required: HashSet::new(),
        component_roots: HashSet::new(),
        tagged_components: all
            .iter()
            .filter_map(|stmt| {
                let Statement::Substitution { var, rhe, .. } = stmt else {
                    return None;
                };
                let Expression::Call { id, .. } = unwrap_parallel(rhe) else {
                    return None;
                };
                let summary = &summaries.get(id)?.summary;
                (!summary.inputs.is_empty() || !summary.outputs.is_empty()).then(|| var.clone())
            })
            .collect(),
        components: HashMap::new(),
        component_worklist: ComponentWorklist::default(),
        constructors: HashMap::new(),
        identities: BTreeMap::new(),
        iterations: HashMap::new(),
        next_declaration: all.iter().map(|stmt| stmt.get_meta().elem_id).max().unwrap_or(0) + 1,
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
            analysis.declare(name, xtype, input, meta, args, dimensions)?;
        }
    }
    let mut body = template.get_body().clone();
    analysis
        .statement(&mut body)
        .with_context(|| format!("template {name}, source {:?}", template.get_param_location()))?;
    let mut arguments = HashMap::new();
    for (component_name, component) in analysis
        .components
        .iter()
        .flat_map(|(name, components)| components.iter().map(move |component| (name, component)))
    {
        let mut args = Vec::new();
        for path in component.summary.inputs.keys() {
            let key = format!("{component_name}.{path}");
            let location = source_location(program, &component.source);
            let tag = component
                .input_tags
                .as_ref()
                .map_or_else(|| analysis.flow.tags.get(&key), |tags| tags.get(path))
                .ok_or_else(|| {
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
    append_arguments(&mut body, &arguments, &mut HashMap::new());
    let outputs = analysis
        .flow
        .tags
        .into_iter()
        .filter(|(key, _)| template.get_outputs().keys().any(|output| below(key, output)))
        .collect();
    let output_capacities = analysis
        .flow
        .capacities
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
        output_capacities,
    };
    summaries.insert(name.to_owned(), AnalyzedTemplate { summary, body });
    active.remove(name);
    callee_first.push(name.to_owned());
    Ok(())
}

/// Resolve symbolic metadata before declaration/type collection.
pub(crate) fn prepare(program: &ProgramArchive, prime: &BigUint) -> Result<ProgramArchive> {
    // Presence-only signal annotations need no value lowering. Preserve the existing
    // symbolic path unless buses or explicit tag reads/writes require metadata analysis.
    if program.buses.is_empty()
        && !program.templates.values().any(|template| {
            uses_matching(template.get_body(), &|meta, _| {
                let knowledge = meta.get_type_knowledge();
                knowledge.is_initialized() && knowledge.is_tag()
            })
        })
    {
        return Ok(program.clone());
    }
    let program = prepare_main_arrays(program)?;
    let program = &program;
    let mut summaries = HashMap::new();
    let mut callee_first = Vec::new();
    let mut names = program.templates.keys().cloned().collect::<Vec<_>>();
    names.sort();
    for name in names {
        analyze(&name, program, prime, &mut summaries, &mut HashSet::new(), &mut callee_first)?;
    }
    let mut result = program.clone();
    for (name, AnalyzedTemplate { summary, body }) in summaries {
        let old = &program.templates[&name];
        let mut params = summary.params;
        params.extend(summary.inputs.values().cloned());
        let template = rebuild_template(old, name.clone(), params, body);
        if let Expression::Call { id, args, meta } = &mut result.initial_template_call {
            if id == &name {
                ensure!(
                    summary.required_values.is_empty(),
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
    prepare_layout_params(result, prime, &callee_first)
}

/// Make derived dimensions explicit parameters so substitution can cross component boundaries
/// without referring to a `poly.expr` owned by another template.
fn prepare_layout_params(
    mut program: ProgramArchive,
    prime: &BigUint,
    callee_first: &[String],
) -> Result<ProgramArchive> {
    let mut extras = HashMap::<String, BTreeMap<String, Expression>>::new();
    // Reuse tag analysis's dependency order: every callee's derived dimensions are
    // complete before forwarding them through its caller, even without local buses.
    for name in callee_first {
        let template = &program.templates[name];
        let mut all = Vec::new();
        statements(template.get_body(), &mut all);
        let mut expressions = Vec::new();
        for stmt in all {
            match stmt {
                Statement::Declaration { name, xtype, dimensions, .. } => {
                    if matches!(xtype, VariableType::Signal(..) | VariableType::Bus(..)) {
                        expressions.extend(dimensions.iter().cloned());
                    }
                    if let VariableType::Bus(bus, ..) = xtype {
                        let args = crate::bus::constructor(template.get_body_as_vec(), name)
                            .map_or(&[][..], |(_, args)| args);
                        expressions.extend(crate::bus::dimensions(&program, bus, args)?);
                    }
                }
                Statement::Substitution { rhe, .. } => {
                    let Expression::Call { id, args, .. } = unwrap_parallel(rhe) else {
                        continue;
                    };
                    if let Some(callee) = program.templates.get(id) {
                        let bindings = callee
                            .get_name_of_params()
                            .iter()
                            .cloned()
                            .zip(args.iter().cloned())
                            .collect();
                        expressions.extend(
                            extras[id].values().map(|expr| crate::bus::substitute(expr, &bindings)),
                        );
                    }
                }
                _ => {}
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
        program.templates.insert(name.clone(), rebuild_template(old, name.clone(), params, body));
    }
    if let Expression::Call { id, args, .. } = &mut program.initial_template_call {
        let bindings = old_templates[id]
            .get_name_of_params()
            .iter()
            .cloned()
            .zip(args.iter().cloned())
            .collect();
        for expr in extras[id].values() {
            let expr = crate::bus::substitute(expr, &bindings);
            // Main's parameter attribute requires literal values, including dimensions
            // obtained from pure function calls after binding the main arguments.
            let value = crate::template_recursion::value(
                &expr,
                &HashMap::new(),
                prime,
                &program.functions,
            )?;
            args.push(value.map_or_else(
                || expr.clone(),
                |value| Expression::Number(expr.get_meta().clone(), value.into()),
            ));
        }
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
    let template = rebuild_template(old, destination.clone(), params, body);
    result.templates.insert(destination.clone(), template);
    if let Expression::Call { id, args, .. } = &mut result.initial_template_call {
        *id = destination;
        *args = actuals;
    }
    Ok(result)
}
