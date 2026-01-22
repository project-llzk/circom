// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_14]]) %[[VAL_12]], %[[VAL_13]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_15]], %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_20]], %[[VAL_16]])
// CHECK-NEXT:            scf.condition(%[[VAL_21]]) %[[VAL_19]], %[[VAL_20]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_24]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_16]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]]
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_27]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            array.write %[[VAL_22]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_22]], %[[VAL_32]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_33]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_18]]#0, %[[VAL_34]] : !array.type<@n x !felt.type>, !felt.type
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
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_47:[0-9a-zA-Z_\.]+]] = %[[VAL_39]], %[[VAL_48:[0-9a-zA-Z_\.]+]] = %[[VAL_45]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_48]], %[[VAL_37]])
// CHECK-NEXT:          scf.condition(%[[VAL_49]]) %[[VAL_47]], %[[VAL_48]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_51:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_50]], %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_52]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_55]], %[[VAL_51]])
// CHECK-NEXT:            scf.condition(%[[VAL_56]]) %[[VAL_54]], %[[VAL_55]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[VAL_58:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]]
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_59]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_51]], %[[VAL_58]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]]
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_62]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_60]], %[[VAL_63]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]]
// CHECK-NEXT:            array.write %[[VAL_57]]{{\[}}%[[VAL_65]]] = %[[VAL_64]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_58]], %[[VAL_66]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_57]], %[[VAL_67]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_68]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_53]]#0, %[[VAL_69]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
