// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Parital vector copy version of `array_copy3_loop.circom` test. The outer dimension is traversed
//  explicitly but the inner dimension is treated as a vector copy. Output is identical.
template Array3(n) {
    signal input inp[n][n];
    signal output out[n][n];

    for (var i = 0; i < n; i++) {
        out[i] <== inp[i];
    }
}

component main = Array3(5);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Array3<[@n]> {
// CHECK-NEXT:      struct.field @out : !array.type<@n,@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n,@n x !felt.type>) -> !struct.type<@Array3<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Array3<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_0]]{{\[}}%[[VAL_9]]] : <@n,@n x !felt.type>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          array.insert %[[VAL_3]]{{\[}}%[[VAL_11]]] = %[[VAL_10]] : <@n,@n x !felt.type>, <@n x !felt.type>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_3]] : <@Array3<[@n]>>, !array.type<@n,@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Array3<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@Array3<[@n]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<@n,@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_19]], %[[VAL_16]])
// CHECK-NEXT:          scf.condition(%[[VAL_20]]) %[[VAL_19]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_15]]{{\[}}%[[VAL_22]]] : <@n,@n x !felt.type>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_14]][@out] : <@Array3<[@n]>>, !array.type<@n,@n x !felt.type>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_24]]{{\[}}%[[VAL_25]]] : <@n,@n x !felt.type>
// CHECK-NEXT:          constrain.eq %[[VAL_26]], %[[VAL_23]] : !array.type<@n x !felt.type>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_28]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
