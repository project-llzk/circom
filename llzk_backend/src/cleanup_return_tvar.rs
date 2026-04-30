//! Find all `function.call` with `poly.tvar` result type and determine the actual type required by
//! looking at use site(s) of the result. Update the `function.call` result type to the inferred
//! type and delete the generated `poly.param` that was backing the type variable. This is necessary
//! to remove the `poly.param` that were added to support call result receiving type variables, but
//! were not added to `struct.type` instances, causing a verification error.

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
use llzk::prelude::BlockLike as _;
use llzk::prelude::OperationLike;
use llzk::prelude::OperationRef;
use llzk::prelude::OperationRefMut;
use llzk::prelude::TemplateOpLike as _;
use llzk::prelude::TemplateOpRef;
use llzk::prelude::Type;
use llzk::prelude::Value;
use llzk::prelude::ValueLike;
use llzk::value_ext::replace_all_uses;
use melior::ir::attribute::StringAttribute;
use melior::ir::operation::OperationBuilder;
use std::convert::TryFrom;

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
fn infer_type_from_unifiable_cast_uses<'ctx: 'a, 'a>(
    call_op: OperationRef<'ctx, 'a>,
) -> Result<Type<'ctx>> {
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

    match inferred_type {
        Some(ty) => Ok(ty),
        None => bail!("function.call at {location} has type-variable result with no use sites"),
    }
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
        if poly::is_param_op(&cur) {
            // TODO: update to use `TemplateParamOpRefMut::try_from(cur)?.sym_name()` API once added
            let sym_name = StringAttribute::try_from(cur.attribute("sym_name")?)?;
            if sym_name.value() == name {
                let _drop = shared::remove_from_parent(&mut cur);
                return Ok(());
            }
        }
    }
    bail!("generated poly.param '{name}' was not found")
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
        let tvar_name = poly::TVarType::try_from(old_result.r#type())?.name().as_str()?.to_owned();
        let use_type = infer_type_from_unifiable_cast_uses(call_op)?;
        let template = parent_template(&call_op)?;
        let operands = call_op.operands().collect::<Vec<_>>();
        let attrs = call_op.attributes().collect::<Vec<_>>();
        let location = call_op.location();
        let block = call_op
            .block()
            .ok_or_else(|| anyhow::anyhow!("function.call at {location} has no parent block"))?;
        let new_call = OperationBuilder::new("function.call", location)
            .add_attributes(&attrs)
            .add_operands(&operands)
            .add_results(&[use_type])
            .build()?;
        let new_call = block.insert_operation_before(call_op, new_call);
        replace_all_uses(Value::from(old_result), Value::from(new_call.result(0)?));
        let _drop = shared::remove_from_parent(&mut unsafe { OperationRefMut::from_raw(raw_call) });
        remove_generated_tvar_param(template, &tvar_name)?;
    }

    Ok(())
}
