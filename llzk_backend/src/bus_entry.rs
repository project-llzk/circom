//! Adapt bus-valued interfaces to LLZK's felt-only main entry ABI.

use crate::{
    aggregate_types::contains_bus,
    function::FunctionContext,
    gen_context::BlockGenContext,
    program_ext::ProgramLike,
    shared::{map_name_to_arg_value, LlzkCodegen},
};
use anyhow::Result;
use llzk::{
    builder::OpBuilder,
    dialect::{
        array::ArrayCtor,
        function, pod, r#struct,
        r#struct::helpers::{compute_fn, constrain_fn},
    },
    prelude::*,
};
use std::{collections::HashMap, convert::TryFrom};

/// Flatten records, retaining all enclosing array dimensions on each leaf.
fn fields<'ctx>(
    name: &str,
    ty: Type<'ctx>,
    dims: &[Attribute<'ctx>],
    out: &mut Vec<(String, Type<'ctx>)>,
) -> Result<()> {
    if let Ok(pod) = PodType::try_from(ty) {
        for record in pod.records() {
            fields(
                &format!("{name}.{}", record.name().as_string_ref().as_str()?),
                record.r#type(),
                dims,
                out,
            )?;
        }
    } else if let Ok(array) = ArrayType::try_from(ty) {
        let mut dims = dims.to_vec();
        dims.extend(array.dims());
        fields(name, array.element_type(), &dims, out)?;
    } else {
        out.push((
            name.to_owned(),
            if dims.is_empty() { ty } else { ArrayType::new(ty, dims).into() },
        ));
    }
    Ok(())
}

/// Reconstruct one bus from flattened function arguments or public member reads.
fn pack<'ctx, 'blk, 'val>(
    name: &str,
    ty: Type<'ctx>,
    prefix: &[Value<'ctx, 'val>],
    flat: &HashMap<String, Value<'ctx, 'val>>,
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    bg: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
    loc: Location<'ctx>,
) -> Result<Value<'ctx, 'val>>
where
    'val: 'blk,
{
    if let Ok(p) = PodType::try_from(ty) {
        let mut values = Vec::new();
        for record in p.records() {
            let id = record.name();
            let field = id.as_string_ref();
            let value = pack(
                &format!("{name}.{}", field.as_str()?),
                record.r#type(),
                prefix,
                flat,
                codegen,
                bg,
                loc,
            )?;
            values.push(RecordValue::new(field, value));
        }
        let builder = bg.builder_at_current_insertion_point(codegen.context);
        return bg.append_op_ref_unnamed_result(pod::new(&builder, loc, &values, Some(p)));
    }
    if let Ok(array) = ArrayType::try_from(ty) {
        if contains_bus(array.element_type()) {
            let builder = bg.builder_at_current_insertion_point(codegen.context);
            let result = bg.append_op_ref_unnamed_result(codegen.new_array_new_op(
                &builder,
                loc,
                array,
                ArrayCtor::Empty,
            ))?;
            bg.gen_loop_nest_from_attrs(codegen, loc, &array.dims(), |bg, indices| {
                let mut next = prefix.to_vec();
                next.extend(indices);
                let value = pack(name, array.element_type(), &next, flat, codegen, bg, loc)?;
                bg.append_array_write(codegen, result, indices, loc, value, None)
            })?;
            return Ok(result);
        }
    }
    let value = flat[name];
    if prefix.is_empty() {
        Ok(value)
    } else {
        bg.append_array_read(codegen, value, prefix, loc, None)
    }
}

/// Extract bus leaves, transposing arrays of records into arrays of leaves.
fn unpack<'ctx, 'blk, 'val>(
    name: &str,
    value: Value<'ctx, 'val>,
    prefix: &[Value<'ctx, 'val>],
    flat: &mut HashMap<String, Value<'ctx, 'val>>,
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    bg: &mut BlockGenContext<'_, 'ctx, 'blk, 'val>,
    loc: Location<'ctx>,
) -> Result<()>
where
    'val: 'blk,
{
    if let Ok(p) = PodType::try_from(value.r#type()) {
        for record in p.records() {
            let id = record.name();
            let field = id.as_string_ref().as_str()?.to_owned();
            let builder = bg.builder_at_current_insertion_point(codegen.context);
            let child = bg.append_op_ref_unnamed_result(
                codegen.new_pod_read_op(&builder, value, &field, loc)?,
            )?;
            unpack(&format!("{name}.{field}"), child, prefix, flat, codegen, bg, loc)?;
        }
        return Ok(());
    }
    if let Ok(array) = ArrayType::try_from(value.r#type()) {
        if contains_bus(array.element_type()) {
            return bg.gen_loop_nest_from_attrs(codegen, loc, &array.dims(), |bg, indices| {
                let child = bg.append_array_read(codegen, value, indices, loc, None)?;
                let mut next = prefix.to_vec();
                next.extend(indices);
                unpack(name, child, &next, flat, codegen, bg, loc)
            });
        }
    }
    if prefix.is_empty() {
        flat.insert(name.to_owned(), value);
    } else {
        bg.append_array_write(codegen, flat[name], prefix, loc, value, None)?;
    }
    Ok(())
}

