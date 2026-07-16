// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional7(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        // Values of 'a' at the header per iteration:
        // i=0: [0, 0, 0, 0]
        // i=1: [-111, -111, -111]
        // i=2: [-222, -222, -222]
        // NOTE: Technically there are no negative values, it's instead wrapped modulo the field prime
        for (var j = 0; j < N; j++) {
            if (i > 1) {
                a[j] += 999;
            } else {
                a[j] -= 111;
            }
        }
    }
    // At this point, 'a[x] = 777' for all 'x', so 'out = 1554'
    out <-- a[0] + a[1];
}

component main = InnerConditional7(3);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InnerConditional7::@InnerConditional7<[3]>>} {
// CHECK-NEXT:    poly.template @InnerConditional7 {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @InnerConditional7 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional7::@InnerConditional7<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional7::@InnerConditional7<[@N]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_4]], %[[VAL_5]] : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_6]] step %[[VAL_8]] {
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_9]]] = %[[VAL_3]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_14]]) %[[VAL_12]], %[[VAL_13]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_15]], %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_21]]) %[[VAL_19]], %[[VAL_20]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_16]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_25]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:                %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_27]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:                %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_22]]{{\[}}%[[VAL_31]]] = %[[VAL_30]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_22]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_32]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  111 : <"bn128">
// CHECK-NEXT:                %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_22]]{{\[}}%[[VAL_36]]] = %[[VAL_35]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_22]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_26]], %[[VAL_38]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]]#0, %[[VAL_40]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]#0{{\[}}%[[VAL_42]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]#0{{\[}}%[[VAL_45]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_47]] : <@InnerConditional7::@InnerConditional7<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@InnerConditional7::@InnerConditional7<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional7::@InnerConditional7<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_49]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@out] : <@InnerConditional7::@InnerConditional7<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_53]], %[[VAL_54]] : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]] to %[[VAL_55]] step %[[VAL_57]] {
// CHECK-NEXT:            array.write %[[VAL_53]]{{\[}}%[[VAL_58]]] = %[[VAL_52]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_53]], %[[VAL_62:[0-9a-zA-Z_\.]+]] = %[[VAL_59]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_62]], %[[VAL_50]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_63]]) %[[VAL_61]], %[[VAL_62]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_64]], %[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_66]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_69]], %[[VAL_50]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_70]]) %[[VAL_68]], %[[VAL_69]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_65]], %[[VAL_73]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_74]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_76]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_71]]{{\[}}%[[VAL_80]]] = %[[VAL_79]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_71]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_81]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  111 : <"bn128">
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_82]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_71]]{{\[}}%[[VAL_85]]] = %[[VAL_84]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_71]] : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_75]], %[[VAL_87]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_65]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_67]]#0, %[[VAL_89]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
