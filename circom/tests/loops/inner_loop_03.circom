// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(n) {
    signal input a[n];
    var b[n];

    for (var j = 0; j <= 0; j++) {
        b[0] = a[0 - j];
    }
    for (var j = 0; j <= 1; j++) {
        b[1] = a[1 - j];
    }
    for (var j = 0; j <= 2; j++) {
        b[2] = a[2 - j];
    }
    for (var j = 0; j <= 3; j++) {
        b[3] = a[3 - j];
    }
    for (var j = 0; j <= 4; j++) {
        b[4] = a[4 - j];
    }
}

component main = InnerLoops(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerLoops::@InnerLoops<[5]>>} {
// CHECK-NEXT:    poly.template @InnerLoops {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @InnerLoops {
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@InnerLoops::@InnerLoops<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_4]], %[[VAL_5]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_6]] step %[[VAL_8]] {
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_9]]] = %[[VAL_3]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_13]], %[[VAL_14]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_12]], %[[VAL_13]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_18]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_20]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_23]]] = %[[VAL_21]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]], %[[VAL_25]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]#0, %[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_29]], %[[VAL_30]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_31]]) %[[VAL_28]], %[[VAL_29]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_34]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_36]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_32]]{{\[}}%[[VAL_39]]] = %[[VAL_37]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_33]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]], %[[VAL_41]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_27]]#0, %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_42]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_45]], %[[VAL_46]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_47]]) %[[VAL_44]], %[[VAL_45]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_49:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_50]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_52]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_55]]] = %[[VAL_53]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_49]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_48]], %[[VAL_57]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_43]]#0, %[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_58]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_61]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_63]]) %[[VAL_60]], %[[VAL_61]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_66]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_68]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_64]]{{\[}}%[[VAL_71]]] = %[[VAL_69]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_65]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_64]], %[[VAL_73]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_59]]#0, %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_74]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_77]], %[[VAL_78]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_79]]) %[[VAL_76]], %[[VAL_77]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_82]], %[[VAL_81]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_84]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_80]]{{\[}}%[[VAL_87]]] = %[[VAL_85]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_81]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_80]], %[[VAL_89]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_90:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops::@InnerLoops<[@n]>>, %[[VAL_91:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_94]], %[[VAL_95]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_97]] to %[[VAL_96]] step %[[VAL_98]] {
// CHECK-NEXT:            array.write %[[VAL_94]]{{\[}}%[[VAL_99]]] = %[[VAL_93]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_102:[0-9a-zA-Z_\.]+]] = %[[VAL_94]], %[[VAL_103:[0-9a-zA-Z_\.]+]] = %[[VAL_100]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_103]], %[[VAL_104]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_105]]) %[[VAL_102]], %[[VAL_103]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_106:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_107:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_108]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_110]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_106]]{{\[}}%[[VAL_113]]] = %[[VAL_111]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_107]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_106]], %[[VAL_115]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_118:[0-9a-zA-Z_\.]+]] = %[[VAL_101]]#0, %[[VAL_119:[0-9a-zA-Z_\.]+]] = %[[VAL_116]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_119]], %[[VAL_120]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_121]]) %[[VAL_118]], %[[VAL_119]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_122:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_123:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_124]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_126]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_122]]{{\[}}%[[VAL_129]]] = %[[VAL_127]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_123]], %[[VAL_130]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_122]], %[[VAL_131]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_117]]#0, %[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_132]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_135]], %[[VAL_136]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_137]]) %[[VAL_134]], %[[VAL_135]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_138:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_139:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_140]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_142]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_144]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_138]]{{\[}}%[[VAL_145]]] = %[[VAL_143]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_139]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_138]], %[[VAL_147]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_150:[0-9a-zA-Z_\.]+]] = %[[VAL_133]]#0, %[[VAL_151:[0-9a-zA-Z_\.]+]] = %[[VAL_148]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_151]], %[[VAL_152]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_153]]) %[[VAL_150]], %[[VAL_151]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_154:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_155:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_156]], %[[VAL_155]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_158]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_154]]{{\[}}%[[VAL_161]]] = %[[VAL_159]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_155]], %[[VAL_162]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_154]], %[[VAL_163]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_166:[0-9a-zA-Z_\.]+]] = %[[VAL_149]]#0, %[[VAL_167:[0-9a-zA-Z_\.]+]] = %[[VAL_164]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_167]], %[[VAL_168]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_169]]) %[[VAL_166]], %[[VAL_167]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_170:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_171:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_172]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_173]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_174]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_170]]{{\[}}%[[VAL_177]]] = %[[VAL_175]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_171]], %[[VAL_178]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_170]], %[[VAL_179]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
