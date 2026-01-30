// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk=concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function add(x1,y1,x2,y2) {
    var a = 168700;
    var d = 168696;

    var res[2];
    res[0] = (x1*y2 + y1*x2) / (1 + d*x1*x2*y1*y2);
    res[1] = (y1*y2 - a*x1*x2) / (1 - d*x1*x2*y1*y2);
    return res;
}

function mul(base, k) {
    var out[16][2];

    var i;
    var p[2];

    var dbl[2] = base;

    for (i=0; i<k*4; i++) {
        dbl = add(dbl[0], dbl[1], dbl[0], dbl[1]);
    }

    out[0][0] = 0;
    out[0][1] = 1;
    for (i=1; i<16; i++) {
        p = add(out[i-1][0], out[i-1][1], dbl[0], dbl[1]);
        out[i][0] = p[0];
        out[i][1] = p[1];
    }

    return out;
}

template Main() {
    signal output out[16][2];
    var base[2] = [5299619240641551281634865583518297030282874472190772894086521144482721001553,
                16950150798460657717958625567821834550301663161624707787222815936182638968203];

    var temp[16][2] = mul(base, 0);
    for (var i=0; i<16; i++) {
        out[i][0] <== temp[i][0];
        out[i][1] <== temp[i][1];
    }
}

