// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// The circom compiler only gives a warning for this:
// warning[T3001]: Typing warning: Mismatched dimensions, assigning to an array an expression of smaller length,
//                 the remaining positions are not modified. Initially all variables are initialized to 0.

template SmallToLarge() {
    signal output out[10];
    var temp[10] = [99, 98, 97, 96, 95, 94, 93, 92 /*, 0, 0 */];
    temp = [89, 88, 87, 86, 85];
    assert(temp[0] == 89);
    assert(temp[4] == 85);
    assert(temp[5] == 94);
    assert(temp[7] == 92);
    assert(temp[8] == 0);
    assert(temp[9] == 0);
    for (var i = 0; i < 10; i++) {
        out[i] <-- temp[i];
    }
}

component main = SmallToLarge();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SmallToLarge<[]>>} {
// CHECK-NEXT:    struct.def @SmallToLarge<[]> {
// CHECK-NEXT:      struct.member @out : !array.type<10 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@SmallToLarge<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@SmallToLarge<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<10 x !felt.type>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  97
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  96
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  95
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  94
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  93
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  92
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_5]], %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]] : <8 x !felt.type>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_12]], %[[VAL_13]] : <8 x !felt.type>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_16]] to %[[VAL_15]] step %[[VAL_17]] {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_18]], %[[VAL_14]] : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_19]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_18]]] : <8 x !felt.type>, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_21]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_22]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_18]]] = %[[VAL_20]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  89
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  88
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  87
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  86
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  85
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_23]], %[[VAL_24]], %[[VAL_25]], %[[VAL_26]], %[[VAL_27]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_28]], %[[VAL_29]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]] to %[[VAL_31]] step %[[VAL_33]] {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_34]], %[[VAL_30]] : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_35]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_34]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_37]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_38]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_34]]] = %[[VAL_36]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]]
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_40]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  89
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_41]], %[[VAL_42]])
// CHECK-NEXT:        bool.assert %[[VAL_43]], "assertion failed"
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]]
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_45]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  85
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_46]], %[[VAL_47]])
// CHECK-NEXT:        bool.assert %[[VAL_48]], "assertion failed"
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]]
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_50]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  94
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_51]], %[[VAL_52]])
// CHECK-NEXT:        bool.assert %[[VAL_53]], "assertion failed"
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]]
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_55]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  92
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_56]], %[[VAL_57]])
// CHECK-NEXT:        bool.assert %[[VAL_58]], "assertion failed"
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]]
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_60]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_61]], %[[VAL_62]])
// CHECK-NEXT:        bool.assert %[[VAL_63]], "assertion failed"
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]]
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_65]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_66]], %[[VAL_67]])
// CHECK-NEXT:        bool.assert %[[VAL_68]], "assertion failed"
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_69]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_71]], %[[VAL_72]])
// CHECK-NEXT:          scf.condition(%[[VAL_73]]) %[[VAL_71]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_74:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]]
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_75]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]]
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_77]]] = %[[VAL_76]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_78]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_79]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@SmallToLarge<[]>>, !array.type<10 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@SmallToLarge<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !struct.type<@SmallToLarge<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@out] : <@SmallToLarge<[]>>, !array.type<10 x !felt.type>
// CHECK-NEXT:        %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_82]], %[[VAL_82]], %[[VAL_82]], %[[VAL_82]], %[[VAL_82]], %[[VAL_82]], %[[VAL_82]], %[[VAL_82]], %[[VAL_82]], %[[VAL_82]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  97
// CHECK-NEXT:        %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  96
// CHECK-NEXT:        %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  95
// CHECK-NEXT:        %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  94
// CHECK-NEXT:        %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  93
// CHECK-NEXT:        %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  92
// CHECK-NEXT:        %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_84]], %[[VAL_85]], %[[VAL_86]], %[[VAL_87]], %[[VAL_88]], %[[VAL_89]], %[[VAL_90]], %[[VAL_91]] : <8 x !felt.type>
// CHECK-NEXT:        %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_92]], %[[VAL_93]] : <8 x !felt.type>
// CHECK-NEXT:        %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:        %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_96]] to %[[VAL_95]] step %[[VAL_97]] {
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_98]], %[[VAL_94]] : index
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_99]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_92]]{{\[}}%[[VAL_98]]] : <8 x !felt.type>, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_101]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_102]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          array.write %[[VAL_83]]{{\[}}%[[VAL_98]]] = %[[VAL_100]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  89
// CHECK-NEXT:        %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  88
// CHECK-NEXT:        %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  87
// CHECK-NEXT:        %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  86
// CHECK-NEXT:        %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  85
// CHECK-NEXT:        %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_103]], %[[VAL_104]], %[[VAL_105]], %[[VAL_106]], %[[VAL_107]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_108]], %[[VAL_109]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:        %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_114:[0-9a-zA-Z_\.]+]] = %[[VAL_112]] to %[[VAL_111]] step %[[VAL_113]] {
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_114]], %[[VAL_110]] : index
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_115]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_114]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_117]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_118]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          array.write %[[VAL_83]]{{\[}}%[[VAL_114]]] = %[[VAL_116]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]]
// CHECK-NEXT:        %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_120]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  89
// CHECK-NEXT:        %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_121]], %[[VAL_122]])
// CHECK-NEXT:        bool.assert %[[VAL_123]], "assertion failed"
// CHECK-NEXT:        %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]]
// CHECK-NEXT:        %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_125]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  85
// CHECK-NEXT:        %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_126]], %[[VAL_127]])
// CHECK-NEXT:        bool.assert %[[VAL_128]], "assertion failed"
// CHECK-NEXT:        %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]]
// CHECK-NEXT:        %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_130]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  94
// CHECK-NEXT:        %[[VAL_133:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_131]], %[[VAL_132]])
// CHECK-NEXT:        bool.assert %[[VAL_133]], "assertion failed"
// CHECK-NEXT:        %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_135:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_134]]
// CHECK-NEXT:        %[[VAL_136:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_135]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  92
// CHECK-NEXT:        %[[VAL_138:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_136]], %[[VAL_137]])
// CHECK-NEXT:        bool.assert %[[VAL_138]], "assertion failed"
// CHECK-NEXT:        %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_139]]
// CHECK-NEXT:        %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_140]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_143:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_141]], %[[VAL_142]])
// CHECK-NEXT:        bool.assert %[[VAL_143]], "assertion failed"
// CHECK-NEXT:        %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_144]]
// CHECK-NEXT:        %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_145]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_148:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_146]], %[[VAL_147]])
// CHECK-NEXT:        bool.assert %[[VAL_148]], "assertion failed"
// CHECK-NEXT:        %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_150:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_151:[0-9a-zA-Z_\.]+]] = %[[VAL_149]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_151]], %[[VAL_152]])
// CHECK-NEXT:          scf.condition(%[[VAL_153]]) %[[VAL_151]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_154:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_154]], %[[VAL_155]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_156]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
