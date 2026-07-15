// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
}

template LessThan(m) {
    assert(m <= 252);
    signal input in[2];
    signal output out;

    component n2b = Num2Bits(m+1);

    n2b.in <== in[0]+ (1<<m) - in[1];

    out <== 1-n2b.out[m];
}

// Pointless loop
template CountDown(x) {
    signal input in;
    signal output out;

    var counter = x + 1;

    while (counter > in) {
        x--;
    }

    in === counter;

    out <-- counter;
}

template UnknownLoopIndex(y) {
    signal input idx;
    signal input choices[y];
    signal output out;

    component lt = LessThan(y);
    lt.in[0] <== idx;
    lt.in[1] <== y;
    lt.out === 1;

    component c = CountDown(y);
    c.in <== idx;

    // This constraint will be unknown (error[T20462])
    // out <== choices[c.out];
    out <-- choices[c.out];
}

component main = UnknownLoopIndex(100);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[100]>>} {
// CHECK-NEXT:    poly.template @CountDown {
// CHECK-NEXT:      poly.param @x : index
// CHECK-NEXT:      struct.def @CountDown {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@CountDown::@CountDown<[@x]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CountDown::@CountDown<[@x]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @x : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_3]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_5]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_5]] : <@CountDown::@CountDown<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@CountDown::@CountDown<[@x]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !struct.type<@CountDown::@CountDown<[@x]>>, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @x : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_14]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_12]][@out] : <@CountDown::@CountDown<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_15]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_18]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_21]]) %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_22]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_13]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @LessThan {
// CHECK-NEXT:      poly.param @m : index
// CHECK-NEXT:      poly.expr @"m_Add_1@633" {
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_27]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_28]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_29]], "assertion failed"
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @LessThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @n2b : !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:        struct.member @n2b$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@LessThan::@LessThan<[@m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.new : <@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_33]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_34]], %[[VAL_37]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_38]], "assertion failed"
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_40]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_42]], @params = %[[VAL_41]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_45]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_47]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_51]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_49]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_36]][@in] = %[[VAL_53]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:          pod.write %[[VAL_43]][@count] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:          scf.if %[[VAL_58]] {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_60]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:            pod.write %[[VAL_43]][@comp] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_65]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_62]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_32]][@out] = %[[VAL_67]] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_32]][@n2b$inputs] = %[[VAL_36]] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          struct.writem %[[VAL_32]][@n2b] = %[[VAL_68]] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          function.return %[[VAL_32]] : !struct.type<@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@m]>>, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_71]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@out] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@n2b] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@n2b$inputs] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_72]], %[[VAL_77]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_78]], "assertion failed"
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_80]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_84]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_86]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_85]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_90]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_88]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_93]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_96]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_94]], %[[VAL_97]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_74]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_75]], %[[VAL_99]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_100:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_102]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_106]], %[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_107]], %[[VAL_111:[0-9a-zA-Z_\.]+]] = %[[VAL_105]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_110]], %[[VAL_103]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_112]]) %[[VAL_109]], %[[VAL_110]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_113:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_114:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_115:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_100]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_116]], %[[VAL_117]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_104]]{{\[}}%[[VAL_119]]] = %[[VAL_118]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_120]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_121]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_115]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_113]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_114]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_124]], %[[VAL_126]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_101]][@out] = %[[VAL_104]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_101]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_127:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_128:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_129]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_127]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_133]], %[[VAL_137:[0-9a-zA-Z_\.]+]] = %[[VAL_134]], %[[VAL_138:[0-9a-zA-Z_\.]+]] = %[[VAL_132]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_137]], %[[VAL_130]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_139]]) %[[VAL_136]], %[[VAL_137]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_140:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_142:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_143]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_145]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_146]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_144]], %[[VAL_148]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_149]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_131]]{{\[}}%[[VAL_151]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_152]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_142]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_140]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_141]], %[[VAL_156]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_155]], %[[VAL_157]], %[[VAL_154]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_135]]#2, %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @UnknownLoopIndex {
// CHECK-NEXT:      poly.param @y : index
// CHECK-NEXT:      struct.def @UnknownLoopIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @c : !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_158:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "idx"}, %[[VAL_159:[0-9a-zA-Z_\.]+]]: !array.type<@y x !felt.type<"bn128">> {function.arg_name = "choices"}) -> !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@y]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_161]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_165]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_167]], @params = %[[VAL_166]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_169]]{{\[}}%[[VAL_171]]] = %[[VAL_158]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_164]][@in] = %[[VAL_169]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_172]], %[[VAL_173]] : index
// CHECK-NEXT:          pod.write %[[VAL_168]][@count] = %[[VAL_174]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_174]], %[[VAL_175]] : index
// CHECK-NEXT:          scf.if %[[VAL_176]] {
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !pod.type<[@m: index]>
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_178]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_168]][@comp] = %[[VAL_179]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_180]]{{\[}}%[[VAL_182]]] = %[[VAL_162]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_164]][@in] = %[[VAL_180]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_183]], %[[VAL_184]] : index
// CHECK-NEXT:          pod.write %[[VAL_168]][@count] = %[[VAL_185]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_185]], %[[VAL_186]] : index
// CHECK-NEXT:          scf.if %[[VAL_187]] {
// CHECK-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !pod.type<[@m: index]>
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_189]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_168]][@comp] = %[[VAL_190]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_191]] }  : <[@x: index]>
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_193]], @params = %[[VAL_192]] }  : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_163]][@in] = %[[VAL_158]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@count] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>, index
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_195]], %[[VAL_196]] : index
// CHECK-NEXT:          pod.write %[[VAL_194]][@count] = %[[VAL_197]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>, index
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_197]], %[[VAL_198]] : index
// CHECK-NEXT:          scf.if %[[VAL_199]] {
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@params] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>, !pod.type<[@x: index]>
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = function.call @CountDown::@CountDown::@compute(%[[VAL_201]]) : (!felt.type<"bn128">) -> !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_194]][@comp] = %[[VAL_202]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_203]][@out] : <@CountDown::@CountDown<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_205]]] : <@y x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_160]][@out] = %[[VAL_206]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_160]][@c$inputs] = %[[VAL_163]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_160]][@c] = %[[VAL_207]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_160]][@lt$inputs] = %[[VAL_164]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_160]][@lt] = %[[VAL_208]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          function.return %[[VAL_160]] : !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_209:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, %[[VAL_210:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "idx"}, %[[VAL_211:[0-9a-zA-Z_\.]+]]: !array.type<@y x !felt.type<"bn128">> {function.arg_name = "choices"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_212]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_209]][@out] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_209]][@c] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_209]][@c$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_209]][@lt] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_209]][@lt$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_219]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_223]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_224]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_225]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_226]]{{\[}}%[[VAL_228]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_229]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_217]][@out] : <@LessThan::@LessThan<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_230]], %[[VAL_231]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_232]] }  : <[@x: index]>
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: index]>]>
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_235]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @CountDown::@CountDown::@constrain(%[[VAL_215]], %[[VAL_236]]) : (!struct.type<@CountDown::@CountDown<[@y]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_217]], %[[VAL_237]]) : (!struct.type<@LessThan::@LessThan<[@y]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
