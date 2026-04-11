// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Scalar copy version of `array_copy2_vec.circom` test. Output is identical except for basic blocks.
template Array2(n) {
    signal input a[n];
    signal output b[n];

    for (var i = 0; i < n; i++) {
      b[i] <== a[i];
    }
}

component main = Array2(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Array2<[5]>>} {
// CHECK-NEXT:    poly.template @Array2 {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Array2 {
// CHECK-NEXT:        struct.member @b : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Array2::@Array2<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Array2::@Array2<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_9]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_11]]] = %[[VAL_10]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_13]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_3]] : <@Array2::@Array2<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Array2::@Array2<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@Array2::@Array2<[@n]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@b] : <@Array2::@Array2<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_16]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_21]]) %[[VAL_20]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_23]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_25]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_26]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_28]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
