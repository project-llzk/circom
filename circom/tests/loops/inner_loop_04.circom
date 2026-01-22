// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(n) {
    signal input a[n];
    var b[n];
    var j;
    for (var i = 0; i < n; i++) {
        for (j = 0; j <= i; j++) {
            b[i] = a[i - j];
        }
    }
}

component main = InnerLoops(2);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerLoops<[@n]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@InnerLoops<[@n]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops<[@n]>>
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
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_11]], %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!array.type<@n x !felt.type>, !felt.type, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_16]]) %[[VAL_13]], %[[VAL_14]], %[[VAL_15]] : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_17]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_23]], %[[VAL_18]])
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_22]], %[[VAL_23]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_18]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]]
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_28]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-NEXT:            array.write %[[VAL_25]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_25]], %[[VAL_32]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_33]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_21]]#0, %[[VAL_34]], %[[VAL_21]]#1 : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@InnerLoops<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops<[@n]>>, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_39]], %[[VAL_40]] : <@n x !felt.type>
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_42]] to %[[VAL_41]] step %[[VAL_43]] {
// CHECK-NEXT:          array.write %[[VAL_39]]{{\[}}%[[VAL_44]]] = %[[VAL_38]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_48:[0-9a-zA-Z_\.]+]] = %[[VAL_39]], %[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_46]], %[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_45]]) : (!array.type<@n x !felt.type>, !felt.type, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_49]], %[[VAL_37]])
// CHECK-NEXT:          scf.condition(%[[VAL_51]]) %[[VAL_48]], %[[VAL_49]], %[[VAL_50]] : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_53:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_54:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_52]], %[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_55]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_58]], %[[VAL_53]])
// CHECK-NEXT:            scf.condition(%[[VAL_59]]) %[[VAL_57]], %[[VAL_58]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_53]], %[[VAL_61]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]]
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_63]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]]
// CHECK-NEXT:            array.write %[[VAL_60]]{{\[}}%[[VAL_65]]] = %[[VAL_64]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_61]], %[[VAL_66]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_60]], %[[VAL_67]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_53]], %[[VAL_68]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_56]]#0, %[[VAL_69]], %[[VAL_56]]#1 : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
