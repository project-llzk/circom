//! Provides functionality to generate LLZK code from the Circom AST.

#![deny(missing_debug_implementations)]
#![deny(missing_docs)]
#![deny(clippy::missing_docs_in_private_items)]
#![deny(rustdoc::broken_intra_doc_links)]
#![warn(redundant_imports)]

/// Code generation entry point.
mod codegen;
/// Function-level code generation.
mod function;
/// Module-level code generation.
mod module;
/// Shared code generation utilities.
mod shared;
/// Template-level code generation.
mod template;

pub use codegen::generate_llzk;
