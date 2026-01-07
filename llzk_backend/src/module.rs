//! Handles the top-level constructs (i.e. circom templates and functions), by delegating
//! to the [crate::function] and [crate::template] modules to generate the code for each.

use crate::function::FunctionContext;
use crate::function::GenerateLLZKInFunction as _;
use crate::function_ext::FunctionLike;
use crate::program_ext::ProgramLike;
use crate::shared::map_name_to_arg_value;
use crate::shared::LlzkCodegen;
use crate::template::GenerateLLZKInTemplate as _;
use crate::template::TemplateContext;
use crate::template_ext::TemplateLike;
use anyhow::Result;
use compiler::hir::very_concrete_program::TemplateInstance;
use compiler::hir::very_concrete_program::Wire;
use compiler::hir::very_concrete_program::VCF;
use compiler::hir::very_concrete_program::VCP;
use llzk::attributes::NamedAttribute;
use llzk::error::Error;
use llzk::prelude::function;
use llzk::prelude::r#struct::helpers::compute_fn;
use llzk::prelude::r#struct::helpers::constrain_fn;
use llzk::prelude::r#struct::{self};
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::FuncDefOpRef;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::FunctionType;
use llzk::prelude::Location;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::PublicAttribute;
use llzk::prelude::RegionLike;
use llzk::prelude::StructDefOpLike as _;
use llzk::prelude::Type;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::SignalType;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use program_structure::file_definition::FileID;
use program_structure::file_definition::FileLibrary;
use program_structure::function_data::FunctionData;
use program_structure::program_archive::ProgramArchive;
use program_structure::template_data::TemplateData;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::slice;

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

/// Information collected from Declaration statements within a template that is used to setup LLZK
/// struct fields and parameters to the functions with the struct.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
#[derive(Debug, Default)]
pub struct DeclarationInfo<'ctx> {
    /// Input Signal declarations to use as parameters to the LLZK struct functions.
    inputs: Vec<InputSignalInfo<'ctx>>,
    /// Output and Intermediate declarations to use as LLZK struct fields.
    struct_fields: Vec<Result<Operation<'ctx>, Error>>,
    /// Map var/signal name to its LLZK declaration Operation (usually `undef.undef`).
    decl_inits: HashMap<String, Operation<'ctx>>,
}

impl<'ctx> DeclarationInfo<'ctx> {
    /// Visit all statements in the body of the template and return a new [DeclarationInfo]
    /// with any declarations found.
    pub(crate) fn from_template(
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        template: &impl TemplateLike,
    ) -> Result<DeclarationInfo<'ctx>> {
        let mut declarations = DeclarationInfo::default();
        for s in template.get_body() {
            declarations.visit(codegen, s)?;
        }
        Ok(declarations)
    }

    /// Visit a statement and populate this [DeclarationInfo] with any declarations found.
    ///
    /// TODO: This currently visits only top-level statements within the template body. However,
    /// since circom 2.1.5, signal declarations are allowed inside of blocks and known-condition if
    /// statements. Those nested declarations are not currently processed here.
    fn visit(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        stmt: &Statement,
    ) -> Result<()> {
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
                        // Create an `undef` of the appropriate type. When the actual assignment is
                        // processed later, this is replaced with the appropriate value.
                        self.decl_inits.insert(
                            name.clone(),
                            codegen.new_nondet_felt_of_dimensions(meta, dimensions)?,
                        );
                        Ok(())
                    }
                    VariableType::Component => {
                        todo!("Handle component declaration in template")
                    }
                    VariableType::AnonymousComponent => {
                        unreachable!("removed by 'syntax_sugar_remover'")
                    }
                }
            }
            _ => Ok(()),
        }
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
        let decl_type = codegen.type_from_dimension_exprs(base_type, dimensions)?;
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
            let new = r#struct::field(
                location,
                name,
                decl_type,
                false,
                SignalType::Output == *signal_type,
            );
            self.struct_fields.push(new.map(Into::into));
        }
        // Create an `undef` of the appropriate type. When the actual assignment is
        // processed later, this is replaced with the appropriate value.
        codegen.new_nondet_at_location(location, decl_type).map(|op| {
            self.decl_inits.insert(name.clone(), op);
        })
    }
}

