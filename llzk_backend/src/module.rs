//! Handles the top-level constructs (i.e. circom templates and functions), by delegating
//! to the [function] and [template] modules to generate the code for each.

use crate::function::FunctionContext;
use crate::function::GenerateLLZKInFunction as _;
use crate::shared::map_name_to_arg_value;
use crate::shared::LlzkCodegen;
use crate::template::GenerateLLZKInTemplate as _;
use crate::template::TemplateContext;
use anyhow::Result;
use llzk::attributes::NamedAttribute;
use llzk::error::Error;
use llzk::prelude::function;
use llzk::prelude::r#struct::helpers::compute_fn;
use llzk::prelude::r#struct::helpers::constrain_fn;
use llzk::prelude::r#struct::{self};
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::FeltType;
use llzk::prelude::FuncDefOpRef;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::FunctionType;
use llzk::prelude::Location;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::PublicAttribute;
use llzk::prelude::RegionLike;
use llzk::prelude::StructDefOpLike as _;
use llzk::prelude::StructType;
use llzk::prelude::Type;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::SignalType;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use program_structure::function_data::FunctionData;
use program_structure::program_archive::ProgramArchive;
use program_structure::template_data::TemplateData;
use std::collections::BTreeMap;
use std::collections::HashMap;
use std::convert::TryFrom;

/// Information needed to create an LLZK struct function parameter collected from the input signal
/// Declaration statements within a circom template.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
struct InputSignalInfo<'ctx> {
    /// Name of circom input signal that maps to a function parameter.
    name: String,
    /// Type+Location information for the function parameter.
    type_and_loc: (Type<'ctx>, Location<'ctx>),
    /// Named Attributes for the function parameter.
    attrs: Vec<NamedAttribute<'ctx>>,
}

/// Version of [`Access`](program_structure::ast::Access) that uses LLZK
/// Attributes instead.
#[derive(Debug, Eq, PartialEq)]
enum LlzkAccess<'ctx> {
    ComponentAccess(String),
    ArrayAccess(Attribute<'ctx>),
}

impl LlzkAccess<'_> {
    /// Returns true if the access is direct.
    ///
    /// An access is direct if it refers to a component or
    /// if the array access refers to a literal value.
    fn is_direct(&self) -> bool {
        matches!(self, LlzkAccess::ComponentAccess(_))
            || matches!(self, LlzkAccess::ArrayAccess(attribute)
                if attribute.is_integer())
    }
}

/// Manual implementation of Hash because the inner types do not implement it.
impl std::hash::Hash for LlzkAccess<'_> {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        /// Hash variant discriminant first to salt the hash.
        core::mem::discriminant(self).hash(state);
        match self {
            LlzkAccess::ComponentAccess(name) => name.hash(state),
            // Hash the attribute's pointer since they are unique w.r.t. the MLIR context.
            LlzkAccess::ArrayAccess(attribute) => attribute.to_raw().ptr.hash(state),
        }
    }
}

/// Information collected about a subcomponent.
#[derive(Debug)]
struct SubcmpDeclInfo<'ctx> {
    /// List of dimensions for arrays of subcomponents of the same type.
    dimensions: Vec<Attribute<'ctx>>,
    /// Name of the subcomponent type if it could be inferred during declaration.
    decl_inferred_type: Option<String>,
    /// Location of the declaration.
    location: Location<'ctx>,
    /// Instances of the subcomponent type.
    instances: HashMap<Vec<LlzkAccess<'ctx>>, StructType<'ctx>>,
}

/// Newtype for implementing Hash in StructType.
struct ST<'ctx>(StructType<'ctx>);

impl PartialEq for ST<'_> {
    fn eq(&self, other: &Self) -> bool {
        self.0.to_raw().ptr == other.0.to_raw().ptr
    }
}

impl Eq for ST<'_> {}

impl std::hash::Hash for ST<'_> {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.0.to_raw().ptr.hash(state);
    }
}

/// Information collected from Declaration statements within a template that is used to setup LLZK
/// struct fields and parameters to the functions with the struct.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
#[derive(Default)]
struct DeclarationInfo<'ctx> {
    /// Input Signal declarations to use as parameters to the LLZK struct functions.
    inputs: Vec<InputSignalInfo<'ctx>>,
    /// Output and Intermediate declarations to use as LLZK struct fields.
    struct_fields: Vec<Result<Operation<'ctx>, Error>>,
    /// Map `var` name to its LLZK declaration Operation (usually `undef.undef`).
    var_decls: HashMap<String, Operation<'ctx>>,
    /// Map `component` name to its declaration information.
    subcmp_decls: HashMap<String, SubcmpDeclInfo<'ctx>>,
}

