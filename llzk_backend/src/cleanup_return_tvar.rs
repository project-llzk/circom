//! Find all `function.call` with `poly.tvar` result type and determine the actual type required by
//! looking at use site(s) of the result. Update the `function.call` result type to the inferred
//! type and delete the generated `poly.param` that was backing the type variable. This is necessary
//! to remove the `poly.param` that were added to support call result receiving type variables, but
//! were not added to `struct.type` instances, causing a verification error.

use crate::function_ext::function_return_type_param;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::next_in_block_mut;
use crate::shared::LlzkCodegen;
use crate::traversal::walk_from_block;
use crate::traversal::WalkCallbacks;
use anyhow::bail;
use anyhow::Result;
use llzk::dialect::function;
use llzk::dialect::poly;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::FunctionType;
use llzk::prelude::OperationLike as _;
use llzk::prelude::OperationRef;
use llzk::prelude::OperationRefMut;
use llzk::prelude::OperationResult;
use llzk::prelude::RegionLike as _;
use llzk::prelude::TemplateOpLike as _;
use llzk::prelude::TemplateOpRef;
use llzk::prelude::TemplateParamOpRefMut;
use llzk::prelude::TemplateSymbolBindingOpLike as _;
use llzk::prelude::Type;
use llzk::prelude::TypeAttribute;
use llzk::prelude::Value;
use llzk::prelude::ValueLike;
use llzk::symbol_ref::SymbolRefAttribute;
use llzk::value_ext::replace_all_uses;
use std::convert::TryFrom;

/// Base name for synthetic functions created to wrap `function.call` operations with
/// unused result Values in order to resolve a type verification issue.
const UNUSED_CALL_RESULT_WRAPPER_NAME: &str = "synthetic";

/// Returns the operations that use the given value.
fn users_of<'ctx: 'a, 'a>(value: impl ValueLike<'ctx> + Copy) -> Vec<OperationRef<'ctx, 'a>> {
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

/// Infers the concrete result type required by all `poly.unifiable_cast` users of a call.
/// Returns `Ok(None)` when the call result has no use sites.
fn infer_type_from_unifiable_cast_uses<'ctx: 'a, 'a>(
    call_op: OperationRef<'ctx, 'a>,
) -> Result<Option<Type<'ctx>>> {
    let result = call_op.result(0)?;
    let location = call_op.location();
    let mut inferred_type = None;
    for user in users_of(result) {
        if !poly::is_unifiable_cast_op(&user) {
            bail!("expected poly.unifiable_cast but found {user}");
        }

        let use_type = user.result(0)?.r#type();
        match inferred_type {
            None => inferred_type = Some(use_type),
            Some(ty) if ty != use_type => bail!(
                "function.call at {location} has type-variable result used as both {ty} and {use_type}"
            ),
            Some(_) => {}
        }
    }
    Ok(inferred_type)
}

/// Finds the enclosing `poly.template` operation for a nested operation.
fn parent_template<'ctx: 'a, 'a>(
    op: &'a OperationRef<'ctx, 'a>,
) -> Result<TemplateOpRef<'ctx, 'a>> {
    let mut parent_opt = op.parent_operation();
    while let Some(parent) = parent_opt {
        if let Ok(r) = TemplateOpRef::try_from(parent) {
            return Ok(r);
        }
        parent_opt = unsafe { parent.to_ref() }.parent_operation();
    }
    bail!("function.call with type-variable result is not inside a poly.template")
}

/// Removes the generated `poly.param` that backs a temporary type variable.
fn remove_generated_tvar_param(template: TemplateOpRef<'_, '_>, name: &str) -> Result<()> {
    let mut op = template.body().first_operation_mut();
    while let Some(mut cur) = op {
        op = next_in_block_mut(&cur);
        if let Ok(param) = TemplateParamOpRefMut::try_from(cur) {
            if param.sym_name() == name {
                let _drop = shared::remove_from_parent(&mut cur);
                return Ok(());
            }
        }
    }
    bail!("generated poly.param '{name}' was not found")
}

