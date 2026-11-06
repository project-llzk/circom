//! Bus data layouts. Bus identity is compile-time metadata, never a component handle.

use crate::shared::{ArrayDimExprKind, ExprToPolyBinding};
use anyhow::{anyhow, Context, Result};
use llzk::prelude::{PodRecordAttribute, PodType};
use num_traits::ToPrimitive;
use program_structure::ast::{Access, AssignOp, Expression, Meta, Statement, VariableType};
use std::collections::HashMap;

use crate::{program_ext::ProgramLike, shared::LlzkCodegen};

/// Nominal layout key. Concrete IDs already include executed parameter bindings.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub(crate) enum BusIdentity {
    /// An entry in the executed program's bus table.
    Concrete(usize),
    /// A generic definition and its arguments in an enclosing symbolic scope.
    Symbolic { definition: String, arguments: Vec<String>, scope: usize },
}

/// Source-level nominal identity, retaining arguments for tag propagation and compatibility.
#[derive(Clone, Debug)]
pub(crate) struct NominalBus {
    /// Bus definition name, independent of its structural POD representation.
    pub(crate) definition: String,
    /// Constructor arguments substituted into the enclosing template's scope.
    pub(crate) arguments: Vec<Expression>,
}

/// One field in declaration order, with source metadata kept outside the POD type.
#[derive(Clone, Debug)]
pub(crate) struct BusField<D, I> {
    /// Source field name, independent of the variable owning the bus.
    pub(crate) name: String,
    /// Array dimensions surrounding the scalar or nested bus.
    pub(crate) dimensions: Vec<D>,
    /// Declared tags (unavailable in executed layouts); never lowered as POD records.
    pub(crate) tags: Vec<String>,
    /// Nested bus, or `None` for a scalar signal.
    pub(crate) nested: Option<Box<BusLayout<D, I>>>,
    /// Generic field declaration location (the VCP has no field source locations).
    pub(crate) source: Option<Meta>,
}

/// Shared field description; identity and tags never become signal or component handles.
#[derive(Clone, Debug)]
pub(crate) struct BusLayout<D, I> {
    /// Definition and parameter identity used for caching, separately from POD unification.
    pub(crate) identity: I,
    /// Ordered records of this bus.
    pub(crate) fields: Vec<BusField<D, I>>,
}

/// A bus and all its nested fields instantiated in the caller's symbolic scope.
pub(crate) type InstantiatedBus = BusLayout<Expression, NominalBus>;

impl BusLayout<usize, BusIdentity> {
    /// Recover an executed layout without relying on alphabetical map order.
    fn concrete(program: &impl ProgramLike, id: usize) -> Result<Self> {
        let bus = program
            .concrete_buses()
            .get(id)
            .ok_or_else(|| anyhow!("unknown concrete bus identity {id}"))?;
        let mut fields = bus.fields.iter().collect::<Vec<_>>();
        fields.sort_by_key(|(_, field)| field.field_id);
        Ok(Self {
            identity: BusIdentity::Concrete(id),
            fields: fields
                .into_iter()
                .map(|(name, field)| {
                    Ok(BusField {
                        name: name.clone(),
                        dimensions: field.dimensions.clone(),
                        tags: vec![],
                        source: None,
                        nested: field
                            .bus_id
                            .map(|id| Self::concrete(program, id).map(Box::new))
                            .transpose()?,
                    })
                })
                .collect::<Result<_>>()?,
        })
    }

    /// Lower fields recursively and cache the structural POD by nominal identity.
    fn lower<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Result<PodType<'ctx>> {
        if let Some(ty) = codegen.bus_layouts.borrow().get(&self.identity) {
            return Ok(*ty);
        }
        let records = self
            .fields
            .iter()
            .map(|field| {
                let element = match &field.nested {
                    Some(bus) => bus.lower(codegen)?.into(),
                    None => codegen.felt_type().into(),
                };
                Ok(PodRecordAttribute::new(
                    &field.name,
                    codegen.type_from_dimension_consts(element, &field.dimensions)?,
                ))
            })
            .collect::<Result<Vec<_>>>()?;
        let ty = PodType::new(codegen.context, &records);
        codegen.bus_layouts.borrow_mut().insert(self.identity.clone(), ty);
        Ok(ty)
    }
}

