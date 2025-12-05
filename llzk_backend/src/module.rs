#![allow(unused_variables)] // TODO: TEMP
use crate::{
    function::{FunctionContext, GenerateLLZKInFunction as _},
    shared::{map_name_to_arg_value, LlzkCodegen},
    template::{GenerateLLZKInTemplate as _, TemplateContext},
};
use anyhow::{anyhow, Result};
use llzk::{
    attributes::NamedAttribute,
    error::Error,
    prelude::{
        function,
        r#struct::{
            self,
            helpers::{compute_fn, constrain_fn},
        },
        undef, ArrayType, FeltType, FuncDefOpRef, FuncDefOpRefMut, FunctionType, IntegerAttribute,
        PublicAttribute, StructDefOpLike as _, StructType,
    },
};
use melior::ir::{
    operation::OperationLike as _, Attribute, Block, BlockLike as _, Identifier, Location,
    Operation, RegionLike, Type,
};
use num_traits::cast::ToPrimitive;
use program_structure::{
    ast::{Expression, Meta, SignalType, Statement, VariableType},
    function_data::FunctionData,
    program_archive::ProgramArchive,
    template_data::TemplateData,
};
use std::{collections::HashMap, convert::TryFrom};

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
}

impl<'ctx> DeclarationInfo<'ctx> {
    /// Visit a statement and populate this `DeclarationInfo` with any declarations found.
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
                        let op = undef::undef(
                            codegen.location_from_meta(meta),
                            Self::type_with_dimensions(
                                codegen,
                                FeltType::new(codegen.context).into(),
                                dimensions,
                            )?,
                        );
                        self.var_decls.insert(name.clone(), op);
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
        let decl_type = Self::type_with_dimensions(codegen, base_type, dimensions)?;
        if SignalType::Input == *signal_type {
            // self.func_inputs.push((decl_type, location));
            let mut attrs: Vec<NamedAttribute<'_>> = Vec::new();
            if codegen.program_archive.get_public_inputs_main_component().contains(name) {
                attrs.push(PublicAttribute::named_attr(codegen.context));
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
            dimensions
                .iter()
                .map(|e| Self::convert_dim_expr(codegen, e))
                .collect::<Result<Vec<_>, _>>()
                .map(|dims| ArrayType::new(base_type, &dims).into())
        }
    }

    /// Convert a circom Expression used as an array dimension to an LLZK Attribute.
    ///
    /// Note: The LLZK ArrayType can only use the following Attribute types for dimensions:
    /// IntegerAttr (`index` or `i1`), SymbolRefAttr, or AffineMapAttr (with single result,
    /// probably an identity map).
    ///
    /// 'ast: lifetime of the circom AST element
    fn convert_dim_expr<'ast>(
        codegen: &LlzkCodegen<'ast, 'ctx>,
        expr: &Expression,
    ) -> Result<Attribute<'ctx>> {
        match expr {
            Expression::Number(meta, big_int) => {
                let int_attr = IntegerAttribute::new(
                    Type::index(codegen.context),
                    big_int.to_i64().ok_or_else(|| anyhow!("Array dimension must fit in i64"))?,
                );
                Ok(int_attr.into())
            }
            Expression::Variable { meta, name, access } => {
                // TODO: generate AffineMapAttr (with single result) or SymbolRefAttr (from param)
                todo!("Handle Variable expression in dimension")
            }
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                todo!("Handle InfixOp expression in dimension")
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                todo!("Handle PrefixOp expression in dimension")
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                todo!("Handle InlineSwitchOp expression in dimension")
            }
            Expression::Call { meta, id, args } => {
                todo!("Handle Call expression in dimension")
            }
            // The remaining cases do not produce a scalar value.
            // i.e. ParallelOp, ArrayInLine, UniformArray, BusCall, AnonymousComp, Tuple
            // Give the same error that the circom type checker gives. The type checker ran
            // earlier so this should technically be unreachable.
            _ => Err(anyhow!("Array indexes and lengths must be single arithmetic expressions")),
        }
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
        for data in self.functions.values() {
            data.gen_llzk(codegen)?;
        }
        for data in self.templates.values() {
            data.gen_llzk(codegen)?;
        }
        Ok(())
    }
}

impl<'ctx> GenerateLLZKInModule<'ctx> for FunctionData {
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx>) -> Result<()> {
        let location = codegen.location(self.get_file_id(), self.get_param_location());
        let felt_type = FeltType::new(codegen.context).into();
        // TODO: This just uses `felt.type` for param and return types but those must actually
        //  be determined based on the caller. This also affects the dimensions of array types
        //  and which array read/write-like ops must be used when translating the body.
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
        let mut func_context = FunctionContext::new(func, name_to_value)?;
        for s in self.get_body_as_vec() {
            s.gen_llzk_in_function(codegen, &mut func_context)?;
        }

        Ok(())
    }
}

impl<'ctx> GenerateLLZKInModule<'ctx> for TemplateData {
    fn gen_llzk<'ast>(&'ast self, codegen: &LlzkCodegen<'ast, 'ctx>) -> Result<()> {
        // Collect declarations first to determine struct fields and function parameters.
        let mut declarations = DeclarationInfo::default();
        for s in self.get_body_as_vec() {
            declarations.visit(codegen, s)?;
        }

        // Generate the struct definition, prepopulated with fields.
        let struct_loc = codegen.location(self.get_file_id(), self.get_param_location());
        let struct_params: Vec<_> = self.get_name_of_params().iter().map(String::as_str).collect();
        let struct_def =
            r#struct::def(struct_loc, self.get_name(), &struct_params, declarations.struct_fields)?;
        let new_struct = codegen.add_struct(struct_def)?;

        // Generate the compute and constrain functions.
        let inputs: Vec<_> = declarations.inputs.iter().map(|v| v.type_and_loc).collect();
        let arg_attrs: Vec<_> = declarations.inputs.iter().map(|v| v.attrs.clone()).collect();
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
        let mut arg_names: Vec<_> = declarations.inputs.iter().map(|i| i.name.clone()).collect();
        let mut compute_ctx =
            FunctionContext::new(compute_func, map_name_to_arg_value(compute_func, &arg_names)?)?;
        arg_names.insert(0, "**self**".to_string());
        let mut constrain_ctx = FunctionContext::new(
            constrain_func,
            map_name_to_arg_value(constrain_func, &arg_names)?,
        )?;
        // Insert the Operations created from variable Declaration statements and map the circom
        // variable name to LLZK op result Value (do this in each function).
        for (name, op) in declarations.var_decls {
            // Insert (a clone of) the declaration into the compute function.
            compute_ctx.append_op_named_result(op.clone(), name.clone());
            // Insert the declaration into the constrain function.
            constrain_ctx.append_op_named_result(op, name);
        }

        // Visit the body of the template and generate LLZK IR for it within the struct functions.
        let template_context = TemplateContext::new(new_struct, compute_ctx, constrain_ctx);
        for s in self.get_body_as_vec() {
            s.gen_llzk_in_template(codegen, &template_context)?;
        }

        Ok(())
    }
}
