//! Handles the top-level constructs (i.e. circom templates and functions), by delegating
//! to the [crate::function] and [crate::template] modules to generate the code for each.

use crate::function::FunctionContext;
use crate::function::GenerateLLZKInFunction as _;
use crate::function_ext::FunctionLike;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::get_poly_expr_name;
use crate::shared::map_array_inner_type;
use crate::shared::map_name_to_arg_value;
use crate::shared::ArrayDimensionResult;
use crate::shared::DimExprConverter;
use crate::shared::LlzkCodegen;
use crate::shared::TmplParamsInstance;
use crate::shared::TypeSizeExpr;
use crate::subcmp::names::COMP;
use crate::subcmp::names::COUNT;
use crate::subcmp::names::PARAMS;
use crate::subcmp::unique_instance_types;
use crate::subcmp::SubcmpDeclInfo;
use crate::subcmp::SubcmpPrologueData;
use crate::template::GenerateLLZKInTemplate as _;
use crate::template::TemplateContext;
use crate::template_ext::TemplateLike;
use anyhow::bail;
use anyhow::Result;
use llzk::attributes::NamedAttribute;
use llzk::dialect::array;
use llzk::dialect::array::ArrayCtor;
use llzk::dialect::function;
use llzk::dialect::pod;
use llzk::dialect::poly;
use llzk::dialect::r#struct;
use llzk::dialect::r#struct::helpers::compute_fn;
use llzk::dialect::r#struct::helpers::constrain_fn;
use llzk::error::Error;
use llzk::prelude::ArrayType;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::FuncDefOpRef;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::FunctionType;
use llzk::prelude::LlzkError;
use llzk::prelude::Location;
use llzk::prelude::MemberDefOpLike as _;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::PodRecordAttribute;
use llzk::prelude::PodType;
use llzk::prelude::PublicAttribute;
use llzk::prelude::RecordValue;
use llzk::prelude::RegionLike as _;
use llzk::prelude::StringAttribute;
use llzk::prelude::StringRef;
use llzk::prelude::StructDefOpLike as _;
use llzk::prelude::StructDefOpRef;
use llzk::prelude::StructType;
use llzk::prelude::TemplateExprOp;
use llzk::prelude::TemplateExprOpLike as _;
use llzk::prelude::TemplateOpLike;
use llzk::prelude::Type;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::SignalType;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use std::cell::RefCell;
use std::collections::HashMap;
use std::collections::HashSet;
use std::convert::TryFrom;
use std::convert::TryInto as _;

/// Information needed to create an LLZK struct function parameter collected from the input signal
/// Declaration statements within a circom template.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
#[derive(Debug)]
struct InputSignalInfo<'ctx> {
    /// Name of circom input signal that maps to a function parameter.
    name: String,
    /// Type+Location information for the function parameter.
    type_and_loc: (Type<'ctx>, Location<'ctx>),
    /// Named Attributes for the function parameter.
    attrs: Vec<NamedAttribute<'ctx>>,
}

/// Information neeeded to create a struct member representing either an output signal, an internal
/// signal or a subcomponent.
#[derive(Debug)]
struct MemberInfo<'ctx> {
    /// Name of the member.
    name: String,
    /// Type of the member.
    decl_type: Type<'ctx>,
    /// Location of the member.
    location: Location<'ctx>,
    /// Whether it's a publicly facing member of the struct
    public: bool,
}

impl<'ctx> TryFrom<MemberInfo<'ctx>> for Operation<'ctx> {
    type Error = Error;

    fn try_from(value: MemberInfo<'ctx>) -> std::result::Result<Self, Self::Error> {
        r#struct::member(value.location, &value.name, value.decl_type, false, value.public)
            .map(Into::into)
    }
}

/// Information collected from Declaration statements within a template that is used to setup LLZK
/// struct fields and parameters to the functions with the struct.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
#[derive(Debug, Default)]
pub struct DeclarationInfo<'ctx> {
    /// Input Signal declarations to use as parameters to the LLZK struct functions.
    inputs: Vec<InputSignalInfo<'ctx>>,
    /// Output and Intermediate declarations to use as LLZK struct fields.
    struct_fields: Vec<MemberInfo<'ctx>>,
    /// Map var/signal name to its LLZK declaration Operation (usually `llzk.nondet`).
    decl_inits: HashMap<String, Operation<'ctx>>,
    /// Map `component` name to its declaration information.
    subcmp_decls: HashMap<String, SubcmpDeclInfo<'ctx>>,
    /// The template params that may be used to instantiate array dimensions.
    /// Note: this is set on construction and not modified.
    template_params: HashSet<String>,
    /// Dimension expressions mapped to generated `poly.expr` op to be inserted into the template.
    poly_exprs: RefCell<HashMap<String, TemplateExprOp<'ctx>>>,
    /// Pre-computed LLZK types for `var` declarations, keyed by var name. Used by
    /// `poly.expr` body generation to avoid recursive dimension-expression recomputation.
    var_decl_types: HashMap<String, Type<'ctx>>,
}