/// Emit an entry struct in the original template, so symbolic dimensions retain their scope.
pub(crate) fn generate<'ctx>(
    codegen: &LlzkCodegen<'_, 'ctx, '_, impl ProgramLike>,
    template: TemplateOpRefMut<'ctx, '_>,
    original: StructDefOpRef<'ctx, '_>,
    inputs: &[(String, Type<'ctx>)],
    outputs: &[(String, Type<'ctx>)],
) -> Result<()> {
    if !inputs.iter().chain(outputs).any(|(_, ty)| contains_bus(*ty)) {
        return Ok(());
    }
    let loc = codegen.location_unknown();
    let mut flat_inputs = Vec::new();
    let mut flat_outputs = Vec::new();
    for (name, ty) in inputs {
        fields(name, *ty, &[], &mut flat_inputs)?;
    }
    for (name, ty) in outputs {
        fields(name, *ty, &[], &mut flat_outputs)?;
    }
    let builder = OpBuilder::at_block_end(codegen.context, template.body());
    let entry = StructDefOpRef::try_from(r#struct::def(
        &builder,
        loc,
        "$bus_entry",
        |builder| -> Result<()> {
            r#struct::member(builder, loc, "$component", original.r#type(), false, false, false)?;
            for (name, ty) in &flat_outputs {
                r#struct::member(builder, loc, name, *ty, true, false, true)?;
            }
            Ok(())
        },
    )?)?;
    let parameters = flat_inputs.iter().map(|(_, ty)| (*ty, loc)).collect::<Vec<_>>();
    let attrs = flat_inputs
        .iter()
        .map(|(name, _)| {
            let mut attrs = vec![function::arg_name_attr(codegen.context, name)];
            if codegen
                .program
                .get_main_public_inputs()
                .iter()
                .any(|input| name == input || name.starts_with(&format!("{input}.")))
            {
                attrs.push(PublicAttribute::new_named_attr(codegen.context));
            }
            attrs
        })
        .collect::<Vec<_>>();
    let builder = OpBuilder::at_block_end(codegen.context, entry.body());
    let var_types = HashMap::new();
    for compute in [true, false] {
        let func = FuncDefOpRef::try_from(if compute {
            compute_fn(&builder, loc, entry.r#type(), &parameters, Some(&attrs))?
        } else {
            constrain_fn(&builder, loc, entry.r#type(), &parameters, Some(&attrs))?
        })?;
        let mut names = flat_inputs.iter().map(|(name, _)| name.clone()).collect::<Vec<_>>();
        if !compute {
            names.insert(0, "$self".to_owned());
        }
        let bindings = template
            .const_binding_ops()
            .iter()
            .map(|op| (op.sym_name().to_owned(), op.type_opt()))
            .collect::<Vec<_>>();
        let mut fc = FunctionContext::new::<false>(
            codegen,
            func.into(),
            map_name_to_arg_value(func.into(), names)?,
            &var_types,
            bindings,
        )?;
        let flat = flat_inputs
            .iter()
            .map(|(name, _)| Ok((name.clone(), *fc.block_ctx.get_named_value(name)?)))
            .collect::<Result<HashMap<_, _>>>()?;
        let args = inputs
            .iter()
            .map(|(name, ty)| pack(name, *ty, &[], &flat, codegen, &mut fc, loc))
            .collect::<Result<Vec<_>>>()?;
        let self_value =
            if compute { func.self_value_of_compute()? } else { func.self_value_of_constrain()? };
        let target = original.r#type();
        let builder = fc.builder_at_current_insertion_point(codegen.context);
        let instance = if compute {
            let call = function::call(
                &builder,
                loc,
                crate::shared::append_tail(&target.name(), "compute"),
                &args,
                &[Type::from(target)],
            )?;
            let value = fc.append_op_ref_unnamed_result(call)?;
            fc.append_op_ref_no_result(r#struct::writem(
                &builder,
                loc,
                self_value,
                "$component",
                value,
            )?)?;
            value
        } else {
            let value = fc.append_op_ref_unnamed_result(r#struct::readm(
                &builder,
                loc,
                target.into(),
                self_value,
                "$component",
            )?)?;
            let mut args = args;
            args.insert(0, value);
            fc.append_op_ref_no_result(function::call(
                &builder,
                loc,
                crate::shared::append_tail(&target.name(), "constrain"),
                &args,
                &[] as &[Type],
            )?)?;
            value
        };
        let mut flat = HashMap::new();
        for (name, ty) in &flat_outputs {
            let builder = fc.builder_at_current_insertion_point(codegen.context);
            let value = if compute {
                fc.append_op_ref_unnamed_result(codegen.new_nondet_at_location(&builder, loc, *ty))?
            } else {
                fc.append_op_ref_unnamed_result(r#struct::readm(
                    &builder, loc, *ty, self_value, name,
                )?)?
            };
            flat.insert(name.clone(), value);
        }
        for (name, ty) in outputs {
            let builder = fc.builder_at_current_insertion_point(codegen.context);
            let value = fc.append_op_ref_unnamed_result(r#struct::readm(
                &builder, loc, *ty, instance, name,
            )?)?;
            if compute {
                unpack(name, value, &[], &mut flat, codegen, &mut fc, loc)?;
            } else {
                let public = pack(name, *ty, &[], &flat, codegen, &mut fc, loc)?;
                fc.append_constrain_eq(codegen, loc, value, public)?;
            }
        }
        if compute {
            for (name, _) in &flat_outputs {
                let builder = fc.builder_at_current_insertion_point(codegen.context);
                fc.append_op_ref_no_result(r#struct::writem(
                    &builder, loc, self_value, name, flat[name],
                )?)?;
            }
        }
        fc.finalize(codegen)?;
    }
    Ok(())
}
