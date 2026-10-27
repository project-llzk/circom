//! Regression coverage for array assignments using `<--`, `-->`, `<==`, and `==>`.
//!
//! These integration tests invoke the built Circom compiler on temporary circuits.
//! They distinguish invalid source-level shape mismatches from valid assignments
//! whose function return types have been widened internally by LLZK generation.
//!
//! Coverage consists of 124 compiler invocations across three test groups:
//! - 96 rejection cases: four operators, root signals or component inputs, four
//!   shape pairs, and normal Circom, concrete LLZK, or templated LLZK compilation.
//! - 20 symbolic-dimension cases: four successful templated compilations with
//!   equal dimensions, plus 16 normal/concrete rejections with unequal dimensions.
//! - Eight successful concrete compilations: four operators and two return shapes
//!   (vector and matrix), each assigning to both a root signal and a component input.
//!
//! Normal Circom and `--llzk concrete` run circuit execution, which rejects
//! mismatched dimensions. Concrete LLZK generation follows that check. Default
//! `--llzk` uses the templated pipeline, which skips circuit execution and must
//! retain LLZK type checks.
//!
//! Assertions check compilation status, diagnostics, and selected IR structure.
//! They do not execute generated witnesses or evaluate the generated constraints.
//!
//! Run with:
//! `nix develop --command bash -c 'cargo test -p circom --test signal_array_assignments'`

use std::{
    fs,
    process::{Command, Output},
};

use assert_fs::TempDir;

const OPERATORS: [&str; 4] = ["<--", "-->", "<==", "==>"];

/// Keep the logical source and destination fixed when reversing the arrow syntax.
fn assignment(destination: &str, source: &str, operator: &str) -> String {
    if operator.starts_with('<') {
        format!("{destination} {operator} {source};")
    } else {
        format!("{source} {operator} {destination};")
    }
}

/// Compile an isolated circuit and return its process output and any successful LLZK IR.
/// Empty flags select normal Circom; `--llzk` alone selects templated generation.
fn compile(source: &str, flags: &[&str]) -> (Output, String) {
    let directory = TempDir::new().unwrap();
    let input = directory.path().join("assignment.circom");
    fs::write(&input, source).unwrap();
    let output = Command::new(env!("CARGO_BIN_EXE_circom"))
        .args(flags)
        .args(["--llzk_plaintext", "--llzk_strip_debug_info"])
        .arg("-o")
        .arg(directory.path())
        .arg(input)
        .output()
        .unwrap();
    let ir = if output.status.success() && flags.contains(&"--llzk") {
        fs::read_to_string(directory.path().join("assignment_llzk/assignment.llzk")).unwrap()
    } else {
        String::new()
    };
    (output, ir)
}

fn assert_success(source: &str, flags: &[&str]) -> String {
    let (output, ir) = compile(source, flags);
    assert!(output.status.success(), "{source}\n{flags:?}\n{}",
        String::from_utf8_lossy(&output.stderr));
    ir
}

/// Reject real shape mismatches for both root outputs and child component inputs.
/// Vectors test smaller/larger sources in both directions; matrices test differing
/// dimensions despite equal element counts. Normal/concrete compilation must report
/// `mismatched dimensions`, while templated compilation must reject the static cast.
#[test]
fn signal_assignments_reject_different_array_sizes() {
    // Include crossed dimensions with equal element counts: shape, not just size, matters.
    for (source_shape, destination_shape) in [
        ("[3]", "[5]"), ("[5]", "[3]"),
        ("[2][3]", "[3][2]"), ("[3][2]", "[2][3]"),
    ] {
        for operator in OPERATORS {
            for component_input in [false, true] {
                let destination = if component_input { "child.in" } else { "out" };
                let declarations = if component_input {
                    "component child = Sink();".to_owned()
                } else {
                    format!("signal output out{destination_shape};")
                };
                let source = format!(r#"
                    pragma circom 2.1.0;
                    template Sink() {{ signal input in{destination_shape}; }}
                    template Main() {{
                        signal input in{source_shape};
                        {declarations}
                        {}
                    }}
                    component main = Main();
                "#, assignment(destination, "in", operator));
                for flags in [&[][..], &["--llzk", "concrete"][..], &["--llzk"][..]] {
                    let (output, _) = compile(&source, flags);
                    let stderr = String::from_utf8_lossy(&output.stderr);
                    assert!(!output.status.success(), "accepted mismatch: {flags:?}\n{source}");
                    let expected = if flags == ["--llzk"] {
                        "Unsupported cast"
                    } else {
                        "mismatched dimensions"
                    };
                    assert!(stderr.contains(expected), "{flags:?}\n{source}\n{stderr}");
                }
            }
        }
    }
}

/// Preserve dimension unification when signal lengths are template parameters.
/// `Ex(3, 3)` must emit a unifiable cast without overlap-copy loops or array writes.
/// `Ex(3, 5)` and `Ex(5, 3)` must fail in normal and concrete compilation for every
/// operator. Those invalid parameterizations are not tested in templated mode,
/// where the dimensions remain symbolic and this test checks the emitted IR instead.
#[test]
fn symbolic_signal_assignments_keep_dimension_unification() {
    for operator in OPERATORS {
        let source = format!(r#"
            pragma circom 2.1.0;
            template Ex(n, m) {{
                signal input in[n];
                signal output out[m];
                {}
            }}
            component main = Ex(3, 3);
        "#, assignment("out", "in", operator));
        let ir = assert_success(&source, &["--llzk"]);
        assert!(ir.contains("poly.unifiable_cast"), "{ir}");
        assert!(!ir.contains("scf.for") && !ir.contains("array.write"),
            "signal assignment must unify dimensions, not copy an overlap:\n{ir}");
        for parameters in ["3, 5", "5, 3"] {
            let invalid = source.replace("Ex(3, 3)", &format!("Ex({parameters})"));
            for flags in [&[][..], &["--llzk", "concrete"][..]] {
                let (output, _) = compile(&invalid, flags);
                assert!(!output.status.success(), "accepted mismatch:\n{invalid}");
                assert!(String::from_utf8_lossy(&output.stderr).contains("mismatched dimensions"));
            }
        }
    }
}

/// Accept valid assignments whose actual function result matches the signal shape.
/// The unselected branch forces LLZK to widen the return type from `[2]` to `[4]`,
/// or from `[1][2]` to `[2][3]`. Concrete generation must still compile the selected
/// smaller result for all four operators, at both root and component destinations.
#[test]
fn concrete_signal_assignments_accept_widened_function_returns() {
    for operator in OPERATORS {
        for (shape, small, large) in [
            ("[2]", "[1, 2]", "[1, 2, 3, 4]"),
            ("[1][2]", "[[1, 2]]", "[[1, 2, 3], [4, 5, 6]]"),
        ] {
            let source = format!(r#"
                pragma circom 2.1.0;
                function vector(n) {{
                    if (n == 2) {{ return {small}; }}
                    else {{ return {large}; }}
                }}
                template Sink() {{ signal input in{shape}; }}
                template Main() {{
                    signal output out{shape};
                    component child = Sink();
                    {}
                    {}
                }}
                component main = Main();
            "#, assignment("out", "vector(2)", operator),
                assignment("child.in", "vector(2)", operator));
            assert_success(&source, &["--llzk", "concrete"]);
        }
    }
}