impl<'ctx> DeclarationInfo<'ctx> {
    /// Returns a mapping of input signal names to their types.
    pub(crate) fn build_input_name_to_type_map(&self) -> HashMap<String, Type<'ctx>> {
        self.inputs.iter().map(|i| (i.name.clone(), i.type_and_loc.0)).collect()
    }

    /// Returns a mapping of output signal names to their types.
    pub(crate) fn build_output_name_to_type_map(&self) -> HashMap<String, Type<'ctx>> {
        self.struct_fields
            .iter()
            .filter(|info| info.public)
            .map(|info| (info.name.clone(), info.decl_type))
            .collect()
    }

    /// Returns the type of the input signal with the given name, if it exists.
    pub(crate) fn get_input_type(&self, signal_name: &str) -> Option<Type<'ctx>> {
        self.inputs.iter().find_map(|i| (i.name == signal_name).then_some(i.type_and_loc.0))
    }

    /// Returns the type of the input signal with the given name, if it exists.
    pub(crate) fn get_output_type(&self, signal_name: &str) -> Option<Type<'ctx>> {
        self.struct_fields.iter().find_map(|member| {
            (member.name == signal_name && member.public).then_some(member.decl_type)
        })
    }

    /// Completes the declaration information from the information collected from the
    /// subcomponents.
    ///
    /// Returns a vector with an associative list of names to the types of the declaration.
    ///
    /// Currently handles declaration of scalar subcomponents and array subcomponents of the same
    /// type.
    fn complete<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    ) -> Result<Vec<SubcmpPrologueData<'ast, 'ctx>>> {
        let mut ops = vec![];
        let mut subcmps: Vec<_> = self.subcmp_decls.keys().cloned().collect();
        if codegen.config.stabilize {
            // Sort by circom subcomponent names to ensure a stable order of struct fields.
            subcmps.sort_by(Ord::cmp);
        }
        for name in subcmps {
            let info = self.subcmp_decls.get_mut(&name).unwrap();
            let instances = info.instances();

            let types = unique_instance_types(instances);
            if types.is_empty() {
                todo!("Handle uninitialized component decl")
            }
            if types.len() > 1 {
                todo!("Handle subcomponents with different instantiations")
            }
            let mut inputs_size = TypeSizeExpr::zero();
            let template_name = shared::get_name_tail(&types[0])?;
            info.set_template(template_name.to_owned());

            let template = codegen
                .program
                .get_templates(false)
                .into_iter()
                .find(|t| t.get_name() == template_name)
                .ok_or_else(|| anyhow::anyhow!("template '{template_name}' not found"))?;
            let template_params =
                TmplParamsInstance::new(template.get_name_of_params(), types[0].params_vec());

            let mut inputs = vec![];
            for (signal_name, _) in template.get_declaration_inputs().iter() {
                let signal_type = template_params
                    .map_type(codegen.get_input_signal_type(template_name, signal_name)?)?;
                inputs_size = inputs_size.add(codegen.count_input_signals(signal_type)?);
                inputs.push(PodRecordAttribute::new(signal_name, signal_type));
            }

            let extend_dims = |t: Type<'ctx>| match info.dimensions() {
                [] => t,
                dims => ArrayType::new(t, dims).into(),
            };
            let inputs = extend_dims(PodType::new(codegen.context, &inputs).into());
            let member_type = extend_dims(types[0].into());
            self.struct_fields.push(MemberInfo {
                name: name.clone(),
                decl_type: member_type,
                location: info.location(),
                public: false,
            });
            self.struct_fields.push(MemberInfo {
                name: crate::subcmp::names::inputs(&name),
                decl_type: inputs,
                location: info.location(),
                public: false,
            });
            ops.push(SubcmpPrologueData {
                name,
                subcmp: member_type,
                inputs,
                inputs_size,
                template_params,
            });
        }
        Ok(ops)
    }

    /// Visit all statements in the body of the template and return a new [DeclarationInfo]
    /// with any declarations found.
    pub(crate) fn from_template(
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        template: &impl TemplateLike,
    ) -> Result<DeclarationInfo<'ctx>> {
        let mut declarations = DeclarationInfo {
            template_params: template.get_name_of_params().iter().cloned().collect(),
            subcmp_decls: template.get_init_subcmp_decls(codegen)?,
            ..DeclarationInfo::default()
        };
        for s in template.get_body() {
            declarations.visit(codegen, s)?;
        }
        Ok(declarations)
    }

    /// Visit a statement and populate this `DeclarationInfo` with any declarations found.
    ///
    /// TODO: This currently visits only top-level statements within the template body. However,
    /// since circom 2.1.5, signal declarations are allowed inside of blocks and known-condition if
    /// statements. Those nested declarations are not currently processed here.
    fn visit(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        stmt: &Statement,
    ) -> Result<()> {
        let _guard = codegen.trace_statement(stmt);
        match stmt {
            Statement::Block { stmts, .. } => {
                // TemplateInstance (in concrete programs) has Declaration in Block (but only for
                // var, not signals). The Block contains no additional information beyond the
                // Declarations that appear within it so just process the inner statements.
                for init in stmts {
                    self.visit(codegen, init)?;
                }
                Ok(())
            }
            Statement::InitializationBlock { initializations, .. } => {
                // TemplateData (in non-concrete programs) has Declaration in InitializationBlock.
                // The InitializationBlock contains no additional information beyond the
                // Declarations that appear within it so just process the inner statements.
                for init in initializations {
                    self.visit(codegen, init)?;
                }
                Ok(())
            }
            Statement::Declaration { meta, name, xtype, dimensions, .. } => {
                // The Signal and Bus types use SignalType to indicate if they are input, output, or
                // intermediate. The others are all intermediate. Intermediates become SSA values
                // (which could later be stored as a struct field if used in a constraint), outputs
                // become "pub" struct fields, and inputs become arguments to the functions.
                match xtype {
                    VariableType::Signal(signal_type, ..) => self.visit_signal_or_bus(
                        codegen,
                        signal_type,
                        name,
                        meta,
                        dimensions,
                        codegen.felt_type().into(),
                    ),
                    VariableType::Bus(bus_name, signal_type, ..) => self.visit_signal_or_bus(
                        codegen,
                        signal_type,
                        name,
                        meta,
                        dimensions,
                        codegen.struct_type(bus_name).into(),
                    ),
                    VariableType::Var => {
                        // Create `llzk.nondet` of the appropriate type. When the actual assignment
                        // is processed later, this is replaced with the appropriate value.
                        let dimensions = self.get_dim_exprs(codegen, dimensions)?;
                        let var_type =
                            dimensions.type_from_dimension_exprs(codegen.felt_type().into());
                        self.var_decl_types.insert(name.clone(), var_type);
                        self.decl_inits.insert(
                            name.clone(),
                            codegen.new_nondet_at_location(
                                codegen.location_from_meta(meta),
                                var_type,
                            )?,
                        );
                        Ok(())
                    }
                    VariableType::Component => {
                        self.visit_component_decl(codegen, meta, name, dimensions)
                    }
                    VariableType::AnonymousComponent => {
                        // The 'syntax_sugar_remover' will convert anonymous components to normal
                        // components unless they appear within a loop. In that case, the anonymous
                        // component is just refactored to the top level, outside the loop.
                        // See: circom/tests/circom_doc_examples/34.circom
                        todo!("handle AnonymousComponent declaration")
                    }
                }
            }
            stmt => self.search_component_instances(codegen, stmt),
        }
    }

    /// Searches in an [`Expression`] for a call to a subcomponent's constructor.
    ///
    /// In this context, constructor refers to `Foo(n)` in Circom, not `@Foo::@compute` in LLZK.
    fn find_subcmp_ctor_call(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        expression: &Expression,
    ) -> Result<StructType<'ctx>> {
        match expression {
            Expression::Call { meta, id, args, .. } if meta.get_type_knowledge().is_component() => {
                let dims = self.get_dim_exprs(codegen, args)?;
                Ok(dims.struct_type_with_concrete_dimensions(codegen, id))
            }
            Expression::ParallelOp { rhe, .. } => {
                // `parallel` is a tag used to generate parallelized code for the C++
                // witness generator. Since LLZK currently has no such hint,
                // we simply generate the underlying expression.
                self.find_subcmp_ctor_call(codegen, rhe)
            }
            _ => bail!("expected call expression for subcomponent substitution rhe"),
        }
    }

    /// [`visit`](Self::visit) helper for component declarations.
    fn visit_component_decl(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        name: &str,
        dimensions: &[Expression],
    ) -> Result<()> {
        let location = codegen.location_from_meta(meta);
        let dims = self.get_dim_exprs(codegen, dimensions)?;
        if self
            .subcmp_decls
            .insert(name.to_owned(), SubcmpDeclInfo::new(dims.attrs(), location))
            .is_some()
        {
            bail!("Subcomponent {name} declared twice");
        }
        Ok(())
    }

    /// `visit()` helper for Signal and Bus VariableType.
    #[inline]
    fn visit_signal_or_bus(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        signal_type: &SignalType,
        name: &String,
        meta: &Meta,
        dimensions: &[Expression],
        base_type: Type<'ctx>,
    ) -> Result<()> {
        let location = codegen.location_from_meta(meta);
        let dims = self.get_dim_exprs(codegen, dimensions)?;
        let decl_type = dims.type_from_dimension_exprs(base_type);
        self.visit_signal_or_bus_impl(codegen, signal_type, name, location, decl_type)
    }

    /// `visit()` helper for Signal and Bus VariableType.
    pub(crate) fn visit_signal_or_bus_impl(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        signal_type: &SignalType,
        name: &String,
        location: Location<'ctx>,
        decl_type: Type<'ctx>,
    ) -> Result<()> {
        if SignalType::Input == *signal_type {
            let mut attrs: Vec<NamedAttribute<'_>> = Vec::new();
            if codegen.program.get_main_public_inputs().contains(name) {
                attrs.push(PublicAttribute::new_named_attr(codegen.context));
            }
            self.inputs.push(InputSignalInfo {
                name: name.clone(),
                type_and_loc: (decl_type, location),
                attrs,
            });
        } else {
            self.struct_fields.push(MemberInfo {
                name: name.clone(),
                decl_type,
                location,
                public: SignalType::Output == *signal_type,
            });
        }
        // Create `llzk.nondet` of the appropriate type. When the actual assignment
        // is processed later, this is replaced with the appropriate value.
        codegen.new_nondet_at_location(location, decl_type).map(|op| {
            self.decl_inits.insert(name.clone(), op);
        })
    }

    /// Traverses the AST looking for assigments of subcomponents and collects the instances used
    /// for them.
    fn search_component_instances(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        stmt: &Statement,
    ) -> Result<()> {
        match stmt {
            Statement::Substitution { var, op, rhe, .. }
                if matches!(op, AssignOp::AssignVar) && self.subcmp_decls.contains_key(var) =>
            {
                let struct_type = self.find_subcmp_ctor_call(codegen, rhe)?;
                self.subcmp_decls.entry(var.clone()).and_modify(|info| {
                    info.instances_mut().push(struct_type);
                });

                Ok(())
            }
            Statement::IfThenElse { if_case, else_case, .. } => {
                self.search_component_instances(codegen, if_case.as_ref())?;
                if let Some(else_case) = else_case.as_deref() {
                    self.search_component_instances(codegen, else_case)?;
                }
                Ok(())
            }
            Statement::While { stmt, .. } => {
                self.search_component_instances(codegen, stmt.as_ref())
            }
            Statement::InitializationBlock { initializations: stmts, .. }
            | Statement::Block { stmts, .. } => {
                for stmt in stmts {
                    self.search_component_instances(codegen, stmt)?;
                }
                Ok(())
            }
            _ => Ok(()),
        }
    }
}

