// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(n) {
    signal input a[n];
    var b[n];

    for (var i = 0; i < n; i++) {
        for (var j = 0; j <= i; j++) {
            b[i] += a[i];
        }
    }
}

component main = InnerLoops(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerLoops<[2]>>} {
// CHECK-NEXT:    poly.template @InnerLoops {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @InnerLoops {
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@InnerLoops::@InnerLoops<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_4]], %[[VAL_5]] : <@n x !felt.type>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_6]] step %[[VAL_8]] {
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_9]]] = %[[VAL_3]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_14]]) %[[VAL_12]], %[[VAL_13]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_15]], %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_20]], %[[VAL_16]]) : !felt.type, !felt.type
// CHECK-NEXT:              scf.condition(%[[VAL_21]]) %[[VAL_19]], %[[VAL_20]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_24]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_26]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type
// CHECK-NEXT:              array.write %[[VAL_22]]{{\[}}%[[VAL_29]]] = %[[VAL_28]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_30]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_22]], %[[VAL_31]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_18]]#0, %[[VAL_33]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops::@InnerLoops<[@n]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_38]], %[[VAL_39]] : <@n x !felt.type>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]] to %[[VAL_40]] step %[[VAL_42]] {
// CHECK-NEXT:            array.write %[[VAL_38]]{{\[}}%[[VAL_43]]] = %[[VAL_37]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_46:[0-9a-zA-Z_\.]+]] = %[[VAL_38]], %[[VAL_47:[0-9a-zA-Z_\.]+]] = %[[VAL_44]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_47]], %[[VAL_36]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_48]]) %[[VAL_46]], %[[VAL_47]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_51]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_54]], %[[VAL_50]]) : !felt.type, !felt.type
// CHECK-NEXT:              scf.condition(%[[VAL_55]]) %[[VAL_53]], %[[VAL_54]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_58]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_60]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_59]], %[[VAL_61]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type
// CHECK-NEXT:              array.write %[[VAL_56]]{{\[}}%[[VAL_63]]] = %[[VAL_62]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_57]], %[[VAL_64]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_56]], %[[VAL_65]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_50]], %[[VAL_66]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_52]]#0, %[[VAL_67]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
