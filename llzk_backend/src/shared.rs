//! Shared code generation utilities.

use crate::function::InfoProviders;
use crate::gen_context::BlockContextStack;
use crate::gen_context::BlockGenContext;
use crate::gen_context::GenerateLLZKInAnyBlock;
use crate::gen_context::NestedBlockInfo;
use crate::lvalue::Lvalue;
use crate::lvalue::Root;
use crate::module::DeclarationInfo;
use crate::program_ext::ProgramLike;
use crate::subcmp::names::COMP;
use crate::template_ext::TemplateLike;
use crate::template_ext::WireLike as _;
use crate::traversal::walk_from_block;
use crate::traversal::WalkCallbacks;
use ansi_term::Color;
use anyhow::anyhow;
use anyhow::ensure;
use anyhow::Context as _;
use anyhow::Result;
use llzk::builder::OpBuilder;
use llzk::dialect;
use llzk::dialect::array;
use llzk::dialect::array::ArrayCtor;
use llzk::dialect::felt;
use llzk::dialect::pod;
use llzk::dialect::poly;
use llzk::dialect::poly::TVarType;
use llzk::prelude::is_felt_type;
use llzk::prelude::melior_dialects::arith;
use llzk::prelude::replace_uses_of_with;
use llzk::prelude::verify_operation_with_diags;
use llzk::prelude::ArrayType;
use llzk::prelude::Attribute;
use llzk::prelude::AttributeLike as _;
use llzk::prelude::Block;
use llzk::prelude::BlockLike;
use llzk::prelude::BlockRef;
use llzk::prelude::BoolAttribute;
use llzk::prelude::FeltConstAttribute;
use llzk::prelude::FeltType;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::FuncDefOp;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::FuncDefOpRef;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::IntegerType;
use llzk::prelude::LlzkContext;
use llzk::prelude::LlzkError;
use llzk::prelude::Location;
use llzk::prelude::Module;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike;
use llzk::prelude::OperationMutLike;
use llzk::prelude::OperationRef;
use llzk::prelude::PassManager;
use llzk::prelude::PodRecordAttribute;
use llzk::prelude::PodType;
use llzk::prelude::Region;
use llzk::prelude::RegionLike;
use llzk::prelude::StringAttribute;
use llzk::prelude::StringRef;
use llzk::prelude::StructType;
use llzk::prelude::SymbolRefAttribute;
use llzk::prelude::TemplateExprOpLike;
use llzk::prelude::TemplateOpLike;
use llzk::prelude::TemplateOpRef;
use llzk::prelude::TemplateOpRefMut;
use llzk::prelude::TemplateSymbolBindingOp;
use llzk::prelude::TemplateSymbolBindingOpLike;
use llzk::prelude::Type;
use llzk::prelude::TypeLike as _;
use llzk::prelude::Value;
use llzk::prelude::ValueLike;
use llzk::symbol_table;
use llzk::value_ext::OwningValueRange;
use llzk::value_ext::ValueRange;
use melior::utility;
use num_bigint_dig::BigInt;
use num_bigint_dig::BigUint;
use num_bigint_dig::ModInverse;
use num_bigint_dig::ToBigInt as _;
use num_traits::cast::ToPrimitive;
use num_traits::One;
use num_traits::Zero;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use program_structure::ast::Meta;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use program_structure::error_code::ReportCode;
use program_structure::error_definition::Report;
use program_structure::file_definition::FileID;
use program_structure::file_definition::FileLocation;
use program_structure::wire_data::WireType;
use std::cell::Cell;
use std::cell::Ref;
use std::cell::RefCell;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::convert::TryInto as _;
use std::fs;
use std::fs::File;
use std::io::Write;
use std::ops::Deref;
use std::os::raw::c_void;
use std::path::Path;

/// This macro allows writing type switches with a syntax similar to match expressions.
#[macro_export]
macro_rules! type_switch {
    // Entry point
    { $name:ident = $value:expr, $( $body:tt )+ } => {{
        // Evaluate once
        let $name = $value;

        type_switch!(@parse $name, $( $body )+)
    }};

    // Entry point
    { $name:ident, $( $body:tt )+ } => {
        type_switch!(@parse $name, $( $body )+)
    };

        // Entry point
    { let $name:ident = $value:expr ; $( $body:tt )+ } => {{
        // Evaluate once
        let $name = $value;

        type_switch!(@parse $name, $( $body )+)
    }};

    // Entry point
    { let $name:ident ; $( $body:tt )+ } => {
        type_switch!(@parse $name, $( $body )+)
    };


    // Parsing

    (@parse $name:ident, $ty:ty => $body:block $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $name, $body) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as $bind:ident => $body:block $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $bind, $body) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as  => $body:block $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, _, $body) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty  => $body:expr, $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $name, {$body}) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as $bind:ident  => $body:expr, $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, $bind, {$body}) $( $rest )*)
    };

    (@parse $name:ident, $ty:ty as _  => $body:expr, $( $rest:tt )*) => {
        type_switch!(@inner $name, ($ty, _, {$body}) $( $rest )*)
    };

    // Inner implementation

    // Last arm without default case
    (@inner $name:ident, ( $ty:ty, $bind:ident, $body:block) $(,)?) => {
        type_switch!(@inner $name, ( $ty, $bind, $body) else => {panic!("unhandled type {}", $name)})
    };
    (@inner $name:ident, ( $ty:ty, _, $body:block) $(,)?) => {
        type_switch!(@inner $name, ( $ty, _, $body) else => {panic!("unhandled type {}", $name)})
    };

    // Last arm with default case
    (@inner $name:ident, ( $ty:ty, $bind:ident, $body:block ) else => $else_body:expr $(,)?) => {
        if let Ok($bind) = <$ty>::try_from($name) {
            $body
        } else {
            $else_body
        }
    };

    (@inner $name:ident, ( $ty:ty, _, $body:block ) else => $else_body:expr $(,)?) => {
        if let Ok(_) = <$ty>::try_from($name) {
            $body
        } else {
            $else_body
        }
    };

    // Recursive case
    (@inner $name:ident, ( $ty:ty, $bind:ident, $body:block ) $( $rest:tt )+ ) => {
        if let Ok($bind) = <$ty>::try_from($name) {
            $body
        } else {
            type_switch!(@parse $name, $( $rest )+)
        }
    };

    (@inner $name:ident, ( $ty:ty, _, $body:block ) $( $rest:tt )+ ) => {
        if let Ok(_) = <$ty>::try_from($name) {
            $body
        } else {
            type_switch!(@parse $name, $( $rest )+)
        }
    };
}

/// Information about a template's declaration, either full before LLZK IR is generated for the
/// template or, after the template is processed, just the minimal information needed to support
/// queries about input signal types that other templates may need.
#[derive(Debug)]
enum DeclInfo<'ctx> {
    /// Complete declaration info computed initially.
    Full(Box<DeclarationInfo<'ctx>>),
    /// Minimal information left behind after generating LLZK for a template.
    Remnant {
        /// Map of signal name to type for input signals.
        inputs: HashMap<String, Type<'ctx>>,
        /// Map of signal name to type for output signals.
        outputs: HashMap<String, Type<'ctx>>,
    },
}

/// Convert circom location information to MLIR location.
pub fn location<'ctx>(
    context: &'ctx LlzkContext,
    program: &impl ProgramLike,
    file_id: FileID,
    file_location: FileLocation,
) -> Location<'ctx> {
    let files = program.get_file_library();
    let filename = files.get_filename_or_default(&file_id);
    let line = files.get_line(file_location.start, file_id).unwrap_or(0);
    let column = files.get_column(file_location.start, file_id).unwrap_or(0);
    Location::new(context, &filename, line, column)
}

/// Configuration for LLZK code generation, derived from user input.
#[derive(Debug)]
pub struct LlzkConfig {
    /// Output filename for the generated LLZK IR.
    pub filename: String,
    /// MLIR pass pipeline to run on the generated module.
    pub pass_pipeline: String,
    /// Value of the `--prime` flag (e.g. `"bn128"`).
    pub prime_str: String,
    /// Prime field modulus as an unsigned integer.
    pub prime: BigUint,
    /// State of the `--verbose` flag.
    pub verbose: bool,
    /// State of the `--stabilize` flag.
    pub stabilize: bool,
    /// Emit plaintext (assembly) instead of bytecode.
    pub emit_plaintext: bool,
}

/// Stores necessary context for generating LLZK IR.
///
/// 'ast: lifetime of the circom AST element
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'r: lifetime of the reference captured by the current `TemplateOpRefMut`
#[derive(Debug)]
pub struct LlzkCodegen<'ast: 'r, 'ctx: 'r, 'r, P: ProgramLike> {
    /// The circom program AST.
    pub program: &'ast P,
    /// The LLZK (and MLIR) context.
    pub context: &'ctx LlzkContext,
    /// The generated LLZK `Module`.
    pub module: Module<'ctx>,
    /// Code generation configuration.
    pub config: LlzkConfig,
    /// Declaration info pre-computed for all templates.
    template_decls: RefCell<HashMap<String, DeclInfo<'ctx>>>,
    /// Strategy used to store `poly.expr` / `poly.param` symbol bindings as they are generated.
    pub(crate) binding_insert_strategy:
        RefCell<Option<Box<dyn PolyBindingStorageStrategy<'ctx, P> + 'r>>>,
    /// Body of the circom function or template currently being processed.
    current_body: Cell<Option<&'ast [Statement]>>,
    /// Current [`Statement`] (or stack thereof when within an `IfThenElse` or `While`) being
    /// visited and/or translated. Used by [`DimExprConverter::gen_template_poly_expr`] to
    /// replicate the body into the `poly.expr` initializer up to the current position so all
    /// variable assignments that contribute to the target expression will be computed.
    ///
    /// Raw pointers are used to avoid a lifetime issue from synthetic Statements created
    /// on-the-fly and translated. These pointers must only be used for pointer equality
    /// comparisons to avoid unsafe behavior.
    statement_trace: RefCell<Vec<*const Statement>>,
    /// Operation builder
    builder: OpBuilder<'ctx>,
}

/// RAII guard that pops one entry from the statement trace on drop.
///
/// Returned by [`LlzkCodegen::trace_statement`] to keep [`LlzkCodegen::statement_trace`] updated.
#[derive(Debug)]
pub struct StatementTraceGuard<'a> {
    /// Reference to the statement trace managed by this guard.
    trace: &'a RefCell<Vec<*const Statement>>,
}

impl Drop for StatementTraceGuard<'_> {
    fn drop(&mut self) {
        self.trace.borrow_mut().pop();
    }
}

/// RAII guard that clears the current [PolyBindingStorageStrategy] on drop.
#[derive(Debug)]
pub struct CurrentTemplateAutoReset<'a, 'ctx, 'r, P: ProgramLike> {
    /// Used to clear the cell within [`LlzkCodegen`] on drop.
    cell_ref: &'a RefCell<Option<Box<dyn PolyBindingStorageStrategy<'ctx, P> + 'r>>>,
}

impl<P: ProgramLike> Drop for CurrentTemplateAutoReset<'_, '_, '_, P> {
    fn drop(&mut self) {
        self.cell_ref.take();
    }
}

/// Maps parameter symbols to the attributes assigned to a concrete instances of a template.
#[derive(Debug)]
pub struct TmplParamsInstance<'ast, 'ctx> {
    /// Maps a symbol name to an attribute used as template parameter.
    map: HashMap<&'ast str, Attribute<'ctx>>,
}

impl<'ast, 'ctx> TmplParamsInstance<'ast, 'ctx> {
    /// Creates a new mapping of template parameter formals to attributes.
    pub fn new(
        params: impl IntoIterator<Item = &'ast String>,
        attrs: impl IntoIterator<Item = Attribute<'ctx>>,
    ) -> Self {
        Self { map: std::iter::zip(params.into_iter().map(|s| s.as_str()), attrs).collect() }
    }

