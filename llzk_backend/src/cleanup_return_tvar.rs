//! Find all `function.call` with `poly.tvar` result type and determine the actual type required by
//! looking at use site(s) of the result. Update the `function.call` result type to the inferred
//! type and delete the generated `poly.param` that was backing the type variable. This is necessary
//! to remove the `poly.param` that were added to support call result receiving type variables, but
//! were not added to `struct.type` instances, causing a verification error.

use crate::function_ext::function_return_type_param;
use crate::program_ext::ProgramLike;
use crate::shared;
use crate::shared::LlzkCodegen;
use crate::traversal::walk_from_block;
use crate::traversal::WalkCallbacks;
use anyhow::bail;
use anyhow::Result;
use llzk::attributes::array::ArrayAttribute;
use llzk::builder::EntryPoint;
use llzk::builder::OpBuilder;
use llzk::dialect::function;
use llzk::dialect::poly;
use llzk::prelude::Block;
use llzk::prelude::BlockLike as _;
use llzk::prelude::CallOpLike as _;
use llzk::prelude::CallOpRef;
use llzk::prelude::FuncDefOpLike as _;
use llzk::prelude::FunctionType;
use llzk::prelude::LlzkError;
use llzk::prelude::OperationLike;
use llzk::prelude::OperationRefMut;
use llzk::prelude::OperationResult;
use llzk::prelude::RegionLike as _;
use llzk::prelude::TemplateOpLike as _;
use llzk::prelude::TemplateOpRef;
use llzk::prelude::TemplateOpRefMut;
use llzk::prelude::TemplateParamOpRefMut;
use llzk::prelude::TemplateSymbolBindingOpLike as _;
use llzk::prelude::Type;
use llzk::prelude::Value;
use llzk::prelude::ValueLike as _;
use llzk::symbol_ref::SymbolRefAttribute;
use llzk::value_ext::replace_all_uses;
use llzk::value_ext::users_of;
use std::convert::TryFrom;

/// Base name for synthetic functions created to wrap `function.call` operations with
/// unused result Values in order to resolve a type verification issue.
const UNUSED_CALL_RESULT_WRAPPER_NAME: &str = "synthetic";

/// Infers the concrete result type required by all `poly.unifiable_cast` users of a call.
/// Returns `Ok(None)` when the call result has no use sites.
fn infer_type_from_unifiable_cast_uses<'ctx: 'a, 'a>(
    call_op: CallOpRef<'ctx, 'a>,
) -> Result<Option<Type<'ctx>>> {
    let result = call_op.result(0)?;
    let mut inferred_type = None;
    for user in users_of(result) {
        if !poly::is_unifiable_cast_op(&user) {
            bail!("expected poly.unifiable_cast but found {user}");
        }

        let use_type = user.result(0)?.r#type();
        match inferred_type {
            None => inferred_type = Some(use_type),
            Some(ty) if ty != use_type => bail!(
                "function.call at {} has type-variable result used as both {ty} and {use_type}",
                call_op.location()
            ),
            Some(_) => {}
        }
    }
    Ok(inferred_type)
}

/// Finds the enclosing `poly.template` operation for a nested operation.
fn parent_template<'ctx: 'a, 'a>(
    op: &impl OperationLike<'ctx, 'a>,
) -> Result<TemplateOpRef<'ctx, 'a>> {
    let mut parent_opt = shared::parent_operation(op);
    while let Some(parent) = parent_opt {
        if let Ok(r) = TemplateOpRef::try_from(parent) {
            return Ok(r);
        }
        parent_opt = shared::parent_operation(&parent);
    }
    bail!("function.call with type-variable result is not inside a poly.template")
}

