//! Extensions for the [`ProgramArchive`] and [`VCP`] types.

use crate::function_ext::FunctionLike;
use crate::template_ext::TemplateLike;
use compiler::compiler_interface::VCP;
use program_structure::file_definition::FileID;
use program_structure::file_definition::FileLibrary;
use program_structure::program_archive::ProgramArchive;

/// A trait that allows common handling of the structs used to represent a circom
/// program at different stages in the compilation process.
pub trait ProgramLike {
    /// Get the file library of the program.
    fn get_file_library(&self) -> &FileLibrary;
    /// Get the FileID of the file containing the "main" declaration.
    fn get_main_file_id(&self) -> &FileID;
    /// Get the names of public inputs of the main component.
    fn get_main_public_inputs(&self) -> &Vec<String>;
    /// Get an iterator over all functions in the program.
    fn get_functions(&self, sorted: bool) -> impl IntoIterator<Item = &impl FunctionLike>;
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
    fn get_template_data(&self, name: &str) -> &impl TemplateLike {
        self.get_templates(false).into_iter().find(|t| t.get_name() == name).unwrap()
    }
}

impl ProgramLike for ProgramArchive {
    fn get_file_library(&self) -> &FileLibrary {
        &self.file_library
    }
    fn get_main_file_id(&self) -> &FileID {
        self.get_file_id_main()
    }
    fn get_main_public_inputs(&self) -> &Vec<String> {
        self.get_public_inputs_main_component()
    }
    fn get_functions(&self, sorted: bool) -> impl IntoIterator<Item = &impl FunctionLike> {
        let mut functions: Vec<_> = self.functions.values().collect();
        if sorted {
            sort_functions_by_name(&mut functions);
        }
        functions
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
    fn get_template_data(&self, name: &str) -> &impl TemplateLike {
        self.get_template_data(name)
    }
}

/// A wrapper around a VCP that also includes the public inputs for the main component.
#[derive(Debug)]
pub struct VCPPlus<'ctx> {
    /// Reference to the [VCP].
    pub vcp: &'ctx VCP,
    /// Names of public inputs of the main component.
    pub public_inputs: Vec<String>,
}

impl ProgramLike for VCPPlus<'_> {
    fn get_file_library(&self) -> &FileLibrary {
        &self.vcp.file_library
    }
    fn get_main_file_id(&self) -> &FileID {
        &self.vcp.main_id
    }
    fn get_main_public_inputs(&self) -> &Vec<String> {
        &self.public_inputs
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
fn sort_functions_by_name<T: FunctionLike>(functions: &mut [&T]) {
    functions.sort_by(|a, b| a.get_name().cmp(b.get_name()));
}

/// Helper function to sort a vector of &TemplateLike by name.
#[inline]
fn sort_templates_by_name<T: TemplateLike>(templates: &mut [&T]) {
    templates.sort_by(|a, b| a.get_name().cmp(b.get_name()));
}
