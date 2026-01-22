// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerLoops<[@n]> {
// CHECK-NEXT:      function.def @compute
// CHECK-SAME:      (%[[V_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@InnerLoops<[@n]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[V_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops<[@n]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_4:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[V_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_6:[0-9a-zA-Z_\.]+]] = array.len %[[V_4]], %[[V_5]] : <@n x !felt.type>
// CHECK-NEXT:        %[[V_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_9:[0-9a-zA-Z_\.]+]] = %[[V_7]] to %[[V_6]] step %[[V_8]] {
// CHECK-NEXT:          array.write %[[V_4]]{{\[}}%[[V_9]]] = %[[V_3]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_12:[0-9a-zA-Z_\.]+]] = %[[V_4]], %[[V_13:[0-9a-zA-Z_\.]+]] = %[[V_10]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_13]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_14]]) %[[V_12]], %[[V_13]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_15:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_16:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_18:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_19:[0-9a-zA-Z_\.]+]] = %[[V_15]], %[[V_20:[0-9a-zA-Z_\.]+]] = %[[V_17]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[V_21:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_20]], %[[V_16]])
// CHECK-NEXT:            scf.condition(%[[V_21]]) %[[V_19]], %[[V_20]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_22:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_23:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_16]]
// CHECK-NEXT:            %[[V_25:[0-9a-zA-Z_\.]+]] = array.read %[[V_22]]{{\[}}%[[V_24]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_16]]
// CHECK-NEXT:            %[[V_27:[0-9a-zA-Z_\.]+]] = array.read %[[V_0]]{{\[}}%[[V_26]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_28:[0-9a-zA-Z_\.]+]] = felt.add %[[V_25]], %[[V_27]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_16]]
// CHECK-NEXT:            array.write %[[V_22]]{{\[}}%[[V_29]]] = %[[V_28]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_31:[0-9a-zA-Z_\.]+]] = felt.add %[[V_23]], %[[V_30]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_22]], %[[V_31]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_33:[0-9a-zA-Z_\.]+]] = felt.add %[[V_16]], %[[V_32]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_18]]#0, %[[V_33]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[V_1]] : !struct.type<@InnerLoops<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain
// CHECK-SAME:      (%[[V_34:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops<[@n]>>, %[[V_35:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_37:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_38:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[V_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_40:[0-9a-zA-Z_\.]+]] = array.len %[[V_38]], %[[V_39]] : <@n x !felt.type>
// CHECK-NEXT:        %[[V_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_43:[0-9a-zA-Z_\.]+]] = %[[V_41]] to %[[V_40]] step %[[V_42]] {
// CHECK-NEXT:          array.write %[[V_38]]{{\[}}%[[V_43]]] = %[[V_37]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_44:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_45:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_46:[0-9a-zA-Z_\.]+]] = %[[V_38]], %[[V_47:[0-9a-zA-Z_\.]+]] = %[[V_44]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_48:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_47]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_48]]) %[[V_46]], %[[V_47]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_49:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_50:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_51:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_52:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_53:[0-9a-zA-Z_\.]+]] = %[[V_49]], %[[V_54:[0-9a-zA-Z_\.]+]] = %[[V_51]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[V_55:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_54]], %[[V_50]])
// CHECK-NEXT:            scf.condition(%[[V_55]]) %[[V_53]], %[[V_54]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_56:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_57:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_50]]
// CHECK-NEXT:            %[[V_59:[0-9a-zA-Z_\.]+]] = array.read %[[V_56]]{{\[}}%[[V_58]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_50]]
// CHECK-NEXT:            %[[V_61:[0-9a-zA-Z_\.]+]] = array.read %[[V_35]]{{\[}}%[[V_60]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_62:[0-9a-zA-Z_\.]+]] = felt.add %[[V_59]], %[[V_61]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_50]]
// CHECK-NEXT:            array.write %[[V_56]]{{\[}}%[[V_63]]] = %[[V_62]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_64:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_65:[0-9a-zA-Z_\.]+]] = felt.add %[[V_57]], %[[V_64]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_56]], %[[V_65]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_67:[0-9a-zA-Z_\.]+]] = felt.add %[[V_50]], %[[V_66]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_52]]#0, %[[V_67]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
