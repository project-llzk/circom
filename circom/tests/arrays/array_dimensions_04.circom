// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayDims(N) {
    signal input inp[N];
}

component main = ArrayDims(7);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @ArrayDims<[@N]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) -> !struct.type<@ArrayDims<[@N]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims<[@N]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@ArrayDims<[@N]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims<[@N]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }

