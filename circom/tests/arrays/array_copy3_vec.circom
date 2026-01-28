// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Vector copy version of `array_copy3_loop.circom` test.
template Array3(n) {
    signal input inp[n][n];
    signal output out[n][n];

    out <== inp;
}

component main = Array3(5);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Array3<[@n]> {
// CHECK-NEXT:      struct.field @out : !array.type<@n,@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n,@n x !felt.type>) -> !struct.type<@Array3<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Array3<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_0]] : <@Array3<[@n]>>, !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Array3<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@Array3<[@n]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !array.type<@n,@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_3]][@out] : <@Array3<[@n]>>, !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        constrain.eq %[[VAL_6]], %[[VAL_4]] : !array.type<@n,@n x !felt.type>, !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
