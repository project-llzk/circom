//! Extensions for the [`TemplateData`] and [`TemplateInstance`] types.

use crate::module::DeclarationInfo;
use crate::program_ext::ProgramLike;
use crate::shared::LlzkCodegen;
use crate::subcmp::MixedSubcmpInstance;
use crate::subcmp::SubcmpDeclInfo;
use crate::template::GenerateLLZKInTemplate;
use crate::template::TemplateContext;
use anyhow::anyhow;
use anyhow::bail;
use anyhow::Result;
use compiler::hir::very_concrete_program::ClusterType;
use compiler::hir::very_concrete_program::TemplateInstance;
use compiler::hir::very_concrete_program::Wire;
use llzk::prelude::Attribute;
use llzk::prelude::Location;
use num_bigint_dig::BigInt;
use num_traits::FromPrimitive;
use program_structure::ast::AssignOp::AssignVar;
use program_structure::ast::Expression;
use program_structure::ast::Meta;
use program_structure::ast::SignalType;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use program_structure::template_data::TemplateData;
use program_structure::wire_data::WireData;
use program_structure::wire_data::WireType;
use std::borrow::Cow;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::slice;

/// Trait for IR objects that can have signal declarations on them.
pub trait SignalDeclarations {
    /// Returns true if the signal is an input.
    ///
    /// Returns false if the signal is not an input or is not declared.
    fn signal_is_input(&self, name: &str) -> bool;
}

impl<T: TemplateLike> SignalDeclarations for T {
    fn signal_is_input(&self, name: &str) -> bool {
        self.get_inputs().contains_key(name)
    }
}

/// A trait that allows common handling of structs/enums that represent template
/// inputs or outputs.
pub trait WireLike: Clone + std::fmt::Debug {
    /// Type of the wire (signal or bus).
    fn get_type(&self) -> WireType;
}

/// A trait that allows common handling of the structs used to represent a circom
/// template at different stages in the compilation process.
pub trait TemplateLike: std::fmt::Debug {
    /// The type used to represent wires.
    type WireDataType: WireLike;

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
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<HashMap<String, SubcmpDeclInfo<'ctx>>>;

    /// Get the body statements of the template.
    fn get_body(&self) -> &[Statement];

    /// Construct [DeclarationInfo] containing var and signal declarations
    /// found in this template body.
    fn get_declarations<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<DeclarationInfo<'ctx>>;

