//! Handles function-level LLZK code generation for both free functions and functions within
//! structs. The [FunctionContext] carries information about the current LLZK function
//! being generated and some helpers related to generating code within the function. The
//! [GenerateLLZKInFunction] trait provides the visitor to generate LLZK IR for all circom
//! [Expression](program_structure::abstract_syntax_tree::ast::Expression) and
//! [Statement](program_structure::abstract_syntax_tree::ast::Statement) nodes.

use crate::function::felt::is_felt_type;
use crate::function_ext::FunctionLike;
use crate::gen_context::BlockContextStack;
use crate::gen_context::GenWithCircomScopeHandling;
use crate::gen_context::NestedBlockInfo;
use crate::lvalue::Lvalue;
use crate::lvalue::Root;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::insert_after_if_op_result;
use crate::shared::is_bool;
use crate::shared::is_index;
use crate::shared::new_array_type;
use crate::shared::next_in_block_mut;
use crate::shared::no_results;
use crate::shared::parent_operation_mut;
use crate::shared::region_with_block;
use crate::shared::remove_from_parent;
use crate::shared::replace_uses_with_new_block_argument;
use crate::shared::set_operand_if_undef;
use crate::shared::single_result_as_value;
use crate::shared::ArrayDimension;
use crate::shared::ArrayDimensionResult;
use crate::shared::DimExprConverter;
use crate::shared::LlzkCodegen;
use crate::subcmp::names::COUNT;
use crate::subcmp::SubcmpCallsMap;
use crate::subcmp::SubcmpInfo;
use crate::template::TemplateContext;
use crate::template_ext::TemplateLike as _;
use crate::try_for_loop_heuristic;
use crate::write_chain::SignalWriteInfo;
use anyhow::anyhow;
use anyhow::Context as _;
use anyhow::Result;
use llzk::builder::OpBuilder;
use llzk::dialect::array::ArrayCtor;
use llzk::dialect::cast;
use llzk::dialect::undef;
use llzk::operation::erase_op;
use llzk::operation::WalkOperationMutLike;
use llzk::prelude::array;
use llzk::prelude::bool;
use llzk::prelude::felt;
use llzk::prelude::function;
use llzk::prelude::function::is_func_def;
use llzk::prelude::function::is_func_return;
use llzk::prelude::melior_dialects::arith;
use llzk::prelude::melior_dialects::index;
use llzk::prelude::melior_dialects::scf;
use llzk::prelude::melior_dialects::scf::is_scf_if;
use llzk::prelude::melior_dialects::scf::is_scf_yield;
use llzk::prelude::pod;
use llzk::prelude::ArrayType;
use llzk::prelude::Attribute;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::BlockRef;
use llzk::prelude::FlatSymbolRefAttribute;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::FuncDefOpRefMut;
use llzk::prelude::IntegerAttribute;
use llzk::prelude::Location;
use llzk::prelude::LoopBoundsAttribute;
use llzk::prelude::Operation;
use llzk::prelude::OperationLike as _;
use llzk::prelude::OperationMutLike;
use llzk::prelude::OperationRef;
use llzk::prelude::OperationRefMut;
use llzk::prelude::PodType;
use llzk::prelude::Region;
use llzk::prelude::RegionLike as _;
use llzk::prelude::StructType;
use llzk::prelude::SymbolRefAttribute;
use llzk::prelude::Type;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use llzk::prelude::WalkOrder;
use llzk::prelude::WalkResult;
use llzk::value_ext::has_uses;
use melior::dialect::ods::math;
use num_bigint_dig::BigInt;
use num_traits::Zero;
use program_structure::ast::Access;
use program_structure::ast::Expression;
use program_structure::ast::ExpressionInfixOpcode;
use program_structure::ast::ExpressionPrefixOpcode;
use program_structure::ast::Meta;
use program_structure::ast::Statement;
use program_structure::ast::VariableType;
use program_structure::error_code::ReportCode;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::convert::TryInto;
use std::ops::Deref;
use std::ops::DerefMut;

/// Special variable name used to reference the return Value throughout the
/// conversion of circom return locations to LLZK return locations.
const VAR_NAME_RETURN_VAL: &str = "**return_val**";
/// Special variable name used to reference the status of whether or not a circom block
/// had a `return` when translating to an LLZK block that cannot contain a `return`.
const VAR_NAME_HAD_RETURN: &str = "**had_return**";
/// LLZK attribute used to mark yield/return ops generated from circom return statements.
const CIRCOM_RETURN_MARKER_ATTR: &str = "from_circom_return";
/// LLZK attribute used to attach comma-separated list of variable names for the operands
/// of an `scf.yield` op.
const OPERAND_VAL_NAMES: &str = "operand_val_names";

/// Contains references to information providers.
///
/// This information is required by [`Lvalue`] for properly constructing the IR representing the
/// read in the case of subcomponents. The information it needs is:
/// - Is the variable a subcomponent?
/// - Is the field read with dot-notation an input or an output?
///
/// To answer that information it needs the [`TemplateContext`] since subcomponents can only occur
/// inside a template. However, the logic in this file lowers [expressions](Expression) in both
/// functions and templates so is necessary to provide that information in such a way that is
/// transparent to that.
///
/// This type holds dyn references to two traits that give just enough information necessary for
/// lowering using [`Lvalue`]. Both traits are implemented by [`TemplateContext`] and by a couple
/// [Null objects](https://en.wikipedia.org/wiki/Null_object_pattern). The former is used while
/// lowering expressions inside a template and the latter used while lowering inside a function.
#[derive(Copy, Clone, Debug)]
pub struct InfoProviders<'info> {
    /// Subcomponent information.
    pub subcmp_info: &'info dyn SubcmpInfo,
    /// Signals write information.
    ///
    /// We may be able to remove this field if the lowering in this file does not need to use
    /// `WriteChain`. Since that type aims to be generic it may be reusable in the context of
    /// lowering freestanding functions, in which case it needs an empty implementation of this
    /// interface. This field is already here in preparation for reusing WriteChain.
    pub signal_write_info: &'info dyn SignalWriteInfo,
}

impl<'tmpl, 'ctx, 'str, 'func, 'blk, 'val>
    From<&'tmpl TemplateContext<'ctx, 'str, 'func, 'blk, 'val>> for InfoProviders<'tmpl>
{
    fn from(template: &'tmpl TemplateContext<'ctx, 'str, 'func, 'blk, 'val>) -> Self {
        Self { subcmp_info: template, signal_write_info: template }
    }
}

/// Stores ref to the current function while generating LLZK IR for the function.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
#[derive(Debug)]
pub struct FunctionContext<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// The function reference.
    pub(crate) func: FuncDefOpRefMut<'ctx, 'func>,
    /// Nested block context within the function.
    pub(crate) block_ctx: BlockContextStack<'ctx, 'blk, 'val>,
    /// Calls to subcomponents
    pub(crate) subcmp_calls: SubcmpCallsMap<'ctx>,
}

/// Cache block yield/return result value while performing early-return refactoring.
enum RefactoringBlockResultType<'ctx> {
    /// Single result value from the block.
    Single(Type<'ctx>),
    /// Multiple result values from the block with `OPERAND_VAL_NAMES` attribute.
    Multiple(Vec<Type<'ctx>>, Attribute<'ctx>),
}

impl<'ctx> RefactoringBlockResultType<'ctx> {
    /// Get the number of result values.
    fn len(&self) -> usize {
        match self {
            RefactoringBlockResultType::Single(_) => 1,
            RefactoringBlockResultType::Multiple(types, _) => types.len(),
        }
    }

    /// Get the result types.
    fn result_types(&self) -> &[Type<'ctx>] {
        match self {
            RefactoringBlockResultType::Single(ty) => std::slice::from_ref(ty),
            RefactoringBlockResultType::Multiple(types, _) => types,
        }
    }

    /// Get name [Attribute] if multiple result types.
    fn name_attr(&self) -> Option<Attribute<'ctx>> {
        match self {
            RefactoringBlockResultType::Single(_) => None,
            RefactoringBlockResultType::Multiple(_, attr) => Some(*attr),
        }
    }

    /// Generate an [scf::yield] operation with the given values and location, propagating the
    /// `name_attr` from `self` if applicable.
    fn gen_yield(&self, values: &[Value<'ctx, '_>], location: Location<'ctx>) -> Operation<'ctx> {
        assert_eq!(values.len(), self.len(), "requires one value per result");
        let mut new_yield = scf::r#yield(values, location);
        if let Some(names_attr) = self.name_attr() {
            new_yield.set_attribute(OPERAND_VAL_NAMES, names_attr);
        }
        new_yield
    }
}

