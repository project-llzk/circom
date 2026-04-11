// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Vector copy version of `array_copy2_loop.circom` test. Output is identical except for basic blocks.
template Array2(n) {
    signal input inp[n];
    signal output out[n];

    out <== inp;
}

component main = Array2(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Array2<[5]>>} {
// CHECK-NEXT:    poly.template @Array2 {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Array2 {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Array2::@Array2<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Array2::@Array2<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@Array2::@Array2<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Array2::@Array2<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@Array2::@Array2<[@n]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@out] : <@Array2::@Array2<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          constrain.eq %[[VAL_6]], %[[VAL_4]] : !array.type<@n x !felt.type>, !array.type<@n x !felt.type>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