impl<'ctx> DeclarationInfo<'ctx> {
    /// Completes the declaration information from the information collected from the
    /// subcomponents.
    fn complete(&mut self) {
        for (name, info) in &self.subcmp_decls {
            let instances =
                info.instances.iter().map(|(a, t)| (a.as_slice(), *t)).collect::<Vec<_>>();
            match instances.as_slice() {
                [] => todo!("Handle uninitialized component decl"),
                [([], t)] => self
                    .struct_fields
                    .push(r#struct::field(info.location, name, *t, false, false).map(Into::into)),
                instances => {
                    let types = instances.iter().map(|(_, t)| ST(*t)).collect::<HashSet<_>>();
                    if types.len() > 1 {
                        todo!("Handle array subcomponents")
                    }
                    self.struct_fields.push(
                        r#struct::field(
                            info.location,
                            name,
                            ArrayType::new(
                                types.into_iter().next().unwrap().0.into(),
                                &info.dimensions,
                            ),
                            false,
                            false,
                        )
                        .map(Into::into),
                    )
                }
            }
        }
    }

    /// Visit a statement and populate this `DeclarationInfo` with any declarations found.
    ///
    /// TODO: This currently visits only top-level statements within the template body. However,
    /// since circom 2.1.5, signal declarations are allowed inside of blocks and known-condition if
    /// statements. Those nested declarations are not currently processed here.
    ///
    /// 'ast: lifetime of the circom AST element
    fn visit<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx>,
        stmt: &'ast Statement,
    ) -> Result<()> {
        match stmt {
            Statement::InitializationBlock { initializations, .. } => {
                // The InitializationBlock is just a wrapper that contains no additional information
                // beyond the Declarations that must appear within it so just process the inner
                // statements.
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
                        meta,
                        name,
                        dimensions,
                        signal_type,
                        FeltType::new(codegen.context).into(),
                    ),
                    VariableType::Bus(bus_name, signal_type, ..) => self.visit_signal_or_bus(
                        codegen,
                        meta,
                        name,
                        dimensions,
                        signal_type,
                        StructType::from_str(codegen.context, bus_name).into(),
                    ),
                    VariableType::Var => {
                        // Create an `undef` of the appropriate type. When the actual assignment is
                        // processed later, replace the `undef` with the appropriate value.
                        self.var_decls.insert(
                            name.clone(),
                            codegen.new_nondet_felt_of_dimensions(meta, dimensions)?,
                        );
                        Ok(())
                    }
                    VariableType::Component => {
                        self.visit_component_decl(codegen, meta, name, dimensions)
                    }
                    VariableType::AnonymousComponent => {
                        unreachable!("removed by 'syntax_sugar_remover'")
                    }
                }
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                // We need to gather the concrete types of the subcomponents used across the template.
                // These are defined in the AST as a substitution over the variable name of the
                // subcomponent.
                if !matches!(op, AssignOp::AssignVar) || !self.subcmp_decls.contains_key(var) {
                    return Ok(());
                }

                let struct_type = Self::find_subcmp_ctor_call(codegen, rhe)?.expect("missing type");
                let access = access
                    .iter()
                    .map(|access| {
                        Ok(match access {
                            Access::ComponentAccess(name) => {
                                LlzkAccess::ComponentAccess(name.clone())
                            }
                            Access::ArrayAccess(expr) => {
                                LlzkAccess::ArrayAccess(convert_dim_expr(codegen, expr)?)
                            }
                        })
                    })
                    .collect::<Result<Vec<_>>>()?;
                let direct_access = access.iter().all(LlzkAccess::is_direct);
                let mut double_assign = false;
                self.subcmp_decls.entry(var.clone()).and_modify(|info| {
                    double_assign = info.instances.insert(access, struct_type).is_some();
                });
                // Only emit the double assignment error if the access path was direct.
                // To avoid reporting cases like `a[n]`.
                if double_assign && direct_access {
                    let err_msg = format!("Component {var} assigned twice",);
                    codegen.emit_circom_error(
                        meta,
                        err_msg.as_str(),
                        ReportCode::AssigningAComponentTwice,
                    );
                    bail!(err_msg);
                }

                Ok(())
            }
            _ => Ok(()),
        }
    }

    /// Searches in an [`Expression`] for a call to a subcomponent's constructor.
    ///
    /// In this context constructor refers to `Foo(n)` in Circom, not `@Foo::@compute` in LLZK.
    fn find_subcmp_ctor_call<'ast>(
        codegen: &LlzkCodegen<'ast, 'ctx>,
        expression: &'ast Expression,
    ) -> Result<Option<StructType<'ctx>>> {
        Ok(match expression {
            Expression::Call { meta, id, args, .. } if meta.get_type_knowledge().is_component() => {
                Some(struct_type_with_concrete_dimensions(codegen, id, args)?)
            }
            _ => None,
        })
    }

    /// [`visit`](Self::visit) helper for component declarations.
    fn visit_component_decl(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx>,
        meta: &Meta,
        name: &str,
        dimensions: &[Expression],
    ) -> Result<()> {
        let location = codegen.location_from_meta(meta);

        if self
            .subcmp_decls
            .insert(
                name.to_owned(),
                SubcmpDeclInfo {
                    dimensions: Self::try_dimensions_to_attrs(codegen, dimensions)?,
                    decl_inferred_type: meta.component_inference.clone(),
                    location,
                    instances: Default::default(),
                },
            )
            .is_some()
        {
            anyhow::bail!("Subcomponent {name} declared twice");
        }
        Ok(())
    }

    /// `visit()` helper for Signal and Bus VariableType.
    fn visit_signal_or_bus(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx>,
        meta: &Meta,
        name: &String,
        dimensions: &[Expression],
        signal_type: &SignalType,
        base_type: Type<'ctx>,
    ) -> Result<()> {
        let location = codegen.location_from_meta(meta);
        let decl_type = codegen.type_with_dimensions(base_type, dimensions)?;
        if SignalType::Input == *signal_type {
            // self.func_inputs.push((decl_type, location));
            let mut attrs: Vec<NamedAttribute<'_>> = Vec::new();
            if codegen.program_archive.get_public_inputs_main_component().contains(name) {
                attrs.push(PublicAttribute::new_named_attr(codegen.context));
            }
            self.inputs.push(InputSignalInfo {
                name: name.clone(),
                type_and_loc: (decl_type, location),
                attrs,
            });
        } else {
            let new = r#struct::field(
                location,
                name,
                decl_type,
                false,
                SignalType::Output == *signal_type,
            );
            self.struct_fields.push(new.map(|f| f.into()));
        }
        Ok(())
    }

    /// If `dimensions` is empty, return `base_type`. Otherwise, create ArrayType by converting the
    /// dimension circom Expressions to LLZK Attributes.
    fn type_with_dimensions(
        codegen: &LlzkCodegen<'_, 'ctx>,
        base_type: Type<'ctx>,
        dimensions: &[Expression],
    ) -> Result<Type<'ctx>> {
        if dimensions.is_empty() {
            Ok(base_type)
        } else {
            Self::try_dimensions_to_attrs(codegen, dimensions)
                .map(|dims| ArrayType::new(base_type, &dims).into())
        }
    }

    /// Tries to convert a list of [`Expression`] to a list of [`Attribute`].
    #[inline]
    fn try_dimensions_to_attrs(
        codegen: &LlzkCodegen<'_, 'ctx>,
        dimensions: &[Expression],
    ) -> Result<Vec<Attribute<'ctx>>> {
        dimensions.iter().map(|e| convert_dim_expr(codegen, e)).collect()
    }
}

