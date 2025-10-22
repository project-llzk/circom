#![allow(dead_code)]

use std::path::Path;
use assert_cmd::Command;
use assert_fs::{NamedTempFile, prelude::FileWriteStr};
use lazy_static::lazy_static;
use regex::Regex;

const TEST_INPUT: &'static str = "%s";
const TMP_FILE: &'static str = "%t";
const CIRCOM: &'static str = "%circom";

type LitResult<T> = Result<T, Box<dyn std::error::Error>>;

fn marked_xfail(content: &str) -> bool {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"^//\s*XFAIL:.*$").unwrap();
    }
    for line in content.lines() {
        if RE.is_match(line) {
            return true;
        }
    }
    return false;
}

fn extract_runs(content: &str) -> Vec<&str> {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"^//\s*RUN:(.*)$").unwrap();
    }
    let mut runs = Vec::new();
    for line in content.lines() {
        if let Some(captures) = RE.captures(line) {
            if let Some(group) = captures.get(1) {
                runs.push(group.as_str());
            }
        }
    }
    if runs.is_empty() {
        panic!("Unsupported test encountered. RUN declaration missing!")
    }
    runs
}

fn write_test(content: &str, name: &str) -> LitResult<NamedTempFile> {
    let file = NamedTempFile::new(format!("{}.circom", name).as_str())?;
    file.write_str(content)?;
    Ok(file)
}

struct LitTest<'a> {
    expected_failure: bool,
    run_commands: Vec<&'a str>,
    test_input: NamedTempFile,
    name: &'a str,
}

impl<'a> LitTest<'a> {
    pub fn create(content: &'a str, name: &'a str) -> LitResult<Self> {
        Ok(LitTest {
            expected_failure: marked_xfail(content),
            run_commands: extract_runs(content),
            test_input: write_test(content, name)?,
            name,
        })
    }

    fn execute_expecting_success(&self, cmd: &mut Command) -> LitResult<()> {
        cmd.assert().success();
        Ok(())
    }

    fn execute_expecting_failure(&self, cmd: &mut Command) -> LitResult<()> {
        cmd.assert().failure();
        Ok(())
    }

    fn prepare_command(&self, run_command: &str, tmp_file: &Path) -> String {
        run_command
            .replace(
                TEST_INPUT,
                format!("\"{}\"", self.test_input.path().to_str().unwrap()).as_str(),
            )
            .replace(TMP_FILE, format!("\"{}\"", tmp_file.to_str().unwrap()).as_str())
            .replace(CIRCOM, env!("CARGO_BIN_EXE_circom"))
    }

    pub fn execute(&self) -> LitResult<()> {
        // Create a single temp file/directory to be shared across all RUN commands
        // that is deleted when it goes out of scope at the end of this function.
        let tmp_file = NamedTempFile::new(self.name)?;

        // Execute all RUN commands in sequence
        for run_command in &self.run_commands {
            let cmd = self.prepare_command(run_command, tmp_file.path());
            let mut sh = Command::new("sh");
            sh.arg("-c").arg(cmd);
            if self.expected_failure {
                self.execute_expecting_failure(&mut sh)?;
            } else {
                self.execute_expecting_success(&mut sh)?;
            }
        }
        Ok(())
    }
}

/// Emulates a lit test
#[inline]
fn lit_test(content: &str, name: &str) -> LitResult<()> {
    LitTest::create(content, name)?.execute()
}

// build.rs generates this file with the discovered circom tests in this crate
include!(concat!(env!("OUT_DIR"), "/discovered_tests.in"));
