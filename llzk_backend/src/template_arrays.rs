//! Represent fixed-shape array template parameters using scalar LLZK parameters.

use std::collections::{HashMap, HashSet};
use std::convert::TryFrom;

use anyhow::{ensure, Result};
use num_bigint_dig::BigUint;
use program_structure::{
    ast::{Access, AssignOp, Expression, Meta, Statement, VariableType},
    program_archive::ProgramArchive,
    template_data::TemplateData,
};

/// Lexically visible variable shapes; `None` means the shape is not statically known.
type Shapes = HashMap<String, Option<Vec<usize>>>;
/// Original template name and array shapes in formal parameter order.
type Specialization = (String, Vec<Option<Vec<usize>>>);

/// Scalarize after layout parameters have been forwarded: reconstructed array locals must
/// retain their original names so bus dimensions still find their `$layout$` aliases.
pub(crate) fn prepare(mut program: ProgramArchive, prime: &BigUint) -> Result<ProgramArchive> {
    let mut preparation = Preparation {
        originals: &program.templates,
        prime,
        templates: HashMap::new(),
        specializations: HashMap::new(),
        active: HashSet::new(),
    };
    let mut main = program.initial_template_call.clone();
    preparation.call(&mut main, &Shapes::new())?;
    program.templates = preparation.templates;
    program.initial_template_call = main;
    Ok(program)
}

/// Rebuild the reachable template graph with scalar parameters for each known array shape.
struct Preparation<'a> {
    /// Unmodified templates, used as the source for every specialization.
    originals: &'a HashMap<String, TemplateData>,
    /// Field modulus for evaluating constant dimensions.
    prime: &'a BigUint,
    /// Completed reachable template definitions.
    templates: HashMap<String, TemplateData>,
    /// Reuse one definition for calls with equal array shapes but different element values.
    specializations: HashMap<Specialization, String>,
    /// Original template names currently being rewritten, to detect recursion.
    active: HashSet<String>,
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
    fn call(&mut self, expr: &mut Expression, shapes: &Shapes) -> Result<()> {
        if let Expression::ParallelOp { rhe, .. } = expr {
            return self.call(rhe, shapes);
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
        let name = self.specialize(id, &parameter_shapes)?;
        let mut scalar_args = Vec::new();
        for (arg, shape) in args.iter().zip(&parameter_shapes) {
            if let Some(shape) = shape {
                let bindings = HashMap::from([("$array_actual".to_owned(), arg.clone())]);
                for indices in indices(shape)? {
                    let indexed = Expression::Variable {
                        meta: arg.get_meta().clone(),
                        name: "$array_actual".to_owned(),
                        access: indices
                            .into_iter()
                            .map(|index| {
                                Access::ArrayAccess(Expression::Number(
                                    arg.get_meta().clone(),
                                    index.into(),
                                ))
                            })
                            .collect(),
                    };
                    scalar_args.push(crate::bus::substitute(&indexed, &bindings));
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
    fn specialize(&mut self, id: &str, parameter_shapes: &[Option<Vec<usize>>]) -> Result<String> {
        let key = (id.to_owned(), parameter_shapes.to_vec());
        if let Some(name) = self.specializations.get(&key) {
            return Ok(name.clone());
        }
        ensure!(self.active.insert(id.to_owned()), "recursive array parameter dependency at {id}");
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
            ensure!(
                !self.originals.contains_key(&name),
                "array specialization name collision: {name}"
            );
        }
        // Recursive calls with the same shapes reuse this declaration while its body
        // is being rewritten. Only shape-changing recursion needs the active guard.
        self.specializations.insert(key, name.clone());
        let mut params = Vec::new();
        let mut prefix = Vec::new();
        let mut shapes = Shapes::new();
        let meta = old.get_body().get_meta();
        for (formal, shape) in old.get_name_of_params().iter().zip(parameter_shapes) {
            shapes.insert(formal.clone(), Some(shape.clone().unwrap_or_default()));
            if let Some(shape) = shape {
                let scalar_names = indices(shape)?
                    .iter()
                    .enumerate()
                    .map(|(element, _)| format!("$array${formal}${element}"))
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
            } else {
                params.push(formal.clone());
            }
        }
        let mut body = old.get_body().clone();
        self.statement(&mut body, &mut shapes)?;
        let Statement::Block { stmts, .. } = &mut body else {
            anyhow::bail!("template {id} body is not a block");
        };
        prefix.append(stmts);
        *stmts = prefix;
        let template = TemplateData::copy(
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
        );
        self.templates.insert(name.clone(), template);
        self.active.remove(id);
        Ok(name)
    }

    /// Track declaration shapes while rewriting constructors without leaking nested bindings.
    fn statement(&mut self, stmt: &mut Statement, shapes: &mut Shapes) -> Result<()> {
        match stmt {
            Statement::Block { stmts, .. } => {
                let mut nested = shapes.clone();
                for stmt in stmts {
                    self.statement(stmt, &mut nested)?;
                }
            }
            Statement::InitializationBlock { initializations, .. } => {
                for stmt in initializations {
                    self.statement(stmt, shapes)?;
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
            }
            Statement::Substitution { rhe, .. } => self.call(rhe, shapes)?,
            Statement::IfThenElse { if_case, else_case, .. } => {
                self.statement(if_case, &mut shapes.clone())?;
                if let Some(stmt) = else_case {
                    self.statement(stmt, &mut shapes.clone())?;
                }
            }
            Statement::While { stmt, .. } => self.statement(stmt, &mut shapes.clone())?,
            _ => {}
        }
        Ok(())
    }
}

/// Enumerate row-major coordinates, checking the size before materializing parameters.
fn indices(shape: &[usize]) -> Result<Vec<Vec<usize>>> {
    if shape.contains(&0) {
        return Ok(vec![]);
    }
    let length = shape.iter().try_fold(1usize, |size, dimension| size.checked_mul(*dimension));
    ensure!(length.is_some(), "array template parameter size overflow");
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
