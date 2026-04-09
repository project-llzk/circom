// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template VariantIndex(n) {
    signal input in;
    signal output out;

    var temp[n];
    for (var i = 0; i<n; i++) {
        temp[i] = (in >> i);
    }
    out <-- temp[0] + temp[1];
}

component main = VariantIndex(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@VariantIndex<[2]>>} {
// CHECK-NEXT:    struct.def @VariantIndex<[@n]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@VariantIndex<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@VariantIndex<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_4]], %[[VAL_5]] : <@n x !felt.type>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_6]] step %[[VAL_8]] {
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_9]]] = %[[VAL_3]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type, !array.type<@n x !felt.type>) -> (!felt.type, !array.type<@n x !felt.type>) {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_14]]) %[[VAL_12]], %[[VAL_13]] : !felt.type, !array.type<@n x !felt.type>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>):
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_0]], %[[VAL_15]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:          array.write %[[VAL_16]]{{\[}}%[[VAL_18]]] = %[[VAL_17]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_20]], %[[VAL_16]] : !felt.type, !array.type<@n x !felt.type>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]#1{{\[}}%[[VAL_22]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]]
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]#1{{\[}}%[[VAL_25]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@out] = %[[VAL_27]] : <@VariantIndex<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@VariantIndex<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !struct.type<@VariantIndex<[@n]>>, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@out] : <@VariantIndex<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_32]], %[[VAL_33]] : <@n x !felt.type>
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_35]] to %[[VAL_34]] step %[[VAL_36]] {
// CHECK-NEXT:          array.write %[[VAL_32]]{{\[}}%[[VAL_37]]] = %[[VAL_31]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]], %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_32]]) : (!felt.type, !array.type<@n x !felt.type>) -> (!felt.type, !array.type<@n x !felt.type>) {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_40]], %[[VAL_30]])
// CHECK-NEXT:          scf.condition(%[[VAL_42]]) %[[VAL_40]], %[[VAL_41]] : !felt.type, !array.type<@n x !felt.type>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_44:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>):
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_29]], %[[VAL_43]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]]
// CHECK-NEXT:          array.write %[[VAL_44]]{{\[}}%[[VAL_46]]] = %[[VAL_45]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_48]], %[[VAL_44]] : !felt.type, !array.type<@n x !felt.type>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
