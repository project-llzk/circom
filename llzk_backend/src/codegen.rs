//! Entry point for LLZK code generation.

use crate::affine_map::AffineMapAttribute;
use crate::module::GenerateLLZKInModule;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::LlzkCodegen;
pub use crate::shared::LlzkConfig;
use ansi_term::Color;
use anyhow::Result;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::LlzkContext;
use llzk::prelude::Module;
use llzk::prelude::OperationMutLike as _;
use llzk::prelude::StructType;
use llzk::prelude::Type;
use llzk::prelude::TypeAttribute;
use llzk::prelude::MAIN_ATTR_NAME;
use num_bigint_dig::BigUint;

/// Create a new, empty LLZK `Module` with Location "main" from the `ProgramArchive`.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
fn new_llzk_module<'ctx>(
    context: &'ctx LlzkContext,
    program: &impl ProgramLike,
    prime: &BigUint,
) -> Result<Module<'ctx>> {
    let main_info = program.get_main_component_info();

    // Compute parameters of the main component StructType.
    //
    // For values that are statically known as i64, materialize an index integer attribute.
    // For non-scalar or non-reducible expressions (e.g. ArrayInLine or Call), keep the main
    // instance generic in that slot using an identity affine map placeholder.
    let params = main_info
        .params
        .into_iter()
        .map(|e| {
            Ok(shared::try_compute_as_i64(&e, prime)?
                .map(|p| IntegerAttribute::new(Type::index(context), p).into())
                .unwrap_or_else(|| AffineMapAttribute::identity(context, 1).into()))
        })
        .collect::<Result<Vec<_>>>()?;

    // Create the LLZK module, using the location of the main component declaration expression.
    let location =
        shared::location(context, program, *program.get_main_file_id(), main_info.file_location);
    let mut ret = llzk::dialect::module::llzk_module(location);
    ret.as_operation_mut().set_attribute(
        MAIN_ATTR_NAME.as_ref(),
        TypeAttribute::new(
            StructType::new(shared::double_ref_sym(context, main_info.name), &params).into(),
        )
        .into(),
    );
    Ok(ret)
}

/// Generate LLZK IR from the given `ProgramArchive` and write it to a file with the given filename.
#[allow(clippy::result_unit_err)]
pub fn generate_llzk(program: &impl ProgramLike, config: LlzkConfig) -> Result<(), ()> {
    let ctx = LlzkContext::new();
    let module = new_llzk_module(&ctx, program, &config.prime).map_err(|err| {
        if config.verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to generate LLZK IR:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to generate LLZK IR:"));
        }
        std::process::exit(20); // force exit to avoid hang if MLIR state is inconsistent
    })?;
    let mut codegen = LlzkCodegen::new(program, &ctx, module, config);

    program.gen_llzk(&codegen).map_err(|err| {
        if codegen.config.verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to generate LLZK IR:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to generate LLZK IR:"));
        }
        std::process::exit(30); // force exit to avoid hang if MLIR state is inconsistent
    })?;

    // Verify the module
    if let Err(err) = codegen.verify() {
        eprintln!("{}", Color::Red.paint("Generated LLZK IR is invalid"));
        eprintln!("{err}");
        eprintln!("{}", codegen.module.as_operation());
        std::process::exit(50); // force exit to avoid hang if MLIR state is inconsistent
    }

    // Run user-specified MLIR pass pipeline
    codegen.run_user_pass_pipeline().map_err(|err| {
        if codegen.config.verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to run pass pipeline:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to run pass pipeline:"));
        }
        std::process::exit(70); // force exit to avoid hang if MLIR state is inconsistent
    })?;

    // Write module to file
    let verbose = codegen.config.verbose;
    let write_result = if codegen.config.emit_plaintext {
        codegen.write_assembly_to_file()
    } else {
        codegen.write_bytecode_to_file()
    };
    write_result.map_err(|err| {
        if verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to write LLZK IR:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to write LLZK IR:"));
        }
        std::process::exit(90); // force exit to avoid hang if MLIR state is inconsistent
    })
}
