// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// COM: The `@outp` field is not instantiated, so it's not clear what the array size is.
// COM: This can be refined when https://github.com/project-llzk/circom/issues/320
// COM: is implemented.

pragma circom 2.0.0;

template ArrayDims(N) {
    var M = N + 1;
    signal output outp[M];
}

component main = ArrayDims(7);

// CHECK: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<()[s0] -> (s0)>
// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @ArrayDims<[@N]> {
// CHECK-NEXT:      struct.field @outp : !array.type<#[[$ATTR_0]] x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@ArrayDims<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims<[@N]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_1]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@ArrayDims<[@N]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }

