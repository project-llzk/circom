// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:      poly.param @x
// CHECK-NEXT:      struct.def @CountDown {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@CountDown::@CountDown<[@x]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CountDown::@CountDown<[@x]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_4]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@CountDown::@CountDown<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@CountDown::@CountDown<[@x]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !struct.type<@CountDown::@CountDown<[@x]>>, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_11]][@out] : <@CountDown::@CountDown<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_13]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_16]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_19]]) %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_20]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_12]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @LessThan {
// CHECK-NEXT:      poly.param @m
// CHECK-NEXT:      poly.expr @"m_Add_1@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_25]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_26]], "assertion failed"
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @LessThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @n2b : !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:        struct.member @n2b$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@LessThan::@LessThan<[@m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.new : <@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_30]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_34]], "assertion failed"
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_35]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_37]], @params = %[[VAL_36]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_40]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_42]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_46]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_44]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_32]][@in] = %[[VAL_48]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_49]], %[[VAL_50]] : index
// CHECK-NEXT:          pod.write %[[VAL_38]][@count] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_51]], %[[VAL_52]] : index
// CHECK-NEXT:          scf.if %[[VAL_53]] {
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_55]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:            pod.write %[[VAL_38]][@comp] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_60]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_57]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_29]][@out] = %[[VAL_62]] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_29]][@n2b$inputs] = %[[VAL_32]] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          struct.writem %[[VAL_29]][@n2b] = %[[VAL_63]] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          function.return %[[VAL_29]] : !struct.type<@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@m]>>, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@out] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@n2b] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@n2b$inputs] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_66]], %[[VAL_71]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_72]], "assertion failed"
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_73]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_77]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_79]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_78]], %[[VAL_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_83]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_81]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_86]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_88]]{{\[}}%[[VAL_89]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_87]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_68]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_69]], %[[VAL_92]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_93:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_95]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_102:[0-9a-zA-Z_\.]+]] = %[[VAL_99]], %[[VAL_103:[0-9a-zA-Z_\.]+]] = %[[VAL_100]], %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_98]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_103]], %[[VAL_96]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_105]]) %[[VAL_102]], %[[VAL_103]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_106:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_107:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_108:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_93]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_109]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_97]]{{\[}}%[[VAL_112]]] = %[[VAL_111]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_113]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_114]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_108]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_106]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_107]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_117]], %[[VAL_119]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_94]][@out] = %[[VAL_97]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_94]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_122]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_129:[0-9a-zA-Z_\.]+]] = %[[VAL_126]], %[[VAL_130:[0-9a-zA-Z_\.]+]] = %[[VAL_127]], %[[VAL_131:[0-9a-zA-Z_\.]+]] = %[[VAL_125]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_130]], %[[VAL_123]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_132]]) %[[VAL_129]], %[[VAL_130]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_133:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_134:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_135:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_136]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_138]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_139]], %[[VAL_140]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_137]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_142]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_144]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_145]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_135]], %[[VAL_146]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_133]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_134]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_148]], %[[VAL_150]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_128]]#2, %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
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
// CHECK-NEXT:        function.def @compute(%[[VAL_151:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "idx"}, %[[VAL_152:[0-9a-zA-Z_\.]+]]: !array.type<@y x !felt.type<"bn128">> {function.arg_name = "choices"}) -> !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@y]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_154]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_158]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_159]] }  : <[@m: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_161]], @params = %[[VAL_160]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_163]]{{\[}}%[[VAL_165]]] = %[[VAL_151]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_157]][@in] = %[[VAL_163]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_166]], %[[VAL_167]] : index
// CHECK-NEXT:          pod.write %[[VAL_162]][@count] = %[[VAL_168]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_168]], %[[VAL_169]] : index
// CHECK-NEXT:          scf.if %[[VAL_170]] {
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !pod.type<[@m: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_172]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_162]][@comp] = %[[VAL_173]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_175]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_174]]{{\[}}%[[VAL_176]]] = %[[VAL_155]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_157]][@in] = %[[VAL_174]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_177]], %[[VAL_178]] : index
// CHECK-NEXT:          pod.write %[[VAL_162]][@count] = %[[VAL_179]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_179]], %[[VAL_180]] : index
// CHECK-NEXT:          scf.if %[[VAL_181]] {
// CHECK-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !pod.type<[@m: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_183]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_162]][@comp] = %[[VAL_184]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_185]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_186]] }  : <[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_188]], @params = %[[VAL_187]] }  : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_156]][@in] = %[[VAL_151]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@count] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_190]], %[[VAL_191]] : index
// CHECK-NEXT:          pod.write %[[VAL_189]][@count] = %[[VAL_192]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_192]], %[[VAL_193]] : index
// CHECK-NEXT:          scf.if %[[VAL_194]] {
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@params] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = function.call @CountDown::@CountDown::@compute(%[[VAL_196]]) : (!felt.type<"bn128">) -> !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_189]][@comp] = %[[VAL_197]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_198]][@out] : <@CountDown::@CountDown<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_200]]] : <@y x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_153]][@out] = %[[VAL_201]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_153]][@c$inputs] = %[[VAL_156]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_153]][@c] = %[[VAL_202]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_153]][@lt$inputs] = %[[VAL_157]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_153]][@lt] = %[[VAL_203]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          function.return %[[VAL_153]] : !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_204:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, %[[VAL_205:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "idx"}, %[[VAL_206:[0-9a-zA-Z_\.]+]]: !array.type<@y x !felt.type<"bn128">> {function.arg_name = "choices"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_207]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_204]][@out] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_204]][@c] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@CountDown::@CountDown<[@y]>>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_204]][@c$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_204]][@lt] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_204]][@lt$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_214]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_215]] }  : <[@m: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_219]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_218]]{{\[}}%[[VAL_220]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_221]], %[[VAL_205]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_223]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_222]]{{\[}}%[[VAL_224]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_225]], %[[VAL_208]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_212]][@out] : <@LessThan::@LessThan<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_226]], %[[VAL_227]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_228]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_229]] }  : <[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_232]], %[[VAL_205]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @CountDown::@CountDown::@constrain(%[[VAL_210]], %[[VAL_233]]) : (!struct.type<@CountDown::@CountDown<[@y]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_212]], %[[VAL_234]]) : (!struct.type<@LessThan::@LessThan<[@y]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
