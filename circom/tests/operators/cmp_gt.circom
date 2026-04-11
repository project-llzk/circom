// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template CmpGT(n) {
    signal input a[n];
    signal output b[n];

    for (var i = n; i > 0; i--) {
      b[i-1] <== a[i-1];
    }
}

component main = CmpGT(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@CmpGT<[5]>>} {
// CHECK-NEXT:    poly.template @CmpGT {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @CmpGT {
// CHECK-NEXT:        struct.member @b : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@CmpGT::@CmpGT<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CmpGT::@CmpGT<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_5]], %[[VAL_6]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_5]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_11]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_15]]] = %[[VAL_12]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_16]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_3]] : <@CmpGT::@CmpGT<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@CmpGT::@CmpGT<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@CmpGT::@CmpGT<[@n]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@b] : <@CmpGT::@CmpGT<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_23]], %[[VAL_24]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_23]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_29]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_33]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_34]], %[[VAL_30]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_35]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_36]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