impl<'ctx, 'val> DimExprConverter<'ctx, 'val> for DeclarationInfo<'ctx>
where
    'ctx: 'val,
{
    fn get_var_decl_types(&self) -> &HashMap<String, Type<'ctx>> {
        &self.var_decl_types
    }

    fn poly_template_binding_names(
        &self,
    ) -> impl IntoIterator<Item = (String, Option<Type<'ctx>>)> {
        self.template_params.iter().map(|name| (name.clone(), None))
    }

    fn callback_store_poly_expr(
        &self,
        name: String,
        op: TemplateExprOp<'ctx>,
    ) -> StringAttribute<'ctx> {
        let uniqued_name = get_poly_expr_name(&op);
        let old = self.poly_exprs.borrow_mut().insert(name, op);
        // ASSERT: In general, `DimExprConverter` has to account for non-unique names but in this
        // `DeclarationInfo` implementation, names will always be unique (assuming the `Meta::start`
        // from the circom AST that `dim_expr_name()` appends to the names is accurate).
        assert!(old.is_none(), "multiple poly.expr generated for the same dimension expression");
        uniqued_name
    }

    fn get_dim_expr(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ArrayDimensionResult<'ctx, 'val>> {
        // First try to compute statically, falling back to literal computation if all values are
        // not compile-time constants or if the final result does not properly convert to i64.
        if let Some(integer) = shared::try_compute_as_i64(expr, codegen.prime())? {
            ArrayDimensionResult::new(codegen.index_attr(integer).into(), &[])
        } else {
            match expr {
                Expression::Number(_, _) => {
                    unreachable!("handled by try_compute_as_i64")
                }
                Expression::Variable { name, access, .. } if access.is_empty() => {
                    if self.template_params.contains(name) {
                        ArrayDimensionResult::new(codegen.flat_sym(name).into(), &[])
                    } else if self.poly_exprs.borrow().contains_key(name) {
                        // This is a `Statement::Declaration` with `VariableType::Var` that was
                        // previously encountered and converted into a `poly.expr`.
                        ArrayDimensionResult::new(codegen.flat_sym(name).into(), &[])
                    } else if self.decl_inits.contains_key(name) {
                        // This is a `Statement::Declaration` with `VariableType::Var` that is
                        // encountered for the first time and must have a `poly.expr` generated.
                        self.gen_template_poly_expr(codegen, expr)
                    } else {
                        // TODO: this happens in `circom/tests/circom_doc_examples/04.circom`
                        // and I think it's related to the "TODO" on `DeclarationInfo::visit`.
                        todo!("not a known circom template parameter or var declaration: {}", name)
                    }
                }
                // Variable case with non-empty `access`
                Expression::Variable { .. }
                | Expression::InlineSwitchOp { .. }
                | Expression::PrefixOp { .. }
                | Expression::InfixOp { .. }
                | Expression::Call { .. } => self.gen_template_poly_expr(codegen, expr),
                // The remaining cases do not produce a scalar value.
                // i.e. ParallelOp, ArrayInLine, UniformArray, BusCall, AnonymousComp, Tuple
                // Give the same error that the circom type checker gives. The type checker ran
                // earlier so this should technically be unreachable.
                _ => {
                    unreachable!("Array indexes and lengths must produce a scalar value")
                }
            }
        }
    }
}