    /// Returns the attribute mapped by the given symbol.
    fn get(&self, sym: SymbolRefAttribute<'ctx>) -> Result<Option<Attribute<'ctx>>> {
        Ok(self.map.get(sym.root().as_str()?).copied())
    }

    /// Converts the given attribute if it is a [`SymbolRefAttribute`] and its symbol has a
    /// mapping.
    ///
    /// If the attribute is not of that type returns it as is.
    pub fn map_attr(&self, attr: Attribute<'ctx>) -> Result<Attribute<'ctx>> {
        type_switch! { attr,
            SymbolRefAttribute => {
                self.get(attr)?.ok_or_else(|| anyhow!("symbol {attr} was not found in the mapping"))
            }
            else => Ok(attr)
        }
    }

    /// Converts the given type using the mapping, replacing the symbols found in the map with the
    /// corresponding attribute.
    pub fn map_type(&self, ty: Type<'ctx>) -> Result<Type<'ctx>> {
        type_switch! { ty,
            ArrayType => self.handle_array_type(ty),
            FeltType => self.handle_passthrough(ty),
            else => {
                todo!("Unhandled type {ty} while mapping through template parameters.")
            }
        }
    }

    /// Handler for array type.
    fn handle_array_type(&self, ty: ArrayType<'ctx>) -> Result<Type<'ctx>> {
        let dims =
            ty.dims().into_iter().map(|attr| self.map_attr(attr)).collect::<Result<Vec<_>>>()?;
        let inner = self.map_type(ty.element_type())?;
        Ok(ArrayType::new(inner, &dims).into())
    }

    /// Handler for mapping types that don't actually require mapping.
    fn handle_passthrough(&self, ty: impl Into<Type<'ctx>>) -> Result<Type<'ctx>> {
        Ok(ty.into())
    }

    /// Return an interator over references of the key-value pairs.
    pub fn iter(&self) -> <&HashMap<&'ast str, Attribute<'ctx>> as IntoIterator>::IntoIter {
        self.into_iter()
    }
}

impl<'i, 'ast, 'ctx> IntoIterator for &'i TmplParamsInstance<'ast, 'ctx> {
    type Item = <&'i HashMap<&'ast str, Attribute<'ctx>> as IntoIterator>::Item;

    type IntoIter = <&'i HashMap<&'ast str, Attribute<'ctx>> as IntoIterator>::IntoIter;

    fn into_iter(self) -> Self::IntoIter {
        self.map.iter()
    }
}

/// Represents the size of a Type as an expression of its parts.
#[derive(Debug, Clone)]
pub enum TypeSizeExpr<'ctx> {
    /// Constant unsigned integer.
    Const(usize),
    /// Symbol reference.
    Sym(SymbolRefAttribute<'ctx>),
    /// Addition of two expressions.
    Add(Box<Self>, Box<Self>),
    /// Multiplication of two expressions.
    Mul(Box<Self>, Box<Self>),
}

impl PartialEq for TypeSizeExpr<'_> {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (TypeSizeExpr::Const(a), TypeSizeExpr::Const(b)) => a == b,
            (TypeSizeExpr::Sym(a), TypeSizeExpr::Sym(b)) => a.to_raw().ptr == b.to_raw().ptr,
            (TypeSizeExpr::Add(lhs1, rhs1), TypeSizeExpr::Add(lhs2, rhs2)) => {
                lhs1 == lhs2 && rhs1 == rhs2
            }
            (TypeSizeExpr::Mul(lhs1, rhs1), TypeSizeExpr::Mul(lhs2, rhs2)) => {
                lhs1 == lhs2 && rhs1 == rhs2
            }
            _ => false,
        }
    }
}

impl<'ctx> TypeSizeExpr<'ctx> {
    /// The zero expression.
    #[inline]
    pub fn zero() -> Self {
        TypeSizeExpr::Const(0)
    }
    /// The one expression.
    #[inline]
    pub fn one() -> Self {
        TypeSizeExpr::Const(1)
    }
    /// Creates a constant expression.
    #[inline]
    pub fn const_val(v: usize) -> Self {
        TypeSizeExpr::Const(v)
    }
    /// Creates a symbol reference expression.
    #[inline]
    pub fn sym(a: SymbolRefAttribute<'ctx>) -> Self {
        TypeSizeExpr::Sym(a)
    }
    /// Creates an addition expression.
    #[inline]
    pub fn add(self, other: Self) -> Self {
        TypeSizeExpr::Add(Box::new(self), Box::new(other))
    }
    /// Creates a multiplication expression.
    #[inline]
    pub fn mul(self, other: Self) -> Self {
        TypeSizeExpr::Mul(Box::new(self), Box::new(other))
    }

    /// Returns true if the expression is known to compute to constant zero.
    pub fn is_const_zero(&self) -> bool {
        match self {
            TypeSizeExpr::Const(a) => *a == 0,
            TypeSizeExpr::Add(lhs, rhs) => lhs.is_const_zero() && rhs.is_const_zero(),
            TypeSizeExpr::Mul(lhs, rhs) => lhs.is_const_zero() || rhs.is_const_zero(),
            _ => false,
        }
    }

    /// Produce a simplified addition expression of the two operands.
    fn simplify_add(lhs: &Self, rhs: &Self) -> Self {
        match (lhs.simplified(), rhs.simplified()) {
            (TypeSizeExpr::Const(0), x) => x.clone(),
            (x, TypeSizeExpr::Const(0)) => x.clone(),
            (TypeSizeExpr::Const(a), TypeSizeExpr::Const(b)) => {
                TypeSizeExpr::Const(a.checked_add(b).expect("type size overflows usize max"))
            }
            (new_lhs, new_rhs) => {
                if new_lhs == *lhs && new_rhs == *rhs {
                    TypeSizeExpr::Add(Box::new(new_lhs), Box::new(new_rhs)) // unchanged
                } else {
                    Self::simplify_add(&new_lhs, &new_rhs)
                }
            }
        }
    }

    /// Produce a simplified multiplication expression of the two operands.
    fn simplify_mul(lhs: &Self, rhs: &Self) -> Self {
        match (lhs.simplified(), rhs.simplified()) {
            (TypeSizeExpr::Const(0), _) => TypeSizeExpr::Const(0),
            (_, TypeSizeExpr::Const(0)) => TypeSizeExpr::Const(0),
            (TypeSizeExpr::Const(1), x) => x.clone(),
            (x, TypeSizeExpr::Const(1)) => x.clone(),
            (TypeSizeExpr::Const(a), TypeSizeExpr::Const(b)) => {
                TypeSizeExpr::Const(a.checked_mul(b).expect("type size overflows usize max"))
            }
            (new_lhs, new_rhs) => {
                if new_lhs == *lhs && new_rhs == *rhs {
                    TypeSizeExpr::Mul(Box::new(new_lhs), Box::new(new_rhs)) // unchanged
                } else {
                    Self::simplify_mul(&new_lhs, &new_rhs)
                }
            }
        }
    }

    /// Returns a simplified version of the expression by applying arithmetic identities.
    pub fn simplified(&self) -> Self {
        match self {
            s @ TypeSizeExpr::Const(_) => s.clone(),
            s @ TypeSizeExpr::Sym(_) => s.clone(),
            TypeSizeExpr::Add(lhs, rhs) => Self::simplify_add(lhs, rhs),
            TypeSizeExpr::Mul(lhs, rhs) => Self::simplify_mul(lhs, rhs),
        }
    }

    /// Generate code for the expression as an index value in LLZK IR.
    pub fn to_index_value<'ast, 'blk, 'val>(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        fc: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        location: Location<'ctx>,
        env: Option<&TmplParamsInstance<'ast, 'ctx>>,
    ) -> Result<Value<'ctx, 'val>> {
        match self.simplified() {
            TypeSizeExpr::Const(a) => {
                fc.append_op_unnamed_result(codegen.new_index_const_op(i64::try_from(a)?, location))
            }
            TypeSizeExpr::Sym(a) => {
                if !a.nested().is_empty() {
                    unreachable!("we don't generate any nested symbols, i.e. reference to globals");
                }
                match env {
                    Some(env) => env
                        .get(a)
                        .and_then(|attr| {
                            attr.ok_or_else(|| {
                                anyhow!(
                                    "Symbol ref {a} was not found in the list of template parameters"
                                )
                            })
                        })
                        .and_then(Self::try_from_attr)
                        .and_then(|e|
                            // The call to this new expression should happen in the context of
                            // the caller since we mapped the formal to its parameter.
                            e.to_index_value(codegen, fc, location, None)),
                    None => {
                        let v = fc.block_ctx.get_named_value(a.root().as_str()?)?;
                        fc.cast_to_index_if_needed(codegen, location, *v)
                    }
                }
            }
            TypeSizeExpr::Add(lhs, rhs) => {
                let lhs = lhs.to_index_value(codegen, fc, location, env)?;
                let rhs = rhs.to_index_value(codegen, fc, location, env)?;
                fc.append_op_unnamed_result(arith::addi(lhs, rhs, location))
            }
            TypeSizeExpr::Mul(lhs, rhs) => {
                let lhs = lhs.to_index_value(codegen, fc, location, env)?;
                let rhs = rhs.to_index_value(codegen, fc, location, env)?;
                fc.append_op_unnamed_result(arith::muli(lhs, rhs, location))
            }
        }
    }

    /// Creates a new expression based on an attribute.
    fn try_from_attr(attr: Attribute<'ctx>) -> Result<Self> {
        type_switch! { attr,
            IntegerAttribute => {
                let value = attr.value();
                if value < 0 {
                    anyhow::bail!("Negative value {value} in attribute: {attr}");
                }
                Ok(Self::const_val(value.try_into()?))
            }
            SymbolRefAttribute => Ok(Self::Sym(attr)),
            else => anyhow::bail!("Unsupported attribute: {attr}")
        }
    }
}

impl<'ast: 'r, 'ctx: 'r, 'r, P: ProgramLike> LlzkCodegen<'ast, 'ctx, 'r, P> {
    /// Construct.
    pub fn new(
        program: &'ast P,
        context: &'ctx LlzkContext,
        module: Module<'ctx>,
        config: LlzkConfig,
    ) -> Self {
        LlzkCodegen {
            program,
            context,
            module,
            config,
            template_decls: RefCell::new(Default::default()),
            binding_insert_strategy: RefCell::new(None),
            current_body: Cell::new(None),
            statement_trace: RefCell::new(Vec::new()),
            builder: OpBuilder::new(context),
        }
    }

    /// Dump the current state of the LLZK module for debugging purposes.
    #[allow(unused)]
    pub fn dump_module(&self) {
        println!("[LlzkCodegen::dump_module] {:?}", self.module.as_operation());
    }

    /// Returns a reference to the operation builder.
    pub fn op_builder(&self) -> &OpBuilder<'ctx> {
        &self.builder
    }

    /// Set the body of the function or template currently being processed.
    pub fn set_current_body(&self, body: &'ast [Statement]) {
        self.current_body.set(Some(body));
    }

