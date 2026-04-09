// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(n) {
    signal input a[n];
    var b[n];

    // Manually unrolled loop from inner_loops_01.circom
    // for (var i = 0; i < n; i++) {

    var i = 0;
    for (var j = 0; j <= i; j++) {
        b[i] = a[i - j];
    }
    i++; // 1
    for (var j = 0; j <= i; j++) {
        b[i] = a[i - j];
    }
    i++; // 2
    for (var j = 0; j <= i; j++) {
        b[i] = a[i - j];
    }
    i++; // 3
    for (var j = 0; j <= i; j++) {
        b[i] = a[i - j];
    }
    i++; // 4
    for (var j = 0; j <= i; j++) {
        b[i] = a[i - j];
    }
    i++; // 5
}

component main = InnerLoops(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerLoops<[5]>>} {
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
// CHECK-NEXT:        %[[V_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B1:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_14:[0-9a-zA-Z_\.]+]] = %[[V_11]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_15:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_14]], %[[V_10]])
// CHECK-NEXT:          scf.condition(%[[V_15]]) %[[V_B1]], %[[V_14]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_B2:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_17:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_18:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_10]], %[[V_17]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_18]]
// CHECK-NEXT:          %[[V_20:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_19]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_10]]
// CHECK-NEXT:          array.write %[[V_B2]]{{\[}}%[[V_21]]] = %[[V_20]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_23:[0-9a-zA-Z_\.]+]] = felt.add %[[V_17]], %[[V_22]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_B2]], %[[V_23]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_25:[0-9a-zA-Z_\.]+]] = felt.add %[[V_10]], %[[V_24]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_26:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_27:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B3:[0-9a-zA-Z_\.]+]] = %[[V_12]]#0, %[[V_29:[0-9a-zA-Z_\.]+]] = %[[V_26]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_30:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_29]], %[[V_25]])
// CHECK-NEXT:          scf.condition(%[[V_30]]) %[[V_B3]], %[[V_29]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_B4:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_32:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_33:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_25]], %[[V_32]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_33]]
// CHECK-NEXT:          %[[V_35:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_34]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_25]]
// CHECK-NEXT:          array.write %[[V_B4]]{{\[}}%[[V_36]]] = %[[V_35]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_38:[0-9a-zA-Z_\.]+]] = felt.add %[[V_32]], %[[V_37]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_B4]], %[[V_38]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_40:[0-9a-zA-Z_\.]+]] = felt.add %[[V_25]], %[[V_39]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_41:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_42:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B5:[0-9a-zA-Z_\.]+]] = %[[V_27]]#0, %[[V_44:[0-9a-zA-Z_\.]+]] = %[[V_41]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_45:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_44]], %[[V_40]])
// CHECK-NEXT:          scf.condition(%[[V_45]]) %[[V_B5]], %[[V_44]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_B6:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_47:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_48:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_40]], %[[V_47]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_48]]
// CHECK-NEXT:          %[[V_50:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_49]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_40]]
// CHECK-NEXT:          array.write %[[V_B6]]{{\[}}%[[V_51]]] = %[[V_50]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_53:[0-9a-zA-Z_\.]+]] = felt.add %[[V_47]], %[[V_52]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_B6]], %[[V_53]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_54:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_55:[0-9a-zA-Z_\.]+]] = felt.add %[[V_40]], %[[V_54]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_56:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_57:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B7:[0-9a-zA-Z_\.]+]] = %[[V_42]]#0, %[[V_59:[0-9a-zA-Z_\.]+]] = %[[V_56]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_60:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_59]], %[[V_55]])
// CHECK-NEXT:          scf.condition(%[[V_60]]) %[[V_B7]], %[[V_59]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_B8:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_62:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_63:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_55]], %[[V_62]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_63]]
// CHECK-NEXT:          %[[V_65:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_64]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_55]]
// CHECK-NEXT:          array.write %[[V_B8]]{{\[}}%[[V_66]]] = %[[V_65]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_67:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_68:[0-9a-zA-Z_\.]+]] = felt.add %[[V_62]], %[[V_67]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_B8]], %[[V_68]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_69:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_70:[0-9a-zA-Z_\.]+]] = felt.add %[[V_55]], %[[V_69]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_71:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_72:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_B9:[0-9a-zA-Z_\.]+]] = %[[V_57]]#0, %[[V_74:[0-9a-zA-Z_\.]+]] = %[[V_71]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_75:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_74]], %[[V_70]])
// CHECK-NEXT:          scf.condition(%[[V_75]]) %[[V_B9]], %[[V_74]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_76:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_77:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_78:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_70]], %[[V_77]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_78]]
// CHECK-NEXT:          %[[V_80:[0-9a-zA-Z_\.]+]] = array.read %[[V_A]]{{\[}}%[[V_79]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_70]]
// CHECK-NEXT:          array.write %[[V_76]]{{\[}}%[[V_81]]] = %[[V_80]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_82:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_83:[0-9a-zA-Z_\.]+]] = felt.add %[[V_77]], %[[V_82]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_76]], %[[V_83]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_84:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_85:[0-9a-zA-Z_\.]+]] = felt.add %[[V_70]], %[[V_84]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return %[[V_1]] : !struct.type<@InnerLoops<[@n]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[V_A:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops<[@n]>>, %[[V_87:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[V_89:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_B:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type>
// CHECK-NEXT:        %[[V_91:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_92:[0-9a-zA-Z_\.]+]] = array.len %[[V_B]], %[[V_91]] : <@n x !felt.type>
// CHECK-NEXT:        %[[V_93:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[V_94:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[V_95:[0-9a-zA-Z_\.]+]] = %[[V_93]] to %[[V_92]] step %[[V_94]] {
// CHECK-NEXT:          array.write %[[V_B]]{{\[}}%[[V_95]]] = %[[V_89]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_96:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_97:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_98:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_99:[0-9a-zA-Z_\.]+]] = %[[V_B]], %[[V_100:[0-9a-zA-Z_\.]+]] = %[[V_97]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_101:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_100]], %[[V_96]])
// CHECK-NEXT:          scf.condition(%[[V_101]]) %[[V_99]], %[[V_100]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_102:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_103:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_104:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_96]], %[[V_103]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_104]]
// CHECK-NEXT:          %[[V_106:[0-9a-zA-Z_\.]+]] = array.read %[[V_87]]{{\[}}%[[V_105]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_96]]
// CHECK-NEXT:          array.write %[[V_102]]{{\[}}%[[V_107]]] = %[[V_106]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_108:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_109:[0-9a-zA-Z_\.]+]] = felt.add %[[V_103]], %[[V_108]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_102]], %[[V_109]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_110:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_111:[0-9a-zA-Z_\.]+]] = felt.add %[[V_96]], %[[V_110]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_112:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_113:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_114:[0-9a-zA-Z_\.]+]] = %[[V_98]]#0, %[[V_115:[0-9a-zA-Z_\.]+]] = %[[V_112]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_116:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_115]], %[[V_111]])
// CHECK-NEXT:          scf.condition(%[[V_116]]) %[[V_114]], %[[V_115]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_117:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_118:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_119:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_111]], %[[V_118]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_119]]
// CHECK-NEXT:          %[[V_121:[0-9a-zA-Z_\.]+]] = array.read %[[V_87]]{{\[}}%[[V_120]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_111]]
// CHECK-NEXT:          array.write %[[V_117]]{{\[}}%[[V_122]]] = %[[V_121]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_123:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_124:[0-9a-zA-Z_\.]+]] = felt.add %[[V_118]], %[[V_123]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_117]], %[[V_124]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_125:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_126:[0-9a-zA-Z_\.]+]] = felt.add %[[V_111]], %[[V_125]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_127:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_128:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_129:[0-9a-zA-Z_\.]+]] = %[[V_113]]#0, %[[V_130:[0-9a-zA-Z_\.]+]] = %[[V_127]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_131:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_130]], %[[V_126]])
// CHECK-NEXT:          scf.condition(%[[V_131]]) %[[V_129]], %[[V_130]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_132:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_133:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_134:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_126]], %[[V_133]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_135:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_134]]
// CHECK-NEXT:          %[[V_136:[0-9a-zA-Z_\.]+]] = array.read %[[V_87]]{{\[}}%[[V_135]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_126]]
// CHECK-NEXT:          array.write %[[V_132]]{{\[}}%[[V_137]]] = %[[V_136]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_138:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_139:[0-9a-zA-Z_\.]+]] = felt.add %[[V_133]], %[[V_138]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_132]], %[[V_139]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_140:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_141:[0-9a-zA-Z_\.]+]] = felt.add %[[V_126]], %[[V_140]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_142:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_143:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_144:[0-9a-zA-Z_\.]+]] = %[[V_128]]#0, %[[V_145:[0-9a-zA-Z_\.]+]] = %[[V_142]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_146:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_145]], %[[V_141]])
// CHECK-NEXT:          scf.condition(%[[V_146]]) %[[V_144]], %[[V_145]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_147:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_148:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_149:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_141]], %[[V_148]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_149]]
// CHECK-NEXT:          %[[V_151:[0-9a-zA-Z_\.]+]] = array.read %[[V_87]]{{\[}}%[[V_150]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_152:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_141]]
// CHECK-NEXT:          array.write %[[V_147]]{{\[}}%[[V_152]]] = %[[V_151]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_153:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_154:[0-9a-zA-Z_\.]+]] = felt.add %[[V_148]], %[[V_153]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_147]], %[[V_154]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_155:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_156:[0-9a-zA-Z_\.]+]] = felt.add %[[V_141]], %[[V_155]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_157:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_158:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_159:[0-9a-zA-Z_\.]+]] = %[[V_143]]#0, %[[V_160:[0-9a-zA-Z_\.]+]] = %[[V_157]]) : (!array.type<@n x !felt.type>, !felt.type) -> (!array.type<@n x !felt.type>, !felt.type) {
// CHECK-NEXT:          %[[V_161:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[V_160]], %[[V_156]])
// CHECK-NEXT:          scf.condition(%[[V_161]]) %[[V_159]], %[[V_160]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[V_162:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>, %[[V_163:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[V_164:[0-9a-zA-Z_\.]+]] = felt.sub %[[V_156]], %[[V_163]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_164]]
// CHECK-NEXT:          %[[V_166:[0-9a-zA-Z_\.]+]] = array.read %[[V_87]]{{\[}}%[[V_165]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[V_156]]
// CHECK-NEXT:          array.write %[[V_162]]{{\[}}%[[V_167]]] = %[[V_166]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[V_168:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_169:[0-9a-zA-Z_\.]+]] = felt.add %[[V_163]], %[[V_168]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_162]], %[[V_169]] : !array.type<@n x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_170:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_171:[0-9a-zA-Z_\.]+]] = felt.add %[[V_156]], %[[V_170]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
