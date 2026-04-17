// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayDims(N) {
    signal input arr[N + 1];
}

component main = ArrayDims(7);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ArrayDims::@ArrayDims<[7]>>} {
// CHECK-NEXT:    poly.template @ArrayDims {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.expr @N_Add_1 {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @ArrayDims {
// CHECK-NEXT:        function.def @compute(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !array.type<@N_Add_1 x !felt.type<"bn128">>) -> !struct.type<@ArrayDims::@ArrayDims<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayDims::@ArrayDims<[@N]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @N_Add_1 : !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@ArrayDims::@ArrayDims<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayDims::@ArrayDims<[@N]>>, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !array.type<@N_Add_1 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N_Add_1 : !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