    /// Get the body of the function or template currently being processed.
    pub fn current_body(&self) -> Option<&'ast [Statement]> {
        self.current_body.get()
    }

    /// Create a `poly.template` from the given parameters, add it to the module, set it as
    /// the current template being generated, and return a mutable reference to it.
    pub fn create_and_set_current_template<'s>(
        &'s self,
        location: Location<'ctx>,
        name: &str,
        template_region_ops: impl IntoIterator<Item = Result<Operation<'ctx>, LlzkError>>,
    ) -> Result<(TemplateOpRefMut<'ctx, 'r>, CurrentTemplateAutoReset<'s, 'ctx, 'r, P>)> {
        let template_op = poly::template(location, name, template_region_ops)?;
        let block = self.module.body();
        let op_ref = block.append_operation(template_op.into());
        let template_ref = TemplateOpRefMut::from(TemplateOpRef::try_from(op_ref)?);
        // SAFETY: The operation is appended to `self.module` which has lifetime `'ctx`.
        // Since `'ctx: 'r` is a bound on `LlzkCodegen`, the operation is valid for `'r`.
        // We extend the borrow lifetime from the anonymous `&self` lifetime to `'r`.
        let template_ref: TemplateOpRefMut<'ctx, 'r> =
            unsafe { TemplateOpRefMut::from_raw(template_ref.to_raw()) };
        self.binding_insert_strategy.replace(Some(Box::new(template_ref)));
        Ok((template_ref, CurrentTemplateAutoReset { cell_ref: &self.binding_insert_strategy }))
    }

    /// Get the LLZK template currently being generated.
    pub fn binding_insert_strategy<'s>(
        &'s self,
    ) -> Option<Ref<'s, dyn PolyBindingStorageStrategy<'ctx, P> + 'r>> {
        Ref::filter_map(self.binding_insert_strategy.borrow(), |strategy| strategy.as_deref()).ok()
    }

    /// Push `stmt` onto the statement trace and return a guard that pops it on drop.
    ///
    /// Call this at the top of every `gen_llzk_in_template`, `gen_llzk_in_function`, etc.
    /// that traverses all body [Statement] and may end up calling the [`DimExprConverter`] so
    /// that its [`DimExprConverter::gen_template_poly_expr`] can observe the exact path of
    /// statements surrounding the target expression.
    pub fn trace_statement<'a>(&'a self, stmt: &Statement) -> StatementTraceGuard<'a> {
        self.statement_trace.borrow_mut().push(stmt as *const Statement);
        StatementTraceGuard { trace: &self.statement_trace }
    }

    /// Snapshot the current statement trace (outermost statement first) as raw pointers.
    ///
    /// The pointers are valid for the duration of the AST (`'ast` lifetime of the codegen).
    /// Use pointer equality (`std::ptr::eq`) when comparing against slice elements.
    pub fn snapshot_statement_trace(&self) -> Vec<*const Statement> {
        self.statement_trace.borrow().clone()
    }

    /// Store the full [DeclarationInfo] for the template with the given name.
    pub fn put_template_decl(&self, name: &str, decl_info: DeclarationInfo<'ctx>) {
        self.template_decls
            .borrow_mut()
            .insert(name.to_string(), DeclInfo::Full(Box::new(decl_info)));
    }

    /// Remove and return the full [DeclarationInfo] for the template with the given name and leave
    /// behind just the mapping of signal names to types.
    pub fn take_template_decl(&self, name: &str) -> Result<DeclarationInfo<'ctx>> {
        let mut borrow = self.template_decls.borrow_mut();
        if let Some((name, DeclInfo::Full(decl_info))) = borrow.remove_entry(name) {
            let decl_info = *decl_info;
            let inputs = decl_info.build_input_name_to_type_map();
            let outputs = decl_info.build_output_name_to_type_map();
            borrow.insert(name, DeclInfo::Remnant { inputs, outputs });
            return Ok(decl_info);
        }
        Err(anyhow!("No full declaration info for {name}"))
    }

    /// Get the type of the input signal with the given name in the given template, if it exists.
    pub fn get_input_signal_type(
        &self,
        template_name: &str,
        signal_name: &str,
    ) -> Result<Type<'ctx>> {
        let borrow = self.template_decls.borrow();
        match borrow.get(template_name) {
            None => anyhow::bail!("No declaration info for {template_name}"),
            Some(DeclInfo::Full(info)) => info.get_input_type(signal_name),
            Some(DeclInfo::Remnant { inputs, .. }) => inputs.get(signal_name).copied(),
        }
        .ok_or_else(|| anyhow!("No input signal with name {signal_name}"))
    }

    /// Get the type of an output signal with the given name in the given template, if it exists.
    pub fn get_output_signal_type(
        &self,
        template_name: &str,
        signal_name: &str,
    ) -> Result<Type<'ctx>> {
        let borrow = self.template_decls.borrow();
        match borrow.get(template_name) {
            None => anyhow::bail!("No declaration info for {template_name}"),
            Some(DeclInfo::Full(info)) => info.get_output_type(signal_name),
            Some(DeclInfo::Remnant { outputs, .. }) => outputs.get(signal_name).copied(),
        }
        .ok_or_else(|| anyhow!("No output signal with name {signal_name}"))
    }

    /// Get the width of the scalar prime field in bits.
    pub fn prime_field_bits(&self) -> usize {
        self.prime().bits()
    }

    /// Get the prime field modulus as a BigUint
    pub fn prime(&self) -> &BigUint {
        &self.config.prime
    }

    /// Emit a circom-style warning.
    pub fn emit_circom_warning(&self, meta: &Meta, message: &str, code: ReportCode) {
        let mut report = Report::warning(String::from(message), code);
        report.add_primary(meta.file_location(), meta.get_file_id(), String::from("here"));
        Report::print_reports(&[report], self.program.get_file_library());
    }

    /// Emit a circom-style error.
    pub fn emit_circom_error(&self, meta: &Meta, message: &str, code: ReportCode) {
        let mut report = Report::error(String::from(message), code);
        report.add_primary(meta.file_location(), meta.get_file_id(), String::from("here"));
        Report::print_reports(&[report], self.program.get_file_library());
    }

    /// Get the unknown location.
    #[inline]
    pub fn location_unknown(&self) -> Location<'ctx> {
        Location::unknown(self.context)
    }

    /// Convert circom location information to MLIR location.
    #[inline]
    pub fn location(&self, file_id: FileID, file_location: FileLocation) -> Location<'ctx> {
        location(self.context, self.program, file_id, file_location)
    }

    /// Convert circom Meta location information to MLIR location.
    pub fn location_from_meta(&self, meta: &Meta) -> Location<'ctx> {
        if let Some(file) = meta.file_id {
            self.location(file, meta.file_location())
        } else {
            self.location_unknown()
        }
    }

    /// Insert the LLZK free function into the module and return a reference to it.
    pub fn add_function(&self, f: FuncDefOp<'ctx>) -> Result<FuncDefOpRefMut<'ctx, '_>> {
        let f: FuncDefOpRef = self.module.body().append_operation(f.into()).try_into()?;
        Ok(f.into())
    }

    /// If `dimensions` is empty, return `base_type`. Otherwise, create [ArrayType] by
    /// converting the dimension sizes to LLZK Attributes.
    pub fn type_from_dimension_consts(
        &self,
        base_type: Type<'ctx>,
        dimensions: &[usize],
    ) -> Result<Type<'ctx>> {
        if dimensions.is_empty() {
            Ok(base_type)
        } else {
            dimensions
                .iter()
                .map(|c| {
                    i64::try_from(*c)
                        .map_err(Into::into)
                        .map(|c| Attribute::from(self.index_attr(c)))
                })
                .collect::<Result<Vec<_>>>()
                .map(|dims| ArrayType::new(base_type, &dims).into())
        }
    }

    /// Create an LLZK operation that produces a nondeterministic value of the given type.
    pub fn new_nondet_at_location(
        &self,
        location: Location<'ctx>,
        result_type: Type<'ctx>,
    ) -> Result<Operation<'ctx>> {
        Ok(dialect::llzk::nondet(location, result_type))
    }

    /// Get the integer type of the given bitwidth.
    #[inline]
    pub fn int_type(&self, bits: u32) -> IntegerType<'ctx> {
        IntegerType::new(self.context, bits)
    }

    /// Get the boolean type (`i1`).
    #[inline]
    pub fn bool_type(&self) -> IntegerType<'ctx> {
        self.int_type(1)
    }

    /// Get the index type.
    #[inline]
    pub fn index_type(&self) -> Type<'ctx> {
        Type::index(self.context)
    }

    /// Get the felt type.
    #[inline]
    pub fn felt_type(&self) -> FeltType<'ctx> {
        FeltType::with_field(self.context, &self.config.prime_str)
    }

    /// Get the polymorphic type variable type for the given name.
    #[inline]
    pub fn tvar_type(&self, name: &str) -> Type<'ctx> {
        TVarType::new(self.context, StringRef::new(name)).into()
    }

    /// Get the struct type for the given struct name and parameters.
    #[inline]
    pub fn struct_type_with_params(
        &self,
        name: &str,
        params: &[Attribute<'ctx>],
    ) -> StructType<'ctx> {
        // When creating a StructType directly, use the same name for both the template and
        // the struct itself to match LLZK code generated by `gen_template_llzk()`.
        StructType::new(self.double_ref_sym(name), params)
    }

    /// Get the struct type for the given struct name.
    #[inline]
    pub fn struct_type(&self, name: &str) -> StructType<'ctx> {
        self.struct_type_with_params(name, &[])
    }

    /// Get a pod struct type with the given records.
    #[inline]
    pub fn pod_type(&self, records: &[(&str, Type<'ctx>)]) -> PodType<'ctx> {
        let records = records
            .iter()
            .map(|(name, r#type)| PodRecordAttribute::new(name, *r#type))
            .collect::<Vec<_>>();
        PodType::new(self.context, &records)
    }

    /// Create an index attribute.
    #[inline]
    pub fn index_attr<T>(&self, integer: T) -> IntegerAttribute<'ctx>
    where
        T: Into<i64>,
    {
        IntegerAttribute::new(self.index_type(), integer.into())
    }

    /// Create an affine_map attribute from a string definition.
    pub fn affine_map_attr(&self, definition: &str) -> Result<Attribute<'ctx>> {
        Attribute::parse(self.context, definition)
            .ok_or_else(|| anyhow!("could not parse affine_map definition"))
    }

    /// Creates a [`FlatSymbolRefAttribute`] from the given string.
    #[inline]
    pub fn flat_sym(&self, sym: impl AsRef<str>) -> FlatSymbolRefAttribute<'ctx> {
        FlatSymbolRefAttribute::new(self.context, sym.as_ref())
    }

    /// Creates a [`SymbolRefAttribute`] from the given string as "@str::str"
    #[inline]
    pub fn double_ref_sym(&self, sym: impl AsRef<str>) -> SymbolRefAttribute<'ctx> {
        double_ref_sym(self.context, sym)
    }

    /// Creates a `pod.read` operation.
    ///
    /// Fails if the type of the value is not [`PodType`] or if the given name does not correspond
    /// with a record in the pod.
    pub fn new_pod_read_op(
        &self,
        pod: Value<'ctx, '_>,
        name: impl AsRef<str>,
        location: Location<'ctx>,
    ) -> Result<Operation<'ctx>> {
        let name = name.as_ref();
        let pod_type = PodType::try_from(pod.r#type())?;
        let record_type = pod_type
            .get_type_of_record(name)
            .ok_or_else(|| anyhow!("record '{}' not found for pod {pod_type}", name))?;
        Ok(pod::read(location, pod, self.flat_sym(name), record_type))
    }

    /// Creates a `pod.write` operation.
    #[inline]
    pub fn new_pod_write_op(
        &self,
        location: Location<'ctx>,
        pod: Value<'ctx, '_>,
        name: impl AsRef<str>,
        src: Value<'ctx, '_>,
    ) -> Operation<'ctx> {
        pod::write(location, pod, self.flat_sym(name), src)
    }

    /// Create an LLZK operation that produces a boolean constant value.
    #[inline]
    pub fn new_bool_const_op(&self, val: bool, location: Location<'ctx>) -> Operation<'ctx> {
        arith::constant(self.context, BoolAttribute::new(self.context, val).into(), location)
    }

    /// Create an LLZK operation that produces an integer constant value.
    #[inline]
    pub fn new_int_const_op(
        &self,
        ty: Type<'ctx>,
        val: i64,
        location: Location<'ctx>,
    ) -> Operation<'ctx> {
        arith::constant(self.context, IntegerAttribute::new(ty, val).into(), location)
    }

    /// Create an LLZK operation that produces an index constant value.
    #[inline]
    pub fn new_index_const_op<T>(&self, val: T, location: Location<'ctx>) -> Operation<'ctx>
    where
        T: Into<i64>,
    {
        arith::constant(self.context, self.index_attr(val).into(), location)
    }

    /// Create an LLZK `array.new` operation with the given type and constructor info.
    #[inline]
    pub fn new_array_new_op(
        &self,
        location: Location<'ctx>,
        r#type: ArrayType<'ctx>,
        ctor: ArrayCtor<'ctx, '_, '_, '_>,
    ) -> Operation<'ctx> {
        array::new(&self.builder, location, r#type, ctor)
    }

    /// Generate a `felt.const` operation from a BigInt. Returns an `Err` result if unsuccessful
    /// or if the number of bits required to represent the BigInt does not fit in 32 bits.
    pub fn new_felt_const_op(
        &self,
        val: &BigInt,
        location: Location<'ctx>,
    ) -> Result<Operation<'ctx>> {
        // ASSERT: The circom parser always produces non-negative constants. These can be negated
        // via PrefixOp but negative BigInt constants are never created directly.
        assert_ne!(val.sign(), num_bigint_dig::Sign::Minus, "Felt constants must be non-negative");
        let attr = FeltConstAttribute::parse(
            self.context,
            // use required bits +1 to ensure unsigned representation
            u32::try_from(val.bits())? + 1,
            val.to_string().as_str(),
            Some(&self.config.prime_str),
        );
        felt::constant(location, attr).map_err(Into::into)
    }

    /// Creates a new constant op to create a constant of the given type.
    /// Assumes `type` will be a felt or integral/index type.
    pub fn new_const_op(
        &self,
        location: Location<'ctx>,
        r#type: Type<'ctx>,
        val: i64,
    ) -> Result<Operation<'ctx>> {
        if is_felt_type(r#type) {
            self.new_felt_const_op(&BigInt::from(val), location)
        } else {
            Ok(self.new_int_const_op(r#type, val, location))
        }
    }

    /// Run the given pass pipeline on the given operation.
    pub fn run_pass_pipeline_on<'c: 'a, 'a>(
        &self,
        pipeline: &str,
        op: &impl OperationLike<'c, 'a>,
    ) -> Result<()> {
        if pipeline.is_empty() {
            return Ok(());
        }

        let manager = PassManager::new(self.context);
        // Disable verifier in case the given op is orphaned (i.e. not yet attached to a parent).
        manager.enable_verifier(false);
        // Print current IR on failure to make debugging easier.
        enable_ir_printing(
            &manager,
            false,
            false,
            false,
            false,
            true,
            Default::default(),
            Default::default(),
        );

        // Setup and run the pass pipeline.
        utility::register_all_passes();
        utility::parse_pass_pipeline(manager.as_operation_pass_manager(), pipeline)
            .map_err(anyhow::Error::from)?;

        let mlir_result =
            unsafe { mlir_sys::mlirPassManagerRunOnOp(manager.to_raw(), op.to_raw()) };
        ensure!(mlir_result.value != 0, "failed to run pass pipeline: {pipeline}");

        Ok(())
    }

    /// Run the pass pipeline from the command line on the generated `Module`.
    pub fn run_user_pass_pipeline(&mut self) -> Result<()> {
        if self.config.pass_pipeline.is_empty() {
            return Ok(());
        }
        let manager = PassManager::new(self.context);
        manager.enable_verifier(true);
        utility::register_all_passes();
        utility::parse_pass_pipeline(
            manager.as_operation_pass_manager(),
            &self.config.pass_pipeline,
        )
        .map_err(anyhow::Error::from)?;
        manager.run(&mut self.module).map_err(Into::into)
    }

    /// Verify the generated `Module`.
    #[inline]
    pub fn verify(&self) -> Result<(), LlzkError> {
        verify_operation_with_diags(&self.module.as_operation())
    }

    /// Create file at the given path, ensuring parent directories exist.
    fn create_file(filename: &str) -> Result<File> {
        let out_path = Path::new(filename);
        // Ensure parent directories exist
        if let Some(parent) = out_path.parent() {
            fs::create_dir_all(parent).map_err(anyhow::Error::from)?;
        }
        File::create(out_path).map_err(Into::into)
    }

    /// Write the generated `Module` to a file in LLZK IR assembly format.
    pub fn write_assembly_to_file(self) -> Result<()> {
        let filename = self.config.filename.as_str();
        let mut file = Self::create_file(filename)?;
        write!(file, "{}", self.module.as_operation())?;
        println!("{} {}", Color::Green.paint("Written successfully:"), filename);
        Ok(())
    }

    /// Write the generated `Module` to a file in bytecode format.
    pub fn write_bytecode_to_file(self) -> Result<()> {
        unsafe extern "C" fn callback(string_ref: mlir_sys::MlirStringRef, user_data: *mut c_void) {
            let file = &mut *(user_data as *mut File);
            let slice = std::slice::from_raw_parts(string_ref.data as *const u8, string_ref.length);
            file.write_all(slice).unwrap();
        }

        let filename = self.config.filename.as_str();
        let mut file = Self::create_file(filename)?;
        unsafe {
            mlir_sys::mlirOperationWriteBytecode(
                self.module.as_operation().to_raw(),
                Some(callback),
                &mut file as *mut File as *mut c_void,
            );
        }
        println!("{} {}", Color::Green.paint("Written successfully:"), filename);
        Ok(())
    }

    /// Returns the data for the template with that name.
    pub fn find_template_data(
        &self,
        name: &str,
    ) -> Option<&'ast (impl TemplateLike + use<'ast, P>)> {
        if self.program.contains_template(name) {
            Some(self.program.get_template_data(name))
        } else {
            None
        }
    }

    /// Returns the types of the inputs for the given template, in declaration order.
    pub fn get_template_input_types(&self, name: &str) -> Result<Vec<Type<'ctx>>> {
        let data =
            self.find_template_data(name).ok_or_else(|| anyhow!("Template {name} not found"))?;
        Ok(data
            .get_declaration_inputs()
            .iter()
            .map(move |(input, _)| -> Type<'ctx> {
                let wire = data
                    .get_input_info(input)
                    // The name comes from `get_declaration_inputs`.
                    // If `get_input_info` fails here with that name,
                    // something has gone very wrong.
                    .unwrap_or_else(|| panic!("Input {:?} not found for type {:?}", input, name));
                match wire.get_type() {
                    WireType::Signal => self.felt_type().into(),
                    WireType::Bus(name) => self.struct_type(&name).into(),
                }
            })
            .collect())
    }

    /// Compute the size of the type in signals. A scalar signal has size 1, an array of 2 signals
    /// has size 2, a 2x3 matrix of signals has size 6, and so on. Structs have a size equal to the
    /// sum of its input sizes.
    pub fn count_input_signals(&self, t: Type<'ctx>) -> Result<TypeSizeExpr<'ctx>> {
        if is_felt_type(t) {
            Ok(TypeSizeExpr::one())
        } else if let Ok(at) = ArrayType::try_from(t) {
            let init = self.count_input_signals(at.element_type())?;
            at.dims().iter().try_fold(init, |acc, d| {
                if let Ok(a) = IntegerAttribute::try_from(*d) {
                    let s = usize::try_from(a.value()).context("negative array size")?;
                    Ok(acc.mul(TypeSizeExpr::const_val(s)))
                } else if let Ok(a) = SymbolRefAttribute::try_from(*d) {
                    Ok(acc.mul(TypeSizeExpr::sym(a)))
                } else {
                    Err(anyhow!("expected array dimension to be Int or SymRef but found: {d}"))
                }
            })
        } else if let Ok(pt) = PodType::try_from(t) {
            pt.get_records().iter().try_fold(TypeSizeExpr::zero(), |acc, r| {
                Ok(acc.add(self.count_input_signals(r.r#type())?))
            })
        } else if let Ok(st) = StructType::try_from(t) {
            self.get_template_input_types(get_name_tail(&st)?)?
                .iter()
                .try_fold(TypeSizeExpr::zero(), |acc, t| Ok(acc.add(self.count_input_signals(*t)?)))
        } else {
            anyhow::bail!("unexpected type while counting signals: {t}");
        }
    }

    /// Convert a `Vec<String>` into a comma-separated [StringAttribute].
    #[inline]
    pub fn list_to_attribute(&self, names: &[String]) -> Attribute<'ctx> {
        StringAttribute::new(self.context, &names.join(",")).into()
    }

    /// Convert a [StringAttribute] containing a comma-separated list into a `Vec<String>`.
    #[inline]
    pub fn attribute_to_list(
        &self,
        attr: Attribute<'ctx>,
    ) -> Result<impl Iterator<Item = &'ctx str>> {
        Ok(StringAttribute::try_from(attr)?.value().split(','))
    }
}

/// Creates a [`SymbolRefAttribute`] from the given string as "@str::str"
#[inline]
pub fn double_ref_sym<'c>(ctx: &'c LlzkContext, sym: impl AsRef<str>) -> SymbolRefAttribute<'c> {
    let sym = sym.as_ref();
    SymbolRefAttribute::new_from_str(ctx, sym, &[sym])
}

/// Get the StructDefOp name from the given StructType.
#[inline]
pub fn get_name_tail<'c>(ty: &StructType<'c>) -> Result<&'c str> {
    ty.name().leaf().as_str().map_err(Into::into)
}

/// Return a new SymbolRefAttribute like the given one with another path element appended.
#[inline]
pub fn append_tail<'c>(base: &SymbolRefAttribute<'c>, append: &'c str) -> SymbolRefAttribute<'c> {
    let mut tail = base.nested();
    tail.push(FlatSymbolRefAttribute::new(unsafe { base.context().to_ref() }, append));
    SymbolRefAttribute::new(unsafe { base.context().to_ref() }, base.root(), &tail)
}

/// Try to statically compute the value of a circom [Expression] used as an array dimension.
///
/// This is computed in a separate function so that nested expressions return BigUint results
/// instead of IntegerAttributes.
///
/// Returns `Ok(None)` if the expression cannot be computed statically, `Ok(Some(BigUint))`
/// if the computation is successful, or `Err` if a conversion error occurs along the way.
pub fn try_compute_biguint(expr: &Expression, prime: &BigUint) -> Result<Option<BigUint>> {
    match expr {
        Expression::Number(_, big_int) => {
            let v =
                big_int.to_biguint().ok_or_else(|| anyhow!("could not convert to signed"))? % prime;
            Ok(Some(v))
        }
        Expression::InfixOp { lhe, infix_op, rhe, .. } => {
            let lhs = try_compute_biguint(lhe, prime)?;
            let rhs = try_compute_biguint(rhe, prime)?;
            match (lhs, rhs) {
                (Some(lhs), Some(rhs)) => {
                    // Perform the arithmetic
                    let bool_to_biguint = |b| if b { BigUint::one() } else { BigUint::zero() };
                    let res = match infix_op {
                        ExpressionInfixOpcode::Mul => (lhs * rhs) % prime,
                        ExpressionInfixOpcode::Div => {
                            let rhs_inv = rhs
                                .mod_inverse(prime)
                                .ok_or_else(|| anyhow!("failed to compute inverse"))?
                                .to_biguint()
                                .ok_or_else(|| anyhow!("could not convert to BigUint"))?;
                            (lhs * rhs_inv) % prime
                        }
                        ExpressionInfixOpcode::Add => (lhs + rhs) % prime,
                        ExpressionInfixOpcode::Sub => (lhs + (prime - rhs)) % prime,
                        ExpressionInfixOpcode::Pow => lhs.modpow(&rhs, prime),
                        ExpressionInfixOpcode::IntDiv => (lhs / rhs) % prime,
                        ExpressionInfixOpcode::Mod => lhs % rhs,
                        ExpressionInfixOpcode::ShiftL => {
                            (lhs << rhs
                                .to_usize()
                                .ok_or_else(|| anyhow!("could not convert to usize"))?)
                                % prime
                        }
                        ExpressionInfixOpcode::ShiftR => {
                            (lhs >> rhs
                                .to_usize()
                                .ok_or_else(|| anyhow!("could not convert to usize"))?)
                                % prime
                        }
                        // Comparison operators are performed based on a signed interpretation
                        // of the field elements as defined by the `relational_val` function,
                        // according to the circom spec.
                        ExpressionInfixOpcode::LesserEq => {
                            let res = relational_val(&lhs, prime)? <= relational_val(&rhs, prime)?;
                            bool_to_biguint(res)
                        }
                        ExpressionInfixOpcode::GreaterEq => {
                            let res = relational_val(&lhs, prime)? >= relational_val(&rhs, prime)?;
                            bool_to_biguint(res)
                        }
                        ExpressionInfixOpcode::Lesser => {
                            let res = relational_val(&lhs, prime)? < relational_val(&rhs, prime)?;
                            bool_to_biguint(res)
                        }
                        ExpressionInfixOpcode::Greater => {
                            let res = relational_val(&lhs, prime)? > relational_val(&rhs, prime)?;
                            bool_to_biguint(res)
                        }
                        ExpressionInfixOpcode::Eq => bool_to_biguint(lhs == rhs),
                        ExpressionInfixOpcode::NotEq => bool_to_biguint(lhs != rhs),
                        ExpressionInfixOpcode::BoolOr => {
                            bool_to_biguint(!lhs.is_zero() || !rhs.is_zero())
                        }
                        ExpressionInfixOpcode::BoolAnd => {
                            bool_to_biguint(!lhs.is_zero() && !rhs.is_zero())
                        }
                        ExpressionInfixOpcode::BitOr => (lhs | rhs) % prime,
                        ExpressionInfixOpcode::BitAnd => lhs & rhs,
                        ExpressionInfixOpcode::BitXor => (lhs ^ rhs) % prime,
                    };
                    Ok(Some(res))
                }
                _ => Ok(None),
            }
        }
        Expression::PrefixOp { prefix_op, rhe, .. } => {
            let rhs = try_compute_biguint(rhe, prime)?;
            match rhs {
                Some(rhs) => {
                    // Perform the arithmetic
                    let res = match prefix_op {
                        ExpressionPrefixOpcode::Sub => {
                            if rhs.is_zero() {
                                rhs
                            } else {
                                prime - rhs
                            }
                        }
                        ExpressionPrefixOpcode::BoolNot => {
                            if rhs.is_zero() {
                                BigUint::one()
                            } else {
                                BigUint::zero()
                            }
                        }
                        ExpressionPrefixOpcode::Complement => {
                            let mask = (BigUint::one() << prime.bits()) - BigUint::one();
                            mask ^ rhs
                        }
                    };
                    Ok(Some(res))
                }
                _ => Ok(None),
            }
        }
        Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
            let cond = try_compute_biguint(cond, prime)?;
            let if_true = try_compute_biguint(if_true, prime)?;
            let if_false = try_compute_biguint(if_false, prime)?;
            match (cond, if_true, if_false) {
                (Some(cond), Some(if_true), Some(if_false)) => {
                    Ok(Some(if !cond.is_zero() { if_true } else { if_false }))
                }
                _ => Ok(None),
            }
        }
        _ => Ok(None),
    }
}