    /// Returns the inputs in declaration order, containing name and number of dimensions.
    fn get_declaration_inputs(&'_ self) -> Cow<'_, [(String, usize)]>;

    /// Gets the index of the input signal with the given name from `get_declaration_inputs()`.
    fn get_declaration_input_idx(&self, signal_name: &str) -> Result<usize> {
        self.get_declaration_inputs()
            .iter()
            .enumerate()
            .find_map(|(idx, (s, _))| (signal_name == s).then_some(idx))
            .ok_or_else(|| {
                anyhow::anyhow!("no input signal '{signal_name}' in template '{}'", self.get_name())
            })
    }

    /// Returns the inputs of the template.
    fn get_inputs(&'_ self) -> Cow<'_, HashMap<String, Self::WireDataType>>;

    /// Returns the outputs of the template.
    fn get_outputs(&'_ self) -> Cow<'_, HashMap<String, Self::WireDataType>>;

    /// Returns information about a concrete input.
    fn get_input_info(&'_ self, name: &str) -> Option<Cow<'_, Self::WireDataType>> {
        match self.get_inputs() {
            Cow::Borrowed(i) => i.get(name).map(Cow::Borrowed),
            Cow::Owned(i) => i.get(name).cloned().map(Cow::Owned),
        }
    }

    /// Generate any LLZK code needed in the beginning of the template.
    fn gen_preamble<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        template: &TemplateContext<'_, 'ctx, '_, '_, '_, '_>,
    ) -> Result<()>;
}

impl TemplateLike for TemplateData {
    type WireDataType = WireData;

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

    fn get_init_subcmp_decls<'ctx>(
        &self,
        _codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<HashMap<String, SubcmpDeclInfo<'ctx>>> {
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

    fn gen_preamble<'ctx>(
        &self,
        _codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        _template: &TemplateContext<'_, 'ctx, '_, '_, '_, '_>,
    ) -> Result<()> {
        Ok(())
    }
}

impl WireLike for WireData {
    fn get_type(&self) -> WireType {
        self.get_type()
    }
}

impl TemplateLike for TemplateInstance {
    type WireDataType = Wire;

    fn get_location<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Location<'ctx> {
        codegen.location_unknown()
    }

    fn get_name(&self) -> &str {
        &self.template_header // this one is unique, but `template_name` is not
    }

    fn get_name_of_params(&self) -> &[String] {
        &[]
    }

    fn get_body(&self) -> &[Statement] {
        slice::from_ref(&self.code)
    }

    fn get_init_subcmp_decls<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<HashMap<String, SubcmpDeclInfo<'ctx>>> {
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

            if subcmp_decls.insert(name.clone(), subcmp_decl).is_some() {
                bail!("Subcomponent {name} declared twice");
            }
        }
        // Get the types for the declarations
        for cluster in &self.clusters {
            if let Some(subcmp_decl) = subcmp_decls.get_mut(&cluster.cmp_name) {
                match &cluster.xtype {
                    ClusterType::Mixed { .. } => {
                        for trigger in &self.triggers[cluster.slice.clone()] {
                            subcmp_decl.mixed_instances_mut().push(MixedSubcmpInstance::new(
                                mixed_record_name(&trigger.indexed_with),
                                trigger.indexed_with.clone(),
                                codegen.struct_type(&trigger.runs),
                            ));
                        }
                    }
                    ClusterType::Uniform { header, .. } => {
                        subcmp_decl.instances_mut().push(codegen.struct_type(header));
                    }
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
        let location = self.get_location(codegen);
        for w in &self.wires {
            match w {
                Wire::TSignal(signal) => declarations.visit_signal_or_bus_impl(
                    codegen,
                    &signal.xtype,
                    &signal.name,
                    location,
                    codegen
                        .type_from_dimension_consts(codegen.felt_type().into(), &signal.lengths)?,
                )?,
                Wire::TBus(bus) => declarations.visit_signal_or_bus_impl(
                    codegen,
                    &bus.xtype,
                    &bus.name,
                    location,
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

    fn gen_preamble<'ctx>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        template: &TemplateContext<'_, 'ctx, '_, '_, '_, '_>,
    ) -> Result<()> {
        fn build_nested(
            meta: &Meta,
            flat_vals: &[BigInt],
            offset: usize,
            dims: &[usize],
        ) -> Result<(Expression, usize)> {
            match dims {
                [] => {
                    if offset >= flat_vals.len() {
                        Err(anyhow!("offset {} out of bounds (len {})", offset, flat_vals.len()))
                    } else {
                        Ok((
                            Expression::Number(meta.clone(), flat_vals[offset].clone()),
                            offset + 1,
                        ))
                    }
                }
                [next, remaining @ ..] => {
                    let mut values = vec![];
                    let mut curr_offset = offset;
                    for _ in 0..*next {
                        let (expr, new_offset) =
                            build_nested(meta, flat_vals, curr_offset, remaining)?;
                        curr_offset = new_offset;
                        values.push(expr);
                    }
                    let expr = Expression::ArrayInLine { meta: meta.clone(), values };
                    Ok((expr, curr_offset))
                }
            }
        }

        // Insert Argument values (static versions of template parameters) in
        // case an assignment references these (happens when assigning an array
        // variable to equal an array Argument).
        for arg in &self.header {
            let meta = Meta::new(0, 0);
            let declaration = Statement::Declaration {
                meta: meta.clone(),
                xtype: VariableType::Var,
                name: arg.name.clone(),
                dimensions: arg
                    .lengths
                    .iter()
                    .map(|d| {
                        let bigint = BigInt::from_usize(*d)
                            .ok_or_else(|| anyhow!("could not convert usize to bigint"))?;
                        Ok(Expression::Number(meta.clone(), bigint))
                    })
                    .collect::<Result<Vec<_>>>()?,
                is_constant: true,
                is_anonymous: false,
            };
            let assignment = Statement::Substitution {
                meta: meta.clone(),
                var: arg.name.clone(),
                access: vec![],
                op: AssignVar,
                rhe: build_nested(&meta, &arg.values, 0, &arg.lengths)?.0,
            };
            declaration.gen_llzk_in_template(codegen, template)?;
            assignment.gen_llzk_in_template(codegen, template)?;
        }
        Ok(())
    }
}

/// Returns a stable pod record name for a mixed concrete subcomponent index tuple.
fn mixed_record_name(indices: &[usize]) -> String {
    let mut name = String::from("idx");
    for index in indices {
        name.push('_');
        name.push_str(&index.to_string());
    }
    name
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
