mod compilation_user;
mod execution_user;
mod input_user;
mod parser_user;
mod type_analysis_user;

const VERSION: &'static str = env!("CARGO_PKG_VERSION");


use ansi_term::Colour;
use input_user::Input;
fn main() {
    let result = start();
    if result.is_err() {
        eprintln!("{}", Colour::Red.paint("previous errors were found"));
        std::process::exit(1);
    } else {
        println!("{}", Colour::Green.paint("Everything went okay"));
        //std::process::exit(0);
    }
}

fn start() -> Result<(), ()> {
    use compilation_user::CompilerConfig;
    use execution_user::ExecutionConfig;
    let user_input = Input::new()?;
    let mut program_archive = parser_user::parse_project(&user_input)?;
    type_analysis_user::analyse_project(&mut program_archive)?;

    // Dump the ProgramArchive if requested
    if user_input.dump_parse_flag() {
        write_to_file(format!("{:#?}", program_archive), user_input.dump_parse_file())?;
    }
    // If requested, generate LLZK IR output with generic templates
    let llzk_gen_opt = user_input.llzk_flag().as_deref();
    if Some(crate::input_user::LLZK_KIND_TEMPLATED) == llzk_gen_opt {
        return llzk_backend::generate_llzk(
            &program_archive,
            user_input.llzk_file(),
            &user_input.llzk_pass_pipeline(),
            &user_input.prime(),
            user_input.flag_verbose(),
        );
    }

    let config = ExecutionConfig {
        no_rounds: user_input.no_rounds(),
        flag_p: user_input.parallel_simplification_flag(),
        flag_s: user_input.reduced_simplification_flag(),
        flag_f: user_input.unsimplified_flag(),
        flag_old_heuristics: user_input.flag_old_heuristics(),
        flag_verbose: user_input.flag_verbose(),
        inspect_constraints_flag: user_input.inspect_constraints_flag(),
        r1cs_flag: user_input.r1cs_flag(),
        json_constraint_flag: user_input.json_constraints_flag(),
        json_substitution_flag: user_input.json_substitutions_flag(),
        sym_flag: user_input.sym_flag(),
        sym: user_input.sym_file().to_string(),
        r1cs: user_input.r1cs_file().to_string(),
        json_constraints: user_input.json_constraints_file().to_string(),
        json_substitutions: user_input.json_substitutions_file().to_string(),
        prime: user_input.prime(),        
    };
    let public_inputs =
        if llzk_gen_opt.is_some_and(|kind| kind == crate::input_user::LLZK_KIND_CONCRETE) {
            Some(program_archive.get_public_inputs_main_component().clone())
        } else {
            None
        };

    let circuit = execution_user::execute_project(program_archive, config)?;

    // Dump the VCP if requested
    if user_input.dump_vcp_flag() {
        println!("Dumping VCP to: {}", user_input.dump_vcp_file());
        println!("{}", Colour::Yellow.paint("Dumping VCP may take a while for large circuits."));
        write_to_file(format!("{:#?}", circuit), user_input.dump_vcp_file())?;
    }

    // If requested, generate LLZK IR output after templates have been made concrete
    if let Some(public_inputs) = public_inputs {
        let vcp_plus = llzk_backend::VCPPlus { vcp: &circuit, public_inputs };
        return llzk_backend::generate_llzk(
            &vcp_plus,
            user_input.llzk_file(),
            &user_input.llzk_pass_pipeline(),
            &user_input.prime(),
            user_input.flag_verbose(),
        );
    }

    let compilation_config = CompilerConfig {
        vcp: circuit,
        debug_output: user_input.print_ir_flag(),
        c_flag: user_input.c_flag(),
        wasm_flag: user_input.wasm_flag(),
        wat_flag: user_input.wat_flag(),
	    js_folder: user_input.js_folder().to_string(),
	    wasm_name: user_input.wasm_name().to_string(),
	    c_folder: user_input.c_folder().to_string(),
	    c_run_name: user_input.c_run_name().to_string(),
        c_file: user_input.c_file().to_string(),
        dat_file: user_input.dat_file().to_string(),
        wat_file: user_input.wat_file().to_string(),
        wasm_file: user_input.wasm_file().to_string(),
        produce_input_log: user_input.main_inputs_flag(),

        no_asm_flag: user_input.no_asm_flag(),
        constraint_assert_disabled_flag: user_input.constraint_assert_disabled_flag(),
        prime: user_input.prime(),        
    };
    compilation_user::compile(compilation_config)?;
    Result::Ok(())
}

fn write_to_file<C: AsRef<[u8]>>(contents: C, filename: &str) -> Result<(), ()> {
    let out_path = std::path::Path::new(filename);
    // Ensure parent directories exist
    if let Some(parent) = out_path.parent() {
        std::fs::create_dir_all(parent).map_err(|_err| {})?;
    }
    std::fs::write(out_path, contents).map_err(|_err| {})?;
    println!("{} {}", Colour::Green.paint("Written successfully:"), filename);
    Result::Ok(())
}
