// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template EmptyTemplate() {
}
component main = EmptyTemplate();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EmptyTemplate<[]>>} {
// CHECK-NEXT:    poly.template @EmptyTemplate {
// CHECK-NEXT:      struct.def @EmptyTemplate {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@EmptyTemplate::@EmptyTemplate<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@EmptyTemplate::@EmptyTemplate<[]>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@EmptyTemplate::@EmptyTemplate<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !struct.type<@EmptyTemplate::@EmptyTemplate<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