/// A trait to generate LLZK IR for structural elements of the circom AST:
/// ProgramArchive, TemplateData, and FunctionData.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
pub trait GenerateLLZKInModule<'ctx> {
    /// Generates LLZK IR from the circom AST element.
    ///
    /// 'ast: lifetime of the circom AST element
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx>) -> Result<()>;
}

impl<'ctx> GenerateLLZKInModule<'ctx> for ProgramArchive {
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx>) -> Result<()> {
        // Sort functions and templates by name for deterministic output (this is only needed for
        // the lit tests since the order in a HashMap is non-deterministic and could be triggered
        // only based on a debug flag or similar).
        for (_, data) in self.functions.iter().collect::<BTreeMap<_, _>>() {
            data.gen_llzk(codegen)?;
        }
        for (_, data) in self.templates.iter().collect::<BTreeMap<_, _>>() {
            data.gen_llzk(codegen)?;
        }
        Ok(())
    }
}

impl<'ctx> GenerateLLZKInModule<'ctx> for FunctionData {
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx>) -> Result<()> {
        let location = codegen.location(self.get_file_id(), self.get_param_location());
        let felt_type = FeltType::new(codegen.context).into();
        // TODO: This just uses `felt.type` for param and return types but those must actually be
        // determined based on the caller. Circom functions cannot accept or return components or
        // busses so the only types allowed for params and return are `felt.type` and arrays of
        // `felt.type`. The actual type used here also affects the dimensions of array types and
        // which array read/write-like ops must be used when translating the body.
        let inputs = vec![felt_type; self.get_num_of_params()];
        let func_type = FunctionType::new(codegen.context, &inputs, &[felt_type]);
        let func_def =
            function::def(location, self.get_name(), func_type, &[], None).and_then(|f| {
                let arguments: Vec<(Type, Location)> =
                    inputs.into_iter().map(|t| (t, location)).collect();
                f.region(0)?.append_block(Block::new(&arguments));
                Ok(f)
            })?;

        // Store function to the module.
        let func: FuncDefOpRefMut = codegen.add_function(func_def)?;

        // Generate mapping from parameter names to SSA Values.
        let name_to_value = map_name_to_arg_value(func, self.get_name_of_params())?;

        // Visit the body of the function and generate LLZK IR for it.
        let mut func_context = FunctionContext::new::<true>(codegen, func, name_to_value)?;
        self.get_body_as_vec().gen_llzk_in_function(codegen, &mut func_context)
    }
}

