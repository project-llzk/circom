// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Main::@Main<[]>>} {
// CHECK-NEXT:    poly.template @add {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_arg3 : !poly.tvar<@T_arg3>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @add(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1>, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg3>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  168700 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_6]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_16]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_17]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_19]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_20]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_22]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_25]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_14]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_7]]{{\[}}%[[VAL_32]]] = %[[VAL_30]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  168700 : <"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_36]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_39]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_40]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_35]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_45]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_46]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_48]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_49]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_51]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_52]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_54]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_55]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_44]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_43]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_7]]{{\[}}%[[VAL_61]]] = %[[VAL_59]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_7]] : (!array.type<2 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_62]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @mul {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @mul(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>, %[[VAL_64:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_65]], %[[VAL_65]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.new  : <16,2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_68]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_69]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_70]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_71]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_72]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_73]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_74]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_75]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_76]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 9 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_77]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_78]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_79]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 12 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_80]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 13 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_81]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 14 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_82]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:        array.insert %[[VAL_67]]{{\[}}%[[VAL_83]]] = %[[VAL_66]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_85]], %[[VAL_85]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_87]], %[[VAL_87]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_89:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_63]] : (!poly.tvar<@T_arg0>) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_91:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_89]], %[[VAL_93:[0-9a-zA-Z_\.]+]] = %[[VAL_90]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_64]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_94]] : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_95]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_93]], %[[VAL_97]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_98]]) %[[VAL_92]], %[[VAL_93]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_99:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>, %[[VAL_100:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_102]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_105]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_108]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_111]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = function.call @add::@add(%[[VAL_103]], %[[VAL_106]], %[[VAL_109]], %[[VAL_112]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_113]] : (!array.type<2 x !felt.type<"bn128">>) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_114]], %[[VAL_116]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_118]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_67]]{{\[}}%[[VAL_119]], %[[VAL_121]]] = %[[VAL_117]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_67]]{{\[}}%[[VAL_124]], %[[VAL_126]]] = %[[VAL_122]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_128:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_129:[0-9a-zA-Z_\.]+]] = %[[VAL_127]], %[[VAL_130:[0-9a-zA-Z_\.]+]] = %[[VAL_86]]) : (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_129]], %[[VAL_131]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_132]]) %[[VAL_129]], %[[VAL_130]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_133:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_134:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>):
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_133]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_136]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_137]], %[[VAL_139]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_133]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_144]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_143]], %[[VAL_145]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]#0{{\[}}%[[VAL_148]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_150]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]#0{{\[}}%[[VAL_151]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = function.call @add::@add(%[[VAL_140]], %[[VAL_146]], %[[VAL_149]], %[[VAL_152]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_153]] : (!array.type<2 x !felt.type<"bn128">>) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_154]]{{\[}}%[[VAL_156]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_67]]{{\[}}%[[VAL_158]], %[[VAL_160]]] = %[[VAL_157]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_154]]{{\[}}%[[VAL_162]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_165]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_67]]{{\[}}%[[VAL_164]], %[[VAL_166]]] = %[[VAL_163]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_133]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_168]], %[[VAL_154]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_169:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_67]] : (!array.type<16,2 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_169]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @out : !array.type<16,2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_172]], %[[VAL_172]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_174]], %[[VAL_175]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_177]], %[[VAL_177]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.new  : <16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_180]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_181]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_182]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_183]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_184]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_185]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_186]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_187]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_188]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 9 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_189]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_190]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_191]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.constant 12 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_192]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 13 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_193]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.constant 14 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_194]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:          array.insert %[[VAL_179]]{{\[}}%[[VAL_195]]] = %[[VAL_178]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = function.call @mul::@mul(%[[VAL_176]], %[[VAL_196]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_197]] : (!array.type<16,2 x !felt.type<"bn128">>) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_201:[0-9a-zA-Z_\.]+]] = %[[VAL_199]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_201]], %[[VAL_202]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_203]]) %[[VAL_201]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_204:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_198]]{{\[}}%[[VAL_205]], %[[VAL_207]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_210]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_171]]{{\[}}%[[VAL_209]], %[[VAL_211]]] = %[[VAL_208]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_213]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_198]]{{\[}}%[[VAL_212]], %[[VAL_214]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_171]]{{\[}}%[[VAL_216]], %[[VAL_218]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_204]], %[[VAL_219]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_170]][@out] = %[[VAL_171]] : <@Main::@Main<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_170]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_221:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_221]][@out] : <@Main::@Main<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_223]], %[[VAL_223]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_225]], %[[VAL_226]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_228]], %[[VAL_228]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = array.new  : <16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_231]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_232]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_233]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_234]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_235]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_236]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_237]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_238]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_239]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.constant 9 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_240]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_241]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_242]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.constant 12 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_243]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.constant 13 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_244]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = arith.constant 14 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_245]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:          array.insert %[[VAL_230]]{{\[}}%[[VAL_246]]] = %[[VAL_229]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = function.call @mul::@mul(%[[VAL_227]], %[[VAL_247]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_248]] : (!array.type<16,2 x !felt.type<"bn128">>) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_252:[0-9a-zA-Z_\.]+]] = %[[VAL_250]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_252]], %[[VAL_253]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_254]]) %[[VAL_252]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_255:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_257]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_256]], %[[VAL_258]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_261]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_260]], %[[VAL_262]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_263]], %[[VAL_259]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_264:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_265:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_265]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_264]], %[[VAL_266]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_270:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_269]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_271:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_268]], %[[VAL_270]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_271]], %[[VAL_267]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_272:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_255]], %[[VAL_272]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_273]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
