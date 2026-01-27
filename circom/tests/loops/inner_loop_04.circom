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
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[V_A:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@InnerLoops<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops<[@n]>>
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[V_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_6:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_5]] : <@n x !felt.type>
// CHECK-NEXT:        %[[V_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_9:[0-9a-zA-Z_\.]+]] = %[[V_7]] to %[[V_6]] step %[[V_8]] {
// CHECK-NEXT:          array.write %[[V_B]]{{\[}}%[[V_9]]] = %[[V_3]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_12:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]], %[[V_J1:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!array.type<@n x !felt.type>, !felt.type, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_16]]) %[[V_B1]], %[[V_I1]], %[[V_J1]] : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_B2:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_J2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_21:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B3:[0-9a-zA-Z_\.]+]] = %[[V_B2]], %[[V_J3:[0-9a-zA-Z_\.]+]] = %[[V_20]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[V_24:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_J3]], %[[V_I2]])
// CHECK-NEXT:            scf.condition(%[[V_24]]) %[[V_B3]], %[[V_J3]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_B4:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_J4:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_27:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_I2]], %[[V_J4]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_27]]
// CHECK-NEXT:            %[[V_29:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_28]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:            array.write %[[V_B4]]{{\[}}%[[V_30]]] = %[[V_29]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_J5:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J4]], %[[V_31]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_B4]], %[[V_J5]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_33:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_33]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_21]]#0, %[[V_I3]], %[[V_21]]#1 : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[V_1]] : !struct.type<@InnerLoops<[@n]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_A:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops<[@n]>>, %[[V_36:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[V_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_41:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_40]] : <@n x !felt.type>
// CHECK-NEXT:        %[[V_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_44:[0-9a-zA-Z_\.]+]] = %[[V_42]] to %[[V_41]] step %[[V_43]] {
// CHECK-NEXT:          array.write %[[V_B]]{{\[}}%[[V_44]]] = %[[V_38]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_47:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[V_48:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_49:[0-9a-zA-Z_\.]+]] = %[[V_46]], %[[V_50:[0-9a-zA-Z_\.]+]] = %[[V_45]]) : (!array.type<@n x !felt.type>, !felt.type, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_51:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_49]], %[[V_N]])
// CHECK-NEXT:          scf.condition(%[[V_51]]) %[[V_48]], %[[V_49]], %[[V_50]] : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_52:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_53:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_54:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_55:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_56:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_57:[0-9a-zA-Z_\.]+]] = %[[V_52]], %[[V_58:[0-9a-zA-Z_\.]+]] = %[[V_55]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[V_59:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_58]], %[[V_53]])
// CHECK-NEXT:            scf.condition(%[[V_59]]) %[[V_57]], %[[V_58]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_60:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_61:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[V_62:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_53]], %[[V_61]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[V_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_62]]
// CHECK-NEXT:            %[[V_64:[0-9a-zA-Z_\.]+]] = array.read %[[V_36]]{{\[}}%[[V_63]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_53]]
// CHECK-NEXT:            array.write %[[V_60]]{{\[}}%[[V_65]]] = %[[V_64]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[V_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_67:[0-9a-zA-Z_\.]+]] = felt.add %[[V_61]], %[[V_66]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[V_60]], %[[V_67]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_68:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_69:[0-9a-zA-Z_\.]+]] = felt.add %[[V_53]], %[[V_68]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_56]]#0, %[[V_69]], %[[V_56]]#1 : !array.type<@n x !felt.type>, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
