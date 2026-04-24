//! Extensions for AST types.

use program_structure::ast::{Expression, Meta};

pub(crate) trait ExpressionExt {
    /// Returns the element id of the expression.
    fn elem_id(&self) -> usize;
}

#[inline]
fn get_meta(expr: &Expression) -> &Meta {
    match expr {
        Expression::InfixOp { meta, .. }
        | Expression::PrefixOp { meta, .. }
        | Expression::InlineSwitchOp { meta, .. }
        | Expression::ParallelOp { meta, .. }
        | Expression::Variable { meta, .. }
        | Expression::Number(meta, _)
        | Expression::Call { meta, .. }
        | Expression::BusCall { meta, .. }
        | Expression::AnonymousComp { meta, .. }
        | Expression::ArrayInLine { meta, .. }
        | Expression::Tuple { meta, .. }
        | Expression::UniformArray { meta, .. } => meta,
    }
}

impl ExpressionExt for Expression {
    fn elem_id(&self) -> usize {
        get_meta(self).elem_id
    }
}
