//! Extensions for AST types.

use program_structure::ast::{Expression, Meta};

pub(crate) trait ExpressionExt {
    /// Returns the element id of the expression.
    fn elem_id(&self) -> usize;
}

impl ExpressionExt for Expression {
    fn elem_id(&self) -> usize {
        self.get_meta().elem_id
    }
}