/// Generate LLZK for a function-like construct. Helper to avoid code duplication.
fn gen_function_llzk<'ast, 'ctx, F: FunctionLike>(
    func_like: &'ast F,
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
) -> Result<()> {
    let location = func_like.get_location(codegen);
    let felt_type = codegen.felt_type().into();
    // TODO: This just uses `felt.type` for param and return types but those must actually be
    // determined based on the caller. Circom functions cannot accept or return components or
    // busses so the only types allowed for params and return are `felt.type` and arrays of
    // `felt.type`. The actual type used here also affects the dimensions of array types and
    // which array read/write-like ops must be used when translating the body.
    let inputs = vec![felt_type; func_like.get_num_of_params()];
    let func_type = FunctionType::new(codegen.context, &inputs, &[felt_type]);
    let func_def =
        function::def(location, func_like.get_name(), func_type, &[], None).and_then(|f| {
            let arguments: Vec<(Type, Location)> =
                inputs.into_iter().map(|t| (t, location)).collect();
            f.region(0)?.append_block(Block::new(&arguments));
            Ok(f)
        })?;

    // Store function to the module.
    let func: FuncDefOpRefMut = codegen.add_function(func_def)?;

    // Generate mapping from parameter names to SSA Values.
    let name_to_value = map_name_to_arg_value(func, func_like.get_name_of_params())?;

    // Visit the body of the function and generate LLZK IR for it.
    let mut func_context = FunctionContext::new::<true>(codegen, func, name_to_value)?;
    func_like.get_body().gen_llzk_in_function(codegen, &mut func_context)
}

/// Generate LLZK for a template-like construct. Helper to avoid code duplication.
fn gen_template_llzk<'ast, 'ctx, T: TemplateLike>(
    template_like: &'ast T,
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
) -> Result<()> {
    // Collect declarations first to determine struct fields and function parameters.
    let declarations = template_like.get_declarations(codegen)?;

    // Generate the struct definition, prepopulated with fields.
    let struct_loc = template_like.get_location(codegen);
    let struct_params: Vec<_> =
        template_like.get_name_of_params().iter().map(String::as_str).collect();
    let struct_def = r#struct::def(
        struct_loc,
        template_like.get_name(),
        &struct_params,
        declarations.struct_fields,
    )?;
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
        map_name_to_arg_value(compute_func, arg_names.clone())?,
    )?;
    let mut arg_names = arg_names;
    arg_names.insert(0, "**self**".to_string());
    let mut constrain_ctx = FunctionContext::new::<false>(
        codegen,
        constrain_func,
        map_name_to_arg_value(constrain_func, arg_names)?,
    )?;
    // Insert the Operations created from variable Declaration statements and map the circom
    // variable name to LLZK op result Value (do this in each function).
    for (name, op) in declarations.decl_inits {
        // Insert (a clone of) the declaration into the compute function.
        compute_ctx.block_ctx.declare_name_if_not_present(&name, || Ok(op.clone()))?;
        // Insert the declaration into the constrain function.
        constrain_ctx.block_ctx.declare_name_if_not_present(&name, || Ok(op))?;
    }

    // Visit the body of the template and generate LLZK IR for it within the struct functions.
    let template_context = TemplateContext::new(new_struct, compute_ctx, constrain_ctx);
    template_like.get_body().gen_llzk_in_template(codegen, &template_context)
}

/// Helper function to sort a vector of &FunctionLike by name.
#[inline]
fn sort_functions_by_name<T: FunctionLike>(functions: &mut [&T]) {
    functions.sort_by(|a, b| a.get_name().cmp(b.get_name()));
}

/// Helper function to sort a vector of &TemplateLike by name.
#[inline]
fn sort_templates_by_name<T: TemplateLike>(templates: &mut [&T]) {
    templates.sort_by(|a, b| a.get_name().cmp(b.get_name()));
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
        // Sort functions and templates by name for deterministic output (this is only needed for
        // the lit tests since the order in a HashMap is non-deterministic and could be triggered
        // only based on a debug flag or similar).
        for f in self.get_functions(true) {
            gen_function_llzk(f, codegen)?;
        }
        for t in self.get_templates(true) {
            gen_template_llzk(t, codegen)?;
        }
        Ok(())
    }
}
