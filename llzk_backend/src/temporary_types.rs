//! Recover aggregate storage for concrete sugar-cleaner temporaries before emitting IR.

use std::{collections::HashMap, convert::TryFrom, rc::Rc};

use anyhow::{ensure, Result};
use llzk::prelude::{ArrayType, Attribute, PodType, Type};
use program_structure::ast::{Access, AssignOp, Expression, Statement, VariableType};

use crate::{
    bus_entry::contains_bus,
    program_ext::ProgramLike,
    shared::{declaration_key, get_name_tail, try_compute_as_i64, LlzkCodegen},
    subcmp::SubcmpDeclInfo,
};

/// A lexical binding captured while collecting temporary initializers.
#[derive(Clone, Debug)]
enum Binding<'ctx> {
    /// A source declaration with a known storage type.
    Data(Type<'ctx>),
    /// A generated declaration, identified by its declaration-qualified key.
    Temporary(String),
}

/// One initializer write and the lexical bindings used by its right-hand side.
#[derive(Debug)]
struct Initializer<'ast, 'ctx> {
    /// Number of array dimensions consumed on the destination.
    indices: usize,
    /// Value assigned to this element or subarray.
    value: &'ast Expression,
    /// Captured bindings distinguish temporary names reused in sibling scopes.
    scope: Rc<HashMap<String, Binding<'ctx>>>,
}

/// Backend-local metadata for a concrete sugar-cleaner temporary.
#[derive(Debug)]
struct Temporary<'ast, 'ctx> {
    /// Concrete storage dimensions, including flattened bus leaves before recovery.
    dimensions: Vec<Attribute<'ctx>>,
    /// All initializer writes, collected before attempting type recovery.
    initializers: Vec<Initializer<'ast, 'ctx>>,
}

/// Collect temporary metadata and resolve aggregate dependencies to a fixed point before IR
/// emission. Numeric declarations retain the concrete pipeline's padding and widening rules.
pub(crate) fn recover<'ctx>(
    statements: &[Statement],
    scope: &HashMap<String, Type<'ctx>>,
    declarations: &mut HashMap<String, Type<'ctx>>,
    components: &HashMap<String, SubcmpDeclInfo<'ctx>>,
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
) -> Result<()> {
    let mut scope =
        Rc::new(scope.iter().map(|(name, ty)| (name.clone(), Binding::Data(*ty))).collect());
    let mut temporaries = HashMap::new();
    collect(statements, &mut scope, declarations, &mut temporaries, codegen)?;
    let mut resolved = HashMap::new();
    loop {
        let mut changed = false;
        for (key, temporary) in &temporaries {
            let mut ty = resolved.get(key).copied();
            for initializer in &temporary.initializers {
                let Some(element) = aggregate_type(
                    initializer.value,
                    &initializer.scope,
                    &resolved,
                    components,
                    codegen,
                )?
                else {
                    continue;
                };
                ensure!(
                    initializer.indices <= temporary.dimensions.len(),
                    "too many indices for temporary {key}"
                );
                let mut dims = temporary.dimensions[..initializer.indices].to_vec();
                let element = if let Ok(array) = ArrayType::try_from(element) {
                    dims.extend(array.dims());
                    array.element_type()
                } else {
                    element
                };
                let candidate =
                    if dims.is_empty() { element } else { ArrayType::new(element, &dims).into() };
                merge(&mut ty, Some(candidate))?;
            }
            if let Some(ty) = ty {
                if resolved.insert(key.clone(), ty).is_none() {
                    changed = true;
                }
            }
        }
        if !changed {
            break;
        }
    }
    declarations.extend(resolved);
    Ok(())
}