/// Generate LLZK for a function-like construct. Helper to avoid code duplication.
fn gen_function_llzk<'ast, 'ctx, F: FunctionLike>(
    func_like: &'ast F,
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
) -> Result<()> {
    if codegen.config.verbose {
        println!("Generating LLZK for function {}", func_like.get_name());
    }
    let location = func_like.get_location(codegen);
    let inputs = func_like.get_type_of_params(codegen);
    let result = func_like.get_type_of_return(codegen);
    let func_type = FunctionType::new(codegen.context, &inputs, &[result]);
    let func_def =
        function::def(location, func_like.get_name(), func_type, &[], None).and_then(|f| {
            let arguments: Vec<(Type, Location)> =
                inputs.into_iter().map(|t| (t, location)).collect();
            f.region(0)?.append_block(Block::new(&arguments));
            Ok(f)
        })?;
    func_def.set_allow_non_native_field_ops_attr(true);

    let template_region_ops = func_like
        .get_type_param_names()
        .iter()
        .map(|name| poly::param(location, name, Some(codegen.tvar_type(name))).map(Into::into))
        .collect::<Vec<_>>();
    let llzk_template_def = poly::template(location, func_like.get_name(), template_region_ops)?;
    let new_template = codegen.add_template(llzk_template_def)?;

    // Store function inside the `poly.template` so its type variables can resolve to the params.
    let func = FuncDefOpRefMut::from(FuncDefOpRef::try_from(
        new_template.body().append_operation(func_def.into()),
    )?);

    // Generate mapping from parameter names to SSA Values.
    let name_to_value = map_name_to_arg_value(func, func_like.get_name_of_params())?;

    // Visit the body of the function and generate LLZK IR for it.
    let var_decl_types = HashMap::new();
    let mut func_context = FunctionContext::new::<true>(
        codegen,
        func,
        name_to_value,
        &var_decl_types,
        std::iter::empty(),
    )?;
    func_like.get_body().gen_llzk_in_function(codegen, &mut func_context, Default::default())?;
    func_context.finalize(codegen)
}