/// Try to statically compute the value of a circom [Expression] used as an array dimension.
///
/// Returns `Ok(None)` if the expression cannot be computed statically as `i64`, `Ok(Some(i64))`
/// if the computation is successful, or `Err` if a conversion error occurs along the way.
pub fn try_compute_as_i64(expr: &Expression, prime: &BigUint) -> Result<Option<i64>> {
    try_compute_biguint(expr, prime).map(|b| b.as_ref().and_then(BigUint::to_i64))
}

/// Extract the single result Value from an OperationRef. Returns an `Err` result if the operation
/// does not have exactly one result.
///
/// 'c: lifetime of the `LlzkContext` and generated `Module`
/// 'a: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn single_result_as_value<'c: 'a, 'a>(op: impl OperationLike<'c, 'a>) -> Result<Value<'c, 'a>> {
    if op.result_count() != 1 {
        return Err(anyhow!(
            "Expected operation to have a single result, found {}",
            op.result_count()
        ));
    }
    op.result(0).map(Value::from).map_err(Into::into)
}

/// Ensures the given OperationRef has 0 result Values, else returns an `Err` result.
///
/// 'c: lifetime of the `LlzkContext` and generated `Module`
/// 'a: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn no_results<'c: 'a, 'a>(op: impl OperationLike<'c, 'a>) -> Result<()> {
    if op.result_count() != 0 {
        return Err(anyhow!("Expected operation to have no results, found {}", op.result_count()));
    }
    Ok(())
}

/// Create a map of circom variable names (either function arguments or template input signals) to
/// LLZK function argument Values.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[inline]
pub fn map_name_to_arg_value<'ctx, 'val>(
    func: FuncDefOpRefMut<'ctx, 'val>,
    arg_names: Vec<String>,
) -> Result<HashMap<String, Value<'ctx, 'val>>> {
    arg_names
        .into_iter()
        .enumerate()
        .map(|(i, name)| {
            func.deref().argument(i).map_err(Into::into).map(|a| (name, Value::from(a)))
        })
        .collect()
}

/// Return `true` iff the given Type is an `IndexType`.
#[inline]
pub fn is_index(t: Type) -> bool {
    t.is_index()
}

/// Return `true` iff the given Type is a boolean type, i.e. `i1`.
#[inline]
pub fn is_bool(t: Type) -> bool {
    t.is_integer() && IntegerType::try_from(t).is_ok_and(|it| it.width() == 1)
}

/// Add a new argument to the given [BlockRef] with the same type as `orig` and replace all uses of
/// `orig` within the given [BlockRef] (and within any nested blocks) with the new block argument.
///
/// Collects the operations that reference `orig` first, then mutates them in a second pass. This
/// avoids a use-list iterator-invalidation hazard in `mlirOperationReplaceUsesOfWith`: when an op
/// has multiple operands pointing at the same `orig` SSA value (e.g. `felt.add %x, %x` produced by
/// `var e2 = e2 + e2;`), replacing all of those operands at once detaches more than one operand
/// cell from `orig`'s use chain. The next pointer that an iterator saved before the mutation is
/// then no longer in `orig`'s use list, so subsequent uses of `orig` in the same block are silently
/// skipped — manifesting as e.g. `Bits2Num`'s `lc1 += in[i] * e2` lowering to `felt.mul %bit,
/// %felt_const_1` (the unreplaced initial value) instead of `felt.mul %bit, %arg_e2`.
pub fn replace_uses_with_new_block_argument<'ctx, 'val>(
    block: BlockRef<'ctx, 'val>,
    orig: &Value<'ctx, 'val>,
    location: Location<'ctx>,
) -> Value<'ctx, 'val> {
    let replacement = block.add_argument(orig.r#type(), location);
    // `OperationRef` lifetimes are HRTB inside `WalkCallbacks::for_ops`, so collect
    // raw handles and rebuild the `OperationRef` outside the walk.
    let mut ops_using_orig: Vec<mlir_sys::MlirOperation> = Vec::new();
    walk_from_block(
        block,
        WalkCallbacks::for_ops(|op| {
            if op.operands().any(|operand| operand == *orig) {
                ops_using_orig.push(op.to_raw());
            }
        }),
    );
    for raw in ops_using_orig {
        let op = unsafe { OperationRef::from_raw(raw) };
        replace_uses_of_with(&op, *orig, replacement);
    }
    replacement
}

/// Create new array type that is an array of the given sub-array type.
#[inline]
pub fn new_array_type<'c>(dim: Attribute<'c>, subarr_ty: &ArrayType<'c>) -> ArrayType<'c> {
    let dims: Vec<_> = std::iter::once(dim).chain(subarr_ty.dims()).collect();
    ArrayType::new(subarr_ty.element_type(), &dims)
}

/// Convert unsigned field elements into relational values used for comparisons.
///
/// relational_val(a) = a-p  if m/2 +1 <= a < m
/// relational_val(a) = a,    otherwise.
///
/// see https://docs.circom.io/circom-language/basic-operators/#relational-operators
/// for definition.
pub fn relational_val(a: &BigUint, p: &BigUint) -> Result<BigInt> {
    let a = (a % p)
        .to_bigint()
        .ok_or_else(|| anyhow!("could not convert field element to signed int"))?;
    let p =
        p.to_bigint().ok_or_else(|| anyhow!("could not convert field modulus to signed int"))?;
    let val = if ((&p / 2) + 1) <= a { a - p } else { a };
    Ok(val)
}

/// Heuristically detect a circom `for` loop (represented by a `Statement::Block` containing a
/// `Statement::InitializationBlock` followed by a `Statement::While`). Since all values in circom
/// are of type `felt`, we cannot (easily) generate `scf.for` which requires index-typed loop
/// variables so this macro generates code for the `Statement::InitializationBlock` followed by an
/// `scf.while` for the loop (and then returns "Ok" so that the caller does not fall through to the
/// normal code generation for a Block). Additionally, if the loop bounds and step can be computed
/// as compile-time constants, then create an LLZK `loopbounds` attribute to attach to the generated
/// `scf.while` loop.
#[macro_export]
macro_rules! try_for_loop_heuristic {
    ($codegen:expr, $gen_context:expr, $meta:expr, $stmts:expr $(, $info:expr)? $(,)?) => {
        if let [program_structure::ast::Statement::InitializationBlock {
            xtype: program_structure::ast::VariableType::Var,
            initializations,
            ..
        }, program_structure::ast::Statement::While { cond, stmt, .. }] = $stmts.as_slice()
        {
            // TODO: Analyze `initializations` and `While` loop contents to determine if loop bounds
            // and step can be computed. The loop `cond` is probably the starting point to find the
            // loop iteration variable and then `initializations` has the start value and the loop
            // body `stmt` has the step.
            // TODO: Once this is implemented, find "for" loops in all `.circom` test files to add
            // the `loopbounds` attribute to relevant loops (because existing tests will likely not
            // fail when this is added since the lit checks only do line prefix by default).
            let loop_bounds = None;

            gen_init_block($codegen, $gen_context, $($info,)* initializations)?;
            return gen_while($codegen, $gen_context, $($info,)* $meta, cond, stmt, loop_bounds);
        }
    };
}

/// Returns a reference to a parent operation.
///
/// This function provides an API that is added in a newer release of melior via
/// [mlir-sys/melior#789](https://github.com/mlir-rs/melior/pull/789).
pub fn parent_operation_mut<'c: 'a, 'a>(
    op: &impl OperationLike<'c, 'a>,
) -> Option<melior::ir::operation::OperationRefMut<'c, 'a>> {
    unsafe {
        melior::ir::operation::OperationRefMut::from_option_raw(
            mlir_sys::mlirOperationGetParentOperation(op.to_raw()),
        )
    }
}

/// Returns a mutable reference to the next operation in the same block.
///
/// This function provides an API fix that is added in a newer release of melior via
/// [mlir-sys/melior#790](https://github.com/mlir-rs/melior/pull/790).
pub fn next_in_block_mut<'c: 'a, 'a>(
    op: &impl melior::ir::operation::OperationLike<'c, 'a>,
) -> Option<melior::ir::operation::OperationRefMut<'c, 'a>> {
    unsafe {
        melior::ir::operation::OperationRefMut::from_option_raw(
            mlir_sys::mlirOperationGetNextInBlock(op.to_raw()),
        )
    }
}

/// Set IR printing options on the given [PassManager].
///
/// This function provides an API fix that is added in a newer release of melior via
/// [mlir-sys/melior#802](https://github.com/mlir-rs/melior/pull/802).
#[allow(clippy::too_many_arguments)]
pub fn enable_ir_printing(
    _self: &melior::pass::PassManager,
    before_all: bool,
    after_all: bool,
    module_scope: bool,
    on_change: bool,
    on_failure: bool,
    flags: melior::ir::operation::OperationPrintingFlags,
    tree_printing_path: std::path::PathBuf,
) {
    unsafe {
        mlir_sys::mlirPassManagerEnableIRPrinting(
            _self.to_raw(),
            before_all,
            after_all,
            module_scope,
            on_change,
            on_failure,
            flags.to_raw(),
            melior::StringRef::new(&tree_printing_path.display().to_string()).to_raw(),
        )
    }
}

