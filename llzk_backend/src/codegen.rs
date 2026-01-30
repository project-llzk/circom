//! Entry point for LLZK code generation.

use crate::module::GenerateLLZKInModule;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::LlzkCodegen;
use ansi_term::Color;
use anyhow::anyhow;
use anyhow::Result;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::LlzkContext;
use llzk::prelude::Module;
use llzk::prelude::OperationMutLike;
use llzk::prelude::StructType;
use llzk::prelude::TypeAttribute;
use llzk::prelude::MAIN_ATTR_NAME;
use melior::ir::Type;
use num_bigint_dig::BigUint;
use program_structure::constants::UsefulConstants;

/// Create a new, empty LLZK `Module` with Location "main" from the `ProgramArchive`.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
fn new_llzk_module<'ctx>(
    context: &'ctx LlzkContext,
    program: &impl ProgramLike,
    prime: &BigUint,
) -> Result<Module<'ctx>> {
    let main_info = program.get_main_component_info();

    // Compute constant parameters of the main component StructType.
    // TODO: This approach does not currently handle ArrayInLine or Call expressions that can be
    // used as parameters to the main component. The Call case could be handled by finding the
    // target function and evaluating it statically. The ArrayInLine (i.e. a literal array like
    // `[9,3,1]`) however may require generating an additional wrapper struct that can construct
    // the array and pass it to the main component. Alternatively, put the array in a global const
    // and then generate the main component with one less template parameter and read the global.
    let params = main_info
        .params
        .into_iter()
        .enumerate()
        .map(|(i, e)| {
            shared::try_compute_as_i64(&e, prime)?
                .ok_or_else(|| anyhow!("main component parameter {i} is not a positive constant"))
        })
        .collect::<Result<Vec<_>>>()?;
    let params: Vec<_> =
        params.into_iter().map(|p| IntegerAttribute::new(Type::index(context), p).into()).collect();

    // Create the LLZK module, using the location of the main component declaration expression.
    let location =
        shared::location(context, program, *program.get_main_file_id(), main_info.file_location);
    let mut ret = llzk::dialect::module::llzk_module(location);
    ret.as_operation_mut().set_attribute(
        MAIN_ATTR_NAME.as_ref(),
        TypeAttribute::new(
            StructType::new(FlatSymbolRefAttribute::new(context, &main_info.name), &params).into(),
        )
        .into(),
    );
    Ok(ret)
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
    let prime = UsefulConstants::new(&prime.to_string()).get_p().to_biguint();
    if prime.is_none() {
        eprintln!(
            "{} prime should be convertible to unsigned",
            Color::Red.paint("LLZK config error:"),
        );
        std::process::exit(10); // force exit to avoid hang if MLIR state is inconsistent
    }
    let prime = prime.unwrap();

    let ctx = LlzkContext::new();
    let module = new_llzk_module(&ctx, program, &prime).map_err(|err| {
        if verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to generate LLZK IR:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to generate LLZK IR:"));
        }
        std::process::exit(20); // force exit to avoid hang if MLIR state is inconsistent
    })?;
    let mut codegen = LlzkCodegen::new(program, &ctx, module, prime, verbose);

    program.gen_llzk(&codegen).map_err(|err| {
        if verbose {
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
    codegen.run_passes(pass_pipeline).map_err(|err| {
        if verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to run pass pipeline:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to run pass pipeline:"));
        }
        std::process::exit(70); // force exit to avoid hang if MLIR state is inconsistent
    })?;

    // Write module to file
    codegen.write_to_file(filename).map_err(|err| {
        if verbose {
            eprintln!("{} {err:?}", Color::Red.paint("Failed to write LLZK IR:"));
        } else {
            eprintln!("{} {err}", Color::Red.paint("Failed to write LLZK IR:"));
        }
        std::process::exit(90); // force exit to avoid hang if MLIR state is inconsistent
    })
}
