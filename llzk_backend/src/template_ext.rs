//! Extensions for the [`TemplateData`] and [`TemplateInstance`] types.

use crate::module::DeclarationInfo;
use crate::program_ext::ProgramLike;
use crate::shared::LlzkCodegen;
use anyhow::Result;
use compiler::hir::very_concrete_program::TemplateInstance;
use compiler::hir::very_concrete_program::Wire;
use melior::ir::Location;
use program_structure::ast::Statement;
use program_structure::template_data::TemplateData;
use std::slice;

/// A trait that allows common handling of the structs used to represent a circom
/// template at different stages in the compilation process.
pub trait TemplateLike: std::fmt::Debug {
    /// Generate the LLZK Location for the template definition.
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx>;
    /// Get the name of the template.
    fn get_name(&self) -> &str;
    /// Get the names of the parameters of the template.
    fn get_name_of_params(&self) -> &[String];
    /// Get the body statements of the template.
    fn get_body(&self) -> &[Statement];
    /// Construct [DeclarationInfo] containing var and signal declarations
    /// found in this template body.
    fn get_declarations<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<DeclarationInfo<'ctx>>;
}

impl TemplateLike for TemplateData {
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx> {
        codegen.location(self.get_file_id(), self.get_param_location())
    }
    fn get_name(&self) -> &str {
        self.get_name()
    }
    fn get_name_of_params(&self) -> &[String] {
        self.get_name_of_params()
    }
    fn get_body(&self) -> &[Statement] {
        self.get_body_as_vec()
    }
    fn get_declarations<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<DeclarationInfo<'ctx>> {
        DeclarationInfo::from_template(codegen, self)
    }
}

impl TemplateLike for TemplateInstance {
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx> {
        codegen.location_unknown()
    }
    fn get_name(&self) -> &str {
        &self.template_name
    }
    fn get_name_of_params(&self) -> &[String] {
        &[]
    }
    fn get_body(&self) -> &[Statement] {
        slice::from_ref(&self.code)
    }
    fn get_declarations<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<DeclarationInfo<'ctx>> {
        let mut declarations = DeclarationInfo::from_template(codegen, self)?;
        for w in &self.wires {
            match w {
                Wire::TSignal(signal) => declarations.visit_signal_or_bus_impl(
                    codegen,
                    &signal.xtype,
                    &signal.name,
                    self.get_location(codegen),
                    codegen
                        .type_from_dimension_consts(codegen.felt_type().into(), &signal.lengths)?,
                )?,
                Wire::TBus(bus) => declarations.visit_signal_or_bus_impl(
                    codegen,
                    &bus.xtype,
                    &bus.name,
                    self.get_location(codegen),
                    codegen.type_from_dimension_consts(
                        codegen.struct_type(&bus.name).into(),
                        &bus.lengths,
                    )?,
                )?,
            }
        }
        Ok(declarations)
    }
}