impl InstantiatedBus {
    /// Instantiate a definition in caller scope before creating any polymorphic bindings.
    pub(crate) fn instantiate(
        program: &impl ProgramLike,
        name: &str,
        args: &[Expression],
    ) -> Result<Self> {
        let bus =
            program.bus_definition(name).ok_or_else(|| anyhow!("unknown bus definition {name}"))?;
        anyhow::ensure!(
            args.len() == bus.get_name_of_params().len(),
            "bus {name} requires {} parameters, got {}",
            bus.get_name_of_params().len(),
            args.len()
        );
        let params = bus
            .get_name_of_params()
            .iter()
            .cloned()
            .zip(args.iter().cloned())
            .collect::<HashMap<_, _>>();
        let mut decls = Vec::new();
        declarations(bus.get_body_as_vec(), &mut decls);
        let mut fields = Vec::new();
        for decl in decls {
            let Statement::Declaration { name, xtype, dimensions, meta, .. } = decl else {
                unreachable!()
            };
            let (tags, nested) = match xtype {
                VariableType::Signal(_, tags) => (tags, None),
                VariableType::Bus(bus_name, _, tags) => {
                    let args =
                        constructor(bus.get_body_as_vec(), meta).map_or(&[][..], |(_, args)| args);
                    let args = args.iter().map(|e| substitute(e, &params)).collect::<Vec<_>>();
                    (tags, Some(Box::new(Self::instantiate(program, bus_name, &args)?)))
                }
                _ => continue,
            };
            fields.push(BusField {
                name: name.clone(),
                dimensions: dimensions.iter().map(|e| substitute(e, &params)).collect(),
                tags: tags.clone(),
                nested,
                source: Some(meta.clone()),
            });
        }
        Ok(Self {
            identity: NominalBus { definition: name.to_owned(), arguments: args.to_vec() },
            fields,
        })
    }

    /// Collect dimensions in declaration order, visiting each field before its nested bus.
    pub(crate) fn dimensions(&self) -> Vec<Expression> {
        /// Append dimensions without rebuilding declarations or parameter bindings.
        fn collect(bus: &InstantiatedBus, out: &mut Vec<Expression>) {
            for field in &bus.fields {
                out.extend(field.dimensions.iter().cloned());
                if let Some(nested) = &field.nested {
                    collect(nested, out);
                }
            }
        }
        let mut result = Vec::new();
        collect(self, &mut result);
        result
    }

    /// Lower substituted dimensions through the existing polymorphic-expression machinery.
    fn lower<'ctx: 'val, 'val>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        bindings: &impl ExprToPolyBinding<'ctx, 'val>,
    ) -> Result<PodType<'ctx>> {
        let identity = BusIdentity::Symbolic {
            definition: self.identity.definition.clone(),
            arguments: self
                .identity
                .arguments
                .iter()
                .map(|arg| format!("{}@{}", expression_key(arg), arg.get_meta().start))
                .collect(),
            scope: codegen.current_body().map_or(0, |body| body.as_ptr() as usize),
        };
        if let Some(ty) = codegen.bus_layouts.borrow().get(&identity) {
            return Ok(*ty);
        }
        let names = bindings
            .poly_template_binding_names()
            .into_iter()
            .map(|(name, _)| name)
            .collect::<std::collections::HashSet<_>>();
        let mut records = Vec::new();
        for field in &self.fields {
            let element = match &field.nested {
                Some(bus) => bus.lower(codegen, bindings)?.into(),
                None => codegen.felt_type().into(),
            };
            let dimensions = field
                .dimensions
                .iter()
                .map(|expr| {
                    let alias = layout_param_name(expr);
                    if names.contains(&alias) {
                        Expression::Variable {
                            meta: expr.get_meta().clone(),
                            name: alias,
                            access: vec![],
                        }
                    } else {
                        expr.clone()
                    }
                })
                .collect::<Vec<_>>();
            let dims = bindings
                .get_poly_bindings::<ArrayDimExprKind>(codegen, &dimensions)
                .with_context(|| {
                    format!(
                        "bus field {} at {}",
                        field.name,
                        codegen.location_from_meta(field.source.as_ref().expect("generic source"))
                    )
                })?;
            records.push(PodRecordAttribute::new(
                &field.name,
                dims.type_from_dimension_exprs(element),
            ));
        }
        let ty = PodType::new(codegen.context, &records);
        codegen.bus_layouts.borrow_mut().insert(identity, ty);
        Ok(ty)
    }
}

