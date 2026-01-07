//! Extensions for the [`FunctionData`] and [`VCF`] types.

use std::slice;

use crate::program_ext::ProgramLike;
use crate::shared::LlzkCodegen;
use compiler::hir::very_concrete_program::VCF;
use melior::ir::Location;
use program_structure::ast::Statement;
use program_structure::function_data::FunctionData;

/// A trait that allows common handling of the structs used to represent a circom
/// function at different stages in the compilation process.
pub trait FunctionLike {
    /// Generate the LLZK Location for the function definition.
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx>;
    /// Get the name of the function.
    fn get_name(&self) -> &str;
    /// Get the number of parameters of the function.
    fn get_num_of_params(&self) -> usize;
    /// Get the names of the parameters of the function.
    fn get_name_of_params(&self) -> Vec<String>;
    /// Get the body statements of the function.
    fn get_body(&self) -> &[Statement];
}

impl FunctionLike for FunctionData {
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx> {
        codegen.location(self.get_file_id(), self.get_param_location())
    }
    fn get_name(&self) -> &str {
        self.get_name()
    }
    fn get_num_of_params(&self) -> usize {
        self.get_num_of_params()
    }
    fn get_name_of_params(&self) -> Vec<String> {
        self.get_name_of_params().clone()
    }
    fn get_body(&self) -> &[Statement] {
        self.get_body_as_vec()
    }
}

impl FunctionLike for VCF {
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx> {
        codegen.location_unknown()
    }
    fn get_name(&self) -> &str {
        &self.header
    }
    fn get_num_of_params(&self) -> usize {
        self.params_types.len()
    }
    fn get_name_of_params(&self) -> Vec<String> {
        self.params_types.iter().map(|p| p.name.clone()).collect()
    }
    fn get_body(&self) -> &[Statement] {
        // In VCF format, the function body is wrapped in a Block that conveys no additional
        // information but will cause returns to generate `scf.yield`` instead of `function.return`.
        match &self.body {
            Statement::Block { stmts, .. } => return stmts,
            b => slice::from_ref(b),
        }
    }
}