impl<'ctx> GenerateLLZKInModule<'ctx> for TemplateData {
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx>) -> Result<()> {
        // Collect declarations first to determine struct fields and function parameters.
        let mut declarations = DeclarationInfo::default();
        for s in self.get_body_as_vec() {
            declarations.visit(codegen, s)?;
        }
        declarations.complete();

        // Generate the struct definition, prepopulated with fields.
        let struct_loc = codegen.location(self.get_file_id(), self.get_param_location());
        let struct_params: Vec<_> = self.get_name_of_params().iter().map(String::as_str).collect();
        let struct_def =
            r#struct::def(struct_loc, self.get_name(), &struct_params, declarations.struct_fields)?;
        let new_struct = codegen.add_struct(struct_def)?;

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
            compute_fn(struct_loc, new_struct_type, &inputs, Some(&arg_attrs))?.into(),
        ))?
        .into();
        let constrain_func = FuncDefOpRef::try_from(struct_body.append_operation(
            constrain_fn(struct_loc, new_struct_type, &inputs, Some(&arg_attrs))?.into(),
        ))?
        .into();

        // Map parameter Values of each LLZK function to the corresponding circom variable names and
        // then create the FunctionContext for each function. Before creating the FunctionContext
        // for constrain, add a dummy name at index 0 since the first parameter is the struct ref.
        let mut compute_ctx = FunctionContext::new::<false>(
            codegen,
            compute_func,
            map_name_to_arg_value(compute_func, &arg_names)?,
        )?;
        let mut arg_names = arg_names;
        arg_names.insert(0, "**self**".to_string());
        let mut constrain_ctx = FunctionContext::new::<false>(
            codegen,
            constrain_func,
            map_name_to_arg_value(constrain_func, &arg_names)?,
        )?;
        // Insert the Operations created from variable Declaration statements and map the circom
        // variable name to LLZK op result Value (do this in each function).
        for (name, op) in declarations.var_decls {
            // Insert (a clone of) the declaration into the compute function.
            compute_ctx.block_ctx.declare_name_if_not_present(&name, || Ok(op.clone()))?;
            // Insert the declaration into the constrain function.
            constrain_ctx.block_ctx.declare_name_if_not_present(&name, || Ok(op))?;
        }

        // Visit the body of the template and generate LLZK IR for it within the struct functions.
        let template_context = TemplateContext::new(new_struct, compute_ctx, constrain_ctx);
        self.get_body_as_vec().gen_llzk_in_template(codegen, &template_context)
    }
}