/// Collect declarations in lexical order, matching BusData's declaration-order metadata.
fn declarations<'a>(body: &'a [Statement], out: &mut Vec<&'a Statement>) {
    for stmt in body {
        match stmt {
            Statement::Block { stmts, .. }
            | Statement::InitializationBlock { initializations: stmts, .. } => {
                declarations(stmts, out)
            }
            Statement::Declaration { .. } => out.push(stmt),
            _ => {}
        }
    }
}

/// Bus construction initializes a declared data layout, including uniform bus arrays.
pub(crate) fn is_constructor(expr: &Expression) -> bool {
    match expr {
        Expression::BusCall { .. } => true,
        Expression::UniformArray { value, .. } => is_constructor(value),
        Expression::ArrayInLine { values, .. } => {
            !values.is_empty() && values.iter().all(is_constructor)
        }
        _ => false,
    }
}

impl<'ast: 'r, 'ctx: 'r, 'r, P: ProgramLike> LlzkCodegen<'ast, 'ctx, 'r, P> {
    /// Lower an executed bus, using field IDs rather than the alphabetical field map.
    pub(crate) fn concrete_bus_type(&self, id: usize) -> Result<PodType<'ctx>> {
        if let Some(ty) = self.bus_layouts.borrow().get(&BusIdentity::Concrete(id)) {
            return Ok(*ty);
        }
        BusLayout::concrete(self.program, id)?.lower(self)
    }
}

/// Find a declaration's adjacent storage constructor, including array initializers.
/// Match declaration identity first: separate scopes may reuse the same bus name.
pub(crate) fn constructor<'a>(
    body: &'a [Statement],
    declaration: &Meta,
) -> Option<(&'a str, &'a [Expression])> {
    fn call(expr: &Expression) -> Option<(&str, &[Expression])> {
        match expr {
            Expression::BusCall { id, args, .. } => Some((id, args)),
            Expression::UniformArray { value, .. } => call(value),
            Expression::ArrayInLine { values, .. } => values.first().and_then(call),
            _ => None,
        }
    }
    for (index, stmt) in body.iter().enumerate() {
        let found = match stmt {
            Statement::Block { stmts, .. }
            | Statement::InitializationBlock { initializations: stmts, .. } => {
                constructor(stmts, declaration)
            }
            Statement::Declaration { meta, name, .. } if meta.elem_id == declaration.elem_id => {
                // The parser emits each declaration and its constructor together,
                // including within comma-separated declaration groups.
                return match body.get(index + 1) {
                    Some(Statement::Substitution {
                        var,
                        access,
                        op: AssignOp::AssignVar,
                        rhe,
                        ..
                    }) if var == name && access.is_empty() => call(rhe),
                    _ => None,
                };
            }
            Statement::IfThenElse { if_case, else_case, .. } => {
                constructor(std::slice::from_ref(if_case), declaration).or_else(|| {
                    else_case
                        .as_ref()
                        .and_then(|s| constructor(std::slice::from_ref(s), declaration))
                })
            }
            Statement::While { stmt, .. } => constructor(std::slice::from_ref(stmt), declaration),
            _ => None,
        };
        if found.is_some() {
            return found;
        }
    }
    None
}

