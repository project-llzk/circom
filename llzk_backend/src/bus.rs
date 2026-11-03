//! Bus data layouts. Bus identity is compile-time metadata, never a component handle.

use crate::shared::{ArrayDimExprKind, ExprToPolyBinding};
use anyhow::{anyhow, Context, Result};
use llzk::prelude::{PodRecordAttribute, PodType};
use num_traits::ToPrimitive;
use program_structure::ast::{Access, Expression, Meta, Statement, VariableType};
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

/// One field in declaration order, with source metadata kept outside the POD type.
#[derive(Clone, Debug)]
struct BusField<D> {
    /// Source field name, independent of the variable owning the bus.
    name: String,
    /// Array dimensions surrounding the scalar or nested bus.
    dimensions: Vec<D>,
    /// Nested bus, or `None` for a scalar signal.
    nested: Option<Box<BusLayout<D>>>,
    /// Generic field declaration location (the VCP has no field source locations).
    source: Option<Meta>,
}

/// Shared data-only layout; identity never becomes a signal or component handle.
#[derive(Clone, Debug)]
struct BusLayout<D> {
    /// Definition and parameter identity used for caching, separately from POD unification.
    identity: BusIdentity,
    /// Ordered records of this bus.
    fields: Vec<BusField<D>>,
}

impl BusLayout<usize> {
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

impl BusLayout<Expression> {
    /// Instantiate a definition in caller scope before creating any polymorphic bindings.
    fn symbolic(
        program: &impl ProgramLike,
        name: &str,
        args: &[Expression],
        scope: usize,
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
            let nested = match xtype {
                VariableType::Signal(..) => None,
                VariableType::Bus(bus_name, ..) => {
                    let args =
                        constructor(bus.get_body_as_vec(), name).map_or(&[][..], |(_, args)| args);
                    let args = args.iter().map(|e| substitute(e, &params)).collect::<Vec<_>>();
                    Some(Box::new(Self::symbolic(program, bus_name, &args, scope)?))
                }
                _ => continue,
            };
            fields.push(BusField {
                name: name.clone(),
                dimensions: dimensions.iter().map(|e| substitute(e, &params)).collect(),
                nested,
                source: Some(meta.clone()),
            });
        }
        Ok(Self {
            identity: BusIdentity::Symbolic {
                definition: name.to_owned(),
                arguments: args
                    .iter()
                    .map(|arg| format!("{}@{}", expression_key(arg), arg.get_meta().start))
                    .collect(),
                scope,
            },
            fields,
        })
    }

    /// Lower substituted dimensions through the existing polymorphic-expression machinery.
    fn lower<'ctx: 'val, 'val>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        bindings: &impl ExprToPolyBinding<'ctx, 'val>,
    ) -> Result<PodType<'ctx>> {
        if let Some(ty) = codegen.bus_layouts.borrow().get(&self.identity) {
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
        codegen.bus_layouts.borrow_mut().insert(self.identity.clone(), ty);
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

/// Find the storage constructor associated with a declaration, including array initializers.
pub(crate) fn constructor<'a>(
    body: &'a [Statement],
    name: &str,
) -> Option<(&'a str, &'a [Expression])> {
    fn call(expr: &Expression) -> Option<(&str, &[Expression])> {
        match expr {
            Expression::BusCall { id, args, .. } => Some((id, args)),
            Expression::UniformArray { value, .. } => call(value),
            Expression::ArrayInLine { values, .. } => values.first().and_then(call),
            _ => None,
        }
    }
    for stmt in body {
        let found = match stmt {
            Statement::Block { stmts, .. }
            | Statement::InitializationBlock { initializations: stmts, .. } => {
                constructor(stmts, name)
            }
            Statement::Substitution { var, rhe, .. } if var == name => call(rhe),
            Statement::IfThenElse { if_case, else_case, .. } => {
                constructor(std::slice::from_ref(if_case), name).or_else(|| {
                    else_case.as_ref().and_then(|s| constructor(std::slice::from_ref(s), name))
                })
            }
            Statement::While { stmt, .. } => constructor(std::slice::from_ref(stmt), name),
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
fn index_expression(actual: &Expression, indices: &[Expression]) -> Expression {
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
    let scope = codegen.current_body().map_or(0, |body| body.as_ptr() as usize);
    BusLayout::symbolic(codegen.program, name, args, scope)?.lower(codegen, bindings)
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
    let bus = program.bus_definition(name).ok_or_else(|| anyhow!("unknown bus {name}"))?;
    let params = bus
        .get_name_of_params()
        .iter()
        .cloned()
        .zip(args.iter().cloned())
        .collect::<HashMap<_, _>>();
    fn walk(stmt: &Statement, out: &mut Vec<Statement>) {
        match stmt {
            Statement::Block { stmts, .. }
            | Statement::InitializationBlock { initializations: stmts, .. } => {
                for s in stmts {
                    walk(s, out);
                }
            }
            Statement::Declaration { .. } => out.push(stmt.clone()),
            _ => {}
        }
    }
    let mut decls = Vec::new();
    walk(bus.get_body(), &mut decls);
    let mut result = Vec::new();
    for decl in decls {
        if let Statement::Declaration { name, xtype, dimensions: dims, .. } = decl {
            result.extend(dims.iter().map(|e| substitute(e, &params)));
            if let VariableType::Bus(nested, ..) = xtype {
                let args =
                    constructor(bus.get_body_as_vec(), &name).map_or(&[][..], |(_, args)| args);
                let args = args.iter().map(|e| substitute(e, &params)).collect::<Vec<_>>();
                result.extend(dimensions(program, &nested, &args)?);
            }
        }
    }
    Ok(result)
}
