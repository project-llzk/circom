//! Extensions for the [`TemplateData`] and [`TemplateInstance`] types.

use crate::module::DeclarationInfo;
use crate::program_ext::ProgramLike;
use crate::shared::LlzkCodegen;
use crate::subcmp;
use crate::subcmp::SubcmpDeclInfo;
use crate::template::TemplateContext;
use anyhow::anyhow;
use anyhow::bail;
use anyhow::Result;
use compiler::hir::very_concrete_program::ClusterType;
use compiler::hir::very_concrete_program::TemplateInstance;
use compiler::hir::very_concrete_program::Wire;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::Location;
use llzk::prelude::Attribute;
use llzk::prelude::StructType;
use llzk::prelude::TypeLike;
use program_structure::ast::Access;
use program_structure::ast::AssignOp;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::SignalType;
use program_structure::ast::Statement;
use program_structure::template_data::TemplateData;
use program_structure::wire_data::WireData;
use program_structure::wire_data::WireType;
use std::borrow::Cow;
use std::collections::HashMap;
use std::collections::HashSet;
use std::slice;
use std::convert::TryFrom;

/// A trait that allows common handling of structs/enums that represent template
/// inputs or outputs.
pub trait WireLike: Clone {
    /// Type of the wire (signal or bus).
    fn get_type(&self) -> WireType;
}

/// A trait that allows common handling of the structs used to represent a circom
/// template at different stages in the compilation process.
pub trait TemplateLike: std::fmt::Debug {
    /// The type used to represent wires.
    type WireData: WireLike;

    /// Generate the LLZK Location for the template definition.
    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx>;
    /// Get the name of the template.
    fn get_name(&self) -> &str;
    /// Get the names of the parameters of the template.
    fn get_name_of_params(&self) -> &[String];
    /// Get the initial subcomponent declarations of the template (outside the body),
    /// if any.
    fn get_init_subcmp_decls<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>
    ) -> Result<HashMap<String, SubcmpDeclInfo<'ctx>>>;
    /// Get the body statements of the template.
    fn get_body(&self) -> &[Statement];
    /// Construct [DeclarationInfo] containing var and signal declarations
    /// found in this template body.
    fn get_declarations<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<DeclarationInfo<'ctx>>;
    /// Returns the inputs in declaration order.
    fn get_declaration_inputs(&'_ self) -> Cow<'_, [(String, usize)]>;
    /// Returns the inputs of the template.
    fn get_inputs(&'_ self) -> Cow<'_, HashMap<String, Self::WireData>>;
    /// Returns the outputs of the template.
    fn get_outputs(&'_ self) -> Cow<'_, HashMap<String, Self::WireData>>;
    /// Returns information about a concrete input.
    fn get_input_info(&'_ self, name: &str) -> Option<Cow<'_, Self::WireData>> {
        match self.get_inputs() {
            Cow::Borrowed(i) => i.get(name).map(Cow::Borrowed),
            Cow::Owned(i) => i.get(name).cloned().map(Cow::Owned),
        }
    }
}

impl TemplateLike for TemplateData {
    type WireData = WireData;

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
    fn get_init_subcmp_decls<'ctx>(&self, _codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Result<HashMap<String, SubcmpDeclInfo<'ctx>>> {
        Ok(HashMap::new())
    }
    fn get_declarations<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<DeclarationInfo<'ctx>> {
        DeclarationInfo::from_template(codegen, self)
    }
    fn get_declaration_inputs(&'_ self) -> Cow<'_, [(String, usize)]> {
        Cow::Borrowed(self.get_declaration_inputs())
    }
    fn get_inputs(&'_ self) -> Cow<'_, HashMap<String, WireData>> {
        Cow::Borrowed(self.get_inputs())
    }
    fn get_outputs(&'_ self) -> Cow<'_, HashMap<String, WireData>> {
        Cow::Borrowed(self.get_outputs())
    }
    fn get_input_info(&'_ self, name: &str) -> Option<Cow<'_, WireData>> {
        self.get_input_info(name).map(Cow::Borrowed)
    }
}

impl WireLike for WireData {
    fn get_type(&self) -> WireType {
        self.get_type()
    }
}

impl TemplateLike for TemplateInstance {
    type WireData = Wire;

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
    fn get_init_subcmp_decls<'ctx>(&self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Result<HashMap<String, SubcmpDeclInfo<'ctx>>> {
        let mut subcmp_decls = HashMap::new();
        let location = codegen.location_unknown();
        // Create the declarations, but they currently have no types
        for component in &self.components {
            let name = &component.name;
            let dimensions = component
                .lengths
                .iter()
                .map(|len| -> Result<Attribute> {
                    let idx = codegen.index_attr(i64::try_from(*len)?);
                    Ok(idx.into())
                })
                .collect::<Result<Vec<Attribute>>>()?;
            let subcmp_decl = SubcmpDeclInfo::new(dimensions, location);

            if subcmp_decls
                .insert(name.clone(), subcmp_decl)
                .is_some()
            {
                bail!("Subcomponent {name} declared twice");
            }
        }
        // Get the types for the declarations
        for cluster in &self.clusters {
            if let Some(subcmp_decl) = subcmp_decls.get_mut(&cluster.cmp_name) {
                match &cluster.xtype {
                    // Mixed instantiation is also not supported in [DeclarationInfo::complete]
                    ClusterType::Mixed { .. } => todo!("Support mixed type subcomponent instantiations"),
                    ClusterType::Uniform { header, .. } => {
                        // See ExecutedTemplate::export_to_circuit for header construction
                        let last_underscore = header.rfind("_").ok_or_else(|| anyhow!("unexpected header string format"))?;
                        let (template_name, _) = header.split_at(last_underscore);
                        let struct_type = StructType::new(FlatSymbolRefAttribute::new(codegen.context, template_name), &[]);
                        subcmp_decl.instances_mut().push(struct_type);
                    },
                }
            }
        }
        Ok(subcmp_decls)
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
    fn get_declaration_inputs(&'_ self) -> Cow<'_, [(String, usize)]> {
        Cow::Owned(
            self.wires
                .iter()
                .filter_map(|w| match w {
                    Wire::TSignal(signal) if signal.xtype == SignalType::Input => {
                        Some((signal.name.clone(), signal.lengths.len()))
                    }
                    Wire::TBus(bus) if bus.xtype == SignalType::Input => {
                        Some((bus.name.clone(), bus.lengths.len()))
                    }
                    _ => None,
                })
                .collect(),
        )
    }
    fn get_inputs(&'_ self) -> Cow<'_, HashMap<String, Wire>> {
        Cow::Owned(wires_of_type(&self.wires, SignalType::Input))
    }
    fn get_outputs(&'_ self) -> Cow<'_, HashMap<String, Wire>> {
        Cow::Owned(wires_of_type(&self.wires, SignalType::Output))
    }
}

/// Filters the wires that match the given type and builds a map with them.
fn wires_of_type(wires: &[Wire], xtype: SignalType) -> HashMap<String, Wire> {
    wires
        .iter()
        .filter_map(|w| match w {
            Wire::TSignal(signal) if signal.xtype == xtype => {
                Some((signal.name.clone(), Wire::TSignal(signal.clone())))
            }
            Wire::TBus(bus) if bus.xtype == xtype => {
                Some((bus.name.clone(), Wire::TBus(bus.clone())))
            }
            _ => None,
        })
        .collect()
}

impl WireLike for Wire {
    fn get_type(&self) -> WireType {
        match self {
            Wire::TSignal(_) => WireType::Signal,
            Wire::TBus(bus) => WireType::Bus(bus.name.clone()),
        }
    }
}
