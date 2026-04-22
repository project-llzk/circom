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

template LessThan(n) {
    assert(n <= 252);
    signal input in[2];
    signal output out;

    component n2b = Num2Bits(n+1);

    n2b.in <== in[0]+ (1<<n) - in[1];

    out <== 1-n2b.out[n];
}

// Pointless loop
template CountDown(n) {
    signal input in;
    signal output out;

    var counter = n + 1;

    while (counter > in) {
        n--;
    }

    in === counter;

    out <-- counter;
}

template UnknownLoopIndex(n) {
    signal input idx;
    signal input choices[n];
    signal output out;

    component lt = LessThan(n);
    lt.in[0] <== idx;
    lt.in[1] <== n;
    lt.out === 1;

    component c = CountDown(n);
    c.in <== idx;

    // This constraint will be unknown (error[T20462])
    // out <== choices[c.out];
    out <-- choices[c.out];
}

component main = UnknownLoopIndex(100);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[100]>>} {
// CHECK-NEXT:    poly.template @CountDown {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @CountDown {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@CountDown::@CountDown<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
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
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@CountDown::@CountDown<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !struct.type<@CountDown::@CountDown<[@n]>>, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_11]][@out] : <@CountDown::@CountDown<[@n]>>, !felt.type<"bn128">
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
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.expr @"n_Add_1@633" {
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_23]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_25]], "assertion failed"
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @LessThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @n2b : !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:        struct.member @n2b$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.new : <@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_32]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_30]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_36]], "assertion failed"
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_38]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_40]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_44]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_42]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_34]][@in] = %[[VAL_46]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_47]], %[[VAL_48]] : index
// CHECK-NEXT:          pod.write %[[VAL_33]][@count] = %[[VAL_49]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_49]], %[[VAL_50]] : index
// CHECK-NEXT:          scf.if %[[VAL_51]] {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_52]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:            pod.write %[[VAL_33]][@comp] = %[[VAL_53]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_55]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_57]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_54]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_29]][@out] = %[[VAL_59]] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_29]][@n2b$inputs] = %[[VAL_34]] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          struct.writem %[[VAL_29]][@n2b] = %[[VAL_60]] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          function.return %[[VAL_29]] : !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@n]>>, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@n2b] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@n2b$inputs] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_63]], %[[VAL_68]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_69]], "assertion failed"
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_71]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_73]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_77]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_75]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_80]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_83]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_81]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_67]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_66]], %[[VAL_86]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_95:[0-9a-zA-Z_\.]+]] = %[[VAL_92]], %[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_93]], %[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_91]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_96]], %[[VAL_89]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_98]]) %[[VAL_95]], %[[VAL_96]], %[[VAL_97]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_99:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_100:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_101:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_87]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_102]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_90]]{{\[}}%[[VAL_105]]] = %[[VAL_104]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_106]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_107]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_101]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_99]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_100]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_110]], %[[VAL_112]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_88]][@out] = %[[VAL_90]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_88]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_113:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_114:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_113]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_118]], %[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_119]], %[[VAL_123:[0-9a-zA-Z_\.]+]] = %[[VAL_117]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_122]], %[[VAL_115]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_124]]) %[[VAL_121]], %[[VAL_122]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_125:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_126:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_127:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_128]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_130]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_131]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_129]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_134]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_136]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_137]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_127]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_125]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_126]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_140]], %[[VAL_142]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_120]]#2, %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @UnknownLoopIndex {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @UnknownLoopIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @c : !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_143:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_144:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_147]] }  : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_150]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_153]]{{\[}}%[[VAL_155]]] = %[[VAL_143]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_152]][@in] = %[[VAL_153]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_156]], %[[VAL_157]] : index
// CHECK-NEXT:          pod.write %[[VAL_151]][@count] = %[[VAL_158]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_158]], %[[VAL_159]] : index
// CHECK-NEXT:          scf.if %[[VAL_160]] {
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_161]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_151]][@comp] = %[[VAL_162]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_163]]{{\[}}%[[VAL_165]]] = %[[VAL_146]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_152]][@in] = %[[VAL_163]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_166]], %[[VAL_167]] : index
// CHECK-NEXT:          pod.write %[[VAL_151]][@count] = %[[VAL_168]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_168]], %[[VAL_169]] : index
// CHECK-NEXT:          scf.if %[[VAL_170]] {
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_171]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_151]][@comp] = %[[VAL_172]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_149]][@in] = %[[VAL_143]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@count] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_173]], %[[VAL_174]] : index
// CHECK-NEXT:          pod.write %[[VAL_148]][@count] = %[[VAL_175]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_175]], %[[VAL_176]] : index
// CHECK-NEXT:          scf.if %[[VAL_177]] {
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = function.call @CountDown::@CountDown::@compute(%[[VAL_178]]) : (!felt.type<"bn128">) -> !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_148]][@comp] = %[[VAL_179]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_180]][@out] : <@CountDown::@CountDown<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_144]]{{\[}}%[[VAL_182]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_145]][@out] = %[[VAL_183]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_145]][@c$inputs] = %[[VAL_149]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_145]][@c] = %[[VAL_184]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_145]][@lt$inputs] = %[[VAL_152]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_145]][@lt] = %[[VAL_185]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_145]] : !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_186:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, %[[VAL_187:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_188:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_186]][@out] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_186]][@c] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_186]][@c$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_186]][@lt] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_186]][@lt$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_195]]{{\[}}%[[VAL_197]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_198]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_200]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_199]]{{\[}}%[[VAL_201]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_202]], %[[VAL_189]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_193]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_203]], %[[VAL_204]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_205]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @CountDown::@CountDown::@constrain(%[[VAL_191]], %[[VAL_206]]) : (!struct.type<@CountDown::@CountDown<[@n]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_193]], %[[VAL_207]]) : (!struct.type<@LessThan::@LessThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
