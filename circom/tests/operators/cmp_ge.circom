// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template CmpGE(n) {
    signal input a[n];
    signal output b[n];

    for (var i = n-1; i >= 0; i--) {
      b[i] <== a[i];
    }
}

component main = CmpGE(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@CmpGE<[5]>>} {
// CHECK-NEXT:    struct.def @CmpGE<[@n]> {
// CHECK-NEXT:      struct.member @b : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@CmpGE<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CmpGE<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_2]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_7]], %[[VAL_8]])
// CHECK-NEXT:          scf.condition(%[[VAL_9]]) %[[VAL_7]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]]
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_11]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]]
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_10]], %[[VAL_14]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_15]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@b] = %[[VAL_3]] : <@CmpGE<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@CmpGE<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@CmpGE<[@n]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@b] : <@CmpGE<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_18]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_22]], %[[VAL_23]])
// CHECK-NEXT:          scf.condition(%[[VAL_24]]) %[[VAL_22]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_26]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_29]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_30]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_25]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_32]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
