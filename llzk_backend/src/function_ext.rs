//! Extensions for the [`FunctionData`] and [`VCF`] types.

use crate::program_ext::ProgramLike;
use crate::shared::LlzkCodegen;
use anyhow::Result;
use compiler::hir::very_concrete_program::VCF;
use llzk::prelude::Location;
use llzk::prelude::Type;
use program_structure::ast::Statement;
use program_structure::function_data::FunctionData;
use std::slice;

/// Return the LLZK polymorphic type parameter name for a function input by position.
#[inline]
pub(crate) fn function_input_type_param(idx: usize) -> String {
    format!("T_arg{idx}")
}

/// Return the LLZK polymorphic type parameter name for a function return.
#[inline]
pub(crate) fn function_return_type_param() -> &'static str {
    "T_return"
}

/// A trait that allows common handling of the structs used to represent a circom
/// function at different stages in the compilation process.
pub trait FunctionLike: std::fmt::Debug {
    /// Generate the LLZK Location for the function definition.
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Location<'ctx>;

    /// Get the name of the function.
    fn get_name(&self) -> &str;

    /// Get the names of the parameters of the function.
    fn get_name_of_params(&self) -> Vec<String>;

    /// Get the types of parameters of the function.
    fn get_type_of_params<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Vec<Type<'ctx>>;

    /// Get the type of the function return value.
    fn get_type_of_return<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Type<'ctx>;

    /// Get the names of the `poly.param` ops to initially create for this function. In concrete
    /// mode, this will be empty but in templated mode, there will be one for each parameter and one
    /// for the return type. More `poly.param` ops may be added during codegen as needed, but these
    /// are the initial ones that will be created before codegen starts on the function body.
    fn initial_poly_param_names(&self) -> impl Iterator<Item = String>;

    /// Get the body statements of the function.
    fn get_body(&self) -> &[Statement];
}

impl FunctionLike for FunctionData {
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Location<'ctx> {
        codegen.location(self.get_file_id(), self.get_param_location())
    }

    fn get_name(&self) -> &str {
        self.get_name()
    }

    fn get_name_of_params(&self) -> Vec<String> {
        self.get_name_of_params().clone()
    }

    fn get_type_of_params<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Vec<Type<'ctx>> {
        (0..self.get_num_of_params())
            .map(|idx| codegen.tvar_type(&function_input_type_param(idx)))
            .collect()
    }

    fn get_type_of_return<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Type<'ctx> {
        codegen.tvar_type(function_return_type_param())
    }

    fn initial_poly_param_names(&self) -> impl Iterator<Item = String> {
        (0..self.get_num_of_params())
            .map(function_input_type_param)
            .chain(std::iter::once(function_return_type_param().to_string()))
    }

    fn get_body(&self) -> &[Statement] {
        self.get_body_as_vec()
    }
}

impl FunctionLike for VCF {
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Location<'ctx> {
        codegen.location_unknown()
    }

    fn get_name(&self) -> &str {
        &self.header
    }

    fn get_name_of_params(&self) -> Vec<String> {
        self.params_types.iter().map(|p| p.name.clone()).collect()
    }

    fn get_type_of_params<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Vec<Type<'ctx>> {
        let base_type = codegen.felt_type().into();
        self.params_types
            .iter()
            .map(|p| codegen.type_from_dimension_consts(base_type, &p.length))
            .collect::<Result<Vec<_>>>()
            .expect("In function parameter types")
    }

    fn get_type_of_return<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    ) -> Type<'ctx> {
        let base_type = codegen.felt_type().into();
        codegen
            .type_from_dimension_consts(base_type, &self.return_type)
            .expect("In function return type")
    }

    fn initial_poly_param_names(&self) -> impl Iterator<Item = String> {
        std::iter::empty()
    }

    fn get_body(&self) -> &[Statement] {
        // In VCF format, the function body is wrapped in a Block that conveys no additional
        // information but will cause returns to generate `scf.yield` instead of `function.return`.
        match &self.body {
            Statement::Block { stmts, .. } => stmts,
            b => slice::from_ref(b),
        }
    }
}
