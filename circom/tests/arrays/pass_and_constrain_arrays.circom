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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// CHECK-NEXT:    poly.template @add {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_arg3 : !poly.tvar<@T_arg3>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @add(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "x1"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "y1"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2> {function.arg_name = "x2"}, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg3> {function.arg_name = "y2"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
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
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_16]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_18]], %[[VAL_19]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_20]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_22]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_14]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_7]]{{\[}}%[[VAL_28]]] = %[[VAL_26]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_29]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  168700 : <"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_32]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_34]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_31]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_39]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_41]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_43]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_45]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_38]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_37]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_7]]{{\[}}%[[VAL_51]]] = %[[VAL_49]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_7]] : (!array.type<2 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_52]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @mul {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @mul(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "base"}, %[[VAL_54:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "k"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_55]], %[[VAL_55]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.new  : <16,2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_58]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_59]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_60]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_61]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_62]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_63]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_64]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_65]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_66]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 9 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_67]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_68]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_69]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 12 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_70]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 13 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_71]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 14 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_72]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:        array.insert %[[VAL_57]]{{\[}}%[[VAL_73]]] = %[[VAL_56]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_75]], %[[VAL_75]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_77]], %[[VAL_77]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_53]] : (!poly.tvar<@T_arg0>) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_81:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_79]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_80]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_54]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_85]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_83]], %[[VAL_86]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_87]]) %[[VAL_82]], %[[VAL_83]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>, %[[VAL_89:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_88]]{{\[}}%[[VAL_91]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_88]]{{\[}}%[[VAL_94]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_88]]{{\[}}%[[VAL_97]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_88]]{{\[}}%[[VAL_100]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = function.call @add::@add(%[[VAL_92]], %[[VAL_95]], %[[VAL_98]], %[[VAL_101]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_89]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_102]], %[[VAL_104]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_57]]{{\[}}%[[VAL_107]], %[[VAL_109]]] = %[[VAL_105]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_57]]{{\[}}%[[VAL_112]], %[[VAL_114]]] = %[[VAL_110]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_116:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]], %[[VAL_118:[0-9a-zA-Z_\.]+]] = %[[VAL_76]]) : (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_117]], %[[VAL_119]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_120]]) %[[VAL_117]], %[[VAL_118]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_122:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>):
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_121]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_125]], %[[VAL_127]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_121]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_131]], %[[VAL_133]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_135]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]#0{{\[}}%[[VAL_136]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]#0{{\[}}%[[VAL_139]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = function.call @add::@add(%[[VAL_128]], %[[VAL_134]], %[[VAL_137]], %[[VAL_140]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_143]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_57]]{{\[}}%[[VAL_145]], %[[VAL_147]]] = %[[VAL_144]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_149]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_57]]{{\[}}%[[VAL_151]], %[[VAL_153]]] = %[[VAL_150]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_121]], %[[VAL_154]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_155]], %[[VAL_141]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_156:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_57]] : (!array.type<16,2 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_156]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @out : !array.type<16,2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_159]], %[[VAL_159]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_161]], %[[VAL_162]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_164]], %[[VAL_164]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.new  : <16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_167]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_168]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_169]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_170]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_171]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_172]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_173]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_174]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_175]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 9 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_176]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_177]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_178]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.constant 12 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_179]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 13 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_180]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 14 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_181]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:          array.insert %[[VAL_166]]{{\[}}%[[VAL_182]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = function.call @mul::@mul(%[[VAL_163]], %[[VAL_183]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_187:[0-9a-zA-Z_\.]+]] = %[[VAL_185]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_187]], %[[VAL_188]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_189]]) %[[VAL_187]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_190:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_192]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_184]]{{\[}}%[[VAL_191]], %[[VAL_193]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_158]]{{\[}}%[[VAL_195]], %[[VAL_197]]] = %[[VAL_194]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_184]]{{\[}}%[[VAL_198]], %[[VAL_200]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_158]]{{\[}}%[[VAL_202]], %[[VAL_204]]] = %[[VAL_201]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_190]], %[[VAL_205]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_157]][@out] = %[[VAL_158]] : <@Main::@Main<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_157]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_207:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_207]][@out] : <@Main::@Main<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_209]], %[[VAL_209]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_211]], %[[VAL_212]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_214]], %[[VAL_214]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.new  : <16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_217]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_218]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_219]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_220]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_221]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_222]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_223]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_224]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_225]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.constant 9 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_226]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = arith.constant 10 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_227]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = arith.constant 11 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_228]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.constant 12 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_229]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = arith.constant 13 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_230]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = arith.constant 14 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_231]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:          array.insert %[[VAL_216]]{{\[}}%[[VAL_232]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = function.call @mul::@mul(%[[VAL_213]], %[[VAL_233]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_237:[0-9a-zA-Z_\.]+]] = %[[VAL_235]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_239:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_237]], %[[VAL_238]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_239]]) %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_240:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_242]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_241]], %[[VAL_243]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_246]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_245]], %[[VAL_247]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_248]], %[[VAL_244]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_250]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_252:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_249]], %[[VAL_251]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_255:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_254]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_253]], %[[VAL_255]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_256]], %[[VAL_252]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_240]], %[[VAL_257]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_258]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