/// Generate LLZK for a template-like construct. Helper to avoid code duplication.
fn gen_template_llzk<'ast, 'ctx, T: TemplateLike>(
    template_like: &'ast T,
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
) -> Result<()> {
    if codegen.config.verbose {
        println!("Generating LLZK for template {}", template_like.get_name());
    }
    // Collect declarations first to determine struct fields and function parameters.
    let mut declarations: DeclarationInfo<'ctx> =
        codegen.take_template_decl(template_like.get_name())?;
    let subcmps = declarations.complete(codegen)?;
    let location = template_like.get_location(codegen);

    // Generate list of template params for the LLZK template body.
    let template_region_ops = template_like
        .get_name_of_params()
        .iter()
        .map(|name| poly::param(location, name, None).map(Into::into))
        .collect::<Vec<Result<Operation, LlzkError>>>();
    let llzk_template_def =
        poly::template(location, template_like.get_name(), template_region_ops)?;
    let new_template = codegen.add_template(llzk_template_def)?;

    // Insert the declarations from `declarations.poly_exprs`.
    let mut poly_exprs = declarations.poly_exprs.into_inner();
    let mut poly_expr_names: Vec<_> =
        poly_exprs.iter().map(|(name, op)| (name.clone(), op.expr_type())).collect();
    if codegen.config.stabilize {
        poly_expr_names.sort_by(|(a, _), (b, _)| a.cmp(b));
    }
    for (name, _) in &poly_expr_names {
        // Here the template is empty and the names are unique per storage in HashMap so they
        // can be directly appended without using `symbol_table::insert` to unique names.
        new_template.body().append_operation(poly_exprs.remove(name).unwrap().into());
    }

    // Add the struct definition, prepopulated with fields, to the template body.
    let new_struct = StructDefOpRef::try_from(
        new_template.body().append_operation(
            r#struct::def(
                location,
                template_like.get_name(),
                declarations.struct_fields.into_iter().map(MemberInfo::try_into),
            )?
            .into(),
        ),
    )?;

    // Consume and separate 'declarations.inputs' (to avoid cloning 'attrs' and 'name').
    let (inputs, arg_attrs, arg_names) = declarations.inputs.into_iter().fold(
        (Vec::new(), Vec::new(), Vec::new()),
        |(mut inputs, mut attrs, mut names), v| {
            inputs.push(v.type_and_loc);
            attrs.push(v.attrs);
            names.push(v.name);
            (inputs, attrs, names)
        },
    );
    // Generate the compute and constrain functions.
    let new_struct_type = new_struct.r#type();
    let struct_body = new_struct.body();
    let compute_func = FuncDefOpRef::try_from(struct_body.append_operation(
        compute_fn(location, new_struct_type, &inputs, Some(&arg_attrs))?.into(),
    ))?
    .into();
    let constrain_func = FuncDefOpRef::try_from(struct_body.append_operation(
        constrain_fn(location, new_struct_type, &inputs, Some(&arg_attrs))?.into(),
    ))?
    .into();

    // Map parameter Values of each LLZK function to the corresponding circom variable names and
    // then create the FunctionContext for each function. Before creating the FunctionContext
    // for constrain, add a dummy name at index 0 since the first parameter is the struct ref.
    let mut compute_ctx = FunctionContext::new::<false>(
        codegen,
        compute_func,
        map_name_to_arg_value(compute_func, arg_names.clone())?,
        &declarations.var_decl_types,
        // concatenate circom template parameter names with `poly_expr_names`
        template_like
            .get_name_of_params()
            .iter()
            .map(|name| (name.clone(), None))
            .chain(poly_expr_names.iter().map(|(name, ty)| (name.clone(), Some(*ty)))),
    )?;
    let mut arg_names = arg_names;
    arg_names.insert(0, "**self**".to_string());
    let mut constrain_ctx = FunctionContext::new::<false>(
        codegen,
        constrain_func,
        map_name_to_arg_value(constrain_func, arg_names)?,
        &declarations.var_decl_types,
        // concatenate circom template parameter names with `poly_expr_names`
        template_like
            .get_name_of_params()
            .iter()
            .map(|name| (name.clone(), None))
            .chain(poly_expr_names.iter().map(|(name, ty)| (name.clone(), Some(*ty)))),
    )?;

    // Insert read operations for struct fields into constrain functions.
    let location = codegen.location_unknown();
    for member in new_struct.get_member_defs() {
        let member_name = member.member_name();
        constrain_ctx.block_ctx.declare_name_if_not_present(member_name, || {
            r#struct::readm(
                codegen.op_builder(),
                location,
                member.member_type(),
                constrain_func.self_value_of_constrain()?,
                member_name,
            )
            .map_err(Into::into)
        })?;
    }

    // Insert the Operations created from variable Declaration statements and map the circom
    // variable name to LLZK op result Value (do this in each function).
    for (name, op) in declarations.decl_inits {
        // Insert (a clone of) the declaration into the compute function.
        compute_ctx.block_ctx.declare_name_if_not_present(&name, || Ok(op.clone()))?;
        // Insert the declaration into the constrain function.
        constrain_ctx.block_ctx.declare_name_if_not_present(&name, || Ok(op))?;
    }
    let subcmp_decls = declarations.subcmp_decls;
    // Insert the Operations created from subcomponent Declaration statements and map the
    // circom variable name to a LLZK op result Value.
    gen_subcmps_prologue_in_template(
        subcmps,
        &mut compute_ctx,
        &mut constrain_ctx,
        codegen,
        &subcmp_decls,
    )?;

    let subcmp_names = subcmp_decls
        .into_iter()
        .map(|(subcmp, decl)| {
            decl.template()
                .map(|template_name| (subcmp.clone(), template_name.to_owned()))
                .ok_or_else(|| {
                    anyhow::anyhow!("could not deduce the type of subcomponent '{subcmp}'")
                })
        })
        .collect::<Result<_>>()?;

    // Visit the body of the template and generate LLZK IR for it within the struct functions.
    let template_context = TemplateContext::new(
        new_template.into(),
        new_struct.into(),
        compute_ctx,
        constrain_ctx,
        &subcmp_names,
        &declarations.var_decl_types,
    );
    template_like.gen_preamble(codegen, &template_context)?;
    template_like.get_body().gen_llzk_in_template(codegen, &template_context)?;
    template_context.finalize(codegen)
}