component main = Main();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @add_1(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type) -> !array.type<2 x !felt.type> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  168700
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  168696
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:      array.write %[[VAL_6]]{{\[}}%[[VAL_9]]] = %[[VAL_7]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]]
// CHECK-NEXT:      array.write %[[VAL_6]]{{\[}}%[[VAL_12]]] = %[[VAL_10]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_14]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  168696
// CHECK-NEXT:      %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_17]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_18]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_19]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_20]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_15]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]]
// CHECK-NEXT:      array.write %[[VAL_6]]{{\[}}%[[VAL_25]]] = %[[VAL_23]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  168700
// CHECK-NEXT:      %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_27]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_28]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_29]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  168696
// CHECK-NEXT:      %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_33]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_34]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_35]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_31]], %[[VAL_36]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_30]], %[[VAL_37]] : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]]
// CHECK-NEXT:      array.write %[[VAL_6]]{{\[}}%[[VAL_40]]] = %[[VAL_38]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      function.return %[[VAL_6]] : !array.type<2 x !felt.type>
// CHECK-NEXT:    }
// CHECK-NEXT:    function.def @mul_0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type) -> !array.type<16,2 x !felt.type> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_43:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<16,2 x !felt.type>
// CHECK-NEXT:      %[[VAL_44:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:      %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]]
// CHECK-NEXT:      array.write %[[VAL_44]]{{\[}}%[[VAL_47]]] = %[[VAL_45]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]]
// CHECK-NEXT:      array.write %[[VAL_44]]{{\[}}%[[VAL_50]]] = %[[VAL_48]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_52]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_54]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:      %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_56]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:      %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_58]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:      %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_60]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:      %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_62]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:      %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_64]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:      %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_66]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:      %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_68]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:      %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_70]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:      %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_72]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  11
// CHECK-NEXT:      %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_74]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:      %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_76]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:      %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_78]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  14
// CHECK-NEXT:      %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_80]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:      %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]]
// CHECK-NEXT:      array.insert %[[VAL_43]]{{\[}}%[[VAL_82]]] = %[[VAL_44]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_84:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:      %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]]
// CHECK-NEXT:      array.write %[[VAL_84]]{{\[}}%[[VAL_87]]] = %[[VAL_85]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]]
// CHECK-NEXT:      array.write %[[VAL_84]]{{\[}}%[[VAL_90]]] = %[[VAL_88]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_91:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:      %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]]
// CHECK-NEXT:      array.write %[[VAL_91]]{{\[}}%[[VAL_94]]] = %[[VAL_92]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]]
// CHECK-NEXT:      array.write %[[VAL_91]]{{\[}}%[[VAL_97]]] = %[[VAL_95]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_99:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_41]], %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_98]]) : (!array.type<2 x !felt.type>, !felt.type) -> (!array.type<2 x !felt.type>, !felt.type) {
// CHECK-NEXT:        %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_42]], %[[VAL_102]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_104:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_101]], %[[VAL_103]])
// CHECK-NEXT:        scf.condition(%[[VAL_104]]) %[[VAL_100]], %[[VAL_101]] : !array.type<2 x !felt.type>, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[VAL_105:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>, %[[VAL_106:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]]
// CHECK-NEXT:        %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_108]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]]
// CHECK-NEXT:        %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_111]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]]
// CHECK-NEXT:        %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_114]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_116]]
// CHECK-NEXT:        %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_117]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_119:[0-9a-zA-Z_\.]+]] = function.call @add_1(%[[VAL_109]], %[[VAL_112]], %[[VAL_115]], %[[VAL_118]]) : (!felt.type, !felt.type, !felt.type, !felt.type) -> !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_106]], %[[VAL_120]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_119]], %[[VAL_121]] : !array.type<2 x !felt.type>, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]]
// CHECK-NEXT:      %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]]
// CHECK-NEXT:      array.write %[[VAL_43]]{{\[}}%[[VAL_124]], %[[VAL_126]]] = %[[VAL_122]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]]
// CHECK-NEXT:      %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]]
// CHECK-NEXT:      array.write %[[VAL_43]]{{\[}}%[[VAL_129]], %[[VAL_131]]] = %[[VAL_127]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_133:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_132]], %[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_84]]) : (!felt.type, !array.type<2 x !felt.type>) -> (!felt.type, !array.type<2 x !felt.type>) {
// CHECK-NEXT:        %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  16
// CHECK-NEXT:        %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_134]], %[[VAL_136]])
// CHECK-NEXT:        scf.condition(%[[VAL_137]]) %[[VAL_134]], %[[VAL_135]] : !felt.type, !array.type<2 x !felt.type>
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_139:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>):
// CHECK-NEXT:        %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_138]], %[[VAL_140]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]]
// CHECK-NEXT:        %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]]
// CHECK-NEXT:        %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_142]], %[[VAL_144]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_138]], %[[VAL_146]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]]
// CHECK-NEXT:        %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]]
// CHECK-NEXT:        %[[VAL_151:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_148]], %[[VAL_150]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]]
// CHECK-NEXT:        %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]#0{{\[}}%[[VAL_153]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]]
// CHECK-NEXT:        %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]#0{{\[}}%[[VAL_156]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_158:[0-9a-zA-Z_\.]+]] = function.call @add_1(%[[VAL_145]], %[[VAL_151]], %[[VAL_154]], %[[VAL_157]]) : (!felt.type, !felt.type, !felt.type, !felt.type) -> !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]]
// CHECK-NEXT:        %[[VAL_161:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_158]]{{\[}}%[[VAL_160]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]]
// CHECK-NEXT:        %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]]
// CHECK-NEXT:        array.write %[[VAL_43]]{{\[}}%[[VAL_162]], %[[VAL_164]]] = %[[VAL_161]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_165]]
// CHECK-NEXT:        %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_158]]{{\[}}%[[VAL_166]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]]
// CHECK-NEXT:        %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]]
// CHECK-NEXT:        array.write %[[VAL_43]]{{\[}}%[[VAL_168]], %[[VAL_170]]] = %[[VAL_167]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_138]], %[[VAL_171]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_172]], %[[VAL_158]] : !felt.type, !array.type<2 x !felt.type>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_43]] : !array.type<16,2 x !felt.type>
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Main<[]> {
// CHECK-NEXT:      struct.field @out : !array.type<16,2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_173:[0-9a-zA-Z_\.]+]] = struct.new : <@Main<[]>>
// CHECK-NEXT:        %[[VAL_174:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<16,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_175:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_177]]
// CHECK-NEXT:        array.write %[[VAL_175]]{{\[}}%[[VAL_178]]] = %[[VAL_176]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_180]]
// CHECK-NEXT:        array.write %[[VAL_175]]{{\[}}%[[VAL_181]]] = %[[VAL_179]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553
// CHECK-NEXT:        %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_183]]
// CHECK-NEXT:        array.write %[[VAL_175]]{{\[}}%[[VAL_184]]] = %[[VAL_182]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203
// CHECK-NEXT:        %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_187:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_186]]
// CHECK-NEXT:        array.write %[[VAL_175]]{{\[}}%[[VAL_187]]] = %[[VAL_185]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_188:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<16,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_189:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_192:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_191]]
// CHECK-NEXT:        array.write %[[VAL_189]]{{\[}}%[[VAL_192]]] = %[[VAL_190]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]]
// CHECK-NEXT:        array.write %[[VAL_189]]{{\[}}%[[VAL_195]]] = %[[VAL_193]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_197]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_198]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_199]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_201:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_200]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_201]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_203]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_205]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_207:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_207]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_209:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_208]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_209]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_211:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_210]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_211]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_213:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_213]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_214]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_215]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_217:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_216]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_217]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  11
// CHECK-NEXT:        %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_219]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:        %[[VAL_221:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_221]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:        %[[VAL_223:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_222]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_223]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  14
// CHECK-NEXT:        %[[VAL_225:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_224]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_225]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_227:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_226]]
// CHECK-NEXT:        array.insert %[[VAL_188]]{{\[}}%[[VAL_227]]] = %[[VAL_189]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_229:[0-9a-zA-Z_\.]+]] = function.call @mul_0(%[[VAL_175]], %[[VAL_228]]) : (!array.type<2 x !felt.type>, !felt.type) -> !array.type<16,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_231:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_232:[0-9a-zA-Z_\.]+]] = %[[VAL_230]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.const  16
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_232]], %[[VAL_233]])
// CHECK-NEXT:          scf.condition(%[[VAL_234]]) %[[VAL_232]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_235:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]]
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]]
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_236]], %[[VAL_238]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]]
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_241]]
// CHECK-NEXT:          array.write %[[VAL_174]]{{\[}}%[[VAL_240]], %[[VAL_242]]] = %[[VAL_239]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]]
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_244]]
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_243]], %[[VAL_245]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]]
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_248]]
// CHECK-NEXT:          array.write %[[VAL_174]]{{\[}}%[[VAL_247]], %[[VAL_249]]] = %[[VAL_246]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_235]], %[[VAL_250]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_251]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_173]][@out] = %[[VAL_174]] : <@Main<[]>>, !array.type<16,2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_173]] : !struct.type<@Main<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_252:[0-9a-zA-Z_\.]+]]: !struct.type<@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_318:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_252]][@out] : <@Main<[]>>, !array.type<16,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_253:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]]
// CHECK-NEXT:        array.write %[[VAL_253]]{{\[}}%[[VAL_256]]] = %[[VAL_254]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_259:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_258]]
// CHECK-NEXT:        array.write %[[VAL_253]]{{\[}}%[[VAL_259]]] = %[[VAL_257]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553
// CHECK-NEXT:        %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_261]]
// CHECK-NEXT:        array.write %[[VAL_253]]{{\[}}%[[VAL_262]]] = %[[VAL_260]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203
// CHECK-NEXT:        %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_264]]
// CHECK-NEXT:        array.write %[[VAL_253]]{{\[}}%[[VAL_265]]] = %[[VAL_263]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_266:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<16,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_267:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_270:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_269]]
// CHECK-NEXT:        array.write %[[VAL_267]]{{\[}}%[[VAL_270]]] = %[[VAL_268]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_271:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_272:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_273:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_272]]
// CHECK-NEXT:        array.write %[[VAL_267]]{{\[}}%[[VAL_273]]] = %[[VAL_271]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_275:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_274]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_275]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_276:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_277:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_276]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_277]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_278:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_279:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_278]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_279]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_281:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_280]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_281]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_282:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_283:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_282]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_283]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_284:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_285:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_284]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_285]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_287]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_289:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_289]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_291:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_291]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_293]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_294]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_295]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.const  11
// CHECK-NEXT:        %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_296]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_297]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.const  12
// CHECK-NEXT:        %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_299]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.const  13
// CHECK-NEXT:        %[[VAL_301:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_300]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_301]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.const  14
// CHECK-NEXT:        %[[VAL_303:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_302]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_303]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_304:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_304]]
// CHECK-NEXT:        array.insert %[[VAL_266]]{{\[}}%[[VAL_305]]] = %[[VAL_267]] : <16,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_307:[0-9a-zA-Z_\.]+]] = function.call @mul_0(%[[VAL_253]], %[[VAL_306]]) : (!array.type<2 x !felt.type>, !felt.type) -> !array.type<16,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_309:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_310:[0-9a-zA-Z_\.]+]] = %[[VAL_308]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_311:[0-9a-zA-Z_\.]+]] = felt.const  16
// CHECK-NEXT:          %[[VAL_312:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_310]], %[[VAL_311]])
// CHECK-NEXT:          scf.condition(%[[VAL_312]]) %[[VAL_310]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_313:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_314:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_313]]
// CHECK-NEXT:          %[[VAL_315:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_316:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_315]]
// CHECK-NEXT:          %[[VAL_317:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_307]]{{\[}}%[[VAL_314]], %[[VAL_316]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_313]]
// CHECK-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_320]]
// CHECK-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_318]]{{\[}}%[[VAL_319]], %[[VAL_321]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_322]], %[[VAL_317]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_313]]
// CHECK-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_324]]
// CHECK-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_307]]{{\[}}%[[VAL_323]], %[[VAL_325]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_313]]
// CHECK-NEXT:          %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_329]]
// CHECK-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_318]]{{\[}}%[[VAL_328]], %[[VAL_330]]] : <16,2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_331]], %[[VAL_326]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_332:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_333:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_313]], %[[VAL_332]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_333]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
