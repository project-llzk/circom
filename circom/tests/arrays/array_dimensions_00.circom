// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayDims() {
    var arr2[2 + 2];
}

component main = ArrayDims();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ArrayDims::@ArrayDims<[]>>} {
// CHECK-NEXT:    poly.template @ArrayDims {
// CHECK-NEXT:      struct.def @ArrayDims {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayDims::@ArrayDims<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims::@ArrayDims<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]], %[[VAL_1]], %[[VAL_1]] : <4 x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ArrayDims::@ArrayDims<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims::@ArrayDims<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]] : <4 x !felt.type>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
