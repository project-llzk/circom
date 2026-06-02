//! Entry point for LLZK code generation.

use std::convert::TryInto as _;

use crate::module::GenerateLLZKInModule;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::LlzkCodegen;
pub use crate::shared::LlzkConfig;
use ansi_term::Color;
use anyhow::anyhow;
use anyhow::Result;
use llzk::prelude::LlzkContext;
use llzk::prelude::Module;
use llzk::prelude::OperationMutLike as _;
use llzk::prelude::StructType;
use llzk::prelude::TypeAttribute;
use llzk::prelude::MAIN_ATTR_NAME;
use melior::ir::Attribute;
use num_bigint_dig::BigUint;
use num_traits::ToPrimitive;
use program_structure::ast::Expression;

/// Converts the given big unsigned integer into parts of 64 bit long in least significant order.
fn to_u64_digits(n: &BigUint) -> Vec<u64> {
    let bytes = n.to_bytes_le();
    bytes
        .chunks(size_of::<u64>() / size_of::<u8>())
        .map(|chunk| {
            u64::from_le_bytes(chunk.try_into().unwrap_or_else(|_| {
                let mut arr = [0u8; 8];
                arr[..chunk.len()].copy_from_slice(chunk);
                arr
            }))
        })
        .collect()
}

/// Prepares the parameters of the main component StructType.
///
/// TODO: This approach does not currently handle ArrayInLine or Call expressions that can be
/// used as parameters to the main component. The Call case could be handled by finding the
/// target function and evaluating it statically. The ArrayInLine (i.e. a literal array like
/// `[9,3,1]`) however may require generating an additional wrapper struct that can construct
/// the array and pass it to the main component. Alternatively, put the array in a global const
/// and then generate the main component with one less template parameter and read the global.
fn prepare_main_component_params<'ctx>(
    params: impl IntoIterator<Item = Expression>,
    prime: &BigUint,
    context: &'ctx LlzkContext,
) -> Result<Vec<Attribute<'ctx>>> {
    params
        .into_iter()
        .enumerate()
        .map(|(i, e)| -> Result<Attribute<'ctx>> {
            let n = shared::try_compute_biguint(&e, prime).and_then(|n| {
                n.ok_or_else(|| anyhow!("main component parameter {i} is not a positive constant"))
            })?;
            Ok(match n.to_i64() {
                Some(n) => context.index_attr(n).into(),
                None => {
                    // Increase by one to ensure the value is kept unsigned.
                    let bitlen = n.bits() + 1;
                    let parts = to_u64_digits(&n);
                    context.felt_attr_from_parts(bitlen.try_into().unwrap(), &parts).into()
                }
            })
        })
        .collect()
}

/// Create a new, empty LLZK `Module` with Location "main" from the `ProgramArchive`.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
fn new_llzk_module<'ctx>(
    context: &'ctx LlzkContext,
    program: &impl ProgramLike,
    prime: &BigUint,
) -> Result<Module<'ctx>> {
    let main_info = program.get_main_component_info();
    let params = prepare_main_component_params(main_info.params, prime, context)?;

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
    let mut ctx = LlzkContext::new();
    ctx.set_field(config.prime_str.as_str());
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