/// Wraps a `function.call` with a type-variable result that has no use sites into a synthetic
/// `poly.template` + `function.def`, then replaces the original call with a call to the synthetic
/// function. The synthetic template looks like:
///
/// ```text
/// poly.template @synthetic {
///   poly.param @T_return : !poly.tvar<@T_return>
///   function.def @synthetic(arg0: T0, ...) {
///     %_ = function.call @original(arg0, ...) : (T0, ...) -> !poly.tvar<@T_return>
///     function.return
///   }
/// }
/// ```
///
/// The replacement call at the original site passes `templateParams = [none]` for `@T_return`.
fn wrap_call_in_synthetic_template<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    call_op: OperationRef<'ctx, '_>,
) -> Result<()> {
    let location = call_op.location();
    let operand_types: Vec<_> = call_op.operands().map(|v| v.r#type()).collect();
    let callee = SymbolRefAttribute::try_from(call_op.attribute("callee")?)?;

    // The tvar type that lives inside the synthetic template, referencing its own @T_return param.
    let synthetic_tvar_type = codegen.tvar_type(function_return_type_param());

    // Build the synthetic function.def with a body block taking the call's operands as args.
    let func_type = FunctionType::new(codegen.context, &operand_types, &[]);
    let func_def = function::def(location, UNUSED_CALL_RESULT_WRAPPER_NAME, func_type, &[], None)?;
    func_def.set_allow_non_native_field_ops_attr(true);
    {
        let arg_locs: Vec<_> = operand_types.iter().map(|&t| (t, location)).collect();
        let block = func_def.region(0)?.append_block(Block::new(&arg_locs));
        let block_args = (0..operand_types.len())
            .map(|i| block.argument(i).map(Value::from).map_err(Into::into))
            .collect::<Result<Vec<_>>>()?;

        // Rebuild the original call inside the synthetic function using the block args as operands.
        // The result type references the synthetic template's own @T_return param.
        let inner_call = function::call(
            codegen.op_builder(),
            location,
            callee,
            &block_args,
            &[synthetic_tvar_type],
        )?;
        block.append_operation(inner_call.into());

        // The result of the inner call is discarded; return void.
        block.append_operation(function::r#return(location, &[]));
    } // block and block_args dropped here, releasing the borrow on func_def

    // Build poly.param @T_return : !poly.tvar<@T_return>.
    let param_op = poly::param(location, function_return_type_param(), Some(synthetic_tvar_type))?;

    // Build poly.template @synthetic { poly.param; function.def }.
    let template_op = poly::template(
        location,
        UNUSED_CALL_RESULT_WRAPPER_NAME,
        [Ok(param_op.into()), Ok(func_def.into())],
    )?;

    // Insert the template into the module, uniquing the name to avoid collisions.
    let template_name =
        shared::insert_unique_symbol_op(&codegen.module.as_operation(), template_op);
    let callee = SymbolRefAttribute::new_from_str(
        codegen.context,
        template_name.value(),
        &[UNUSED_CALL_RESULT_WRAPPER_NAME],
    );

    // The replacement call passes the original operands and uses `none` for the template params
    // (i.e. the unused return `tvar` of the call op).
    let original_operands: Vec<_> = call_op.operands().collect();
    let replacement = shared::build_func_call_with_template_params(
        codegen.context,
        location,
        callee,
        &original_operands,
        &[], // synthetic function returns void; original result was already unused
        Some(&[TypeAttribute::new(Type::none(codegen.context)).into()]),
    )?;

    // Insert the replacement before the original call, then remove the original.
    let call_block = call_op
        .block()
        .ok_or_else(|| anyhow::anyhow!("function.call at {location} has no parent block"))?;
    call_block.insert_operation_before(call_op, replacement);
    Ok(())
}

/// Specializes the result type of a `function.call` operation from its inferred concrete type.
/// The original call is replaced by a new one with the concrete result type; all uses of the old
/// result are updated to point to the new result.
fn specialize_call_result_type<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    call_op: OperationRef<'ctx, '_>,
    old_result: OperationResult<'ctx, '_>,
    use_type: Type<'ctx>,
) -> Result<()> {
    let callee = SymbolRefAttribute::try_from(call_op.attribute("callee")?)?;
    let operands: Vec<_> = call_op.operands().collect();
    let location = call_op.location();
    let block = call_op
        .block()
        .ok_or_else(|| anyhow::anyhow!("function.call at {location} has no parent block"))?;
    let new_call = block.insert_operation_before(
        call_op,
        function::call(codegen.op_builder(), location, callee, &operands, &[use_type])?.into(),
    );
    replace_all_uses(Value::from(old_result), Value::from(new_call.result(0)?));
    Ok(())
}

/// Specializes type-variable function call results from their concrete cast use sites.
pub(crate) fn specialize_tvar_function_calls<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
) -> Result<()> {
    let mut calls = Vec::new();
    walk_from_block(
        codegen.module.body(),
        WalkCallbacks::for_ops(|op| {
            if function::is_func_call(&op)
                && op.result_count() == 1
                && poly::is_type_variable(op.result(0).expect("result exists").r#type())
            {
                calls.push(op.to_raw());
            }
        }),
    );

    for raw_call in calls {
        let call_op = unsafe { OperationRef::from_raw(raw_call) };
        let old_result = call_op.result(0)?;
        // Generate a new call with the inferred type from user(s) of the call result
        // or a new call to a synthetic wrapper function if there are no users.
        match infer_type_from_unifiable_cast_uses(call_op)? {
            Some(use_type) => {
                specialize_call_result_type(codegen, call_op, old_result, use_type)?;
            }
            None => {
                wrap_call_in_synthetic_template(codegen, call_op)?;
            }
        }
        // Remove the old op and type variable param.
        let tvar_name = poly::TVarType::try_from(old_result.r#type())?.name().as_str()?.to_owned();
        let template = parent_template(&call_op)?;
        remove_generated_tvar_param(template, &tvar_name)?;
        let _drop = shared::remove_from_parent(&mut unsafe { OperationRefMut::from_raw(raw_call) });
    }

    Ok(())
}