/// Backend-only call representing indexing an expression, which Circom's AST only permits
/// on variables. The name cannot collide with a source-level function identifier.
pub(crate) const ARRAY_ACCESS: &str = "$bus_array_access";

/// Apply indices in caller scope, selecting literal elements without materializing the array.
/// Other array-valued expressions retain their indices for normal LLZK array-read lowering.
pub(crate) fn index_expression(actual: &Expression, indices: &[Expression]) -> Expression {
    let Some((index, rest)) = indices.split_first() else {
        return actual.clone();
    };
    match actual {
        Expression::Variable { meta, name, access } => {
            let mut access = access.clone();
            access.extend(indices.iter().cloned().map(Access::ArrayAccess));
            return Expression::Variable { meta: meta.clone(), name: name.clone(), access };
        }
        Expression::ArrayInLine { values, .. } => {
            if let Expression::Number(_, index) = index {
                if let Some(value) = index.to_usize().and_then(|index| values.get(index)) {
                    return index_expression(value, rest);
                }
            }
        }
        Expression::UniformArray { value, dimension, .. } => {
            if let (Expression::Number(_, index), Expression::Number(_, dimension)) =
                (index, dimension.as_ref())
            {
                if index.to_usize().zip(dimension.to_usize()).is_some_and(|(i, n)| i < n) {
                    return index_expression(value, rest);
                }
            }
        }
        Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
            return Expression::InlineSwitchOp {
                meta: meta.clone(),
                cond: cond.clone(),
                if_true: Box::new(index_expression(if_true, indices)),
                if_false: Box::new(index_expression(if_false, indices)),
            };
        }
        Expression::Call { id, args, .. } if id == ARRAY_ACCESS => {
            let combined = args[1..].iter().chain(indices).cloned().collect::<Vec<_>>();
            return index_expression(&args[0], &combined);
        }
        _ => {}
    }
    Expression::Call {
        meta: actual.get_meta().clone(),
        id: ARRAY_ACCESS.to_owned(),
        args: std::iter::once(actual.clone()).chain(indices.iter().cloned()).collect(),
    }
}

/// Substitute expressions before creating polymorphic bindings, preserving the caller's scope.
pub(crate) fn substitute(expr: &Expression, bindings: &HashMap<String, Expression>) -> Expression {
    let mut expr = expr.clone();
    match &mut expr {
        Expression::Variable { name, access, .. } if access.is_empty() => {
            if let Some(actual) = bindings.get(name) {
                return actual.clone();
            }
        }
        Expression::Variable { name, access, .. } => {
            for item in access.iter_mut() {
                if let Access::ArrayAccess(index) = item {
                    *index = substitute(index, bindings);
                }
            }
            if let Some(Expression::Variable { name: actual, access: prefix, .. }) =
                bindings.get(name)
            {
                *name = actual.clone();
                let mut combined = prefix.clone();
                combined.append(access);
                *access = combined;
            } else if let Some(actual) = bindings.get(name) {
                let indices = access
                    .iter()
                    .map(|item| match item {
                        Access::ArrayAccess(index) => Some(index.clone()),
                        Access::ComponentAccess(_) => None,
                    })
                    .collect::<Option<Vec<_>>>();
                if let Some(indices) = indices {
                    return index_expression(actual, &indices);
                }
            }
        }
        Expression::InfixOp { lhe, rhe, .. } => {
            **lhe = substitute(lhe, bindings);
            **rhe = substitute(rhe, bindings);
        }
        Expression::PrefixOp { rhe, .. } => **rhe = substitute(rhe, bindings),
        Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
            **cond = substitute(cond, bindings);
            **if_true = substitute(if_true, bindings);
            **if_false = substitute(if_false, bindings);
        }
        Expression::Call { id, args, .. } if id == ARRAY_ACCESS => {
            let args = args.iter().map(|arg| substitute(arg, bindings)).collect::<Vec<_>>();
            return index_expression(&args[0], &args[1..]);
        }
        Expression::Call { args, .. } | Expression::BusCall { args, .. } => {
            for arg in args {
                *arg = substitute(arg, bindings);
            }
        }
        Expression::ArrayInLine { values, .. } | Expression::Tuple { values, .. } => {
            for value in values {
                *value = substitute(value, bindings);
            }
        }
        Expression::UniformArray { value, dimension, .. } => {
            **value = substitute(value, bindings);
            **dimension = substitute(dimension, bindings);
        }
        _ => {}
    }
    expr
}