/// Identify implicit-dimension declarations from the concrete AST's existing metadata, without
/// consulting identifier spelling. Record writes by declaration identity and lexical scope.
fn collect<'ast, 'ctx>(
    statements: &'ast [Statement],
    scope: &mut Rc<HashMap<String, Binding<'ctx>>>,
    declarations: &HashMap<String, Type<'ctx>>,
    temporaries: &mut HashMap<String, Temporary<'ast, 'ctx>>,
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
) -> Result<()> {
    for statement in statements {
        match statement {
            Statement::Declaration {
                meta,
                name,
                xtype: VariableType::Var,
                dimensions,
                is_constant,
                ..
            } => {
                let key = declaration_key(name, meta);
                let memory = meta.get_memory_knowledge();
                // rmv_sugar emits constant vars with no source dimensions; their concrete
                // dimensions live in MemoryKnowledge. Source array declarations have explicit
                // dimensions, and scalar numeric temporaries need no aggregate recovery.
                if *is_constant
                    && dimensions.is_empty()
                    && memory.has_concrete_dimensions()
                    && !memory.get_concrete_dimensions().is_empty()
                {
                    let dimensions = memory
                        .get_concrete_dimensions()
                        .iter()
                        .map(|dim| Ok(codegen.index_attr(i64::try_from(*dim)?).into()))
                        .collect::<Result<Vec<_>>>()?;
                    temporaries
                        .insert(key.clone(), Temporary { dimensions, initializers: Vec::new() });
                    Rc::make_mut(scope).insert(name.clone(), Binding::Temporary(key));
                } else if let Some(ty) = declarations.get(&key) {
                    Rc::make_mut(scope).insert(name.clone(), Binding::Data(*ty));
                }
            }
            Statement::Substitution { var, access, op: AssignOp::AssignVar, rhe, .. } => {
                if let Some(Binding::Temporary(key)) = scope.get(var) {
                    ensure!(
                        access.iter().all(|a| matches!(a, Access::ArrayAccess(_))),
                        "unexpected field write to temporary {key}"
                    );
                    temporaries.get_mut(key).expect("collected declaration").initializers.push(
                        Initializer { indices: access.len(), value: rhe, scope: scope.clone() },
                    );
                }
            }
            Statement::Block { stmts, .. } => {
                collect(stmts, &mut scope.clone(), declarations, temporaries, codegen)?;
            }
            Statement::InitializationBlock { initializations, .. } => {
                collect(initializations, scope, declarations, temporaries, codegen)?;
            }
            Statement::IfThenElse { if_case, else_case, .. } => {
                collect(
                    std::slice::from_ref(if_case),
                    &mut scope.clone(),
                    declarations,
                    temporaries,
                    codegen,
                )?;
                if let Some(else_case) = else_case {
                    collect(
                        std::slice::from_ref(else_case),
                        &mut scope.clone(),
                        declarations,
                        temporaries,
                        codegen,
                    )?;
                }
            }
            Statement::While { stmt, .. } => collect(
                std::slice::from_ref(stmt),
                &mut scope.clone(),
                declarations,
                temporaries,
                codegen,
            )?,
            _ => {}
        }
    }
    Ok(())
}

/// Add an array dimension, flattening nested array types as required by LLZK.
fn array_type<'ctx>(
    element: Type<'ctx>,
    length: i64,
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
) -> Type<'ctx> {
    let mut dims = vec![codegen.index_attr(length).into()];
    let element = if let Ok(array) = ArrayType::try_from(element) {
        dims.extend(array.dims());
        array.element_type()
    } else {
        element
    };
    ArrayType::new(element, &dims).into()
}

/// Require all aggregate alternatives to agree, independently of their emission order.
fn merge<'ctx>(result: &mut Option<Type<'ctx>>, ty: Option<Type<'ctx>>) -> Result<()> {
    if let Some(ty) = ty {
        if let Some(previous) = result {
            ensure!(*previous == ty, "incompatible temporary aggregate types: {previous} and {ty}");
        } else {
            *result = Some(ty);
        }
    }
    Ok(())
}

