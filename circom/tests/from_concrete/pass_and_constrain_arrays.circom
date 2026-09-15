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
// CHECK-NEXT:    poly.template @add_1 {
// CHECK-NEXT:      function.def @add_1(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x1"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "y1"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "x2"}, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "y2"}) -> !array.type<2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  168700 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_11]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_12]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_13]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_14]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_9]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_6]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  168700 : <"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_21]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_22]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_20]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  168696 : <"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_26]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_27]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_28]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_29]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_25]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_24]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_6]]{{\[}}%[[VAL_34]]] = %[[VAL_32]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        function.return %[[VAL_6]] : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    poly.template @mul_0 {
// CHECK-NEXT:      function.def @mul_0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "base"}, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "k"}) -> !array.type<16,2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_40]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_42]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_44]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_46]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_48]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_50]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_52]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_54]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_56]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_58]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_60]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  11 : <"bn128">
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_62]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_64]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  13 : <"bn128">
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_66]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  14 : <"bn128">
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_68]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_37]]{{\[}}%[[VAL_70]]] = %[[VAL_38]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_72:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_73:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_35]], %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_74]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_36]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_77]], %[[VAL_79]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_80]]) %[[VAL_76]], %[[VAL_77]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_84]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_87]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_90]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_93]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = function.call @add_1::@add_1(%[[VAL_85]], %[[VAL_88]], %[[VAL_91]], %[[VAL_94]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_82]], %[[VAL_96]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_95]], %[[VAL_97]] : !array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_37]]{{\[}}%[[VAL_100]], %[[VAL_102]]] = %[[VAL_98]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_37]]{{\[}}%[[VAL_105]], %[[VAL_107]]] = %[[VAL_103]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_109:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_108]], %[[VAL_111:[0-9a-zA-Z_\.]+]] = %[[VAL_72]]) : (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_110]], %[[VAL_112]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_113]]) %[[VAL_110]], %[[VAL_111]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_114:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_115:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>):
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_114]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_118]], %[[VAL_120]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_114]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_124]], %[[VAL_126]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]#0{{\[}}%[[VAL_129]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_131]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]#0{{\[}}%[[VAL_132]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = function.call @add_1::@add_1(%[[VAL_121]], %[[VAL_127]], %[[VAL_130]], %[[VAL_133]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_135]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_134]]{{\[}}%[[VAL_136]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_139]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_37]]{{\[}}%[[VAL_138]], %[[VAL_140]]] = %[[VAL_137]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_134]]{{\[}}%[[VAL_142]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_37]]{{\[}}%[[VAL_144]], %[[VAL_146]]] = %[[VAL_143]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_114]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_148]], %[[VAL_134]] : !felt.type<"bn128">, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_37]] : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main_0 {
// CHECK-NEXT:      struct.def @Main_0 {
// CHECK-NEXT:        struct.member @out : !array.type<16,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main_0::@Main_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_0::@Main_0<[]>>
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_151]]{{\[}}%[[VAL_154]]] = %[[VAL_152]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_151]]{{\[}}%[[VAL_157]]] = %[[VAL_155]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_151]]{{\[}}%[[VAL_160]]] = %[[VAL_158]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_151]]{{\[}}%[[VAL_163]]] = %[[VAL_161]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_167]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_165]]{{\[}}%[[VAL_168]]] = %[[VAL_166]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_165]]{{\[}}%[[VAL_171]]] = %[[VAL_169]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_173]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_174]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_175]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_177]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_178]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_179]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_180]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_181]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_182]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_183]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_185]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_186]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_187]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_189]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_191]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_192]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_193]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  11 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_195]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_197]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  13 : <"bn128">
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_198]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_199]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  14 : <"bn128">
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_200]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_201]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_164]]{{\[}}%[[VAL_203]]] = %[[VAL_165]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = function.call @mul_0::@mul_0(%[[VAL_151]], %[[VAL_204]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_208:[0-9a-zA-Z_\.]+]] = %[[VAL_206]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_208]], %[[VAL_209]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_210]]) %[[VAL_208]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_211:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_213]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_205]]{{\[}}%[[VAL_212]], %[[VAL_214]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_150]]{{\[}}%[[VAL_216]], %[[VAL_218]]] = %[[VAL_215]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_205]]{{\[}}%[[VAL_219]], %[[VAL_221]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_224]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_150]]{{\[}}%[[VAL_223]], %[[VAL_225]]] = %[[VAL_222]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_211]], %[[VAL_226]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_227]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_149]][@out] = %[[VAL_150]] : <@Main_0::@Main_0<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_149]] : !struct.type<@Main_0::@Main_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_228:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_0::@Main_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_228]][@out] : <@Main_0::@Main_0<[]>>, !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_230]]{{\[}}%[[VAL_233]]] = %[[VAL_231]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_230]]{{\[}}%[[VAL_236]]] = %[[VAL_234]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  5299619240641551281634865583518297030282874472190772894086521144482721001553 : <"bn128">
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_238]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_230]]{{\[}}%[[VAL_239]]] = %[[VAL_237]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = felt.const  16950150798460657717958625567821834550301663161624707787222815936182638968203 : <"bn128">
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_241]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_230]]{{\[}}%[[VAL_242]]] = %[[VAL_240]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_246]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_244]]{{\[}}%[[VAL_247]]] = %[[VAL_245]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_249]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_244]]{{\[}}%[[VAL_250]]] = %[[VAL_248]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_251]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_252]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_254]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_256]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_257]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_258]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_260]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_261]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_262]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_263]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_264]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_265]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_266]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_267]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_268]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_269]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_270]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_271]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_272]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.const  11 : <"bn128">
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_273]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_274]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_275]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_276]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.const  13 : <"bn128">
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_278]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.const  14 : <"bn128">
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_279]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_280]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_281]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_243]]{{\[}}%[[VAL_282]]] = %[[VAL_244]] : <16,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_284:[0-9a-zA-Z_\.]+]] = function.call @mul_0::@mul_0(%[[VAL_230]], %[[VAL_283]]) : (!array.type<2 x !felt.type<"bn128">>, !felt.type<"bn128">) -> !array.type<16,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_285:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_286:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_287:[0-9a-zA-Z_\.]+]] = %[[VAL_285]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.const  16 : <"bn128">
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_287]], %[[VAL_288]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_289]]) %[[VAL_287]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_290:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_292]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_284]]{{\[}}%[[VAL_291]], %[[VAL_293]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_296]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_295]], %[[VAL_297]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_298]], %[[VAL_294]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_300]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_284]]{{\[}}%[[VAL_299]], %[[VAL_301]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_304]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_306:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_229]]{{\[}}%[[VAL_303]], %[[VAL_305]]] : <16,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_306]], %[[VAL_302]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_307:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_290]], %[[VAL_307]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_308]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
