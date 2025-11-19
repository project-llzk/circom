#![allow(unused_variables)] // TODO: TEMP
use crate::{module::GenerateLLZKInModule as _, shared::LlzkCodegen};
use ansi_term::Color;
use anyhow::Result;
use llzk::prelude::LlzkContext;
use melior::ir::{Location, Module};
use program_structure::program_archive::ProgramArchive;

/// Create a new, empty LLZK `Module` with Location "main" from the `ProgramArchive`.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
fn new_llzk_module<'ctx>(
    context: &'ctx LlzkContext,
    program_archive: &ProgramArchive,
) -> Module<'ctx> {
    let files = &program_archive.file_library;
    let filename = files.get_filename_or_default(program_archive.get_file_id_main());
    let main_file_location = Location::new(context, &filename, 0, 0);
    llzk::dialect::module::llzk_module(main_file_location)
}

/// Generate LLZK IR from the given `ProgramArchive` and write it to a file with the given filename.
#[allow(clippy::result_unit_err)]
pub fn generate_llzk(
    program_archive: &ProgramArchive,
    filename: &str,
    pass_pipeline: &str,
) -> Result<(), ()> {
    let ctx = LlzkContext::new();
    let module = new_llzk_module(&ctx, program_archive);
    let mut codegen = LlzkCodegen { program_archive, context: &ctx, module };

    program_archive.gen_llzk(&codegen).map_err(|err| {
        eprintln!("{} {err}", Color::Red.paint("Failed to generate LLZK IR:"));
    })?;

    // Verify the module
    if !codegen.verify() {
        eprintln!("{}", Color::Red.paint("Generated LLZK IR is invalid"));
        eprintln!("{}", codegen.module.as_operation());
        return Err(());
    }

    // Run user-specified MLIR pass pipeline
    codegen.run_passes(pass_pipeline).map_err(|err| {
        eprintln!("{} {err}", Color::Red.paint("Failed to run pass pipeline:"));
    })?;

    // Write module to file
    codegen.write_to_file(filename).map_err(|err| {
        eprintln!("{} {err}", Color::Red.paint("Failed to write LLZK IR:"));
    })
}
