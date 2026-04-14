// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(n) {
    signal input a[n];
    var b[n];

    for (var i = 0; i < n; i++) {
        for (var j = 0; j <= i; j++) {
            b[i] += a[i - j];
        }
    }
}

component main = InnerLoops(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerLoops::@InnerLoops<[2]>>} {
// CHECK-NEXT:    poly.template @InnerLoops {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @InnerLoops {
// CHECK-NEXT:        function.def @compute(%[[V_A:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@InnerLoops::@InnerLoops<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[V_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_6:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_5]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_9:[0-9a-zA-Z_\.]+]] = %[[V_7]] to %[[V_6]] step %[[V_8]] {
// CHECK-NEXT:            array.write %[[V_B]]{{\[}}%[[V_9]]] = %[[V_3]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_14]]) %[[V_B1]], %[[V_I1]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_B2:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_J0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_18:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B3:[0-9a-zA-Z_\.]+]] = %[[V_B2]], %[[V_J2:[0-9a-zA-Z_\.]+]] = %[[V_J0]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[V_21:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_J2]], %[[V_I2]])
// CHECK-NEXT:              scf.condition(%[[V_21]]) %[[V_B3]], %[[V_J2]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_B4:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_J3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[V_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:              %[[V_25:[0-9a-zA-Z_\.]+]] = array.read %[[V_B4]]{{\[}}%[[V_24]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_26:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_I2]], %[[V_J3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_26]]
// CHECK-NEXT:              %[[V_28:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_27]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_29:[0-9a-zA-Z_\.]+]] = felt.add %[[V_25]], %[[V_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_I2]]
// CHECK-NEXT:              array.write %[[V_B4]]{{\[}}%[[V_30]]] = %[[V_29]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_32:[0-9a-zA-Z_\.]+]] = felt.add %[[V_J3]], %[[V_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_B4]], %[[V_32]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_33:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_34:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_18]]#0, %[[V_34]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[V_1]] : !struct.type<@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[V_A:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops::@InnerLoops<[@n]>>, %[[V_36:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[V_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_41:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_40]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[V_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[V_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[V_44:[0-9a-zA-Z_\.]+]] = %[[V_42]] to %[[V_41]] step %[[V_43]] {
// CHECK-NEXT:            array.write %[[V_B]]{{\[}}%[[V_44]]] = %[[V_38]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[V_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_46:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_47:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_48:[0-9a-zA-Z_\.]+]] = %[[V_45]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[V_49:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_48]], %[[V_N]])
// CHECK-NEXT:            scf.condition(%[[V_49]]) %[[V_47]], %[[V_48]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[V_50:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_51:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[V_52:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[V_53:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_54:[0-9a-zA-Z_\.]+]] = %[[V_50]], %[[V_55:[0-9a-zA-Z_\.]+]] = %[[V_52]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[V_56:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_55]], %[[V_51]])
// CHECK-NEXT:              scf.condition(%[[V_56]]) %[[V_54]], %[[V_55]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[V_57:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[V_58:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[V_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_51]]
// CHECK-NEXT:              %[[V_60:[0-9a-zA-Z_\.]+]] = array.read %[[V_57]]{{\[}}%[[V_59]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_61:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_51]], %[[V_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_61]]
// CHECK-NEXT:              %[[V_63:[0-9a-zA-Z_\.]+]] = array.read %[[V_36]]{{\[}}%[[V_62]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_64:[0-9a-zA-Z_\.]+]] = felt.add %[[V_60]], %[[V_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_51]]
// CHECK-NEXT:              array.write %[[V_57]]{{\[}}%[[V_65]]] = %[[V_64]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[V_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[V_67:[0-9a-zA-Z_\.]+]] = felt.add %[[V_58]], %[[V_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[V_57]], %[[V_67]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[V_68:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[V_69:[0-9a-zA-Z_\.]+]] = felt.add %[[V_51]], %[[V_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[V_53]]#0, %[[V_69]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
