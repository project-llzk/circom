//! Provides functionality to generate LLZK code from the Circom AST.

#![deny(missing_debug_implementations)]
#![deny(missing_docs)]
#![deny(clippy::missing_docs_in_private_items)]
#![deny(rustdoc::broken_intra_doc_links)]
#![deny(unused_must_use)]
#![warn(redundant_imports)]
#![warn(clippy::cast_lossless)]
#![allow(clippy::useless_conversion)]

mod codegen;
mod function;
mod function_ext;
mod gen_context;
mod module;
mod program_ext;
#[macro_use]
mod shared;
mod affine_map;
//mod ast_ext;
mod lvalue;
mod subcmp;
mod template;
mod template_ext;
mod traversal;
mod write_chain;

pub use codegen::generate_llzk;
pub use codegen::LlzkConfig;
pub use program_ext::CachedParseInfo;
pub use program_ext::VCPPlus;
