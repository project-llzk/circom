// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_12:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_13:[0-9a-zA-Z_\.]+]] = %[[V_10]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_15:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_13]], %[[V_14]])
// CHECK-NEXT:          scf.condition(%[[V_15]]) %[[V_12]], %[[V_13]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_16:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_17:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_19:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_18]], %[[V_17]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_19]]
// CHECK-NEXT:          %[[V_21:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_20]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_22]]
// CHECK-NEXT:          array.write %[[V_16]]{{\[}}%[[V_23]]] = %[[V_21]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_25:[0-9a-zA-Z_\.]+]] = felt.add %[[V_17]], %[[V_24]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_16]], %[[V_25]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_27:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_28:[0-9a-zA-Z_\.]+]] = %[[V_11]]#0, %[[V_29:[0-9a-zA-Z_\.]+]] = %[[V_26]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_30:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_31:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_29]], %[[V_30]])
// CHECK-NEXT:          scf.condition(%[[V_31]]) %[[V_28]], %[[V_29]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_32:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_33:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_35:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_34]], %[[V_33]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_35]]
// CHECK-NEXT:          %[[V_37:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_36]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_38]]
// CHECK-NEXT:          array.write %[[V_32]]{{\[}}%[[V_39]]] = %[[V_37]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_40:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_41:[0-9a-zA-Z_\.]+]] = felt.add %[[V_33]], %[[V_40]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_32]], %[[V_41]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_42:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_43:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_44:[0-9a-zA-Z_\.]+]] = %[[V_27]]#0, %[[V_45:[0-9a-zA-Z_\.]+]] = %[[V_42]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_46:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_47:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_45]], %[[V_46]])
// CHECK-NEXT:          scf.condition(%[[V_47]]) %[[V_44]], %[[V_45]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_48:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_49:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_50:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_51:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_50]], %[[V_49]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_51]]
// CHECK-NEXT:          %[[V_53:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_52]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_54:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_54]]
// CHECK-NEXT:          array.write %[[V_48]]{{\[}}%[[V_55]]] = %[[V_53]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_56:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_57:[0-9a-zA-Z_\.]+]] = felt.add %[[V_49]], %[[V_56]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_48]], %[[V_57]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_59:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_60:[0-9a-zA-Z_\.]+]] = %[[V_43]]#0, %[[V_61:[0-9a-zA-Z_\.]+]] = %[[V_58]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_62:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_63:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_61]], %[[V_62]])
// CHECK-NEXT:          scf.condition(%[[V_63]]) %[[V_60]], %[[V_61]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_64:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_65:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_66:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_67:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_66]], %[[V_65]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_67]]
// CHECK-NEXT:          %[[V_69:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_68]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_70:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_70]]
// CHECK-NEXT:          array.write %[[V_64]]{{\[}}%[[V_71]]] = %[[V_69]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_72:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_73:[0-9a-zA-Z_\.]+]] = felt.add %[[V_65]], %[[V_72]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_64]], %[[V_73]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_74:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_75:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_76:[0-9a-zA-Z_\.]+]] = %[[V_59]]#0, %[[V_77:[0-9a-zA-Z_\.]+]] = %[[V_74]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_78:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[V_79:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_77]], %[[V_78]])
// CHECK-NEXT:          scf.condition(%[[V_79]]) %[[V_76]], %[[V_77]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_80:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_81:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_82:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[V_83:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_82]], %[[V_81]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_83]]
// CHECK-NEXT:          %[[V_85:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_84]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_86:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[V_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_86]]
// CHECK-NEXT:          array.write %[[V_80]]{{\[}}%[[V_87]]] = %[[V_85]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_88:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_89:[0-9a-zA-Z_\.]+]] = felt.add %[[V_81]], %[[V_88]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_80]], %[[V_89]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[V_1]] : !struct.type<@InnerLoops<[@n]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_A:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops<[@n]>>, %[[V_91:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_93:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[V_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_96:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_95]] : <@n x !felt.type>
// CHECK-NEXT:        %[[V_97:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_99:[0-9a-zA-Z_\.]+]] = %[[V_97]] to %[[V_96]] step %[[V_98]] {
// CHECK-NEXT:          array.write %[[V_B]]{{\[}}%[[V_99]]] = %[[V_93]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_100:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_101:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_102:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_103:[0-9a-zA-Z_\.]+]] = %[[V_100]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_104:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_105:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_103]], %[[V_104]])
// CHECK-NEXT:          scf.condition(%[[V_105]]) %[[V_102]], %[[V_103]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_106:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_107:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_108:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_109:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_108]], %[[V_107]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_109]]
// CHECK-NEXT:          %[[V_111:[0-9a-zA-Z_\.]+]] = array.read %[[V_91]]{{\[}}%[[V_110]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_112:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_112]]
// CHECK-NEXT:          array.write %[[V_106]]{{\[}}%[[V_113]]] = %[[V_111]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_114:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_115:[0-9a-zA-Z_\.]+]] = felt.add %[[V_107]], %[[V_114]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_106]], %[[V_115]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_116:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_117:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_118:[0-9a-zA-Z_\.]+]] = %[[V_101]]#0, %[[V_119:[0-9a-zA-Z_\.]+]] = %[[V_116]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_120:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_121:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_119]], %[[V_120]])
// CHECK-NEXT:          scf.condition(%[[V_121]]) %[[V_118]], %[[V_119]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_122:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_123:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_124:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_125:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_124]], %[[V_123]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_125]]
// CHECK-NEXT:          %[[V_127:[0-9a-zA-Z_\.]+]] = array.read %[[V_91]]{{\[}}%[[V_126]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_128:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_128]]
// CHECK-NEXT:          array.write %[[V_122]]{{\[}}%[[V_129]]] = %[[V_127]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_130:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_131:[0-9a-zA-Z_\.]+]] = felt.add %[[V_123]], %[[V_130]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_122]], %[[V_131]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_132:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_133:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_134:[0-9a-zA-Z_\.]+]] = %[[V_117]]#0, %[[V_135:[0-9a-zA-Z_\.]+]] = %[[V_132]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_136:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_137:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_135]], %[[V_136]])
// CHECK-NEXT:          scf.condition(%[[V_137]]) %[[V_134]], %[[V_135]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_138:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_139:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_140:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_141:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_140]], %[[V_139]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_141]]
// CHECK-NEXT:          %[[V_143:[0-9a-zA-Z_\.]+]] = array.read %[[V_91]]{{\[}}%[[V_142]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_144:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_144]]
// CHECK-NEXT:          array.write %[[V_138]]{{\[}}%[[V_145]]] = %[[V_143]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_146:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_147:[0-9a-zA-Z_\.]+]] = felt.add %[[V_139]], %[[V_146]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_138]], %[[V_147]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_148:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_149:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_150:[0-9a-zA-Z_\.]+]] = %[[V_133]]#0, %[[V_151:[0-9a-zA-Z_\.]+]] = %[[V_148]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_152:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_153:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_151]], %[[V_152]])
// CHECK-NEXT:          scf.condition(%[[V_153]]) %[[V_150]], %[[V_151]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_154:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_155:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_156:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_157:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_156]], %[[V_155]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_157]]
// CHECK-NEXT:          %[[V_159:[0-9a-zA-Z_\.]+]] = array.read %[[V_91]]{{\[}}%[[V_158]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_160:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[V_161:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_160]]
// CHECK-NEXT:          array.write %[[V_154]]{{\[}}%[[V_161]]] = %[[V_159]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_162:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_163:[0-9a-zA-Z_\.]+]] = felt.add %[[V_155]], %[[V_162]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_154]], %[[V_163]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_164:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_165:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_166:[0-9a-zA-Z_\.]+]] = %[[V_149]]#0, %[[V_167:[0-9a-zA-Z_\.]+]] = %[[V_164]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_168:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[V_169:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_167]], %[[V_168]])
// CHECK-NEXT:          scf.condition(%[[V_169]]) %[[V_166]], %[[V_167]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_170:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_171:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_172:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[V_173:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_172]], %[[V_171]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_173]]
// CHECK-NEXT:          %[[V_175:[0-9a-zA-Z_\.]+]] = array.read %[[V_91]]{{\[}}%[[V_174]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_176:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[V_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_176]]
// CHECK-NEXT:          array.write %[[V_170]]{{\[}}%[[V_177]]] = %[[V_175]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_178:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_179:[0-9a-zA-Z_\.]+]] = felt.add %[[V_171]], %[[V_178]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_170]], %[[V_179]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
