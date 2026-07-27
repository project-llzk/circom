// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(nBits) {
    // When using `concrete` option, this becomes `assert(1)`
    assert(nBits <= 512);
}

component main = A(32);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_0::@A_0<[]>>} {
// CHECK-NEXT:    poly.template @A_0 {
// CHECK-NEXT:      struct.def @A_0 {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_2]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_4]], "assertion failed"
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_9]], "assertion failed"
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
