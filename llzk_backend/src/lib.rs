//! Provides functionality to generate LLZK code from the Circom AST.

#![deny(missing_debug_implementations)]
#![deny(missing_docs)]
#![deny(clippy::missing_docs_in_private_items)]
#![deny(rustdoc::broken_intra_doc_links)]
#![warn(redundant_imports)]

/// Entry point for LLZK code generation.
mod codegen;
/// Handles function-level LLZK code generation for both free functions and functions within
/// structs. The [function::FunctionContext] carries information about the current LLZK function
/// being generated and some helpers related to generating code within the function. The
/// [function::GenerateLLZKInFunction] trait provides the visitor to generate LLZK IR for all circom
/// [Expression](program_structure::abstract_syntax_tree::ast::Expression) and
/// [Statement](program_structure::abstract_syntax_tree::ast::Statement) nodes.
mod function;
/// Handles circom var scoping and LLZK blocks stack management.
mod gen_context;
/// Handles the top-level constructs (i.e. circom templates and functions), by delegating
/// to the [function] and [template] modules to generate the code for each.
mod module;
/// Shared code generation utilities.
mod shared;
/// Handles template-level LLZK code generation. The [template::TemplateContext] carries information
/// about the current LLZK struct being generated and some helpers related to generating code within
/// the struct. The [template::GenerateLLZKInTemplate] trait provides the visitor to generate LLZK
/// IR for all circom [Expression](program_structure::abstract_syntax_tree::ast::Expression) and
/// [Statement](program_structure::abstract_syntax_tree::ast::Statement) nodes. There are also a few
/// helper traits like `ExprGenResult` and `Chainable` that implement some boilerplate to make the
/// actual code generation within [template::GenerateLLZKInTemplate] a lot simpler.
mod template;

pub use codegen::generate_llzk;