/// Removes itself from a parent block and returns the owned [Operation].
pub fn remove_from_parent<'c: 'a, 'a>(op: &mut impl OperationMutLike<'c, 'a>) -> Operation<'c> {
    unsafe {
        mlir_sys::mlirOperationRemoveFromParent(op.to_raw());
    }
    unsafe { Operation::from_raw(op.to_raw()) }
}

/// Information needed to create a new LLZK array type with the given dimension
/// and to instantiate that array if the dimension attribute is an affine_map
/// with symbols.
#[derive(Debug, Clone)]
pub struct ArrayDimension<'ctx, 'val> {
    /// The attribute to use as the dimension; could be a constant, a symbol, or an affine map.
    attr: Attribute<'ctx>,
    /// The symbols to be passed to the affine map, if attr is an AffineMapAttr
    symbols: Option<OwningValueRange<'ctx, 'val>>,
}

impl<'ctx, 'val> ArrayDimension<'ctx, 'val> {
    /// Construct a new ArrayDimension.
    /// If attr is not an affine map, then symbol_vals should be empty.
    pub fn new(attr: Attribute<'ctx>, symbol_vals: &[Value<'ctx, 'val>]) -> Result<Self> {
        ensure!(
            attr.is_affine_map() || symbol_vals.is_empty(),
            "if attribute is not an affine map, no symbols should be provided"
        );
        Ok(Self {
            attr,
            symbols: (!symbol_vals.is_empty()).then(|| OwningValueRange::from(symbol_vals)),
        })
    }
    /// Access the inner attribute.
    pub fn attr(&self) -> &Attribute<'ctx> {
        &self.attr
    }
    /// Access the inner symbols, if present, as a [ValueRange].
    pub fn value_range(&self) -> Result<Option<ValueRange<'ctx, '_, 'val>>> {
        self.symbols.as_ref().map(|s| ValueRange::try_from(s).map_err(Into::into)).transpose()
    }
    /// Create a new [ArrayType] with the given dimension.
    pub fn new_array_type(&self, element_type: &Type<'ctx>) -> ArrayType<'ctx> {
        if let Ok(subarr_ty) = ArrayType::try_from(*element_type) {
            new_array_type(self.attr, &subarr_ty)
        } else {
            ArrayType::new(*element_type, &[self.attr])
        }
    }
    /// Transform the array dimension using the given function that converts
    /// values into new values (e.g., casting operations to index).
    pub fn transform(
        &self,
        mut map_fn: impl FnMut(Value<'ctx, 'val>) -> Result<Value<'ctx, 'val>>,
    ) -> Result<Self> {
        Ok(Self {
            attr: self.attr,
            symbols: match &self.symbols {
                None => None,
                Some(ovr) => {
                    let translated_vals = ovr
                        .values()
                        .iter()
                        .map(|v| map_fn(unsafe { Value::from_raw(*v) }))
                        .collect::<Result<Vec<_>>>()?;
                    Some(OwningValueRange::from(translated_vals.as_slice()))
                }
            },
        })
    }
}

#[derive(Debug, Clone)]
/// Conveys information about array dimension computation.
pub enum ArrayDimensionResult<'ctx, 'val> {
    /// Indicates that the computing context had sufficient information to compute the array and
    /// computed it successfully.
    Computed(ArrayDimension<'ctx, 'val>),
    /// Indicates that the computing context was missing information (e.g., variables defined
    /// within the function not accessible at template level).
    InsufficientData,
}

impl<'ctx, 'val> ArrayDimensionResult<'ctx, 'val> {
    /// Construct a new [ArrayDimensionResult::Computed].
    pub fn new(attr: Attribute<'ctx>, symbol_vals: &[Value<'ctx, 'val>]) -> Result<Self> {
        Ok(Self::Computed(ArrayDimension::new(attr, symbol_vals)?))
    }
    /// Construct a [ArrayDimensionResult::InsufficientData].
    /// A convenience method for cases needing a return value of [Result<ArrayDimensionResult>]
    pub fn insufficient_data_result() -> Result<Self> {
        Ok(Self::InsufficientData)
    }
}

impl<'ctx, 'val> TryFrom<ArrayDimensionResult<'ctx, 'val>> for ArrayDimension<'ctx, 'val> {
    type Error = anyhow::Error;

    fn try_from(value: ArrayDimensionResult<'ctx, 'val>) -> Result<Self> {
        match value {
            ArrayDimensionResult::Computed(array_dimension) => Ok(array_dimension),
            ArrayDimensionResult::InsufficientData => {
                Err(anyhow!("insufficient data to convert dimension expression"))
            }
        }
    }
}

impl<'ctx, 'val> TryFrom<&ArrayDimension<'ctx, 'val>> for IntegerAttribute<'ctx> {
    type Error = anyhow::Error;

    fn try_from(dim: &ArrayDimension<'ctx, 'val>) -> Result<Self> {
        ensure!(dim.value_range()?.is_none(), "const dimension should have no symbols");
        if let Ok(d) = IntegerAttribute::try_from(*dim.attr()) {
            Ok(d)
        } else {
            Err(anyhow!("could not convert to IntegerAttribute"))
        }
    }
}

/// Information needed to create a new LLZK array type with the given dimensions.
#[derive(Debug, Default)]
pub struct ArrayDimensions<'ctx, 'val>(Vec<ArrayDimension<'ctx, 'val>>);

impl<'ctx, 'val> ArrayDimensions<'ctx, 'val> {
    /// Check if the number of dimensions is non-zero.
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
    /// Get all contained attributes.
    pub fn attrs(&self) -> Vec<Attribute<'ctx>> {
        self.0.iter().map(|d| *d.attr()).collect()
    }
    /// Create a new [ArrayType] with the given dimensions.
    pub fn new_array_type(&self, element_type: &Type<'ctx>) -> ArrayType<'ctx> {
        ArrayType::new(*element_type, self.attrs().as_slice())
    }
    /// Get the non-empty symbol values for affine map instantiation.
    #[allow(dead_code)] // TODO: temporary, pending more support for computing array dimensions
    pub fn symbol_vals(&self) -> Result<Vec<ValueRange<'ctx, '_, 'val>>> {
        let optional_vec = self.0.iter().map(|d| d.value_range()).collect::<Result<Vec<_>>>()?;
        Ok(optional_vec.into_iter().flatten().collect())
    }

    /// If `self` is empty, return `base_type`. Otherwise, create [ArrayType] by
    /// converting the dimension circom [Expressions](Expression) to LLZK Attributes.
    pub fn type_from_dimension_exprs(&self, base_type: Type<'ctx>) -> Type<'ctx> {
        if self.is_empty() {
            base_type
        } else {
            self.new_array_type(&base_type).into()
        }
    }

    /// Create an LLZK operation that produces a nondeterministic `felt.type` value of the given
    /// `dimensions` (non-array scalar if empty).
    #[inline]
    pub fn new_nondet_felt_of_dimensions_at_location(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<Operation<'ctx>> {
        codegen.new_nondet_at_location(
            location,
            self.type_from_dimension_exprs(codegen.felt_type().into()),
        )
    }

    /// Create an LLZK operation that produces a nondeterministic `felt.type` value of the given
    /// `dimensions` (non-array scalar if empty).
    #[inline]
    pub fn new_nondet_felt_of_dimensions(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        meta: &Meta,
    ) -> Result<Operation<'ctx>> {
        self.new_nondet_felt_of_dimensions_at_location(codegen, codegen.location_from_meta(meta))
    }

    /// If `dimensions` is empty, returns a [`StructType`] with just the name. Otherwise,
    /// returns a [`StructType`] with parameters by converting the
    /// dimension circom Expressions to LLZK Attributes.
    pub fn struct_type_with_concrete_dimensions(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        name: &str,
    ) -> StructType<'ctx> {
        if self.is_empty() {
            codegen.struct_type(name)
        } else {
            codegen.struct_type_with_params(name, &self.attrs())
        }
    }
}

impl<'ctx> IntoIterator for &ArrayDimensions<'ctx, '_> {
    type Item = Attribute<'ctx>;

    type IntoIter = <Vec<Attribute<'ctx>> as IntoIterator>::IntoIter;

    fn into_iter(self) -> Self::IntoIter {
        self.attrs().into_iter()
    }
}

/// Constructs a new [ArrayDimensions] if all input [ArrayDimensionResult] are
/// [ArrayDimensionResult::Computed], returns [Err] otherwise.
impl<'ctx, 'val> TryFrom<Vec<ArrayDimensionResult<'ctx, 'val>>> for ArrayDimensions<'ctx, 'val> {
    type Error = anyhow::Error;

    fn try_from(dim_results: Vec<ArrayDimensionResult<'ctx, 'val>>) -> Result<Self, Self::Error> {
        dim_results
            .into_iter()
            .map(ArrayDimension::try_from)
            .collect::<Result<Vec<_>>>()
            .map(ArrayDimensions)
    }
}

impl<'ctx, 'val, P: ProgramLike> TryFrom<(&[usize], &LlzkCodegen<'_, 'ctx, '_, P>)>
    for ArrayDimensions<'ctx, 'val>
{
    type Error = anyhow::Error;

    fn try_from(
        (dim_sizes, codegen): (&[usize], &LlzkCodegen<'_, 'ctx, '_, P>),
    ) -> Result<Self, Self::Error> {
        dim_sizes
            .iter()
            .map(|size| ArrayDimension::new(codegen.index_attr(i64::try_from(*size)?).into(), &[]))
            .collect::<Result<Vec<_>>>()
            .map(ArrayDimensions)
    }
}

/// Determines where newly created [`TemplateSymbolBindingOp`]s are stored during code generation.
pub trait PolyBindingStorageStrategy<'ctx, P: ProgramLike>: std::fmt::Debug {
    /// Returns `true` if a binding with the given name has already been stored.
    fn contains_name(&self, name: &str) -> bool;

    /// Stores the given op and returns its (possibly uniqued) name attribute.
    fn store(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, P>,
        op: TemplateSymbolBindingOp<'ctx>,
    ) -> StringAttribute<'ctx>;

    /// Converts this boxed strategy into a [`PendingPolyBindings`], if that is the concrete type.
    fn into_pending(self: Box<Self>) -> Option<PendingPolyBindings<'ctx>> {
        None
    }
}

/// Accumulates [`TemplateSymbolBindingOp`]s during declaration processing so they can be
/// bulk-inserted into the template region after it is created.
#[derive(Debug, Default)]
pub struct PendingPolyBindings<'ctx> {
    /// Maps base name to last suffix used for that name.
    uniquer: RefCell<HashMap<String, usize>>,
    /// List of all uniquely named symbol bindings generated so far, to be inserted
    /// into the template once it's created.
    new_sym_bindings: RefCell<Vec<TemplateSymbolBindingOp<'ctx>>>,
}

impl<'ctx> PendingPolyBindings<'ctx> {
    /// Removes and returns all accumulated symbol binding ops.
    pub fn take_bindings(&mut self) -> Vec<TemplateSymbolBindingOp<'ctx>> {
        self.new_sym_bindings.take()
    }
}