/// Returns the element type if the type is an [`ArrayType`]. Returns the type itself otherwise.
fn scalar_or_inner<'ctx>(t: Type<'ctx>) -> Type<'ctx> {
    ArrayType::try_from(t).map(|t| t.element_type()).unwrap_or(t)
}

/// Generates the prologue related to subcomponents in a template body.
fn gen_subcmps_prologue_in_template<'ast, 'ctx, 'func, 'blk, 'val>(
    subcmps: impl IntoIterator<Item = SubcmpPrologueData<'ast, 'ctx>>,
    compute_ctx: &mut FunctionContext<'_, 'ctx, 'func, 'blk, 'val>,
    constrain_ctx: &mut FunctionContext<'_, 'ctx, '_, '_, '_>,
    codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    subcmp_decls: &HashMap<String, SubcmpDeclInfo<'ctx>>,
) -> Result<()>
where
    'val: 'blk,
{
    let op_builder = codegen.op_builder();
    for SubcmpPrologueData {
        name,
        subcmp: subcmp_type,
        inputs: subcmp_inputs_type,
        inputs_size: count,
        template_params,
    } in subcmps
    {
        let name_inputs = crate::subcmp::names::inputs(&name);
        // Constrain function
        // Do this one first to avoid cloning `name` and `name_inputs` unnecessarily.
        {
            let self_ref = constrain_ctx.func.self_value_of_constrain()?;
            constrain_ctx.block_ctx.declare_name_if_not_present(&name, || {
                Ok(r#struct::readm(
                    op_builder,
                    subcmp_decls[&name].location(),
                    subcmp_type,
                    self_ref,
                    &name,
                )?)
            })?;
            constrain_ctx.block_ctx.declare_name_if_not_present(&name_inputs, || {
                Ok(r#struct::readm(
                    op_builder,
                    subcmp_decls[&name].location(),
                    subcmp_inputs_type,
                    self_ref,
                    &name_inputs,
                )?)
            })?;
        }

        // Compute function
        {
            let subcmp_struct_type = scalar_or_inner(subcmp_type);
            let records = [
                // Counts the number of inputs pending an assignment. When it reaches 0 it's safe
                // to call the corresponding `@compute` function.
                (COUNT, codegen.index_type()),
                // Holds the output of calling `@compute`. Before the call, this value is undefined
                // and should not be read from.
                (COMP, subcmp_struct_type),
                // Holds the affine map operands of the subcomponents, if any.
                (PARAMS, codegen.pod_type(&[]).into()),
            ];

            let comp_pod = map_array_inner_type(subcmp_type, codegen.pod_type(&records).into());
            let location = codegen.location_unknown();
            match ArrayType::try_from(comp_pod) {
                Ok(comp_pod) => {
                    compute_ctx.block_ctx.declare_name_ensure_not_present(
                        &name,
                        array::new(op_builder, location, comp_pod, ArrayCtor::Empty),
                    )?;
                    let comp_memory = *compute_ctx.block_ctx.get_named_value(&name)?;

                    compute_ctx.gen_loop_nest_from_attrs(
                        codegen,
                        location,
                        &comp_pod.dims(),
                        |fc, indices| {
                            let comp_memory_pod =
                                fc.append_array_read(comp_memory, indices, location, None)?;

                            let (record_name, record_value) = if count.is_const_zero() {
                                let empty_inputs = fc.append_op_unnamed_result(pod::new(
                                    op_builder,
                                    location,
                                    &[],
                                    Some(codegen.pod_type(&[])),
                                ))?;
                                let instance = fc.gen_compute_call(
                                    subcmp_struct_type.try_into()?,
                                    empty_inputs,
                                    location,
                                    codegen,
                                )?;
                                (COMP, instance)
                            } else {
                                let count_value = count.to_index_value(
                                    codegen,
                                    fc,
                                    location,
                                    Some(&template_params),
                                )?;
                                (COUNT, count_value)
                            };
                            fc.append_op_no_result(codegen.new_pod_write_op(
                                location,
                                comp_memory_pod,
                                record_name,
                                record_value,
                            ))?;

                            fc.append_array_write(
                                codegen,
                                comp_memory,
                                indices,
                                location,
                                comp_memory_pod,
                                None,
                            )
                        },
                    )?;
                }
                Err(_) => {
                    let (record_name, record_value) = if count.is_const_zero() {
                        let empty_inputs = compute_ctx.append_op_unnamed_result(pod::new(
                            op_builder,
                            location,
                            &[],
                            Some(codegen.pod_type(&[])),
                        ))?;
                        let instance = compute_ctx.gen_compute_call(
                            subcmp_struct_type.try_into()?,
                            empty_inputs,
                            location,
                            codegen,
                        )?;
                        (COMP, instance)
                    } else {
                        let count_value = count.to_index_value(
                            codegen,
                            compute_ctx,
                            location,
                            Some(&template_params),
                        )?;
                        (COUNT, count_value)
                    };
                    compute_ctx.block_ctx.declare_name_ensure_not_present(
                        &name,
                        pod::new(
                            op_builder,
                            location,
                            &[RecordValue::new(StringRef::new(record_name), record_value)],
                            Some(PodType::try_from(comp_pod)?),
                        ),
                    )?
                }
            };
            compute_ctx.block_ctx.declare_name_ensure_not_present(
                &name_inputs,
                match ArrayType::try_from(subcmp_inputs_type) {
                    Ok(subcmp_inputs_type) => {
                        array::new(op_builder, location, subcmp_inputs_type, ArrayCtor::Empty)
                    }
                    Err(_) => pod::new(
                        op_builder,
                        location,
                        &[],
                        Some(PodType::try_from(subcmp_inputs_type)?),
                    ),
                },
            )?;
        }
    }
    Ok(())
}

/// A trait to generate LLZK IR for structural elements of the circom AST:
/// ProgramArchive, TemplateData, and FunctionData.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
pub trait GenerateLLZKInModule<'ctx, P: ProgramLike> {
    /// Generates LLZK IR from the circom AST element.
    ///
    /// 'ast: lifetime of the circom AST element
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx, P>) -> Result<()>;
}

impl<'ctx, P: ProgramLike> GenerateLLZKInModule<'ctx, P> for P {
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx, P>) -> Result<()> {
        for f in self.get_functions(codegen.config.stabilize) {
            codegen.set_current_body(f.get_body());
            gen_function_llzk(f, codegen)?;
        }
        // Collect declaration information for all templates first to avoid duplicating work.
        for t in self.get_templates(false) {
            codegen.set_current_body(t.get_body());
            codegen.put_template_decl(t.get_name(), t.get_declarations(codegen)?);
        }
        for t in self.get_templates(codegen.config.stabilize) {
            codegen.set_current_body(t.get_body());
            gen_template_llzk(t, codegen)?;
        }
        Ok(())
    }
}