impl<'ctx, 'func, 'blk, 'val> FunctionContext<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Create a new [FunctionContext] for the given function with an initial name-to-value mapping.
    pub fn new<'ast, const FREE_FUNC: bool>(
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        func: FuncDefOpRefMut<'ctx, 'func>,
        param_name_to_value: HashMap<String, Value<'ctx, 'val>>,
    ) -> Result<Self> {
        let mut block_ctx = BlockContextStack::new(func.deref(), param_name_to_value)?;
        if FREE_FUNC {
            // Ensure the specially-named values are declared in free functions.
            block_ctx.declare_name_if_not_present(VAR_NAME_RETURN_VAL, || {
                // Get the result type from the free function. It supports exactly 1.
                let ty = func.get_function_type_attribute()?;
                assert_eq!(ty.result_count(), 1);
                codegen.new_nondet_at_location(codegen.location_unknown(), ty.result(0)?)
            })?;
            block_ctx.declare_name_if_not_present(VAR_NAME_HAD_RETURN, || {
                codegen
                    .new_nondet_at_location(codegen.location_unknown(), codegen.bool_type().into())
            })?;
        }
        Ok(Self { func, block_ctx, subcmp_calls: Default::default() })
    }

    /// Get the return type of the function.
    pub fn return_type(&self) -> Type<'ctx> {
        self.func
            .get_function_type_attribute()
            .expect("`function_type` attr must exist")
            .result(0)
            .expect("LLZK function must return a single result")
    }

    /// Append an operation.
    pub fn append_op(&mut self, op: Operation<'ctx>) -> OperationRef<'ctx, 'val> {
        self.block_ctx.append_current_block(op)
    }

    /// Append an operation that must produce no results.
    pub fn append_op_no_result(&mut self, op: Operation<'ctx>) -> Result<()> {
        no_results(self.append_op(op))
    }

    /// Append an operation that must produce a single result and is NOT associated with a variable
    /// name in the circom code.
    pub fn append_op_unnamed_result(&mut self, op: Operation<'ctx>) -> Result<Value<'ctx, 'val>> {
        single_result_as_value(self.append_op(op))
    }

    /// Append an operation that must produce a single result and store the mapping of the circom
    /// variable name to the result Value.
    pub fn append_op_named_result(
        &mut self,
        op: Operation<'ctx>,
        name: String,
    ) -> Result<Value<'ctx, 'val>> {
        let v = self.append_op_unnamed_result(op)?;
        self.block_ctx.set_named_value(name, v)?;
        Ok(v)
    }

    /// Generate and append an op to carry the value from a circom return statement. It will
    /// generate a return op if the context stack height is 1, otherwise a yield op. In either
    /// case, it is marked with the [CIRCOM_RETURN_MARKER_ATTR] attribute.
    pub fn append_circom_return<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        value: Value<'ctx, 'val>,
    ) -> Result<()> {
        let mut op = if self.block_ctx.is_only_root() {
            let value = self.cast_to_return_type_if_needed(codegen, location, value)?;
            function::r#return(location, &[value])
        } else {
            scf::r#yield(&[value], location)
        };
        op.set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
        self.append_op_no_result(op)
    }

    /// Generate an `array.write` or `array.insert` operation appropriate for the number of indices
    /// and the [ArrayType] of the `arr_ref` value.
    pub fn append_array_write(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        arr_ref: Value<'ctx, 'val>,
        indices: &[Value<'ctx, 'val>],
        location: Location<'ctx>,
        rvalue: Value<'ctx, 'val>,
        var_name: Option<&str>,
    ) -> Result<()> {
        let arr_ty = ArrayType::try_from(arr_ref.r#type()).with_context(|| {
            let v = var_name.map_or(String::from("array"), |s| format!("'{}'", s));
            format!("Conflicting types to write {v} at {location}")
        })?;
        let arr_ty_dims = arr_ty.dims();
        let write_op = match indices.len().cmp(&arr_ty_dims.len()) {
            std::cmp::Ordering::Equal => {
                // Indexing all dimensions requires an `array.write`
                let rvalue = self.cast_to_expected_type_if_needed(
                    codegen,
                    location,
                    rvalue,
                    arr_ty.element_type(),
                )?;
                array::write(location, arr_ref, indices, rvalue)
            }
            std::cmp::Ordering::Less => {
                // Indexing a subset of dimensions requires an `array.insert`
                array::insert(location, arr_ref, indices, rvalue)
            }
            std::cmp::Ordering::Greater => {
                let v = var_name.map_or(String::from("array"), |s| format!("'{}'", s));
                anyhow::bail!("Too many indices to write {v} at {location}");
            }
        };
        self.append_op_no_result(write_op)
    }

    /// Generate an `array.read` or `array.extract` operation appropriate for the number of indices
    /// and the [ArrayType] of the `arr_ref` value.
    pub fn append_array_read(
        &mut self,
        arr_ref: Value<'ctx, 'val>,
        indices: &[Value<'ctx, 'val>],
        location: Location<'ctx>,
        var_name: Option<&str>,
    ) -> Result<Value<'ctx, 'val>> {
        let arr_ty = ArrayType::try_from(arr_ref.r#type()).with_context(|| {
            let v = var_name.map_or(String::from("array"), |s| format!("'{}'", s));
            format!("Conflicting types to read {v} at {location}")
        })?;
        let arr_ty_dims = arr_ty.dims();
        let array_get_op = match indices.len().cmp(&arr_ty_dims.len()) {
            std::cmp::Ordering::Equal => {
                // Indexing all dimensions requires an `array.read`
                array::read(location, arr_ty.element_type(), arr_ref, indices)
            }
            std::cmp::Ordering::Less => {
                // Indexing a subset of dimensions requires an `array.extract`
                let reduced_dims: Vec<_> =
                    arr_ty_dims.iter().skip(indices.len()).copied().collect();
                let reduced_type = ArrayType::new(arr_ty.element_type().into(), &reduced_dims);
                array::extract(location, reduced_type.into(), arr_ref, indices)
            }
            std::cmp::Ordering::Greater => {
                let v = var_name.map_or(String::from("array"), |s| format!("'{}'", s));
                anyhow::bail!("Too many indices to read {v} at {location}");
            }
        };
        self.append_op_unnamed_result(array_get_op)
    }

    /// Create a cast to felt (field element) type if the given value is not already a felt.
    #[inline]
    pub fn cast_to_felt_if_needed(
        &mut self,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        if !is_felt_type(val.r#type()) {
            self.append_op_unnamed_result(cast::tofelt(location, val))
        } else {
            Ok(val)
        }
    }

    /// Create a cast to index type if the given value is not already an index.
    #[inline]
    pub fn cast_to_index_if_needed(
        &mut self,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        if !is_index(val.r#type()) {
            self.append_op_unnamed_result(cast::toindex(location, val).into())
        } else {
            Ok(val)
        }
    }

    /// Create a cast to bool type (i1) if the given value is not already a bool.
    #[inline]
    pub fn cast_to_bool_if_needed<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // The conversion to bool is simply to check `!=0` which is the same as
        // `normalize()` in `modular_arithmetic.rs`.
        if is_felt_type(val.r#type()) {
            let zero = self
                .append_op_unnamed_result(codegen.new_felt_const_op(&BigInt::zero(), location)?)?;
            self.append_op_unnamed_result(bool::ne(location, val, zero)?)
        } else if is_index(val.r#type()) {
            let zero = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
            self.append_op_unnamed_result(index::cmp(
                codegen.context,
                arith::CmpiPredicate::Ne,
                val,
                zero,
                location,
            ))
        } else {
            assert!(is_bool(val.r#type()));
            Ok(val)
        }
    }

    /// Create an op to cast `val` to match the `expected` type.
    #[inline]
    pub fn cast_to_expected_type_if_needed<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
        expected: Type<'ctx>,
    ) -> Result<Value<'ctx, 'val>> {
        if expected == val.r#type() {
            Ok(val)
        } else if is_felt_type(expected) {
            self.cast_to_felt_if_needed(location, val)
        } else if is_index(expected) {
            self.cast_to_index_if_needed(location, val)
        } else if is_bool(expected) {
            self.cast_to_bool_if_needed(codegen, location, val)
        } else {
            anyhow::bail!(
                "Unsupported 'expected' type '{expected}' with value type {}",
                val.r#type()
            )
        }
    }

    /// Create an op to cast `val` to match the return type of the function.
    #[inline]
    pub fn cast_to_return_type_if_needed<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        val: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        self.cast_to_expected_type_if_needed(codegen, location, val, self.return_type())
    }

    /// Generates a list of undef ops inside the given function context.
    #[inline]
    pub fn gen_arg_undefs(
        &mut self,
        args: &[Type<'ctx>],
        loc: Location<'ctx>,
    ) -> Result<Vec<Value<'ctx, 'val>>> {
        args.iter().copied().map(|t| self.append_op_unnamed_result(undef::undef(loc, t))).collect()
    }

    /// Searches for the argument index of a subcomponent's signal.
    pub fn lookup_arg_idx(
        &self,
        subcmp_signal: &str,
        subcmp_value: &Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<usize> {
        let name = self.subcmp_calls.get(subcmp_value).ok_or_else(|| {
            anyhow::anyhow!(
                "template constructed by {subcmp_value}@{:?} not found (map: {:?})",
                subcmp_value.to_raw().ptr,
                self.subcmp_calls
            )
        })?;
        let template_data = codegen.find_template_data(name).ok_or_else(|| {
            anyhow::anyhow!("template with name {name:?} constructed by {subcmp_value} not found")
        })?;
        template_data.get_declaration_input_idx(subcmp_signal)
    }

    /// Assigns the `rhe` value to the given subcomponent signal.
    ///
    /// The subcomponent is determined by
    /// `var`, which must correspond to a named value in the current scope.
    /// Since the subcomponent's call is different depending on the current function the
    /// `get_call` callback needs to return the operation representing the call from the value
    /// representing the subcomponent.
    pub fn assign_subcmp<'op>(
        &mut self,
        rhe: Value<'ctx, 'val>,
        var: &str,
        subcmp_signal: &str,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        arg_offset: usize,
        get_call: impl FnOnce(Value<'ctx, 'val>) -> Result<OperationRef<'ctx, 'op>>,
    ) -> Result<()>
    where
        'ctx: 'op,
    {
        let subcmp_value = self.block_ctx.get_named_value(var)?;

        let arg_idx = self.lookup_arg_idx(subcmp_signal, subcmp_value, codegen)?;

        let call_op = get_call(*subcmp_value)?;
        set_operand_if_undef(call_op, arg_idx + arg_offset, rhe)?;
        insert_after_if_op_result(rhe, call_op)
    }

    /// Generate LLZK code in the current function for a circom prefix operation.
    pub fn gen_prefix_op<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        meta: &Meta,
        op: &ExpressionPrefixOpcode,
        rhs: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        let mut get_negative_idx = || {
            let zero = self.append_op_unnamed_result(index::constant(
                codegen.context,
                IntegerAttribute::new(rhs.r#type(), 0),
                codegen.location_from_meta(meta),
            ))?;
            self.append_op_unnamed_result(index::sub(zero, rhs, codegen.location_from_meta(meta)))
        };
        match op {
            ExpressionPrefixOpcode::Sub => {
                if is_felt_type(rhs.r#type()) {
                    return self.append_op_unnamed_result(felt::neg(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
                // For index negation, we need to subtract from zero.
                if shared::is_index(rhs.r#type()) {
                    return get_negative_idx();
                }
            }
            ExpressionPrefixOpcode::BoolNot => {
                if shared::is_bool(rhs.r#type()) {
                    return self.append_op_unnamed_result(bool::not(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
            }
            ExpressionPrefixOpcode::Complement => {
                if is_felt_type(rhs.r#type()) {
                    return self.append_op_unnamed_result(felt::bit_not(
                        codegen.location_from_meta(meta),
                        rhs,
                    )?);
                }
                // For index negation, we need to subtract one from the negative
                // value (for the identity that `~x == -x - 1`).
                if shared::is_index(rhs.r#type()) {
                    let negative_idx = get_negative_idx()?;
                    let one = self.append_op_unnamed_result(index::constant(
                        codegen.context,
                        IntegerAttribute::new(rhs.r#type(), 1),
                        codegen.location_from_meta(meta),
                    ))?;
                    return self.append_op_unnamed_result(index::sub(
                        negative_idx,
                        one,
                        codegen.location_from_meta(meta),
                    ));
                }
            }
        }
        let err_msg = format!(
            "Cannot generate LLZK for prefix {:?} with operand type '{}'",
            self,
            rhs.r#type()
        );
        codegen.emit_circom_error(meta, err_msg.as_str(), ReportCode::PrefixOperatorWithWrongTypes);
        Err(anyhow!(err_msg))
    }

    /// If both operands have types that match the respective filter predicates, generate the
    /// operation using the provided generator function and return the result, otherwise None.
    #[inline]
    fn gen_infix_op_if_types_are(
        &mut self,
        lhs_type_filter: impl FnOnce(Type) -> bool,
        rhs_type_filter: impl FnOnce(Type) -> bool,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
        op_gen_fn: impl FnOnce(&mut Self) -> Result<Operation<'ctx>>,
    ) -> Result<Option<Value<'ctx, 'val>>> {
        if lhs_type_filter(lhs.r#type()) && rhs_type_filter(rhs.r#type()) {
            let op_res = op_gen_fn(self)?;
            self.append_op_unnamed_result(op_res).map(Option::Some)
        } else {
            Ok(None)
        }
    }

    /// Generate LLZK code in the current function for an infix operation.
    pub fn gen_infix_op<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        meta: &Meta,
        op: &ExpressionInfixOpcode,
        lhs: Value<'ctx, 'val>,
        rhs: Value<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // Macro to handle the common pattern for type checks for op selection.
        macro_rules! try_callback_for_type {
            ($type_check:path, $cb:expr) => {{
                if let Some(result) =
                    self.gen_infix_op_if_types_are($type_check, $type_check, lhs, rhs, $cb)?
                {
                    return Ok(result);
                }
            }};
        }

        macro_rules! generic_op_callback {
            ($op_path:path) => {{
                |_| {
                    let loc = codegen.location_from_meta(meta);
                    $op_path(loc, lhs, rhs).map_err(Into::into)
                }
            }};
        }

        macro_rules! try_felt_op {
            ($op_path:path) => {{
                try_callback_for_type!(is_felt_type, generic_op_callback!($op_path));
            }};
        }

        macro_rules! try_bool_op {
            ($op_path:path) => {{
                let loc = codegen.location_from_meta(meta);
                let lhs = self.cast_to_bool_if_needed(codegen, loc, lhs)?;
                let rhs = self.cast_to_bool_if_needed(codegen, loc, rhs)?;
                return self.append_op_unnamed_result($op_path(loc, lhs, rhs)?);
            }};
        }

        macro_rules! try_index_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_index, |_| {
                    let loc = codegen.location_from_meta(meta);
                    Ok($op_path(lhs, rhs, loc))
                });
            }};
        }

        macro_rules! try_math_op {
            ($op_path:path) => {{
                try_callback_for_type!(shared::is_index, |_| {
                    let loc = codegen.location_from_meta(meta);
                    Ok(Operation::from($op_path(codegen.context, lhs, rhs, loc)))
                });
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For index operations that use felt:: module and simple index operations.
        macro_rules! try_felt_or_index_op {
            ($felt_op:path, $index_op:path) => {{
                try_felt_op!($felt_op);
                try_index_op!($index_op);
            }};
        }

        macro_rules! try_felt_or_math_op {
            ($felt_op:path, $math_op:path) => {{
                try_felt_op!($felt_op);
                try_math_op!($math_op);
            }};
        }

        // Macro to handle the common pattern for felt and index type checks.
        // For comparison operations that use bool:: module and index::cmpi.
        macro_rules! try_bool_cmp_op {
            ($bool_op:path, $cmp:ident) => {{
                try_felt_op!($bool_op);
                try_callback_for_type!(shared::is_index, |_| {
                    let loc = codegen.location_from_meta(meta);
                    Ok(index::cmp(codegen.context, arith::CmpiPredicate::$cmp, lhs, rhs, loc))
                });
            }};
        }

        match op {
            ExpressionInfixOpcode::Add => {
                try_felt_or_index_op!(felt::add, index::add);
            }
            ExpressionInfixOpcode::Sub => {
                try_felt_or_index_op!(felt::sub, index::sub);
            }
            ExpressionInfixOpcode::Mul => {
                try_felt_or_index_op!(felt::mul, index::mul);
            }
            ExpressionInfixOpcode::Div => {
                try_felt_or_index_op!(felt::div, index::divu);
            }
            ExpressionInfixOpcode::IntDiv => {
                try_felt_or_index_op!(felt::uintdiv, index::divu);
            }
            ExpressionInfixOpcode::Mod => {
                try_felt_or_index_op!(felt::umod, index::remu);
            }
            ExpressionInfixOpcode::Pow => {
                try_felt_or_math_op!(felt::pow, math::ipowi);
            }
            ExpressionInfixOpcode::ShiftL => {
                try_felt_or_index_op!(felt::shl, index::shl);
            }
            ExpressionInfixOpcode::ShiftR => {
                try_felt_or_index_op!(felt::shr, index::shru);
            }
            ExpressionInfixOpcode::LesserEq => {
                try_bool_cmp_op!(bool::le, Ule);
            }
            ExpressionInfixOpcode::GreaterEq => {
                try_bool_cmp_op!(bool::ge, Uge);
            }
            ExpressionInfixOpcode::Lesser => {
                try_bool_cmp_op!(bool::lt, Ult);
            }
            ExpressionInfixOpcode::Greater => {
                try_bool_cmp_op!(bool::gt, Ugt);
            }
            ExpressionInfixOpcode::Eq => {
                try_bool_cmp_op!(bool::eq, Eq);
            }
            ExpressionInfixOpcode::NotEq => {
                try_bool_cmp_op!(bool::ne, Ne);
            }
            ExpressionInfixOpcode::BoolOr => {
                try_bool_op!(bool::or);
            }
            ExpressionInfixOpcode::BoolAnd => {
                try_bool_op!(bool::and);
            }
            ExpressionInfixOpcode::BitOr => {
                try_felt_or_index_op!(felt::bit_or, index::or);
            }
            ExpressionInfixOpcode::BitAnd => {
                try_felt_or_index_op!(felt::bit_and, index::and);
            }
            ExpressionInfixOpcode::BitXor => {
                try_felt_or_index_op!(felt::bit_xor, index::xor);
            }
        }
        let err_msg = format!(
            "Cannot generate LLZK for infix {:?} with LHS type '{}' and RHS type '{}'",
            op,
            lhs.r#type(),
            rhs.r#type()
        );
        codegen.emit_circom_error(meta, err_msg.as_str(), ReportCode::InfixOperatorWithWrongTypes);
        Err(anyhow!(err_msg))
    }

    /// Create a new `scf.yield` op, in the given block, that yields multiple values with associated
    /// variable names. Create an [Attribute] containing comma-separated list of `value_names`
    /// and attach it to the `scf.yield` op using the [OPERAND_VAL_NAMES] attribute key.
    fn append_multi_operand_yield_to_block(
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        block: BlockRef<'ctx, 'val>,
        values: &[Value<'ctx, 'val>],
        value_names: &[String],
        location: Location<'ctx>,
    ) -> Result<()> {
        assert_eq!(values.len(), value_names.len(), "requires one name per value");
        let mut op = scf::r#yield(values, location);
        op.set_attribute(OPERAND_VAL_NAMES, codegen.list_to_attribute(value_names));
        no_results(block.append_operation(op))
    }

    /// Generate an `scf.if` op based on the given [NestedBlockInfo] for each branch and update the
    /// block context with the results of the `scf.if` op mapped to the given names.
    pub fn gen_scf_if<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        condition: Value<'ctx, 'val>,
        mut then_info: NestedBlockInfo<'ctx, 'blk, 'val>,
        else_info: NestedBlockInfo<'ctx, 'blk, 'val>,
    ) -> Result<()> {
        // Ensure both blocks will yield the same set of variables.
        then_info.add_missing_values(&else_info, self)?;

        // Split `then_block_info.var_overwrites` into ordered lists of names and values. The
        // ordering of names here defines the ordering of results from the `scf.if` op and
        // thus the ordering of operands to `scf.yield` ops in both branches. Sort by circom
        // variable names to ensure a stable order.
        let mut overwrites_sorted: Vec<_> = then_info.var_overwrites.into_iter().collect();
        overwrites_sorted.sort_by(|(name_a, _), (name_b, _)| name_a.cmp(name_b));
        let (overwrite_names, then_values): (Vec<_>, Vec<_>) =
            overwrites_sorted.into_iter().unzip();

        // Create list of values to yield from the `else` block in the same order
        // as `overwrite_names`, again using current-scope values for missing keys.
        let else_values = overwrite_names
            .iter()
            .map(|name| {
                else_info
                    .var_overwrites
                    .get(name)
                    .map_or_else(|| self.block_ctx.get_named_value(name).cloned(), |v| Ok(*v))
            })
            .collect::<Result<Vec<_>, _>>()?;

        // Insert `scf.yield` at the end of each block.
        Self::append_multi_operand_yield_to_block(
            codegen,
            then_info.block,
            &then_values,
            &overwrite_names,
            location,
        )?;
        Self::append_multi_operand_yield_to_block(
            codegen,
            else_info.block,
            &else_values,
            &overwrite_names,
            location,
        )?;

        // Use `overwrite_names` and the current block context to get the types of
        // the named values to define the result types of the `scf.if` op.
        let result_types = overwrite_names
            .iter()
            .map(|name| {
                self.block_ctx
                    .get_named_value(name)
                    .inspect_err(|e| eprintln!("\nERROR: {:?}", e))
                    .map(|v| v.r#type())
            })
            .collect::<Result<Vec<_>, _>>()?;

        // Cast condition value to bool type if needed.
        let condition = self.cast_to_bool_if_needed(codegen, location, condition)?;
        // Generate the `scf.if` op for the circom `IfThenElse` statement.
        let scf_if_op = self.append_op(scf::r#if(
            condition,
            &result_types,
            then_info.region,
            else_info.region,
            location,
        ));

        // Update the current block context with results from the `scf.if` op.
        overwrite_names
            .into_iter()
            .zip(scf_if_op.results())
            .try_for_each(|(name, result)| self.block_ctx.set_named_value(name, result.into()))?;
        Ok(())
    }

    /// Generate one region for either the then-arm or else-arm of a simple scf.if operation.
    /// Used by [Self::generate_simple_scf_if].
    /// The `value_gen` function is called to generate the value to be yielded from the arm.
    fn generate_simple_scf_if_arm<'ast, F>(
        &mut self,
        location: Location<'ctx>,
        value_gen: F,
    ) -> Result<(Region<'ctx>, Value<'ctx, 'val>)>
    where
        F: FnOnce(&mut Self) -> Result<Value<'ctx, 'val>>,
    {
        let region = Region::new();
        let block = region.append_block(Block::new(&[]));
        self.block_ctx.push(block);
        let arm_val = value_gen(self)?;
        self.block_ctx.pop();
        no_results(block.append_operation(scf::r#yield(&[arm_val], location)))?;
        Ok((region, arm_val))
    }

    /// Generate a simple scf.if operation that yields the given `then_value` or `else_value`
    /// depending on the `condition` value. Unlike [Self::gen_scf_if], this assumes that the
    /// then and else arms do not modify the current block context and only produce values.
    pub fn generate_simple_scf_if<'ast, F1, F2>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        meta: &Meta,
        condition: Value<'ctx, 'val>,
        then_value_gen: F1,
        else_value_gen: F2,
    ) -> Result<Operation<'ctx>>
    where
        F1: FnOnce(&mut Self) -> Result<Value<'ctx, 'val>>,
        F2: FnOnce(&mut Self) -> Result<Value<'ctx, 'val>>,
    {
        let location = codegen.location_from_meta(meta);

        let (then_region, then_value) =
            self.generate_simple_scf_if_arm(location, then_value_gen)?;
        let (else_region, else_value) =
            self.generate_simple_scf_if_arm(location, else_value_gen)?;

        // Ensure then_value and else_value have the same types
        assert_eq!(
            then_value.r#type(),
            else_value.r#type(),
            "then and else branches of scf.if must have matching value types"
        );

        Ok(scf::r#if(condition, &[then_value.r#type()], then_region, else_region, location))
    }

    /// Generate a simple `scf.for` op that doesn't need to override variables
    /// in the block context.
    /// The body function (`body_fn`) accepts a `Block` with a single argument representing
    /// the for-loop induction variable and is used to fill in the `scf.for` op.
    pub fn gen_simple_scf_for<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        start: Value<'ctx, 'val>,
        step: Value<'ctx, 'val>,
        end: Value<'ctx, 'val>,
        body_fn: impl FnOnce(&mut Block<'ctx>) -> Result<()>,
    ) -> Result<()> {
        let block_arg = (codegen.index_type(), location);
        let mut block = Block::new(&[block_arg]);
        body_fn(&mut block)?;
        let region = Region::new();
        region.append_block(block);
        let scf_op = scf::r#for(start, end, step, region, location);
        self.append_op_no_result(scf_op)
    }

    /// Generate a simple `scf.for` op with normalized start=0 and step=1.
    #[inline]
    pub fn gen_normalized_scf_for<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        end: Value<'ctx, 'val>,
        body_fn: impl FnOnce(&mut Block<'ctx>) -> Result<()>,
    ) -> Result<()> {
        let start = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
        let step = self.append_op_unnamed_result(codegen.new_index_const_op(1, location))?;
        self.gen_simple_scf_for(codegen, location, start, step, end, body_fn)
    }

    /// Generates IR for decreasing the counter of a subcomponent.
    ///
    /// Returns a [`Value`] with the updated counter.
    pub fn gen_subcmp_decrease_counter(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        subcmp_memory: Value<'ctx, 'val>,
        amount: u32,
    ) -> Result<Value<'ctx, 'val>> {
        let counter = self.append_op_unnamed_result(codegen.new_pod_read_op(
            subcmp_memory,
            COUNT,
            location,
        )?)?;
        let one = self.append_op_unnamed_result(codegen.new_index_const_op(amount, location))?;
        let counter = self.append_op_unnamed_result(arith::subi(counter, one, location))?;
        self.append_op_no_result(codegen.new_pod_write_op(
            subcmp_memory,
            COUNT,
            counter,
            location,
        ))?;
        Ok(counter)
    }

    /// Generates a `scf.if` block that runs the 'then' branch if the given value is 0.
    pub fn gen_scf_if_is_zero(
        &mut self,
        value: Value<'ctx, 'val>,
        location: Location<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        body: impl FnOnce(&mut Self) -> Result<()>,
    ) -> Result<()> {
        let zero = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
        let cmp = self.append_op_unnamed_result(arith::cmpi(
            codegen.context,
            arith::CmpiPredicate::Eq,
            value,
            zero,
            location,
        ))?;
        let then_region = region_with_block(&[]);
        self.block_ctx.push(then_region.first_block().unwrap());
        body(self)?;
        self.append_op_no_result(scf::r#yield(&[], location))?;
        self.block_ctx.pop();
        let else_region = region_with_block(&[]);
        else_region.first_block().unwrap().append_operation(scf::r#yield(&[], location));

        self.append_op_no_result(scf::r#if(cmp, &[], then_region, else_region, location))
    }

    /// Decomposes the given value of [`PodType`] into a sequence of values in declaration order.
    pub fn gen_decompose_pod(
        &mut self,
        pod: Value<'ctx, 'val>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
    ) -> Result<Vec<Value<'ctx, 'val>>> {
        PodType::try_from(pod.r#type())?
            .get_records()
            .into_iter()
            .map(|record| {
                let record_name = codegen.flat_sym(record.name().as_str()?);
                self.append_op_unnamed_result(pod::read(
                    location,
                    pod,
                    record_name,
                    record.r#type(),
                ))
            })
            .collect()
    }

    /// Generates a call to `@compute` for the given struct type.
    ///
    /// The arguments for the call are given as a value of [`PodType`] representing the inputs of
    /// the subcomponent.
    ///
    /// # TODO
    ///
    /// Map operands are missing.
    pub fn gen_compute_call(
        &mut self,
        struct_type: StructType<'ctx>,
        inputs: Value<'ctx, 'val>,
        location: Location<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<Value<'ctx, 'val>> {
        let input_values = self.gen_decompose_pod(inputs, codegen, location)?;

        let func_name =
            SymbolRefAttribute::new(codegen.context, struct_type.name().value(), &["compute"]);

        self.append_op_unnamed_result(
            function::call(
                codegen.op_builder(),
                location,
                func_name,
                &input_values,
                &[struct_type],
            )?
            .into(),
        )
    }

    /// Generates a call to `@constrain` for the given struct type.
    ///
    /// The arguments for the call are given as a value of [`PodType`] representing the inputs of
    /// the subcomponent.
    pub fn gen_constrain_call(
        &mut self,
        subcmp: Value<'ctx, 'val>,
        inputs: Value<'ctx, 'val>,
        location: Location<'ctx>,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
    ) -> Result<()> {
        let mut call_args = vec![subcmp];
        call_args.extend(self.gen_decompose_pod(inputs, codegen, location)?);

        let func_name = SymbolRefAttribute::new(
            codegen.context,
            StructType::try_from(call_args[0].r#type())?.name().value(),
            &["constrain"],
        );
        let return_types: [Type; 0] = [];
        self.append_op_no_result(
            function::call(codegen.op_builder(), location, func_name, &call_args, &return_types)?
                .into(),
        )
    }

    /// Creates a loop nest from a list of dimensions.
    ///
    /// The body of the inner-most loop is defined by the given closure, which accepts a list of
    /// values representing the current value of each loop's induction variable.
    pub fn gen_loop_nest(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        dims: &[Attribute<'ctx>],
        body: impl FnOnce(&mut Self, &[Value<'ctx, 'val>]) -> Result<()>,
    ) -> Result<()>
    where
        'val: 'blk,
    {
        let zero = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
        let one = self.append_op_unnamed_result(codegen.new_index_const_op(1, location))?;

        // Create values from the dimensions
        let dim_values = dims
            .iter()
            .copied()
            .map(|attr| {
                if IntegerAttribute::try_from(attr).is_ok() {
                    return self.append_op_unnamed_result(arith::constant(
                        codegen.context,
                        attr,
                        location,
                    ));
                }
                unreachable!("Unhandled attribute in array dimensions {}", attr)
            })
            .collect::<Result<Vec<_>, _>>()?;

        let loop_block_args = [(codegen.index_type(), location)];
        let top_block = *self.block_ctx.top_block();
        let mut loop_vars: Vec<Value> = vec![];
        // Create the loop nest
        let mut block: Option<BlockRef<'_, '_>> = None;
        for dim in dim_values {
            let op = scf::r#for(zero, dim, one, region_with_block(&loop_block_args), location);
            let loop_op = match &block {
                Some(block_ref) => block_ref.append_operation(op),
                None => self.append_op(op),
            };
            block = Some(
                loop_op
                    .region(0)?
                    .first_block()
                    .ok_or_else(|| anyhow::anyhow!("region is missing first block"))?,
            );
            // Accumulate the induction variables for later giving all of them to the callback.
            loop_vars.push(block.unwrap().argument(0)?.into());
        }

        // Unwrap the block after creating the loop nest.
        let mut block = block.ok_or_else(|| anyhow::anyhow!("no loops created"))?;
        // Push the block of the inner-most loop s.t. the user can use `self` and ops will get added
        // to the right block.
        self.block_ctx.push(block);
        body(self, &loop_vars)?;
        self.block_ctx.pop();

        // Traverse the stack of blocks until we reach the block where we inserted the whole nest.
        // For each block traversed this way add the scf terminator op.
        while block != top_block {
            block.append_operation(scf::r#yield(&[], location));
            block = block
                .parent_operation()
                .and_then(|op| op.block())
                .ok_or_else(|| anyhow::anyhow!("detached block while creating loop nest"))?;
        }

        Ok(())
    }

    /// Creates LLZK ops for array indexing from the collection of elements.
    pub fn gen_index_ops<'ast, 'info, E>(
        &mut self,
        indices: impl IntoIterator<Item = &'ast E>,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        info: InfoProviders<'info>,
    ) -> Result<Vec<Value<'ctx, 'val>>>
    where
        E: GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val, Output = Value<'ctx, 'val>> + 'ast,
    {
        indices
            .into_iter()
            .map(|e| {
                let val = e.gen_llzk_in_function(codegen, self, info)?;
                self.append_op_unnamed_result(cast::toindex(location, val))
            })
            .collect()
    }

    /// Implementation for [Expression::UniformArray] after conversion of dimension
    /// expression. Useful because dimension generation differs between function
    /// and template contexts due to template parameters, but the actual array generation
    /// is otherwise the same.
    pub fn generate_uniform_array<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        value: Value<'ctx, 'val>,
        dimension: &ArrayDimension<'ctx, 'val>,
    ) -> Result<Value<'ctx, 'val>> {
        // Ensure all symbols are of index type
        let dimension = &self.transform_symbols_to_index(location, dimension)?;
        let const_dim = IntegerAttribute::try_from(dimension);
        if let Ok(subarr_ty) = ArrayType::try_from(value.r#type()) {
            let arr_ty = dimension.new_array_type(&subarr_ty.into());
            let mut symbols_sto = vec![];
            // The array.new constructor doesn't accept arrays as initializer values,
            // so we instead create the array empty and use array.insert to insert values.
            let ctor = if let Some(symbols) = dimension.value_range()? {
                symbols_sto.push(symbols);
                ArrayCtor::MapDimSlice(&symbols_sto, &[0])
            } else {
                ArrayCtor::Values(&[])
            };
            let new_arr = self.append_op_unnamed_result(array::new(
                &OpBuilder::new(codegen.context),
                location,
                arr_ty,
                ctor,
            ))?;
            if let Ok(const_dim) = const_dim {
                for idx in 0..const_dim.value() {
                    let idx_val =
                        self.append_op_unnamed_result(codegen.new_index_const_op(idx, location))?;
                    self.append_op_no_result(array::insert(location, new_arr, &[idx_val], value))?;
                }
            } else {
                let dim = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
                let array_len =
                    self.append_op_unnamed_result(array::len(location, new_arr, dim))?;
                self.gen_normalized_scf_for(codegen, location, array_len, |b| {
                    let induction_var = b.argument(0)?;
                    b.append_operation(array::insert(
                        location,
                        new_arr,
                        &[induction_var.into()],
                        value,
                    ));
                    b.append_operation(scf::r#yield(&[], location));
                    Ok(())
                })?;
            };
            // Output value is still the newly created array
            Ok(new_arr)
        } else {
            let arr_ty = dimension.new_array_type(&value.r#type());
            let builder = &OpBuilder::new(codegen.context);
            if let Ok(const_dim) = const_dim {
                let values = vec![value; usize::try_from(const_dim.value())?];
                let ctor = ArrayCtor::Values(&values);
                self.append_op_unnamed_result(array::new(builder, location, arr_ty, ctor))
            } else {
                let mut v_sto = vec![];
                let ctor = if let Ok(Some(v)) = dimension.value_range() {
                    v_sto.push(v);
                    ArrayCtor::MapDimSlice(&v_sto, &[0])
                } else {
                    ArrayCtor::Values(&[])
                };
                let array_ref =
                    self.append_op_unnamed_result(array::new(builder, location, arr_ty, ctor))?;
                let dim = self.append_op_unnamed_result(codegen.new_index_const_op(0, location))?;
                let array_len =
                    self.append_op_unnamed_result(array::len(location, array_ref, dim))?;
                self.gen_normalized_scf_for(codegen, location, array_len, |b| {
                    let induction_var = b.argument(0)?;
                    b.append_operation(array::write(
                        location,
                        array_ref,
                        &[induction_var.into()],
                        value,
                    ));
                    b.append_operation(scf::r#yield(&[], location));
                    Ok(())
                })?;
                Ok(array_ref)
            }
        }
    }

    /// Generate an `scf.while` op based on the given [NestedBlockInfo] and update the
    /// block context with the results of the `scf.while` op mapped to the given names.
    pub fn gen_scf_while<'ast>(
        &mut self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        location: Location<'ctx>,
        condition: Value<'ctx, 'val>,
        loop_cond_info: NestedBlockInfo<'ctx, 'blk, 'val>,
        loop_body_info: NestedBlockInfo<'ctx, 'blk, 'val>,
        loop_bounds: Option<LoopBoundsAttribute<'ctx>>,
    ) -> Result<bool> {
        // ASSERT: loop condition was a single Expression so there are no variable overwrites.
        assert!(loop_cond_info.var_overwrites.is_empty());

        // Split `loop_body_info.var_overwrites` into ordered lists of names and values. The
        // ordering of names here defines the ordering of the loop-carried variables for the
        // `scf.while` op and thus the ordering of operands for the `scf.yield` and
        // `scf.condition` ops. Sort by circom variable names to ensure a stable order.
        let mut overwrites_sorted: Vec<_> = loop_body_info.var_overwrites.into_iter().collect();
        overwrites_sorted.sort_by(|(name_a, _), (name_b, _)| name_a.cmp(name_b));
        let (loop_carried_var_names, body_yield_values): (Vec<_>, Vec<_>) =
            overwrites_sorted.into_iter().unzip();

        // Append the loop body block with an `scf.yield`
        Self::append_multi_operand_yield_to_block(
            codegen,
            loop_body_info.block,
            &body_yield_values,
            &loop_carried_var_names,
            location,
        )?;

        // Use `loop_carried_var_names` and the current block context to build a list of types of
        // the loop-carried variables, add BlockArguments of those types in both blocks, and
        // replace uses of the overwritten variables in both blocks with references to the new
        // BlockArguments Values.
        let mut loop_carried_types = Vec::new();
        // Additionally, track if `VAR_NAME_HAD_RETURN` is among the loop-carried variables
        // (indicating there was a return somewhere within the loop body) to later update the
        // loop condition to ensure iteration stops when a return occurs.
        let mut return_flag: Option<Value> = None;
        for name in loop_carried_var_names.iter() {
            let orig_val = self.block_ctx.get_named_value(name).unwrap();
            loop_carried_types.push(orig_val.r#type());
            replace_uses_with_new_block_argument(loop_body_info.block, orig_val, location);
            let f = replace_uses_with_new_block_argument(loop_cond_info.block, orig_val, location);
            if name == VAR_NAME_HAD_RETURN {
                return_flag = Some(f);
            }
        }

        // In the loop condition block, ensure the condition has bool type and generate an
        // `scf.condition` op with the condition value and the loop-carried variables.
        {
            let mut condition = self.cast_to_bool_if_needed(codegen, location, condition)?;
            // If there is a return within the loop, add prefix "!<VAR_NAME_HAD_RETURN> &&" to the
            // loop condition to ensure the loop terminates when the return occurs.
            if let Some(flag) = return_flag {
                let not_return_flag = single_result_as_value(
                    loop_cond_info.block.append_operation(bool::r#not(location, flag)?.into()),
                )?;
                condition =
                    single_result_as_value(loop_cond_info.block.append_operation(
                        bool::and(location, not_return_flag, condition)?.into(),
                    ))?;
            }
            // Pass the block arguments as the initial values to the condition op.
            let block_arg_values = (0..loop_cond_info.block.argument_count())
                .map(|i| loop_cond_info.block.argument(i).map_err(Into::into).map(Value::from))
                .collect::<Result<Vec<Value>>>()?;
            no_results(loop_cond_info.block.append_operation(scf::condition(
                condition,
                &block_arg_values,
                location,
            )))?;
        }

        // Create list of initial values of the loop-carried variables (i.e. the overwritten
        // variables, in the order of `loop_carried_var_names`) to pass into the `scf.while`.
        let initial_values = loop_carried_var_names
            .iter()
            .map(|name| self.block_ctx.get_named_value(name).cloned())
            .collect::<Result<Vec<_>, _>>()?;

        // Generate the `scf.while` op for the circom `While` statement, adding `loopbounds`
        // attribute if given, and append it to the current block.
        let mut scf_op = scf::r#while(
            &initial_values,
            &loop_carried_types,
            loop_cond_info.region,
            loop_body_info.region,
            location,
        );
        if let Some(loop_bounds) = loop_bounds {
            scf_op.set_attribute("llzk.loopbounds", loop_bounds.into());
        }
        let scf_op = self.append_op(scf_op);

        // Update the current block context with results from the `scf.while` op.
        loop_carried_var_names
            .into_iter()
            .zip(scf_op.results())
            .try_for_each(|(name, result)| self.block_ctx.set_named_value(name, result.into()))?;

        Ok(return_flag.is_some())
    }

    /// Finalizes the context.
    pub fn finalize(&mut self, codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>) -> Result<()> {
        self.func.walk_mut(WalkOrder::PreOrder, |mut op| {
            // Remove any `undef.undef` ops from the function whose result value is unused. These
            // were added, for example, when visiting [Statement::Declaration] but their uses were
            // later replaced with actual values when visiting [Statement::Substitution], etc.
            if undef::is_undef_op(&op) && !has_uses(single_result_as_value(op).unwrap()) {
                OperationMutLike::remove_from_parent(op.deref_mut());
                return WalkResult::Skip;
            }
            WalkResult::Advance
        });

        // Use a bottom-up (i.e. PostOrder) traversal that also walks blocks in reverse order to
        // remove `CIRCOM_RETURN_MARKER_ATTR` and find `scf.return` ops located within `scf.if` ops.
        let mut rets_in_if: Vec<_> = vec![];
        self.func.walk_rev_mut(WalkOrder::PostOrder, |mut op| {
            if op.has_attribute(CIRCOM_RETURN_MARKER_ATTR) {
                // Perform replacement of "if(..) return" pattern.
                if is_func_return(&op) {
                    if let Some(parent) = parent_operation_mut(&op) {
                        if is_scf_if(&parent) {
                            // Cannot directly do the refactor here because it will invalidate the
                            // walk iterator. Instead, collect the pairs to process after the walk.
                            // But, must use raw objects since `op` is invalid outside this closure.
                            rets_in_if.push((op.to_raw(), parent.to_raw()));
                            return WalkResult::Skip;
                        }
                    }
                }

                // Remove the `CIRCOM_RETURN_MARKER_ATTR` attribute because it is a temporary marker
                // used to adjust the location of return statements to match LLZK requirements.
                let r = op.remove_attribute(CIRCOM_RETURN_MARKER_ATTR);
                assert!(r.is_ok(), "Must succeed due to the has_attribute check above");
            }
            WalkResult::Advance
        });
        for (ret, parent) in rets_in_if {
            let ret_op = unsafe { OperationRefMut::from_raw(ret) };
            let parent_if_op = unsafe { OperationRefMut::from_raw(parent) };
            Self::refactor_return_in_if(codegen, ret_op, parent_if_op)?;
        }
        // One more pass to remove remaining `OPERAND_VAL_NAMES` attributes
        self.func.walk_mut(WalkOrder::PreOrder, |mut op| {
            let _ = op.remove_attribute(OPERAND_VAL_NAMES);
            WalkResult::Advance
        });
        Ok(())
    }

    /// Replace `parent_if_op` with a new `scf.if` op where the existing `ret_op` is changed to a
    /// yield and all operations in the same block following `parent_if_op` are moved into the else
    /// branch (with return op there also converted to a yield op). The new `scf.if` op result is
    /// used in a new `scf.return` op added after the new `scf.if`.
    fn refactor_return_in_if(
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        ret_op: OperationRefMut<'ctx, '_>,
        mut parent_if_op: OperationRefMut<'ctx, '_>,
    ) -> Result<()> {
        assert!(is_func_return(&ret_op)); // precondition
        assert!(is_scf_if(&parent_if_op)); // precondition

        // Move all ops after the `scf.if` into a new block for "else" branch of new `scf.if`.
        let new_else_block = Block::new(&[]);
        let new_else_result_info: RefactoringBlockResultType;
        {
            // Collect all ops before removing any to avoid invalidating references.
            let mut following_ops = Vec::new();
            let mut cur = next_in_block_mut(&parent_if_op);
            while let Some(op_ref) = cur {
                following_ops.push(op_ref);
                cur = next_in_block_mut(&op_ref);
            }
            let mut tail = following_ops.pop().context("expected at least a yield/return")?;
            for op_ref in following_ops.iter_mut() {
                new_else_block.append_operation(remove_from_parent(op_ref));
            }
            // Special handling for the tail op: yield is just added, return is converted to yield.
            let tail = remove_from_parent(&mut tail);
            if is_scf_yield(&tail) {
                let result_types = tail.operands().map(|v| v.r#type()).collect();
                let names = tail
                    .attribute(OPERAND_VAL_NAMES)
                    .expect("multi-value yield op must have names");
                new_else_result_info = RefactoringBlockResultType::Multiple(result_types, names);
                no_results(new_else_block.append_operation(tail))?;
            } else if is_func_return(&tail) {
                assert_eq!(tail.operand_count(), 1, "circom functions must return a single value");
                let ret_val = tail.operand(0).unwrap();
                new_else_result_info = RefactoringBlockResultType::Single(ret_val.r#type());
                no_results(
                    new_else_block.append_operation(scf::r#yield(&[ret_val], tail.location())),
                )?;
            } else {
                anyhow::bail!("expected either yield or return at end of block");
            }
        }

        // Create "then" block for new `scf.if` and add yield converted from `ret_op`.
        let new_then_block = Block::new(&[]);
        {
            assert_eq!(ret_op.operand_count(), 1, "circom functions must return a single value");
            let ret_val = ret_op.operand(0).unwrap();
            let mut yield_values = Vec::with_capacity(new_else_result_info.len());

            // The blocks must yield the same number and type of values. So if the "else" block
            // yields more than one value, need to add additional operands to yield here.
            match &new_else_result_info {
                RefactoringBlockResultType::Single(t) => {
                    if ret_val.r#type() != *t {
                        anyhow::bail!("type mismatch in return value between branches");
                    }
                    yield_values.push(ret_val);
                }
                RefactoringBlockResultType::Multiple(result_types, names) => {
                    let location = ret_op.location();
                    for (i, s) in codegen.attribute_to_list(*names)?.enumerate() {
                        if s == VAR_NAME_RETURN_VAL {
                            yield_values.push(ret_val);
                        } else if s == VAR_NAME_HAD_RETURN {
                            // Gen true constant since this case has a return.
                            yield_values.push(single_result_as_value(
                                new_then_block
                                    .append_operation(codegen.new_bool_const_op(true, location)),
                            )?);
                        } else {
                            assert!(i <= result_types.len(), "more names than result types");
                            // Fill other positions with undef values of the appropriate type.
                            yield_values.push(single_result_as_value(
                                new_then_block.append_operation(
                                    codegen.new_nondet_at_location(location, result_types[i])?,
                                ),
                            )?);
                        }
                    }
                }
            }
            let new_yield = new_else_result_info.gen_yield(&yield_values, ret_op.location());
            no_results(new_then_block.append_operation(new_yield))?;
        }

        // Create new `scf.if` op using the new "then" and "else" blocks. Replace `parent_if_op`
        // with this new `scf.if` and then append a return/yield with the new `scf.if` results.
        let blk = parent_if_op.block().context("expected parent block for original `if`")?;
        let else_region = Region::new();
        else_region.append_block(new_else_block);
        let then_region = Region::new();
        then_region.append_block(new_then_block);
        let new_if_ref = blk.append_operation(scf::r#if(
            parent_if_op.operand(0)?,
            new_else_result_info.result_types(),
            then_region,
            else_region,
            parent_if_op.location(),
        ));

        // Add return if the destination block is the function def body, else yield.
        let result_values: Vec<_> = new_if_ref.results().map(Value::from).collect();
        let op = if blk.parent_operation().is_some_and(|r| is_func_def(&r)) {
            function::r#return(parent_if_op.location(), &result_values)
        } else {
            new_else_result_info.gen_yield(&result_values, parent_if_op.location())
        };
        no_results(blk.append_operation(op))?;

        // Finally, remove and drop the original `parent_if_op`.
        let _drop = remove_from_parent(&mut parent_if_op);

        Ok(())
    }

    /// Cast all symbols passed to affine_maps into index types, which is required
    /// for affine_map usage.
    #[inline]
    fn transform_symbols_to_index(
        &mut self,
        location: Location<'ctx>,
        dimension: &ArrayDimension<'ctx, 'val>,
    ) -> Result<ArrayDimension<'ctx, 'val>> {
        dimension.transform(|val| self.cast_to_index_if_needed(location, val))
    }

    /// Handle a [Statement::Declaration] by generating a nondet felt value with the given
    /// dimensions and declaring it in the current block context.
    pub fn gen_declaration(
        &mut self,
        codegen: &LlzkCodegen<'_, 'ctx, impl ProgramLike>,
        meta: &Meta,
        name: &str,
        dimensions: &[Expression],
    ) -> Result<()> {
        if self.block_ctx.is_name_present(name) {
            return Ok(());
        }
        // If generating from VCP, there are cases where the `sugar_cleaner` added new
        // declarations that only have `MemoryKnowledge` but not `dimensions` in the AST. So
        // check `MemoryKnowledge` first (if not generating from VCP, this will always be
        // empty so `dimensions` will be used).
        let mk = meta.get_memory_knowledge();
        let dims = if mk.has_concrete_dimensions() {
            (mk.get_concrete_dimensions(), codegen).try_into()?
        } else {
            self.get_dimensions(codegen, dimensions)?
        };
        if codegen.verbose {
            println!("Declaring variable '{name}' with dimensions {dims:?}");
        }
        let op = dims.new_nondet_felt_of_dimensions(codegen, meta)?;
        self.block_ctx.declare_name_ensure_not_present(name, op)
    }
}

impl<'ast, 'ctx, 'func, 'blk, 'val> DimExprConverter<'ctx, 'ast, 'val>
    for FunctionContext<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    fn convert_dim_expr(
        &self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        expr: &Expression,
    ) -> Result<ArrayDimensionResult<'ctx, 'val>> {
        // First try to compute statically, falling back to literal computation if all values are
        // not compile-time constants or if the final result does not properly convert to i64.
        if let Some(integer) = shared::try_compute_as_i64(expr, codegen.prime())? {
            ArrayDimensionResult::new(codegen.index_attr(integer).into(), &[])
        } else {
            #[allow(unused_variables)] // TODO: TEMP
            match expr {
                Expression::Number(_, _) => {
                    unreachable!("handled by try_compute_as_i64")
                }
                Expression::Variable { meta, name, access } => match access.as_slice() {
                    [] => {
                        if let Ok(v) = self.block_ctx.get_named_value(name) {
                            let id_map = codegen.affine_map_attr("affine_map<()[i] -> (i)>")?;
                            ArrayDimensionResult::new(id_map, &[*v])
                        } else {
                            todo!("Handle Variable expression in dimension for non-integer, non-template parameter attributes in FunctionContext")
                        }
                    }
                    a => {
                        todo!("Handle Variable expression with accesses in FunctionContext")
                    }
                },
                Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                    todo!("Handle Infix expression in dimension for non-integer attributes")
                }
                Expression::PrefixOp { meta, prefix_op, rhe } => {
                    todo!("Handle Prefix expression in dimension for non-integer attributes")
                }
                Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                    todo!(
                        "Handle InlineSwitchOp expression in dimension for non-integer attributes"
                    )
                }
                Expression::Call { meta, id, args } => {
                    todo!("Handle Call expression in dimension")
                }
                // The remaining cases do not produce a scalar value.
                // i.e. ParallelOp, ArrayInLine, UniformArray, BusCall, AnonymousComp, Tuple
                // Give the same error that the circom type checker gives. The type checker ran
                // earlier so this should technically be unreachable.
                _ => {
                    unreachable!("Array indexes and lengths must be single arithmetic expressions")
                }
            }
        }
    }
}

/// The [FunctionContext] directly accesses a single [BlockContextStack] for circom scope handling.
impl<'ctx, 'func, 'blk, 'val> GenWithCircomScopeHandling<'ctx, 'func, 'blk, 'val>
    for FunctionContext<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type BlockType = BlockRef<'ctx, 'blk>;
    type HandlerDataType = NestedBlockInfo<'ctx, 'blk, 'val>;

    fn stack_top(&self) -> Self::BlockType {
        *self.block_ctx.top_block()
    }

    fn stack_push(&mut self, block: Self::BlockType) {
        self.block_ctx.push(block)
    }

    fn stack_pop<H>(
        &mut self,
        overwrite_handler: H,
        overwrite_data: &mut Self::HandlerDataType,
    ) -> Result<()>
    where
        H: Fn(
            &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
            &mut NestedBlockInfo<'ctx, 'blk, 'val>,
            HashMap<String, Value<'ctx, 'val>>,
        ) -> Result<()>,
    {
        let popped = self.block_ctx.pop();
        overwrite_handler(self, overwrite_data, popped)
    }
}

/// A trait to generate LLZK IR from the body of a circom function.
///
/// 'ctx: lifetime of the `LlzkContext` and generated `Module`
/// 'func: lifetime of the generated `FuncDefOp` instances within the struct
/// 'blk: lifetime of the generated `Block` instances within functions
/// 'val: lifetime of the generated `Value` or `Operation` instances within blocks
pub trait GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    /// Output type of the generator function. [Statement] nodes do not produce a value so this
    /// should be the unit type whereas [Expression] nodes produce a Value.
    type Output;

    /// Generates LLZK IR from [Statement] and [Expression] nodes in a circom function.
    ///
    /// 'ast: lifetime of the circom AST element
    fn gen_llzk_in_function<'ast, 'info>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Self::Output>;
}

/// Output type of [GenerateLLZKInFunction] implemented for [Statement] indicating whether the
/// current statement causes abrupt termination of the current block (in other words, whether
/// the remaining statements in the same block should be skipped).
type SkipRestOfBlock = bool;

/// Within a nested (i.e. non-root) block, get the Value wrapped within an `scf.yield` op that was
/// created from a circom return op.
fn get_val_of_circom_return_and_erase<'ctx, 'blk, 'val>(
    block: BlockRef<'ctx, 'blk>,
) -> Option<Value<'ctx, 'val>>
where
    'ctx: 'blk,
    'blk: 'val,
{
    if let Some(mut term) = block.terminator_mut() {
        // Per `append_circom_return()`, the op generated from a circom return
        // statement has the special attribute `CIRCOM_RETURN_MARKER_ATTR`.
        if term.has_attribute(CIRCOM_RETURN_MARKER_ATTR) {
            // ASSERT: This must be a `yield` not a `return` since it's generated
            // within a nested block of an `if` or `while` statement.
            assert!(is_scf_yield(&term));
            // ASSERT: Per `append_circom_return()` it has exactly one operand.
            assert_eq!(term.operand_count(), 1);
            let result = term.operand(0).unwrap();
            term.remove_from_parent();
            // To avoid "still has uses" native errors, must perform an explicit erase
            // since there's no way to get the owned `Operation` out of the block.
            erase_op(term);
            return Some(result);
        }
    }
    None
}

/// Helper for [gen_if_then_else] to mangage the special return-related variables needed
/// when a circom [Statement::IfThenElse] contains a return statement.
#[allow(clippy::too_many_arguments)]
fn handle_unbalanced_return<'ast, 'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
    return_val: Value<'ctx, 'val>,
    returning_block: BlockRef<'ctx, 'blk>,
    returning_block_overwrites: &mut HashMap<String, Value<'ctx, 'val>>,
    nonreturning_block: BlockRef<'ctx, 'blk>,
    nonreturning_block_overwrites: &mut HashMap<String, Value<'ctx, 'val>>,
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    // Set `VAR_NAME_HAD_RETURN` in both maps: `true` in returning block, `false` in other.
    returning_block_overwrites.insert(
        VAR_NAME_HAD_RETURN.to_string(),
        single_result_as_value(
            returning_block.append_operation(codegen.new_bool_const_op(true, location)),
        )?,
    );
    nonreturning_block_overwrites.insert(
        VAR_NAME_HAD_RETURN.to_string(),
        single_result_as_value(
            nonreturning_block.append_operation(codegen.new_bool_const_op(false, location)),
        )?,
    );

    // Set return value in both maps. In the non-returning block, use the existing value in the
    // block context, if present, otherwise create a new non-det value.
    returning_block_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), return_val);
    nonreturning_block_overwrites.insert(
        VAR_NAME_RETURN_VAL.to_string(),
        function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL).cloned().or_else(|_| {
            single_result_as_value(
                nonreturning_block.append_operation(
                    codegen.new_nondet_at_location(location, return_val.r#type())?,
                ),
            )
        })?,
    );
    Ok(())
}

/// Generate LLZK code that follows a circom `if-then-else` statement that has an unbalanced return
/// (i.e. one branch returns and the other does not) or `while`. Generates the following LLZK code:
/// ```llzk
///  VAR_NAME_RETURN_VAL = scf.if VAR_NAME_HAD_RETURN {
///      function.return VAR_NAME_RETURN_VAL
///  }
/// ```
fn gen_unbalanced_return_extra<'ast, 'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    location: Location<'ctx>,
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    let then_region = Region::new();
    let then_block = then_region.append_block(Block::new(&[]));
    function.gen_in_given_block_with_new_circom_scope_and_merge_overwrites(then_block, |fc| {
        let ret_val = fc.block_ctx.get_named_value(VAR_NAME_RETURN_VAL)?;
        let value = fc.cast_to_return_type_if_needed(codegen, location, *ret_val)?;
        let mut op = function::r#return(location, &[value]);
        op.set_attribute(CIRCOM_RETURN_MARKER_ATTR, Attribute::unit(codegen.context));
        fc.append_op_no_result(op)
    })?;

    let condition = function.block_ctx.get_named_value(VAR_NAME_HAD_RETURN)?;
    function.append_op_no_result(scf::r#if(*condition, &[], then_region, Region::new(), location))
}

/// Generate LLZK code for a circom [Statement::IfThenElse].
fn gen_if_then_else<'ast, 'ctx, 'func, 'blk, 'val, 'info>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'info>,
    meta: &Meta,
    cond: &Expression,
    if_case: &Statement,
    else_case: &Option<Box<Statement>>,
) -> Result<SkipRestOfBlock>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    // Initially, generate the blocks for the 'then' and 'else' cases naively.
    let mut then_info = NestedBlockInfo::default();
    function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        then_info.block,
        |function| if_case.gen_llzk_in_function(codegen, function, info),
        &mut then_info,
    )?;
    let mut else_info = NestedBlockInfo::default();
    if let Some(else_case) = else_case {
        function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
            else_info.block,
            |function| else_case.gen_llzk_in_function(codegen, function, info),
            &mut else_info,
        )?;
    }

    let location = codegen.location_from_meta(meta);
    let condition = cond.gen_llzk_in_function(codegen, function, info)?;

    // Check if one or both blocks end with a return in circom. The `scf.if` op used in LLZK cannot
    // have returns nested within other blocks like circom allows. Use of `append_circom_return()`
    // already ensures `scf.yield` is used instead of `function.return` when not in the root
    // block but the `scf.if` additionally requires that both blocks yield the same number and type
    // of values. Additionally, if one block returns and the other does not (in the circom code),
    // an additional return state must be added to the values to be yielded from both branches and
    // an additional `scf.if` must be added after the main `scf.if` to check the return state flag.
    let then_return_opt = get_val_of_circom_return_and_erase(then_info.block);
    let else_return_opt = get_val_of_circom_return_and_erase(else_info.block);
    if let Some(then_return) = then_return_opt {
        if let Some(else_return) = else_return_opt {
            // Both return, just add the return value to both overwrite maps.
            then_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), then_return);
            else_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), else_return);
        } else {
            // Return in `then` block but not `else` block.
            handle_unbalanced_return(
                codegen,
                function,
                location,
                then_return,
                then_info.block,
                &mut then_info.var_overwrites,
                else_info.block,
                &mut else_info.var_overwrites,
            )?;
        }
    } else if let Some(else_return) = else_return_opt {
        // Return in `else` block but not `then` block.
        handle_unbalanced_return(
            codegen,
            function,
            location,
            else_return,
            else_info.block,
            &mut else_info.var_overwrites,
            then_info.block,
            &mut then_info.var_overwrites,
        )?;
    }

    function.gen_scf_if(codegen, location, condition, then_info, else_info)?;

    // Finally, if both blocks ended with a return, then add a new return/yield here. Else,
    // if only one block returned, gen additional code to handle the unbalanced return.
    if then_return_opt.is_some() && else_return_opt.is_some() {
        let ret_val = function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL)?;
        function.append_circom_return(codegen, location, *ret_val)?;
        // Since we added a return/yield here, the rest of current block is unreachable.
        return Ok(true);
    } else if then_return_opt.is_some() || else_return_opt.is_some() {
        gen_unbalanced_return_extra(codegen, function, location)?;
    }
    Ok(false)
}

