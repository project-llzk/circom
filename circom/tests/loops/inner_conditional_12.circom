// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This test contains inner loops with different iteration counts. Further, one is
//  independent of the outer loop induction variable and the other loop depends on it.
template InnerConditional12(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        if (i < 2) {
            // runs when i∈{0,1}
            for (var j = 0; j < N; j++) {
                a[i] += 999;
            }
        } else {
            // runs when i∈{2,3}
            for (var j = 0; j < i; j++) {
                a[i] += 888;
            }
        }
    }
    out <-- a[0] + a[1];
}

component main = InnerConditional12(4);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InnerConditional12::@InnerConditional12<[4]>>} {
// CHECK-NEXT:    poly.template @InnerConditional12 {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @InnerConditional12 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional12::@InnerConditional12<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional12::@InnerConditional12<[@N]>>
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
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_17]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_18]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_15]], %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_24]]) %[[VAL_22]], %[[VAL_23]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_27]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:                %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_25]]{{\[}}%[[VAL_31]]] = %[[VAL_30]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_25]], %[[VAL_33]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_21]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_36:[0-9a-zA-Z_\.]+]] = %[[VAL_15]], %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_34]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_38:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_37]], %[[VAL_16]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_38]]) %[[VAL_36]], %[[VAL_37]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_41]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  888 : <"bn128">
// CHECK-NEXT:                %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_39]]{{\[}}%[[VAL_45]]] = %[[VAL_44]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_39]], %[[VAL_47]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_35]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_19]], %[[VAL_49]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]#0{{\[}}%[[VAL_51]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]#0{{\[}}%[[VAL_54]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_52]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_56]] : <@InnerConditional12::@InnerConditional12<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@InnerConditional12::@InnerConditional12<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional12::@InnerConditional12<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_58]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_57]][@out] : <@InnerConditional12::@InnerConditional12<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_62]], %[[VAL_63]] : <@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_65]] to %[[VAL_64]] step %[[VAL_66]] {
// CHECK-NEXT:            array.write %[[VAL_62]]{{\[}}%[[VAL_67]]] = %[[VAL_61]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_62]], %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_68]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_71]], %[[VAL_59]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_72]]) %[[VAL_70]], %[[VAL_71]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_74]], %[[VAL_75]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_76]] -> (!array.type<@N x !felt.type<"bn128">>) {
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_73]], %[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_78]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_81]], %[[VAL_59]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_82]]) %[[VAL_80]], %[[VAL_81]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_83:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_85]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_83]]{{\[}}%[[VAL_89]]] = %[[VAL_88]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_83]], %[[VAL_91]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_79]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_94:[0-9a-zA-Z_\.]+]] = %[[VAL_73]], %[[VAL_95:[0-9a-zA-Z_\.]+]] = %[[VAL_92]]) : (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_95]], %[[VAL_74]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_96]]) %[[VAL_94]], %[[VAL_95]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_97:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_98:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_99]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  888 : <"bn128">
// CHECK-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_101]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_97]]{{\[}}%[[VAL_103]]] = %[[VAL_102]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_98]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_97]], %[[VAL_105]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_93]]#0 : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_77]], %[[VAL_107]] : !array.type<@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
