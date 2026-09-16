# AGENTS.md

This repository expects coding agents to use `nix` for builds and command execution so all necessary dependencies are available.

## Guardrails

- As much as possible, code changes should be restricted to the `llzk_backend` directory.
- Tests are located within `circom/tests`.
- Auto-formatting commands should only be applied in the `llzk_backend` directory via `cargo fmt -p llzk_backend`.

## Build and command guidance

- Preferred build command: `nix build -L`
- When you need to run a project command inside the development environment, use:
  `nix develop --command bash -c "[command]"`

## Completion requirement

- Always ensure the build is successful before you stop working.
- If you make changes, finish by running a successful build with `nix`.
- **Implementation agents only:** While independently modifying code, do not update "CHECK" lines for FileCheck in ".circom" tests. Tests that fail solely because these expectations require refreshes do not block implementation completion.
- **Code-review agents:** This implementation constraint is not a review criterion. Do not raise a finding, request a revert, or recommend against a submitted change solely because it updates FileCheck "CHECK" lines in ".circom" tests. Review the correctness of those expectation changes on their technical merits, like any other test change.