/// Resolve only bus-valued expressions; ordinary felt temporaries need no recovery.
fn aggregate_type<'ctx>(
    expr: &Expression,
    scope: &HashMap<String, Binding<'ctx>>,
    resolved: &HashMap<String, Type<'ctx>>,
    components: &HashMap<String, SubcmpDeclInfo<'ctx>>,
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
) -> Result<Option<Type<'ctx>>> {
    match expr {
        Expression::Variable { name, access, .. } => {
            if let Some(binding) = scope.get(name) {
                let ty = match binding {
                    Binding::Data(ty) => Some(*ty),
                    Binding::Temporary(key) => resolved.get(key).copied(),
                };
                return ty.map(|ty| accessed_type(ty, access)).transpose().map(Option::flatten);
            }
            let Some(component) = components.get(name) else { return Ok(None) };
            let rank = component.dimensions().len();
            let Some(Access::ComponentAccess(signal)) = access.get(rank) else {
                return Ok(None);
            };
            // Mixed component arrays can have different layouts at each concrete index.
            // Dynamic reads must agree on the aggregate type across all possible entries.
            let indices = access[..rank]
                .iter()
                .map(|access| match access {
                    Access::ArrayAccess(index) => try_compute_as_i64(index, codegen.prime()),
                    _ => Ok(None),
                })
                .collect::<Result<Vec<_>>>()?;
            let instances = component.instances().iter().copied().chain(
                component
                    .mixed_instances()
                    .iter()
                    .filter(|instance| {
                        indices.iter().zip(instance.indexed_with()).all(|(index, actual)| {
                            index.is_none_or(|index| index == *actual as i64)
                        })
                    })
                    .map(|instance| instance.struct_type()),
            );
            let mut result = None;
            for instance in instances {
                let template = get_name_tail(&instance)?;
                let ty = codegen
                    .get_output_signal_type(template, signal)
                    .or_else(|_| codegen.get_input_signal_type(template, signal))?;
                merge(&mut result, accessed_type(ty, &access[rank + 1..])?)?;
            }
            Ok(result)
        }
        Expression::ArrayInLine { values, .. } => {
            let mut element = None;
            for value in values {
                merge(&mut element, aggregate_type(value, scope, resolved, components, codegen)?)?;
            }
            Ok(element.map(|element| array_type(element, values.len() as i64, codegen)))
        }
        Expression::UniformArray { value, dimension, .. } => {
            let Some(element) = aggregate_type(value, scope, resolved, components, codegen)? else {
                return Ok(None);
            };
            let length = try_compute_as_i64(dimension, codegen.prime())?
                .ok_or_else(|| anyhow::anyhow!("nonconstant concrete temporary dimension"))?;
            Ok(Some(array_type(element, length, codegen)))
        }
        Expression::InlineSwitchOp { if_true, if_false, .. } => {
            let mut result = aggregate_type(if_true, scope, resolved, components, codegen)?;
            merge(&mut result, aggregate_type(if_false, scope, resolved, components, codegen)?)?;
            Ok(result)
        }
        Expression::ParallelOp { rhe, .. } => {
            aggregate_type(rhe, scope, resolved, components, codegen)
        }
        _ => Ok(None),
    }
}

/// Follow array and bus-field accesses without creating any values or operations.
fn accessed_type<'ctx>(mut ty: Type<'ctx>, access: &[Access]) -> Result<Option<Type<'ctx>>> {
    if !contains_bus(ty) {
        return Ok(None);
    }
    for access in access {
        ty = match access {
            Access::ArrayAccess(_) => {
                let array = ArrayType::try_from(ty)?;
                let dims = array.dims();
                if dims.len() == 1 {
                    array.element_type()
                } else {
                    ArrayType::new(array.element_type(), &dims[1..]).into()
                }
            }
            Access::ComponentAccess(field) => {
                let Ok(pod) = PodType::try_from(ty) else { return Ok(None) };
                let Some(field) = pod.record_type(field) else { return Ok(None) };
                field
            }
        };
    }
    Ok(contains_bus(ty).then_some(ty))
}
