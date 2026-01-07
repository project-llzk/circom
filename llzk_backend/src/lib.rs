//! Provides functionality to generate LLZK code from the Circom AST.

#![deny(missing_debug_implementations)]
#![deny(missing_docs)]
#![deny(clippy::missing_docs_in_private_items)]
#![deny(rustdoc::broken_intra_doc_links)]
#![warn(redundant_imports)]
#![deny(unused_must_use)]

mod codegen;
mod function;
mod function_ext;
mod gen_context;
mod module;
mod program_ext;
mod shared;
mod template;
mod template_ext;

pub use codegen::generate_llzk;
pub use module::VCPPlus;
