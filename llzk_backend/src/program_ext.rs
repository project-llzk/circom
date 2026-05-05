//! Extensions for the [`ProgramArchive`] and [`VCP`] types.

use crate::function_ext::FunctionLike;
use crate::shared::LlzkCodegen;
use crate::template_ext::SignalDeclarations;
use crate::template_ext::TemplateLike;
use compiler::compiler_interface::VCP;
use program_structure::ast::Expression;
use program_structure::file_definition::FileID;
use program_structure::file_definition::FileLibrary;
use program_structure::file_definition::FileLocation;
use program_structure::program_archive::ProgramArchive;

/// A dyn-safe trait for obtaining information about the program.
pub trait ProgramInfo {
    /// Looks for a template with the given name.
    fn find_template(&self, name: &str) -> anyhow::Result<&dyn SignalDeclarations>;
}

impl<P: ProgramLike> ProgramInfo for LlzkCodegen<'_, '_, '_, P> {
    fn find_template(&self, name: &str) -> anyhow::Result<&dyn SignalDeclarations> {
        self.program
            .get_templates(false)
            .into_iter()
            .find(|t| t.get_name() == name)
            .map(|t| -> &dyn SignalDeclarations { t })
            .ok_or_else(|| anyhow::anyhow!("template '{name}' not found"))
    }
}

/// Specification of the main component of a circom program.
#[derive(Debug)]
pub struct MainComponentInfo {
    /// Location of the main component declaration.
    pub file_location: FileLocation,
    /// Name of the main component template.
    pub name: String,
    /// Parameters of the main component template.
    pub params: Vec<Expression>,
}

/// A trait that allows common handling of the structs used to represent a circom
/// program at different stages in the compilation process.
pub trait ProgramLike: std::fmt::Debug {
    /// Get the file library of the program.
    fn get_file_library(&self) -> &FileLibrary;
    /// Get the FileID of the file containing the "main" component declaration.
    fn get_main_file_id(&self) -> &FileID;
    /// Get information specifying the main component.
    fn get_main_component_info(&self) -> MainComponentInfo;
    /// Get the names of public inputs of the main component.
    fn get_main_public_inputs(&self) -> &[String];
    /// Get an iterator over all functions in the program.
    fn get_functions(&self, sorted: bool) -> impl IntoIterator<Item = &impl FunctionLike>;
    /// Returns true if the program contains a function with the given name.
    fn contains_function(&self, name: &str) -> bool {
        self.get_functions(false).into_iter().any(|f| f.get_name() == name)
    }
    /// Returns the function with the given name.
    ///
    /// # Panics
    ///
    /// If the program does not have a function with that name.
    fn get_function_data(&self, name: &str) -> &impl FunctionLike {
        self.get_functions(false)
            .into_iter()
            .find(|f| f.get_name() == name)
            .unwrap_or_else(|| panic!("Function not found: {}", name))
    }
    /// Get an iterator over all templates in the program.
    fn get_templates(&self, sorted: bool) -> impl IntoIterator<Item = &impl TemplateLike>;
    /// Returns true if the program contains a template with the given name.
    fn contains_template(&self, name: &str) -> bool {
        self.get_templates(false).into_iter().any(|t| t.get_name() == name)
    }
    /// Returns the template with the given name.
    ///
    /// # Panics
    ///
    /// If the program does not have a template with that name.
    fn get_template_data<'a>(&'a self, name: &str) -> &'a (impl TemplateLike + use<'a, Self>) {
        self.get_templates(false)
            .into_iter()
            .find(|t| t.get_name() == name)
            .unwrap_or_else(|| panic!("Template not found: {}", name))
    }
}

