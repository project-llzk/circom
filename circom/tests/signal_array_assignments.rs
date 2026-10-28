//! Regression coverage for array assignments using `<--`, `-->`, `<==`, and `==>`.
//!
//! These integration tests invoke the built Circom compiler on temporary circuits.
//! They distinguish invalid source-level shape mismatches from valid assignments
//! whose function return types have been widened internally by LLZK generation.
//!
//! Coverage includes:
//! - Rejection of mismatched array shapes across all operators, for root signals and
//!   component inputs, in normal Circom, concrete LLZK, and templated LLZK compilation.
//! - Symbolic dimensions: successful templated compilations with equal dimensions,
//!   plus normal/concrete rejections with unequal dimensions.
//! - Successful concrete compilations of widened vector and matrix function returns,
//!   using all operators for both root signals and component inputs.
//! - Indexed assignments of widened vector/matrix returns to root signals and component
//!   inputs, including dynamic dispatch to mixed components with different input shapes.
//! - Rejection of real indexed shape mismatches and preservation of symbolic dimensions.
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
/// dimensions despite equal element counts.
#[test]
fn signal_assignments_reject_different_array_sizes() {
    // Include crossed dimensions with equal element counts: shape, not just size, matters.
    for (source_shape, destination_shape, lengths) in [
        ("[3]", "[5]", "Expected length: 5, given 3"),
        ("[5]", "[3]", "Expected length: 3, given 5"),
        ("[2][3]", "[3][2]", "Expected length: 3, given 2"),
        ("[3][2]", "[2][3]", "Expected length: 2, given 3"),
        ("[2][3]", "[2][5]", "Expected length: 5, given 3"),
        ("[2][5]", "[2][3]", "Expected length: 3, given 5"),
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
                    assert!(!output.status.success(), "accepted mismatch: {:?}\n{}", flags, source);
                    assert!(stderr.contains("Typing error found: mismatched dimensions.")
                        && stderr.contains(lengths), "{:?}\n{}\n{}", flags, source, stderr);
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
        assert!(ir.contains("poly.unifiable_cast"), "{}", ir);
        assert!(!ir.contains("scf.for") && !ir.contains("array.write"),
            "signal assignment must unify dimensions, not copy an overlap:\n{}", ir);
        for parameters in ["3, 5", "5, 3"] {
            let invalid = source.replace("Ex(3, 3)", &format!("Ex({parameters})"));
            for flags in [&[][..], &["--llzk", "concrete"][..]] {
                let (output, _) = compile(&invalid, flags);
                assert!(!output.status.success(), "accepted mismatch:\n{}", invalid);
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

/// Narrow to the remaining destination dimensions before inserting a padded return value.
/// Cover one/two consumed indices and vector/matrix subarrays for every signal operator.
#[test]
fn concrete_indexed_signal_assignments_accept_widened_function_returns() {
    for operator in OPERATORS {
        for (shape, small, large) in [
            ("[2]", "[1, 2]", "[1, 2, 3, 4]"),
            ("[1][2]", "[[1, 2]]", "[[1, 2, 3], [4, 5, 6]]"),
        ] {
            for (prefix, indices) in [("[1]", "[0]"), ("[1][1]", "[0][0]")] {
                let source = format!(r#"
                    pragma circom 2.1.0;
                    function vector(n) {{
                        if (n == 2) {{ return {small}; }}
                        else {{ return {large}; }}
                    }}
                    template Sink() {{ signal input in{prefix}{shape}; }}
                    template Main() {{
                        signal output out{prefix}{shape};
                        component child = Sink();
                        {}
                        {}
                    }}
                    component main = Main();
                "#, assignment(&format!("out{indices}"), "vector(2)", operator),
                    assignment(&format!("child.in{indices}"), "vector(2)", operator));
                assert_success(&source, &[]);
                assert_success(&source, &["--llzk", "concrete"]);
            }
        }
    }
}

/// A dynamic component index must narrow inside each branch to that component's row type.
#[test]
fn concrete_mixed_indexed_inputs_accept_widened_function_returns() {
    for operator in OPERATORS {
        let source = format!(r#"
            pragma circom 2.1.0;
            function vector(n) {{
                if (n == 2) {{ return [1, 2]; }}
                else if (n == 4) {{ return [1, 2, 3, 4]; }}
                else {{ return [1, 2, 3, 4, 5, 6]; }}
            }}
            template Sink(n) {{ signal input in[1][n]; }}
            template Main() {{
                component children[2];
                children[0] = Sink(2);
                children[1] = Sink(4);
                for (var i = 0; i < 2; i++) {{
                    {}
                }}
            }}
            component main = Main();
        "#, assignment("children[i].in[0]", "vector(2 * (i + 1))", operator));
        assert_success(&source, &[]);
        assert_success(&source, &["--llzk", "concrete"]);
    }
}

/// Indexed narrowing must not accept genuine shape mismatches or copy symbolic bounds.
#[test]
fn indexed_signal_assignments_preserve_dimension_checks() {
    for operator in OPERATORS {
        for component_input in [false, true] {
            let declarations = if component_input {
                "component child = Sink(m);"
            } else {
                "signal output out[1][m];"
            };
            let destination = if component_input { "child.in[0]" } else { "out[0]" };
            let source = format!(r#"
                pragma circom 2.1.0;
                template Sink(m) {{ signal input in[1][m]; }}
                template Main(n, m) {{
                    signal input in[n];
                    {declarations}
                    {}
                }}
                component main = Main(2, 2);
            "#, assignment(destination, "in", operator));
            let ir = assert_success(&source, &["--llzk"]);
            assert!(ir.contains("array.insert"), "{}", ir);
            assert!(!ir.contains("scf.for"), "symbolic assignment must not copy elements:\n{}", ir);
            for parameters in ["2, 4", "4, 2"] {
                let invalid = source.replace("Main(2, 2)", &format!("Main({parameters})"));
                for flags in [&[][..], &["--llzk", "concrete"][..]] {
                    let (output, _) = compile(&invalid, flags);
                    assert!(!output.status.success(), "accepted mismatch: {:?}\n{}", flags, invalid);
                    assert!(String::from_utf8_lossy(&output.stderr).contains("mismatched dimensions"));
                }
                // Literal dimensions must also be rejected by the templated pipeline.
                let (n, m) = if parameters == "2, 4" { ("2", "4") } else { ("4", "2") };
                let invalid = invalid.replace("in[n]", &format!("in[{n}]"))
                    .replace("[m]", &format!("[{m}]"));
                let (output, _) = compile(&invalid, &["--llzk"]);
                assert!(!output.status.success(), "accepted mismatch:\n{}", invalid);
                assert!(String::from_utf8_lossy(&output.stderr).contains("cannot unify array dimensions"));
            }
        }
    }
}