/// Generate LLZK code for a circom [Statement::While].
fn gen_while<'ast, 'ctx, 'func, 'blk, 'val, 'info>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'info>,
    meta: &Meta,
    cond: &Expression,
    body_stmt: &Statement,
    loop_bounds: Option<LoopBoundsAttribute<'ctx>>,
) -> Result<SkipRestOfBlock>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    // Generate the loop condition (i.e. "before") and body (i.e. "after") blocks naively.
    let mut loop_cond_info = NestedBlockInfo::default();
    let cond_result = function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        loop_cond_info.block,
        |fc| cond.gen_llzk_in_function(codegen, fc, info),
        &mut loop_cond_info,
    )?;
    let mut loop_body_info = NestedBlockInfo::default();
    function.gen_in_given_block_with_new_circom_scope_and_cache_overwrites(
        loop_body_info.block,
        |fc| body_stmt.gen_llzk_in_function(codegen, fc, info),
        &mut loop_body_info,
    )?;

    let location = codegen.location_from_meta(meta);

    // Check if loop body block ends with a return in circom. The `scf.while` op used in LLZK cannot
    // have returns nested within other blocks like circom allows. Use of `append_circom_return()`
    // already ensures `scf.yield` is used instead of `function.return` when not in the root block
    // but the `scf.while` additionally requires that both blocks yield the same number and type
    // of values. Additionally, if the loop body block returns (in the circom code), an additional
    // return state must be added to the values to be yielded and an additional `scf.if` must be
    // added after the `scf.while` to check the return state flag.
    if let Some(early_return) = get_val_of_circom_return_and_erase(loop_body_info.block) {
        // Within the loop body, set `VAR_NAME_HAD_RETURN` to `true` since a return occurs.
        loop_body_info.var_overwrites.insert(
            VAR_NAME_HAD_RETURN.to_string(),
            single_result_as_value(
                loop_body_info.block.append_operation(codegen.new_bool_const_op(true, location)),
            )?,
        );
        // In the current block, initialize the `VAR_NAME_HAD_RETURN` flag to `false` to capture the
        // scenario where the loop body does not execute and thus the return within does not occur.
        function.append_op_named_result(
            codegen.new_bool_const_op(false, location),
            VAR_NAME_HAD_RETURN.to_string(),
        )?;

        // Add the return value to the overwrite map of the loop body.
        loop_body_info.var_overwrites.insert(VAR_NAME_RETURN_VAL.to_string(), early_return);
        // In the current block, ensure the return value variable is initialized, default to nondet.
        if function.block_ctx.get_named_value(VAR_NAME_RETURN_VAL).is_err() {
            function.append_op_named_result(
                codegen.new_nondet_at_location(location, early_return.r#type())?,
                VAR_NAME_RETURN_VAL.to_string(),
            )?;
        }
    }

    // Generate the loop op.
    let had_return = function.gen_scf_while(
        codegen,
        location,
        cond_result,
        loop_cond_info,
        loop_body_info,
        loop_bounds,
    )?;

    // Finally, if the loop body contained a return statement, gen additional code to handle it.
    if had_return {
        gen_unbalanced_return_extra(codegen, function, location)?;
    }
    Ok(false)
}

