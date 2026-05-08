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
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_25]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_26]], "assertion failed"
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
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
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_30]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_34]], "assertion failed"
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633_0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_35]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_37]], @params = %[[VAL_36]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_38]] : (!pod.type<[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_41]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_43]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_47]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_45]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_32]][@in] = %[[VAL_49]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_50]], %[[VAL_51]] : index
// CHECK-NEXT:          pod.write %[[VAL_39]][@count] = %[[VAL_52]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_53]] : index
// CHECK-NEXT:          scf.if %[[VAL_54]] {
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_56]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:            pod.write %[[VAL_39]][@comp] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_60]]{{\[}}%[[VAL_61]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_58]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_29]][@out] = %[[VAL_63]] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_29]][@n2b$inputs] = %[[VAL_32]] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          struct.writem %[[VAL_29]][@n2b] = %[[VAL_64]] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          function.return %[[VAL_29]] : !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_65:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@n]>>, %[[VAL_66:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_65]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_65]][@n2b] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_65]][@n2b$inputs] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_67]], %[[VAL_72]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_73]], "assertion failed"
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633_0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_74]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_78]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_80]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_79]], %[[VAL_81]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_84]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_82]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_87]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_70]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_90]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_88]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_69]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_70]], %[[VAL_93]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"n_Add_1@633_0" {
// CHECK-NEXT:        %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_96:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_97:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_96]], %[[VAL_94]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_97]], "assertion failed"
// CHECK-NEXT:        %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_96]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_98]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_99:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_107:[0-9a-zA-Z_\.]+]] = %[[VAL_104]], %[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_105]], %[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_103]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_108]], %[[VAL_101]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_110]]) %[[VAL_107]], %[[VAL_108]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_112:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_113:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_99]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_114]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_102]]{{\[}}%[[VAL_117]]] = %[[VAL_116]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_118]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_119]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_113]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_111]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_112]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_122]], %[[VAL_124]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_100]][@out] = %[[VAL_102]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_100]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_125:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_126:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_125]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_130]], %[[VAL_134:[0-9a-zA-Z_\.]+]] = %[[VAL_131]], %[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_129]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_134]], %[[VAL_127]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_136]]) %[[VAL_133]], %[[VAL_134]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_137:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_139:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_140]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_142]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_143]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_141]], %[[VAL_145]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_146]], %[[VAL_147]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_148]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_149]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_139]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_137]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_138]], %[[VAL_153]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_152]], %[[VAL_154]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_132]]#2, %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
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
// CHECK-NEXT:        function.def @compute(%[[VAL_155:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_156:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_161]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_163]], @params = %[[VAL_162]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_166]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_165]]{{\[}}%[[VAL_167]]] = %[[VAL_155]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_160]][@in] = %[[VAL_165]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_168]], %[[VAL_169]] : index
// CHECK-NEXT:          pod.write %[[VAL_164]][@count] = %[[VAL_170]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_171]] : index
// CHECK-NEXT:          scf.if %[[VAL_172]] {
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_174]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_164]][@comp] = %[[VAL_175]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_176]]{{\[}}%[[VAL_178]]] = %[[VAL_158]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_160]][@in] = %[[VAL_176]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_179]], %[[VAL_180]] : index
// CHECK-NEXT:          pod.write %[[VAL_164]][@count] = %[[VAL_181]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_181]], %[[VAL_182]] : index
// CHECK-NEXT:          scf.if %[[VAL_183]] {
// CHECK-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_185]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_164]][@comp] = %[[VAL_186]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_187]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_189]], @params = %[[VAL_188]] }  : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_159]][@in] = %[[VAL_155]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@count] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_191]], %[[VAL_192]] : index
// CHECK-NEXT:          pod.write %[[VAL_190]][@count] = %[[VAL_193]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_193]], %[[VAL_194]] : index
// CHECK-NEXT:          scf.if %[[VAL_195]] {
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@params] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_159]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = function.call @CountDown::@CountDown::@compute(%[[VAL_197]]) : (!felt.type<"bn128">) -> !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_190]][@comp] = %[[VAL_198]] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_199]][@out] : <@CountDown::@CountDown<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_200]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_156]]{{\[}}%[[VAL_201]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_157]][@out] = %[[VAL_202]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_157]][@c$inputs] = %[[VAL_159]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@comp] : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_157]][@c] = %[[VAL_203]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_157]][@lt$inputs] = %[[VAL_160]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_164]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_157]][@lt] = %[[VAL_204]] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_157]] : !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_205:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, %[[VAL_206:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_207:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@out] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@c] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@CountDown::@CountDown<[@n]>>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@c$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@lt] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@lt$inputs] : <@UnknownLoopIndex::@UnknownLoopIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_214]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_217]]{{\[}}%[[VAL_219]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_220]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_222]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_221]]{{\[}}%[[VAL_223]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_224]], %[[VAL_208]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_212]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_225]], %[[VAL_226]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_227]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CountDown::@CountDown<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_230]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @CountDown::@CountDown::@constrain(%[[VAL_210]], %[[VAL_231]]) : (!struct.type<@CountDown::@CountDown<[@n]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_212]], %[[VAL_232]]) : (!struct.type<@LessThan::@LessThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