impl<'ctx, P: ProgramLike> PolyBindingStorageStrategy<'ctx, P> for PendingPolyBindings<'ctx> {
    fn contains_name(&self, name: &str) -> bool {
        self.uniquer.borrow().contains_key(name)
    }

    fn store(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, P>,
        op: TemplateSymbolBindingOp<'ctx>,
    ) -> StringAttribute<'ctx> {
        // Ensure the operation "sym_name" attribute is unique by appending a suffix if necessary.
        let base_name = op.sym_name().to_string();
        let mut uniq_map = self.uniquer.borrow_mut();
        let op = if uniq_map.contains_key(&base_name) {
            let counter = uniq_map[&base_name] + 1;
            uniq_map.insert(base_name.clone(), counter);
            let unique_name = StringAttribute::new(
                codegen.context,
                format!("{}_{}", base_name, counter).as_str(),
            );
            // `TemplateSymbolBindingOp` does not (currently) implement `OperationMutLike` directly,
            // so match on the inner variant to call `set_attribute` through the concrete type.
            match op {
                TemplateSymbolBindingOp::Param(mut inner) => {
                    inner.set_attribute("sym_name", unique_name.into());
                    TemplateSymbolBindingOp::Param(inner)
                }
                TemplateSymbolBindingOp::Expr(mut inner) => {
                    inner.set_attribute("sym_name", unique_name.into());
                    TemplateSymbolBindingOp::Expr(inner)
                }
            }
        } else {
            uniq_map.insert(base_name.clone(), 0);
            op
        };
        // Store the operation and return its unique name.
        let final_name = op.sym_name_attr();
        self.new_sym_bindings.borrow_mut().push(op);
        final_name
    }

    fn into_pending(self: Box<Self>) -> Option<PendingPolyBindings<'ctx>> {
        Some(*self)
    }
}

impl<'ctx, P: ProgramLike> PolyBindingStorageStrategy<'ctx, P> for TemplateOpRefMut<'ctx, '_> {
    fn contains_name(&self, name: &str) -> bool {
        self.has_const_param_named(name) || self.has_const_expr_named(name)
    }

    fn store(
        &self,
        _: &LlzkCodegen<'_, 'ctx, '_, P>,
        op: TemplateSymbolBindingOp<'ctx>,
    ) -> StringAttribute<'ctx> {
        insert_unique_symbol_op(self, op)
    }
}

/// A trait to generate array dimensions from the given dimension expressions.
pub trait DimExprConverter<'ctx, 'val>
where
    'ctx: 'val,
{
    /// Convert a circom [Expression] used as an array dimension to an LLZK Attribute.
    ///
    /// Returns an error if there was an error converting a dimension that should be convertible.
    /// Returns [ArrayDimensionResult::InsufficientData] if a dimension is not convertible due to
    /// lack of information in the implementer. Users can then attempt to resolve the dimension in a
    /// different context, or throw an error if all available contexts are unable to convert the
    /// dimension.
    fn get_dim_expr(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ArrayDimensionResult<'ctx, 'val>>;

    /// Computes the [ArrayDimensions] from the given `dimension_exprs`, returning:
    /// - An error if one of the underlying [Expression]s generated an error,
    /// - [None] if one generates [ArrayDimensionResult::InsufficientData],
    /// - [Some] otherwise
    fn get_dim_exprs_if_able(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        dimension_exprs: &[Expression],
    ) -> Result<Option<ArrayDimensions<'ctx, 'val>>> {
        let dim_result_vec = dimension_exprs
            .iter()
            .map(|e| self.get_dim_expr(codegen, e))
            .collect::<Result<Vec<_>>>()?; // propagate error
        Ok(ArrayDimensions::try_from(dim_result_vec).ok()) // insufficient -> None
    }

    /// Same as [DimExprConverter::get_dim_exprs_if_able], but converts [None] into an error.
    /// For cases where [ArrayDimensions] are expected to be generated and there are no fallback
    /// contexts to try.
    fn get_dim_exprs(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        dimension_exprs: &[Expression],
    ) -> Result<ArrayDimensions<'ctx, 'val>> {
        self.get_dim_exprs_if_able(codegen, dimension_exprs)?.ok_or_else(|| {
            anyhow!("unexpected lack of data needed to convert dimension expressions")
        })
    }

    /// Names of `poly.param` and `poly.expr` defs visible in the current context.
    fn poly_template_binding_names(
        &self,
    ) -> impl IntoIterator<Item = (String, Option<Type<'ctx>>)> {
        std::iter::empty()
    }

    /// Callback to store a `poly.expr` and `poly.param` operations generated on the fly.
    fn record_new_sym_binding(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        op: TemplateSymbolBindingOp<'ctx>,
    ) -> StringAttribute<'ctx> {
        codegen.binding_insert_strategy().unwrap().store(codegen, op)
    }

    /// Get the mapping of `var` name to declared LLZK type.
    fn get_var_decl_types(&self) -> &HashMap<String, Type<'ctx>>;

    /// Generate a new `poly.expr` operation for the given array dimension [Expression].
    fn gen_template_poly_expr(
        &self,
        codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
        target_expr: &Expression, // the result that should yield from the `poly.expr`
    ) -> Result<ArrayDimensionResult<'ctx, 'val>> {
        if codegen.config.verbose {
            println!("[gen_template_poly_expr] {target_expr:?}");
        }

        /// Fully generate LLZK for a single [Statement] in a `poly.expr` initializer without
        /// truncating at any target expression.
        fn gen_stmt_fully<'ctx, 'blk, 'val>(
            stmt: &Statement,
            codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
            gen_ctx: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
        ) -> Result<()>
        where
            'ctx: 'blk,
            'blk: 'val,
            'val: 'blk,
        {
            match stmt {
                Statement::Block { stmts, .. } => {
                    for s in stmts {
                        gen_stmt_fully(s, codegen, gen_ctx)?;
                    }
                }
                Statement::InitializationBlock { initializations, .. } => {
                    for s in initializations {
                        gen_stmt_fully(s, codegen, gen_ctx)?;
                    }
                }
                Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                    if VariableType::Var == *xtype {
                        // Use the pre-computed type from DeclarationInfo (seeded into the
                        // BlockContextStack root) to avoid triggering recursive
                        // gen_template_poly_expr calls for non-constant dimension expressions.
                        let qualified_key = format!("{}@{}", name, meta.start);
                        if let Some(ty) = gen_ctx.get_var_decl_types().get(&qualified_key) {
                            let op = codegen
                                .new_nondet_at_location(codegen.location_from_meta(meta), *ty)?;
                            gen_ctx.block_ctx.declare_name_ensure_not_present(name, op)?;
                        } else {
                            gen_ctx.gen_declaration(codegen, meta, name, dimensions)?;
                        }
                    }
                }
                Statement::Substitution { meta, var, access, op, rhe } => {
                    // Signal assignments don't affect var values so skip those.
                    if !op.is_signal_operator() {
                        gen_ctx.handle_substitution_stmt_nonsignal(
                            codegen,
                            InfoProviders::default(),
                            meta,
                            var,
                            access,
                            op,
                            rhe,
                        )?;
                    }
                }
                Statement::IfThenElse { meta, cond, if_case, else_case } => {
                    let location = codegen.location_from_meta(meta);
                    let cond_val = cond.gen_llzk_in_block(codegen, gen_ctx, Default::default())?;
                    let cond_bool = gen_ctx.cast_to_bool_if_needed(codegen, location, cond_val)?;
                    // Build then-branch NestedBlockInfo.
                    let mut then_info = NestedBlockInfo::default();
                    gen_ctx.block_ctx.push(then_info.block);
                    gen_stmt_fully(if_case, codegen, gen_ctx)?;
                    then_info.var_overwrites = gen_ctx.block_ctx.pop();
                    // Build else-branch NestedBlockInfo.
                    let mut else_info = NestedBlockInfo::default();
                    gen_ctx.block_ctx.push(else_info.block);
                    if let Some(ec) = else_case {
                        gen_stmt_fully(ec, codegen, gen_ctx)?;
                    }
                    else_info.var_overwrites = gen_ctx.block_ctx.pop();
                    gen_ctx.gen_scf_if_with_var_overwrites(
                        codegen, location, cond_bool, then_info, else_info,
                    )?;
                }
                Statement::While { .. } => {
                    todo!(
                        "[gen_stmt_fully] poly.expr depending on a while loop is not yet supported"
                    );
                }
                Statement::Assert { meta, arg } => {
                    let val = arg.gen_llzk_in_block(codegen, gen_ctx, Default::default())?;
                    gen_ctx.append_assert(codegen, codegen.location_from_meta(meta), val)?
                }
                Statement::LogCall { meta, .. } => {
                    codegen.emit_circom_warning(
                        meta,
                        "log calls are not currently supported in LLZK",
                        ReportCode::NotAllowedOperation,
                    );
                }
                Statement::Return { .. } => {
                    unreachable!("encountered return statement while computing array dimension")
                }
                _ => {}
            }
            Ok(())
        }

        /// Generate the `scf.if` for a [Statement::IfThenElse] boundary encountered while
        /// walking toward `target_expr`. The branch containing the target recursively calls
        /// `gen_up_to_target`; the other branch yields a `nondet` placeholder of the same type.
        #[allow(clippy::too_many_arguments)]
        fn gen_if_then_else_up_to_target<'ctx, 'blk, 'val>(
            codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
            gen_ctx: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
            target_expr: &Expression,
            trace: &[*const Statement],
            meta: &Meta,
            cond: &Expression,
            if_case: &Statement,
            else_case: &Option<Box<Statement>>,
        ) -> Result<Value<'ctx, 'val>>
        where
            'ctx: 'blk,
            'blk: 'val,
            'val: 'blk,
        {
            ensure!(
                !trace.is_empty(),
                "trace ended at IfThenElse; expected continuation into a branch"
            );
            let boundary_ptr: *const Statement = trace[0];

            let location = codegen.location_from_meta(meta);
            let cond_val = cond.gen_llzk_in_block(codegen, gen_ctx, Default::default())?;
            let cond_bool = gen_ctx.cast_to_bool_if_needed(codegen, location, cond_val)?;

            // Determine which branch contains the target by pointer identity.
            let target_in_then = std::ptr::eq(if_case, boundary_ptr);
            let containing_stmt = if target_in_then {
                if_case
            } else {
                let opt = else_case.as_deref();
                ensure!(
                    opt.is_some_and(|ec| std::ptr::eq(ec, boundary_ptr)),
                    "trace does not point to either branch of IfThenElse"
                );
                opt.expect("checked above")
            };

            // Generate the branch that contains the target, then a nondet placeholder for the
            // other branch (using the result type from the containing branch).
            let containing_arm_info = gen_ctx.gen_scf_if_arm_no_var_overwrites(location, |gc| {
                gen_up_to_target(
                    codegen,
                    gc,
                    target_expr,
                    std::slice::from_ref(containing_stmt),
                    trace,
                )
            })?;
            let result_type = containing_arm_info.1.r#type();
            let other_arm_info = gen_ctx.gen_scf_if_arm_no_var_overwrites(location, |gc| {
                gc.append_op_unnamed_result(codegen.new_nondet_at_location(location, result_type)?)
            })?;

            // Assemble the scf.if with regions in the correct order.
            let (then_arm_info, else_arm_info) = if target_in_then {
                (containing_arm_info, other_arm_info)
            } else {
                (other_arm_info, containing_arm_info)
            };
            gen_ctx.gen_safe_scf_if(
                codegen,
                location,
                cond_bool,
                then_arm_info,
                else_arm_info,
                Some(result_type),
            )
        }

        /// Generate LLZK for all of `stmts` up to the first [Statement] in the `trace` (i.e. the
        /// boundary). Then, pop the first [Statement] from the `trace` and, if applicable, descend
        /// into its nested body following the same proceedure. When the trace is exhausted,
        /// generate LLZK for the `target_expr` and return its result [Value].
        fn gen_up_to_target<'ctx, 'blk, 'val>(
            codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
            gen_ctx: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
            target_expr: &Expression,
            stmts: &[Statement],
            trace: &[*const Statement],
        ) -> Result<Value<'ctx, 'val>>
        where
            'ctx: 'blk,
            'blk: 'val,
            'val: 'blk,
        {
            assert!(!trace.is_empty(), "trace must not be empty in gen_up_to_target");
            let boundary_ptr: *const Statement = trace[0];
            let inner_trace = &trace[1..];

            // Generate all statements that precede the boundary, then find the boundary itself.
            let mut boundary_stmt: Option<&Statement> = None;
            for stmt in stmts {
                if std::ptr::eq(stmt, boundary_ptr) {
                    boundary_stmt = Some(stmt);
                    break;
                }
                gen_stmt_fully(stmt, codegen, gen_ctx)?;
            }
            let boundary_stmt = boundary_stmt.ok_or_else(|| {
                anyhow!("statement trace boundary not found in current stmts slice")
            })?;

            // Process the boundary statement (the one on the trace path).
            match boundary_stmt {
                Statement::Block { stmts, .. } => {
                    gen_up_to_target(codegen, gen_ctx, target_expr, stmts, inner_trace)
                }
                Statement::InitializationBlock { initializations, .. } => {
                    gen_up_to_target(codegen, gen_ctx, target_expr, initializations, inner_trace)
                }
                Statement::IfThenElse { meta, cond, if_case, else_case } => {
                    gen_if_then_else_up_to_target(
                        codegen,
                        gen_ctx,
                        target_expr,
                        inner_trace,
                        meta,
                        cond,
                        if_case,
                        else_case,
                    )
                }
                Statement::While { .. } => {
                    todo!("[gen_up_to_target] poly.expr depending on a while loop is not yet supported");
                }
                _ => {
                    assert!(inner_trace.is_empty(), "trace should end at a leaf statement");
                    // Leaf: this boundary statement directly contains `target_expr` in its
                    // dimensions. Generate the target expression in the current block context.
                    target_expr.gen_llzk_in_block(codegen, gen_ctx, Default::default())
                }
            }
        }

        //////////////////////////////////////////////////////////////////////////////////////////
        // Generate `poly.expr` and fill its initializer region.
        let name = dim_expr_name(target_expr);
        let location = codegen.location_from_meta(target_expr.get_meta());
        let expr_op = poly::expr(location, &name, std::iter::empty())?;
        let mut expr_gen_ctx = BlockGenContext::new(
            BlockContextStack::new(
                expr_op.initializer_region().first_block().expect("block should have been added"),
            ),
            self.get_var_decl_types(),
            self.poly_template_binding_names(),
        )
        .with_poly_template_binding_locals(codegen, location)?;
        let body_opt = codegen.current_body();
        assert!(body_opt.is_some(), "should have been set at top level");
        let trace = codegen.snapshot_statement_trace();
        let val =
            gen_up_to_target(codegen, &mut expr_gen_ctx, target_expr, body_opt.unwrap(), &trace)?;
        expr_gen_ctx.append_op_no_result(poly::r#yield(location, val)?.into())?;

        // Run cleanup passes to simplify and normalize the generated code a bit:
        // - remove-dead-values: drop ops whose results are not used
        // - sccp: constant fold and propagate values
        // - canonicalize: mainly to remove unused `llzk.nondet` (which `remove-dead-values` cannot
        //   remove due to memory effects) but also folds felt constants, etc.
        // This cleanup is not simply an optimization. In some cases, an `llzk.nondet` may be
        // generated that references a symbol defined by a different `poly.expr` due to the way
        // array declaration and initialization are split up in the circom AST. This is illegal
        // in LLZK but that `llzk.nondet` result value is unused so it can be removed.
        codegen.run_pass_pipeline_on(
            "any(composite-fixed-point-pass{pipeline=\"canonicalize,sccp,remove-dead-values\"})",
            &expr_op,
        )?;

        let uniqued_name = self.record_new_sym_binding(codegen, expr_op.into());
        // Have to convert the StringAttribute to FlatSymbolRefAttribute before returning it.
        ArrayDimensionResult::new(codegen.flat_sym(uniqued_name.value()).into(), &[])
    }
}