/// Generate LLZK code for a circom [Statement::InitializationBlock].
/// This is needed to support the `try_for_loop_heuristic` macro.
#[inline]
fn gen_init_block<'ast, 'ctx, 'func, 'blk, 'val>(
    codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
    function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
    info: InfoProviders<'_>,
    initializations: &[Statement],
) -> Result<()>
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    initializations.gen_llzk_in_function(codegen, function, info)
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for Statement
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output = SkipRestOfBlock;

    fn gen_llzk_in_function<'ast, 'info>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Self::Output> {
        match self {
            Statement::InitializationBlock { xtype, initializations, .. } => {
                if let VariableType::Signal(..) = xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                gen_init_block(codegen, function, info, initializations)?;
                Ok(false)
            }
            Statement::Declaration { meta, xtype, name, dimensions, .. } => {
                if VariableType::Var != *xtype {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Template elements declared inside the function")
                }
                function.gen_declaration(codegen, meta, name, dimensions)?;
                Ok(false)
            }
            Statement::Block { meta, stmts } => {
                function.gen_in_current_block_with_new_circom_scope_and_merge_overwrites(
                    |function| {
                        try_for_loop_heuristic!(codegen, function, meta, stmts, info);
                        // Fallback to standard block handling.
                        stmts.gen_llzk_in_function(codegen, function, info)?;
                        Ok(false)
                    },
                )?;
                Ok(false)
            }
            Statement::Substitution { meta, var, access, op, rhe } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                let rvalue = rhe.gen_llzk_in_function(codegen, function, info)?;
                match access.as_slice() {
                    [] => {
                        // Since there's no simple assignment in LLZK, just update the mapped Value
                        // which essentially propagates the assignment.
                        function.block_ctx.set_named_value(var.clone(), rvalue)?;
                    }
                    a => {
                        let location = codegen.location_from_meta(meta);
                        let indices = &a
                            .iter()
                            .map(|access| {
                                let idx = match access {
                                    Access::ArrayAccess(index_expr) => {
                                        index_expr.gen_llzk_in_function(codegen, function, info)
                                    }
                                    #[allow(unused_variables)] // TODO: TEMP
                                    Access::ComponentAccess(name) => {
                                        todo!("Handle Substitution component access in function")
                                    }
                                }?;
                                function.cast_to_index_if_needed(location, idx)
                            })
                            .collect::<Result<Vec<Value<'_, '_>>>>()?;
                        let arr_ref = function.block_ctx.get_named_value(var)?;
                        function.append_array_write(
                            codegen,
                            *arr_ref,
                            indices,
                            location,
                            rvalue,
                            Some(var),
                        )?;
                    }
                }
                Ok(false)
            }
            Statement::UnderscoreSubstitution { op, rhe, .. } => {
                if op.is_signal_operator() {
                    // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                    unreachable!("Function uses template operators");
                }
                // Just visit and drop the resulting Value since it's unused.
                rhe.gen_llzk_in_function(codegen, function, info).map(drop)?;
                Ok(false)
            }
            Statement::IfThenElse { meta, cond, if_case, else_case } => {
                gen_if_then_else(codegen, function, info, meta, cond, if_case, else_case)
            }
            Statement::While { meta, cond, stmt } => {
                gen_while(codegen, function, info, meta, cond, stmt, None)
            }
            Statement::Return { meta, value } => {
                let value = value.gen_llzk_in_function(codegen, function, info)?;
                let location = codegen.location_from_meta(meta);
                function.append_circom_return(codegen, location, value)?;
                // circom allows unreachable code after a return but it is not processed
                // (e.g. `assert(1 == 0)` after a return does not cause an error as it normally
                // would) so replicate the same behavior here by stopping processing after a
                // return (which is also what MLIR expects, no code after a terminator op).
                Ok(true)
            }
            Statement::Assert { meta, arg } => {
                let cond = arg.gen_llzk_in_function(codegen, function, info)?;
                let location = codegen.location_from_meta(meta);
                let cond = function.cast_to_bool_if_needed(codegen, location, cond)?;
                let msg = Some("assertion failed");
                function.append_op_no_result(llzk::dialect::bool::assert(location, cond, msg)?)?;
                Ok(false)
            }
            Statement::LogCall { meta, .. } => {
                codegen.emit_circom_warning(
                    meta,
                    "log calls are not currently supported in LLZK",
                    ReportCode::NotAllowedOperation,
                );
                Ok(false)
            }
            Statement::MultSubstitution { .. } => {
                unreachable!("removed by 'syntax_sugar_remover'")
            }
            Statement::ConstraintEquality { .. } => {
                // per `type_analysis/src/analyzers/functions_free_of_template_elements.rs`
                unreachable!("Function uses template operators");
            }
        }
    }
}

