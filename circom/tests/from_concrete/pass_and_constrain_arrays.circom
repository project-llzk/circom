// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_0::@Main_0<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<16,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<2 x !felt.type<"bn128">> = [ 5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">,  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @add_1 {
// CHECK-NEXT:      function.def @add_1(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x1"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "y1"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x2"}, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "y2"}) -> !array.type<2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  168700 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_17]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_18]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_19]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_20]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_15]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_6]]{{\[}}%[[VAL_25]]] = %[[VAL_23]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  168700 : <"bn128">
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_27]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_28]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_26]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_33]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_34]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_35]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_31]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_30]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_6]]{{\[}}%[[VAL_40]]] = %[[VAL_38]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        function.return %[[VAL_6]] : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @mul_0 {
// CHECK-NEXT:      function.def @mul_0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "k"}) -> !array.type<16,2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_84:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_91:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_99:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_41]], %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_98]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_42]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_101]], %[[VAL_103]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_104]]) %[[VAL_100]], %[[VAL_101]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_105:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>, %[[VAL_106:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_108]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_111]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_114]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_116]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_117]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = function.call @add_1::@add_1(%[[VAL_109]], %[[VAL_112]], %[[VAL_115]], %[[VAL_118]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_106]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_119]], %[[VAL_121]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_43]]{{\[}}%[[VAL_124]], %[[VAL_126]]] = %[[VAL_122]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_43]]{{\[}}%[[VAL_129]], %[[VAL_131]]] = %[[VAL_127]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_133:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_132]], %[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_84]]) : (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_134]], %[[VAL_136]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_137]]) %[[VAL_134]], %[[VAL_135]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_139:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>):
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_138]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_142]], %[[VAL_144]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_138]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_148]], %[[VAL_150]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]#0{{\[}}%[[VAL_153]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]#0{{\[}}%[[VAL_156]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = function.call @add_1::@add_1(%[[VAL_145]], %[[VAL_151]], %[[VAL_154]], %[[VAL_157]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_158]]{{\[}}%[[VAL_160]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_43]]{{\[}}%[[VAL_162]], %[[VAL_164]]] = %[[VAL_161]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_165]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_158]]{{\[}}%[[VAL_166]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_43]]{{\[}}%[[VAL_168]], %[[VAL_170]]] = %[[VAL_167]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_138]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_172]], %[[VAL_158]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_43]] : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main_0 {
// CHECK-NEXT:      struct.def @Main_0 {
// CHECK-NEXT:        struct.member @out : !array.type<16,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main_0::@Main_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_0::@Main_0<[]>>
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = function.call @mul_0::@mul_0(%[[VAL_175]], %[[VAL_228]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_232:[0-9a-zA-Z_\.]+]] = %[[VAL_230]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_234:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_232]], %[[VAL_233]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_234]]) %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_235:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_236:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_236]], %[[VAL_238]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_241]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_174]]{{\[}}%[[VAL_240]], %[[VAL_242]]] = %[[VAL_239]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_244]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_243]], %[[VAL_245]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_248]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_174]]{{\[}}%[[VAL_247]], %[[VAL_249]]] = %[[VAL_246]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_235]], %[[VAL_250]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_251]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_173]][@out] = %[[VAL_174]] : <@Main_0::@Main_0<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_173]] : !struct.type<@Main_0::@Main_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_252:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_0::@Main_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_252]][@out] : <@Main_0::@Main_0<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = function.call @mul_0::@mul_0(%[[VAL_254]], %[[VAL_307]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_310:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_311:[0-9a-zA-Z_\.]+]] = %[[VAL_309]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_311]], %[[VAL_312]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_313]]) %[[VAL_311]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_314:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_314]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_316]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_308]]{{\[}}%[[VAL_315]], %[[VAL_317]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_314]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_320]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_319]], %[[VAL_321]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_322]], %[[VAL_318]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_314]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_324]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_308]]{{\[}}%[[VAL_323]], %[[VAL_325]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_314]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_328]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_327]], %[[VAL_329]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_330]], %[[VAL_326]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_314]], %[[VAL_331]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_332]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