/// Maps the inner type of the given type if it is an [`ArrayType`]. Returns the new type
/// otherwise.
///
/// ```text
/// map([T], O) -> [O]
/// map(T, O) -> O
/// ```
pub fn map_array_inner_type<'ctx>(t: Type<'ctx>, new_inner: Type<'ctx>) -> Type<'ctx> {
    ArrayType::try_from(t).map(|t| ArrayType::new(new_inner, &t.dims()).into()).unwrap_or(new_inner)
}
/// Returns a new region that is empty.
#[inline]
pub fn new_region_empty<'ctx>() -> Region<'ctx> {
    Region::new()
}

/// Returns a new region that contains the given block.
#[inline]
pub fn new_region<'ctx: 'blk, 'blk>(b: Block<'ctx>) -> (Region<'ctx>, BlockRef<'ctx, 'blk>) {
    let r = new_region_empty();
    let b = r.append_block(b);
    (r, b)
}

/// Returns a new region that contains one block with the given arguments.
#[inline]
pub fn new_region_and_block<'ctx: 'blk, 'blk>(
    arguments: &[(Type<'ctx>, Location<'ctx>)],
) -> (Region<'ctx>, BlockRef<'ctx, 'blk>) {
    new_region(Block::new(arguments))
}

/// Returns the type of a subcomponent as defined in its memory.
pub fn comp_type<'ctx>(pod: PodType<'ctx>) -> Result<Type<'ctx>> {
    pod.get_type_of_record(COMP)
        .ok_or_else(|| anyhow::anyhow!("missing {COMP} record in memory struct: {pod:?}"))
}

/// Generate a stable name for a dimension expression, suitable for use as a `poly.expr` name.
///
/// The generated name uniquely represents the expression structure so that the same expression
/// always maps to the same name, enabling deduplication of `poly.expr` ops.
pub fn dim_expr_name(expr: &Expression) -> String {
    fn visit(expr: &Expression) -> String {
        match expr {
            Expression::Number(_, n) => n.to_string(),
            Expression::Variable { name, access, .. } => {
                if access.is_empty() {
                    name.clone()
                } else {
                    // Reuse `Lvalue` string format but drop the "Var:" prefix.
                    Lvalue::new(name, Root::Var, access)
                        .to_string()
                        .trim_start_matches("Var:")
                        .to_string()
                }
            }
            Expression::InfixOp { lhe, infix_op, rhe, .. } => {
                format!("{}_{infix_op:?}_{}", visit(lhe), visit(rhe))
            }
            Expression::PrefixOp { prefix_op, rhe, .. } => {
                format!("{prefix_op:?}_{}", visit(rhe))
            }
            Expression::InlineSwitchOp { cond, if_true, if_false, .. } => {
                format!("{}?{}:{}", visit(cond), visit(if_true), visit(if_false))
            }
            Expression::Call { id, args, .. } => {
                format!("{id}({})", args.iter().map(visit).collect::<Vec<_>>().join(","))
            }
            _ => unreachable!("dimension expression must produce a scalar value"),
        }
    }
    // Add starting location of the expression to the name to ensure (**assuming Meta information
    // is accurate**) context sensitivity (i.e. expressions at different code locations may have a
    // different value store and thus should be treated as different values).
    format!("{}@{}", visit(expr), expr.get_meta().start)
}

/// Get the `sym_name` attribute from the operation, if present.
///
/// TODO: llzk-rs should provide this function.
pub fn get_sym_name_attr<'c: 'a, 'a>(
    op: &impl OperationLike<'c, 'a>,
) -> Result<StringAttribute<'c>> {
    op.attribute("sym_name").and_then(StringAttribute::try_from).map_err(Into::into)
}

/// Insert a new symbol operation into the symbol table owned by `sym_table_op`. The inserted symbol
/// is renamed automatically if necessary to avoid collisions. Ownership of `new_symbol_op` is
/// transferred to the symbol table. Return the (possibly renamed) symbol name.
pub fn insert_unique_symbol_op<'c: 'a, 'a>(
    sym_table_op: &impl OperationLike<'c, 'a>,
    new_symbol_op: impl Into<Operation<'c>>,
) -> StringAttribute<'c> {
    get_sym_name_attr(&symbol_table::insert(sym_table_op, new_symbol_op.into()))
        .expect("Symbol ops must have `sym_name` attribute per ODS")
}

/// Print a single operation using "assume verified" flag to avoid verification errors on
/// in-progress IR.
///
/// TODO: llzk-rs should provide this function.
#[allow(unused)]
pub fn print_operation<'c: 'a, 'a>(op: &impl OperationLike<'c, 'a>) {
    // Melior does not currently have a wrapper for `mlirOpPrintingFlagsAssumeVerified()`
    unsafe extern "C" fn collect(s: mlir_sys::MlirStringRef, user_data: *mut c_void) {
        let out = &mut *(user_data as *mut String);
        let slice = std::slice::from_raw_parts(s.data as *const u8, s.length);
        out.push_str(std::str::from_utf8_unchecked(slice));
    }
    let mut buf = String::new();
    unsafe {
        let flags = mlir_sys::mlirOpPrintingFlagsCreate();
        mlir_sys::mlirOpPrintingFlagsAssumeVerified(flags);
        mlir_sys::mlirOperationPrintWithFlags(
            op.to_raw(),
            flags,
            Some(collect),
            &mut buf as *mut String as *mut c_void,
        );
        mlir_sys::mlirOpPrintingFlagsDestroy(flags);
    }
    println!("{buf}");
}

/// Print all operations in a block using [`print_operation`].
///
/// TODO: llzk-rs should provide this function.
#[allow(unused)]
pub fn print_block<'c: 'a, 'a>(block: &impl BlockLike<'c, 'a>) {
    let mut op = block.first_operation();
    while let Some(o) = op {
        print_operation(&o);
        op = o.next_in_block();
    }
}

/// Print all blocks (and their operations) in a region using [`print_block`].
///
/// TODO: llzk-rs should provide this function.
#[allow(unused)]
pub fn print_region<'c: 'a, 'a>(region: &impl RegionLike<'c, 'a>) {
    let mut block = region.first_block();
    while let Some(b) = block {
        print_block(&b);
        block = b.next_in_region();
    }
}

/// Build a `function.call` operation using [`OperationBuilder`], supporting the optional
/// `templateParams` attribute for calling functions inside `poly.template` regions when
/// template parameters are not bound by the call's argument or result types.
///
/// TODO: llzk-rs should provide this function (or even more general with map operands too).
pub(crate) fn build_func_call_with_template_params<'c>(
    context: &'c LlzkContext,
    location: Location<'c>,
    callee: SymbolRefAttribute<'c>,
    args: &[Value<'c, '_>],
    result_types: &[Type<'c>],
    template_params: Option<&[Attribute<'c>]>,
) -> Result<Operation<'c>> {
    use melior::ir::attribute::ArrayAttribute;
    use melior::ir::attribute::DenseI32ArrayAttribute;
    use melior::ir::operation::OperationBuilder;
    use melior::ir::Identifier;

    let ctx = &**context;
    let arg_count = i32::try_from(args.len()).expect("arg count too large");
    let mut attrs = vec![
        (Identifier::new(ctx, "callee"), callee.into()),
        (Identifier::new(ctx, "mapOpGroupSizes"), DenseI32ArrayAttribute::new(ctx, &[]).into()),
        (
            Identifier::new(ctx, "operandSegmentSizes"),
            DenseI32ArrayAttribute::new(ctx, &[arg_count, 0]).into(),
        ),
    ];
    if let Some(params) = template_params {
        attrs.push((
            Identifier::new(ctx, "templateParams"),
            ArrayAttribute::new(ctx, params).into(),
        ));
    }
    OperationBuilder::new("function.call", location)
        .add_attributes(&attrs)
        .add_operands(args)
        .add_results(result_types)
        .build()
        .map_err(Into::into)
}

/// Returns the operations that use the given value.
///
/// TODO: llzk-rs should provide this function.
pub fn users_of<'ctx: 'a, 'a>(value: impl ValueLike<'ctx> + Copy) -> Vec<OperationRef<'ctx, 'a>> {
    let mut users = Vec::new();
    // SAFETY: MLIR owns the value use-list and the owning operations. This helper only walks the
    // list and creates non-owning references while the surrounding module is still alive.
    // Use C API directly since `llzk-rs` does not expose a safe iterator over value uses.
    unsafe {
        let mut op_use = mlir_sys::mlirValueGetFirstUse(value.to_raw());
        while !op_use.ptr.is_null() {
            users.push(OperationRef::from_raw(mlir_sys::mlirOpOperandGetOwner(op_use)));
            op_use = mlir_sys::mlirOpOperandGetNextUse(op_use);
        }
    }
    users
}
