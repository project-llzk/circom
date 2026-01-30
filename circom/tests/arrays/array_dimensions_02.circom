// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayDims() {
    // (prime + 3) - (prime + 1) = 2
    var arr[21888242871839275222246405745257275088548364400416034343698204186575808495620 - 21888242871839275222246405745257275088548364400416034343698204186575808495618];
}

component main = ArrayDims();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@ArrayDims<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @ArrayDims<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@ArrayDims<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@ArrayDims<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_4]] : <2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
