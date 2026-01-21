//! Entry point for LLZK code generation.

use crate::module::GenerateLLZKInModule;
use crate::program_ext::ProgramLike;
use crate::shared::LlzkCodegen;
use ansi_term::Color;
use anyhow::Result;
use llzk::prelude::LlzkContext;
use llzk::prelude::Location;
use llzk::prelude::Module;

/// Create a new, empty LLZK `Module` with Location "main" from the `ProgramArchive`.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
fn new_llzk_module<'ctx>(context: &'ctx LlzkContext, program: &impl ProgramLike) -> Module<'ctx> {
    let files = program.get_file_library();
    let filename = files.get_filename_or_default(program.get_main_file_id());
    let main_file_location = Location::new(context, &filename, 0, 0);
    llzk::dialect::module::llzk_module(main_file_location)
}

/// Generate LLZK IR from the given `ProgramArchive` and write it to a file with the given filename.
#[allow(clippy::result_unit_err)]
pub fn generate_llzk(
    program: &impl ProgramLike,
    filename: &str,
    pass_pipeline: &str,
    prime: &str,
    verbose: bool,
) -> Result<(), ()> {
    let ctx = LlzkContext::new();
    let module = new_llzk_module(&ctx, program);
    let mut codegen = LlzkCodegen { program, context: &ctx, module, prime_str: prime, verbose };

    program.gen_llzk(&codegen).map_err(|err| {
        if verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to generate LLZK IR:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to generate LLZK IR:"));
        }
        std::process::exit(1); // force exit to avoid hang if MLIR state is inconsistent
    })?;

    // Verify the module
    if let Err(err) = codegen.verify() {
        eprintln!("{}", Color::Red.paint("Generated LLZK IR is invalid"));
        if verbose {
            eprintln!("{err:?}");
        } else {
            eprintln!("{err}");
        }
        eprintln!("{}", codegen.module.as_operation());
        std::process::exit(2); // force exit to avoid hang if MLIR state is inconsistent
    }

    // Run user-specified MLIR pass pipeline
    codegen.run_passes(pass_pipeline).map_err(|err| {
        if verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to run pass pipeline:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to run pass pipeline:"));
        }
        std::process::exit(3); // force exit to avoid hang if MLIR state is inconsistent
    })?;

    // Write module to file
    codegen.write_to_file(filename).map_err(|err| {
        if verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to write LLZK IR:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to write LLZK IR:"));
        }
        std::process::exit(4); // force exit to avoid hang if MLIR state is inconsistent
    })
}