/// Removes the generated `poly.param` that backs a temporary type variable.
fn remove_generated_tvar_param(template: TemplateOpRef<'_, '_>, name: &str) -> Result<()> {
    let mut op = template.body().first_operation_mut();
    while let Some(mut cur) = op {
        op = shared::next_in_block_mut(&cur);
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
/// The replacement call at the original site passes `templateParams = [?]` for `@T_return`.
fn wrap_call_in_synthetic_template<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    call_op: CallOpRef<'ctx, '_>,
) -> Result<mlir_sys::MlirOperation> {
    let location = call_op.location();
    let operand_types: Vec<_> = call_op.operands().map(|v| v.r#type()).collect();

    // The tvar type that lives inside the synthetic template, referencing its own @T_return param.
    let synthetic_tvar_type = codegen.tvar_type(function_return_type_param());

    let func_type = FunctionType::new(codegen.context, &operand_types, &[]);

    // Use a temporary block to build the synthetic template because it will be detached and
    // re-inserted to avoid naming collisions.
    let scratch = Block::new(&[]);
    let builder = OpBuilder::at_block_end(codegen.context, &scratch);
    let mut inner_call = None;

    // Build poly.template @synthetic { poly.param; function.def }.
    let template_op =
        poly::template(&builder, location, UNUSED_CALL_RESULT_WRAPPER_NAME, |builder| {
            poly::param(
                builder,
                location,
                function_return_type_param(),
                Some(synthetic_tvar_type),
            )?;
            let func_def = function::def(
                builder,
                location,
                UNUSED_CALL_RESULT_WRAPPER_NAME,
                func_type,
                &[],
                None,
                llzk::dialect::empty_region,
            )?;
            func_def.set_allow_non_native_field_ops_attr(true);

            let block = func_def.body()?.first_block().expect("synthetic function body is empty");
            let inner_builder = OpBuilder::at_block_end(codegen.context, block);

            // Rebuild the original call inside the synthetic function using the block args as
            // operands. The result type references the synthetic template's own @T_return param.
            let block_args = (0..operand_types.len())
                .map(|i| block.argument(i).map(Value::from).map_err(LlzkError::from))
                .collect::<std::result::Result<Vec<_>, LlzkError>>()?;
            let call = function::call(
                &inner_builder,
                location,
                call_op.callee()?,
                &block_args,
                &[synthetic_tvar_type],
            )?;

            // The result of the inner call is discarded; return void.
            function::r#return(&inner_builder, location, &[]);
            inner_call = Some(call.to_raw());
            Ok(())
        })?;
    let inner_call = inner_call.expect("synthetic template callback must create inner call");

    // Detach and re-insert the template into the module to unique the name and avoid collisions.
    let template_op = shared::detach_owned_operation(&template_op);
    let op_ref = shared::insert_unique_symbol_op(&codegen.module.as_operation(), template_op);
    let template_name = shared::get_sym_name_attr(&op_ref)
        .expect("`poly.template` must have `sym_name` attribute per ODS");
    let callee = SymbolRefAttribute::new_from_str(
        codegen.context,
        template_name.value(),
        &[UNUSED_CALL_RESULT_WRAPPER_NAME],
    );

    // The replacement call passes the original operands and uses wildcard attribute for the
    // template params (i.e. the unused return `tvar` of the call op).
    let original_operands: Vec<_> = call_op.operands().collect();
    let replacement_builder = OpBuilder::new(codegen.context, EntryPoint::Before(call_op.into()));
    function::call_with_template_params(
        &replacement_builder,
        location,
        callee,
        &original_operands,
        // no return from synthetic function; original result was already unused
        &[] as &[Type<'ctx>],
        &[codegen.wildcard_attr()],
    )?;
    Ok(inner_call)
}

/// Specializes the result type of a `function.call` operation from its inferred concrete type.
/// The original call is replaced by a new one with the concrete result type; all uses of the old
/// result are updated to point to the new result. After updating, any `poly.unifiable_cast` ops
/// that became identity casts (input type == output type) as a result of this specialization are
/// removed and their uses forwarded directly to their input.
fn specialize_call_result_type<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    call_op: CallOpRef<'ctx, '_>,
    old_result: OperationResult<'ctx, '_>,
    use_type: Type<'ctx>,
) -> Result<mlir_sys::MlirOperation> {
    let callee = call_op.callee()?;
    let operands: Vec<_> = call_op.operands().collect();
    let location = call_op.location();
    let builder = OpBuilder::new(codegen.context, EntryPoint::Before(call_op.into()));
    let new_call = function::call(&builder, location, callee, &operands, &[use_type])?;
    let new_call_raw = new_call.to_raw();
    let new_result = Value::from(new_call.result(0)?);
    replace_all_uses(Value::from(old_result), new_result);

    // After replace_all_uses, any `poly.unifiable_cast` that was consuming the old tvar result now
    // consumes `new_result`. If such a cast has become an identity (input type == output type),
    // it is a no-op introduced solely to bridge the tvar; remove it and forward its output uses
    // directly to its input.
    let identity_casts: Vec<_> = users_of(new_result)
        .into_iter()
        .filter(|user| {
            poly::is_unifiable_cast_op(user)
                && user
                    .result(0)
                    .ok()
                    .zip(user.operand(0).ok())
                    .is_some_and(|(res, inp)| res.r#type() == inp.r#type())
        })
        .collect();

    for op in identity_casts {
        let cast_result = op.result(0)?;
        let cast_input = op.operand(0)?;
        replace_all_uses(Value::from(cast_result), cast_input);
        let _drop =
            shared::remove_from_parent(&mut unsafe { OperationRefMut::from_raw(op.to_raw()) });
    }

    Ok(new_call_raw)
}

/// Count the number of `poly.param` ops that are direct children of the `poly.template` with the
/// given `sym_name` in the module body. Returns `None` if no matching template is found.
fn count_poly_params_in_callee_template(
    codegen: &LlzkCodegen<'_, '_, '_, impl ProgramLike>,
    callee_func_name: &str,
) -> Option<usize> {
    let mut op = codegen.module.body().first_operation_mut();
    while let Some(cur) = op {
        op = shared::next_in_block_mut(&cur);
        if let Ok(tmpl) = TemplateOpRefMut::try_from(cur) {
            let is_match =
                shared::get_sym_name_attr(&tmpl).is_ok_and(|a| a.value() == callee_func_name);
            if is_match {
                return Some(tmpl.const_param_names().len());
            }
        }
    }
    None
}

/// Specializes type-variable function call results from their concrete cast use sites.
pub(crate) fn specialize_tvar_function_calls<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
) -> Result<()> {
    if codegen.config.verbose {
        println!("Module state before `specialize_tvar_function_calls()`:");
        codegen.dump_module();
    }

    // All `CallOpRef` within the module body.
    let mut calls = Vec::new();
    walk_from_block(
        codegen.module.body(),
        WalkCallbacks::for_ops(|op| {
            if function::is_func_call(&op) {
                calls.push(op.to_raw());
            }
        }),
    );
    for raw_call in &mut calls {
        let call_op = unsafe { CallOpRef::from_raw(*raw_call) };
        if call_op.result_count() != 1 {
            continue;
        }
        let call_result = call_op.result(0)?;
        if let Ok(result_tvar) = poly::TVarType::try_from(call_result.r#type()) {
            // Generate a new call with the inferred type from user(s) of the call result
            // or a new call to a synthetic wrapper function if there are no users.
            let rewritten_call = match infer_type_from_unifiable_cast_uses(call_op)? {
                Some(use_type) => {
                    specialize_call_result_type(codegen, call_op, call_result, use_type)?
                }
                None => wrap_call_in_synthetic_template(codegen, call_op)?,
            };
            // Remove the old op and type variable param.
            let tvar_name = result_tvar.name().as_str()?.to_owned();
            let template = parent_template(&call_op)?;
            remove_generated_tvar_param(template, &tvar_name)?;
            let _drop =
                shared::remove_from_parent(&mut unsafe { OperationRefMut::from_raw(*raw_call) });
            // Replace the deleted call op with the new one in the `calls` vector.
            *raw_call = rewritten_call;
        }
    }

    // Second pass: set `templateParams` on circom function calls whose callee template has more
    // `poly.param` ops than the default (#args + #results). In the normal case, the first pass
    // above removes all temporary tvar params (e.g. `$t_0`) from every callee template, leaving
    // the count equal to the default and making this pass a no-op. This pass exists as a safety
    // net for any edge case where extra params survive. Only `function.call` ops with exactly one
    // nested callee reference are considered — the `@f::@f` style used for circom function calls,
    // as opposed to struct method calls like `@T::@T::@compute` which have two nested refs.
    for raw_call in calls {
        let call_op = unsafe { CallOpRef::from_raw(raw_call) };
        let callee_path = call_op.callee()?.nested();
        if callee_path.len() != 1 {
            continue;
        }
        // For `@f::@f`, `callee_path[0]` is the function/template name within the module.
        let func_name = callee_path[0].value();
        if let Some(param_count) = count_poly_params_in_callee_template(codegen, func_name) {
            // When the verifier sees a `function.call` without an explicit `templateParams`
            // attribute it assumes the callee has exactly (#args + #results) params. Only set
            // `templateParams` explicitly when the callee has additional params beyond that.
            let default_param_count = call_op.operand_count() + call_op.result_count();
            if param_count > default_param_count {
                // TODO: this could use actual types for params and returns instead of wildcards.
                let attr = ArrayAttribute::new(
                    codegen.context,
                    &vec![codegen.wildcard_attr(); param_count],
                );
                call_op.set_template_params(Some(attr));
            }
        }
    }

    Ok(())
}