/// This handles translation of circom [Expression] nodes within functions and templates (i.e.
/// [crate::template::GenerateLLZKInTemplate] implementation for [Expression] directly calls this).
/// Therefore, it must handle things that are not legal in functions such as [Expression::BusCall]
/// and [Access::ComponentAccess]. The `type_analysis_user::analyse_project()` pass that runs before
/// the LLZK translation pass ensures that these illegal constructs do not appear in pure functions.
impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for Expression
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output = Value<'ctx, 'val>;

    fn gen_llzk_in_function<'ast, 'info>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Self::Output> {
        match self {
            Expression::Number(meta, big_int) => {
                // Convert the BigInt to an LLZK `felt.const` op. The user of the Expression is
                // responsible for converting this `felt.type` value to another type if needed.
                function.append_op_unnamed_result(
                    codegen.new_felt_const_op(big_int, codegen.location_from_meta(meta))?,
                )
            }
            Expression::Variable { meta, name, access } => {
                let lvalue = Lvalue::new(
                    name,
                    if info.subcmp_info.is_subcmp(name) { Root::Signal } else { Root::Var },
                    access,
                );
                lvalue.get_value(
                    codegen,
                    function,
                    info.subcmp_info,
                    codegen.location_from_meta(meta),
                    None,
                )
            }
            Expression::InfixOp { meta, lhe, infix_op, rhe } => {
                let lhs = lhe.gen_llzk_in_function(codegen, function, info)?;
                let rhs = rhe.gen_llzk_in_function(codegen, function, info)?;
                function.gen_infix_op(codegen, meta, infix_op, lhs, rhs)
            }
            Expression::PrefixOp { meta, prefix_op, rhe } => {
                let rhs = rhe.gen_llzk_in_function(codegen, function, info)?;
                function.gen_prefix_op(codegen, meta, prefix_op, rhs)
            }
            Expression::InlineSwitchOp { meta, cond, if_true, if_false } => {
                let location = codegen.location_from_meta(meta);
                // Ensure the condition is a bool type.
                let cond_val = cond.gen_llzk_in_function(codegen, function, info)?;
                let condition = function.cast_to_bool_if_needed(codegen, location, cond_val)?;
                let scf_if_op = function.generate_simple_scf_if(
                    codegen,
                    meta,
                    condition,
                    |fc| if_true.gen_llzk_in_function(codegen, fc, info),
                    |fc| if_false.gen_llzk_in_function(codegen, fc, info),
                )?;

                function.append_op_unnamed_result(scf_if_op)
            }
            Expression::ArrayInLine { meta, values } => {
                let location = codegen.location_from_meta(meta);
                let builder = &OpBuilder::new(codegen.context);
                // Multi-dimensional arrays are made up of array values as their elements
                let values = values
                    .iter()
                    .map(|val_expr| val_expr.gen_llzk_in_function(codegen, function, info))
                    .collect::<Result<Vec<Value>>>()?;
                let value_ty =
                    values.first().expect("Array must have at least one element").r#type();
                assert!(
                    values.iter().all(|&v| v.r#type() == value_ty),
                    "All array elements must have the same type"
                );
                if let Ok(subarr_ty) = ArrayType::try_from(value_ty) {
                    // For subarrays, we need to create a new array then insert the values
                    let dim = codegen.index_attr(i64::try_from(values.len())?);
                    let arr_ty = new_array_type(dim.into(), &subarr_ty);
                    let new_arr = function.append_op_unnamed_result(array::new(
                        builder,
                        location,
                        arr_ty,
                        llzk::dialect::array::ArrayCtor::Values(&[]),
                    ))?;
                    for (idx, val) in values.iter().enumerate() {
                        let idx_val = function.append_op_unnamed_result(
                            codegen.new_index_const_op(i64::try_from(idx)?, location),
                        )?;
                        function.append_op_no_result(array::insert(
                            location,
                            new_arr,
                            &[idx_val],
                            *val,
                        ))?;
                    }

                    // Output value is still the newly created array
                    Ok(new_arr)
                } else {
                    let dim = codegen.index_attr(i64::try_from(values.len())?);
                    let arr_ty = ArrayType::new(value_ty.into(), &[dim.into()]);
                    function.append_op_unnamed_result(array::new(
                        builder,
                        location,
                        arr_ty,
                        llzk::dialect::array::ArrayCtor::Values(&values),
                    ))
                }
            }
            Expression::UniformArray { meta, value, dimension } => {
                let location = codegen.location_from_meta(meta);
                // Multi-dimensional arrays are made up of array values as their elements
                let value = value.gen_llzk_in_function(codegen, function, info)?;
                let dim_result = function.convert_dim_expr(codegen, dimension)?;
                let dim = Option::from(dim_result)
                    .ok_or_else(|| anyhow!("unable to convert dimension in function context"))?;
                function.generate_uniform_array(codegen, location, value, &dim)
            }
            Expression::Call { meta, id, args } => {
                let builder = OpBuilder::new(codegen.context.deref());
                let location = codegen.location_from_meta(meta);
                let target_function_data = codegen.program.get_function_data(id);
                // Visit each argument and collect the resulting LLZK Values for both functions.
                let param_types = target_function_data.get_type_of_params(codegen);
                assert_eq!(param_types.len(), args.len(), "Argument-parameter count mismatch");
                let call_operands = args
                    .iter()
                    .zip(param_types)
                    .map(|(arg, expected_type)| {
                        let operand_val = arg.gen_llzk_in_function(codegen, function, info)?;
                        function.cast_to_expected_type_if_needed(
                            codegen,
                            location,
                            operand_val,
                            expected_type,
                        )
                    })
                    .collect::<Result<Vec<Value>>>()?;
                // Create the CallOp in each function using the collected args.
                function.append_op_unnamed_result(
                    function::call(
                        &builder,
                        location,
                        FlatSymbolRefAttribute::new(codegen.context, id),
                        &call_operands,
                        &[target_function_data.get_type_of_return(codegen)],
                    )?
                    .into(),
                )
            }
            #[allow(unused_variables)] // TODO: TEMP
            Expression::BusCall { meta, id, args } => {
                todo!("Handle BusCall expression")
            }
            Expression::AnonymousComp { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::Tuple { .. } => unreachable!("removed by 'syntax_sugar_remover'"),
            Expression::ParallelOp { .. } => {
                unreachable!("handled in templates, illegal in pure functions")
            }
        }
    }
}

impl<'ctx, 'func, 'blk, 'val> GenerateLLZKInFunction<'ctx, 'func, 'blk, 'val> for [Statement]
where
    'ctx: 'func,
    'func: 'blk,
    'blk: 'val,
{
    type Output = ();

    fn gen_llzk_in_function<'ast, 'info>(
        &'ast self,
        codegen: &LlzkCodegen<'ast, 'ctx, impl ProgramLike>,
        function: &mut FunctionContext<'ctx, 'func, 'blk, 'val>,
        info: InfoProviders<'info>,
    ) -> Result<Self::Output> {
        for s in self {
            let skip_rest_of_block = s.gen_llzk_in_function(codegen, function, info)?;
            if skip_rest_of_block {
                break;
            }
        }
        Ok(())
    }
}