impl ProgramLike for ProgramArchive {
    fn get_file_library(&self) -> &FileLibrary {
        &self.file_library
    }
    fn get_main_file_id(&self) -> &FileID {
        self.get_file_id_main()
    }
    fn get_main_component_info(&self) -> MainComponentInfo {
        match self.get_main_expression() {
            c @ Expression::Call { id, args, .. } => MainComponentInfo {
                file_location: c.get_meta().location.clone(),
                name: id.clone(),
                params: args.clone(),
            },
            _ => unreachable!("Main component expression must be `Call`"),
        }
    }
    fn get_main_public_inputs(&self) -> &[String] {
        self.get_public_inputs_main_component()
    }
    fn get_functions(&self, sorted: bool) -> impl IntoIterator<Item = &impl FunctionLike> {
        let mut functions: Vec<_> = self.functions.values().collect();
        if sorted {
            sort_functions_by_name(&mut functions);
        }
        functions
    }
    fn contains_function(&self, name: &str) -> bool {
        self.contains_function(name)
    }
    fn get_function_data(&self, name: &str) -> &impl FunctionLike {
        self.get_function_data(name)
    }
    fn get_templates(&self, sorted: bool) -> impl IntoIterator<Item = &impl TemplateLike> {
        let mut templates: Vec<_> = self.templates.values().collect();
        if sorted {
            sort_templates_by_name(&mut templates);
        }
        templates
    }
    fn contains_template(&self, name: &str) -> bool {
        self.contains_template(name)
    }
    fn get_template_data<'a>(&'a self, name: &str) -> &'a (impl TemplateLike + use<'a>) {
        self.get_template_data(name)
    }
}

/// Caches info from the [ProgramArchive] that is not present in the [VCP].
#[derive(Debug)]
pub struct CachedParseInfo {
    /// Names of public inputs of the "main" component.
    pub public_inputs: Vec<String>,
    /// ID of the file containing the "main" component declaration.
    pub main_file_id: FileID,
    /// Location of the "main" component declaration expression.
    pub main_expr_location: FileLocation,
}

impl From<&ProgramArchive> for CachedParseInfo {
    fn from(program: &ProgramArchive) -> Self {
        Self {
            public_inputs: program.get_public_inputs_main_component().clone(),
            main_file_id: *program.get_file_id_main(),
            main_expr_location: program.get_main_expression().get_meta().file_location(),
        }
    }
}

/// A wrapper around a VCP that also includes the public inputs for the main component.
#[derive(Debug)]
pub struct VCPPlus<'vcp> {
    /// Reference to the [VCP].
    pub vcp: &'vcp VCP,
    /// Additional information cached from the [ProgramArchive] before it was consumed.
    pub parse_info: CachedParseInfo,
}

impl ProgramLike for VCPPlus<'_> {
    fn get_file_library(&self) -> &FileLibrary {
        &self.vcp.file_library
    }
    fn get_main_file_id(&self) -> &FileID {
        &self.parse_info.main_file_id
    }
    fn get_main_component_info(&self) -> MainComponentInfo {
        MainComponentInfo {
            file_location: self.parse_info.main_expr_location.clone(),
            name: self.vcp.templates[self.vcp.main_id].template_header.clone(),
            params: vec![],
        }
    }
    fn get_main_public_inputs(&self) -> &[String] {
        &self.parse_info.public_inputs
    }
    fn get_functions(&self, sorted: bool) -> impl IntoIterator<Item = &impl FunctionLike> {
        let mut functions: Vec<_> = self.vcp.functions.iter().collect();
        if sorted {
            sort_functions_by_name(&mut functions);
        }
        functions
    }
    fn get_templates(&self, sorted: bool) -> impl IntoIterator<Item = &impl TemplateLike> {
        let mut templates: Vec<_> = self.vcp.templates.iter().collect();
        if sorted {
            sort_templates_by_name(&mut templates);
        }
        templates
    }
}

/// Helper function to sort a vector of &FunctionLike by name.
#[inline]
fn sort_functions_by_name<F: FunctionLike>(functions: &mut [&F]) {
    functions.sort_by(|a, b| a.get_name().cmp(b.get_name()));
}

/// Helper function to sort a vector of &TemplateLike by name.
#[inline]
fn sort_templates_by_name<T: TemplateLike>(templates: &mut [&T]) {
    templates.sort_by(|a, b| a.get_name().cmp(b.get_name()));
}
