#![allow(dead_code)]

use std::fs::{self, File};
use std::path::{Path, PathBuf};
use assert_cmd::Command;
use assert_fs::{NamedTempFile, prelude::FileWriteStr};
use lazy_static::lazy_static;
use regex::Regex;
use rand::{distr::Alphanumeric, Rng};

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

fn extract_runs(content: &str) -> Vec<String> {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"^//\s*RUN:(.*)$").unwrap();
    }
    let mut runs = Vec::new();
    for line in content.lines() {
        if let Some(captures) = RE.captures(line) {
            if let Some(group) = captures.get(1) {
                runs.push(group.as_str().to_string());
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
    run_commands: Vec<String>,
    test_input: NamedTempFile,
    name: &'a str,
}

impl<'a> LitTest<'a> {
    pub fn create(content: &str, name: &'a str) -> LitResult<Self> {
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

    fn create_tmp_file(&self) -> LitResult<PathBuf> {
        let temp = Path::new(env!("CARGO_TARGET_TMPDIR"));
        let postfix: String =
            rand::rng().sample_iter(&Alphanumeric).take(10).map(char::from).collect();
        let tmp_file = temp.join(Path::new(format!("{}.{}", self.name, postfix).as_str()));
        File::create(tmp_file.clone())?;
        Ok(tmp_file)
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

    fn cleanup_test(&self, tmp_file: &Path) -> LitResult<()> {
        if tmp_file.exists() {
            if tmp_file.is_file() {
                fs::remove_file(tmp_file)?;
            } else if tmp_file.is_dir() {
                fs::remove_dir_all(tmp_file)?;
            }
        }
        Ok(())
    }

    pub fn execute(&self) -> LitResult<()> {
        // Create a single temp file to be shared across all RUN commands
        let tmp_file = self.create_tmp_file()?;

        // Execute all RUN commands in sequence
        for run_command in &self.run_commands {
            let cmd = self.prepare_command(run_command, &tmp_file);
            let mut sh = Command::new("sh");
            sh.arg("-c").arg(cmd);
            let result = if self.expected_failure {
                self.execute_expecting_failure(&mut sh)
            } else {
                self.execute_expecting_success(&mut sh)
            };
            // Don't cleanup yet - continue to next command
            result?;
        }

        // Cleanup the temp file after all commands have executed
        self.cleanup_test(&tmp_file)?;
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