/// Construct a generic bus layout using the caller's polymorphic-expression machinery.
pub(crate) fn generic_type<'ctx: 'val, 'val>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    bindings: &impl ExprToPolyBinding<'ctx, 'val>,
    name: &str,
    args: &[Expression],
) -> Result<PodType<'ctx>> {
    InstantiatedBus::instantiate(codegen.program, name, args)?.lower(codegen, bindings)
}

/// Stable name for a derived dimension parameter within its enclosing template scope.
pub(crate) fn layout_param_name(expr: &Expression) -> String {
    format!("$layout${}", expression_key(expr))
}

/// Source-independent expression identity preserving grouping and array argument structure.
pub(crate) fn expression_key(expr: &Expression) -> String {
    match expr {
        Expression::Number(_, n) => n.to_string(),
        Expression::Variable { name, access, .. } => {
            let mut key = name.clone();
            for item in access {
                match item {
                    Access::ComponentAccess(field) => {
                        key.push('.');
                        key.push_str(field);
                    }
                    Access::ArrayAccess(index) => {
                        key.push_str(&format!("[{}]", expression_key(index)))
                    }
                }
            }
            key
        }
        Expression::InfixOp { lhe, infix_op, rhe, .. } => {
            format!("({}_{infix_op:?}_{})", expression_key(lhe), expression_key(rhe))
        }
        Expression::PrefixOp { prefix_op, rhe, .. } => {
            format!("{prefix_op:?}({})", expression_key(rhe))
        }
        Expression::InlineSwitchOp { cond, if_true, if_false, .. } => format!(
            "({}?{}:{})",
            expression_key(cond),
            expression_key(if_true),
            expression_key(if_false)
        ),
        Expression::Call { id, args, .. } | Expression::BusCall { id, args, .. } => {
            format!("{id}({})", args.iter().map(expression_key).collect::<Vec<_>>().join(","))
        }
        Expression::ArrayInLine { values, .. } => {
            format!("[{}]", values.iter().map(expression_key).collect::<Vec<_>>().join(","))
        }
        Expression::Tuple { values, .. } => {
            format!("({})", values.iter().map(expression_key).collect::<Vec<_>>().join(","))
        }
        Expression::UniformArray { value, dimension, .. } => {
            format!("[{};{}]", expression_key(value), expression_key(dimension))
        }
        Expression::ParallelOp { rhe, .. } => expression_key(rhe),
        Expression::AnonymousComp { id, params, signals, .. } => format!(
            "{id}({})({})",
            params.iter().map(expression_key).collect::<Vec<_>>().join(","),
            signals.iter().map(expression_key).collect::<Vec<_>>().join(",")
        ),
    }
}

/// Collect substituted field dimensions without creating IR or mixing bus parameter scopes.
pub(crate) fn dimensions(
    program: &impl ProgramLike,
    name: &str,
    args: &[Expression],
) -> Result<Vec<Expression>> {
    Ok(InstantiatedBus::instantiate(program, name, args)?.dimensions())
}
