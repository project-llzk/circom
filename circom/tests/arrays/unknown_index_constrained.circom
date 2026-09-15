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

template GreaterEqThan(x) {
    signal input in[2];
    signal output out;

    component lt = LessThan(x);

    lt.in[0] <== in[1];
    lt.in[1] <== in[0]+1;
    lt.out ==> out;
}

template ForUnknownIndex(y) {
    signal input in;
    signal output out;

    var arr2[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    component get = GreaterEqThan(y);
    get.in[0] <== in;
    get.in[1] <== 0;
    get.out === 1;

    component lt = LessThan(y);
    lt.in[0] <== in;
    lt.in[1] <== 10;
    lt.out === 1;

    // non-quadractic constraint
    // out <== arr[acc];
    out <-- arr2[in];
}

component main = ForUnknownIndex(252);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ForUnknownIndex::@ForUnknownIndex<[252]>>} {
// CHECK-NEXT:    poly.template @ForUnknownIndex {
// CHECK-NEXT:      poly.param @y
// CHECK-NEXT:      struct.def @ForUnknownIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @get : !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:        struct.member @get$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@y]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @y : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @y : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_8]] }  : <[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_10]], @params = %[[VAL_9]] }  : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_14]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_12]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:          pod.write %[[VAL_11]][@count] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_17]], %[[VAL_18]] : index
// CHECK-NEXT:          scf.if %[[VAL_19]] {
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@params] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_21]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_11]][@comp] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_24]]{{\[}}%[[VAL_26]]] = %[[VAL_23]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_24]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:          pod.write %[[VAL_11]][@count] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_29]], %[[VAL_30]] : index
// CHECK-NEXT:          scf.if %[[VAL_31]] {
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@params] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !pod.type<[@x: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_33]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_11]][@comp] = %[[VAL_34]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @y : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_35]] }  : <[@m: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_37]], @params = %[[VAL_36]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_39]]{{\[}}%[[VAL_41]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_39]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:          pod.write %[[VAL_38]][@count] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:          scf.if %[[VAL_46]] {
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !pod.type<[@m: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_48]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_38]][@comp] = %[[VAL_49]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_51]]{{\[}}%[[VAL_53]]] = %[[VAL_50]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_51]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:          pod.write %[[VAL_38]][@count] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:          scf.if %[[VAL_58]] {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !pod.type<[@m: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_60]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_38]][@comp] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_62]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_63]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get$inputs] = %[[VAL_3]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@comp] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get] = %[[VAL_64]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt$inputs] = %[[VAL_4]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt] = %[[VAL_65]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@y]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@y]>>, %[[VAL_67:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = poly.read_const @y : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@out] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@get] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@get$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@lt] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@lt$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_74]], %[[VAL_74]], %[[VAL_74]], %[[VAL_74]], %[[VAL_74]], %[[VAL_74]], %[[VAL_74]], %[[VAL_74]], %[[VAL_74]], %[[VAL_74]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = poly.read_const @y : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_77]] }  : <[@x: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_82]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_85]]{{\[}}%[[VAL_87]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_88]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_70]][@out] : <@GreaterEqThan::@GreaterEqThan<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_89]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @y : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_91]] }  : <[@m: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_96]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_97]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_101]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_102]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@out] : <@LessThan::@LessThan<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @GreaterEqThan::@GreaterEqThan::@constrain(%[[VAL_70]], %[[VAL_105]]) : (!struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_72]], %[[VAL_106]]) : (!struct.type<@LessThan::@LessThan<[@y]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">,  8 : <"bn128">,  9 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @GreaterEqThan {
// CHECK-NEXT:      poly.param @x
// CHECK-NEXT:      struct.def @GreaterEqThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_107:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@x]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.new : <@GreaterEqThan::@GreaterEqThan<[@x]>>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_111]] }  : <[@m: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_113]], @params = %[[VAL_112]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_107]]{{\[}}%[[VAL_116]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_118]]{{\[}}%[[VAL_120]]] = %[[VAL_117]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_110]][@in] = %[[VAL_118]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_121]], %[[VAL_122]] : index
// CHECK-NEXT:          pod.write %[[VAL_114]][@count] = %[[VAL_123]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_123]], %[[VAL_124]] : index
// CHECK-NEXT:          scf.if %[[VAL_125]] {
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !pod.type<[@m: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_127]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:            pod.write %[[VAL_114]][@comp] = %[[VAL_128]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_107]]{{\[}}%[[VAL_130]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_131]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_135]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_134]]{{\[}}%[[VAL_136]]] = %[[VAL_133]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_110]][@in] = %[[VAL_134]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_137]], %[[VAL_138]] : index
// CHECK-NEXT:          pod.write %[[VAL_114]][@count] = %[[VAL_139]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_139]], %[[VAL_140]] : index
// CHECK-NEXT:          scf.if %[[VAL_141]] {
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !pod.type<[@m: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_143]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:            pod.write %[[VAL_114]][@comp] = %[[VAL_144]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_145]][@out] : <@LessThan::@LessThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_108]][@out] = %[[VAL_146]] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_108]][@lt$inputs] = %[[VAL_110]] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          struct.writem %[[VAL_108]][@lt] = %[[VAL_147]] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          function.return %[[VAL_108]] : !struct.type<@GreaterEqThan::@GreaterEqThan<[@x]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_148:[0-9a-zA-Z_\.]+]]: !struct.type<@GreaterEqThan::@GreaterEqThan<[@x]>>, %[[VAL_149:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_148]][@out] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_148]][@lt] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_148]][@lt$inputs] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = poly.read_const @x : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_154]] }  : <[@m: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_149]]{{\[}}%[[VAL_158]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_160]]{{\[}}%[[VAL_162]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_163]], %[[VAL_159]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_149]]{{\[}}%[[VAL_165]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_166]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_171]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_172]], %[[VAL_168]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_152]][@out] : <@LessThan::@LessThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_151]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_152]], %[[VAL_174]]) : (!struct.type<@LessThan::@LessThan<[@x]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @LessThan {
// CHECK-NEXT:      poly.param @m
// CHECK-NEXT:      poly.expr @"m_Add_1@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_177:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_178:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_177]], %[[VAL_175]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_178]], "assertion failed"
// CHECK-NEXT:        %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_177]], %[[VAL_176]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_179]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @LessThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @n2b : !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:        struct.member @n2b$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_180:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@LessThan::@LessThan<[@m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = struct.new : <@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_182]], %[[VAL_185]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_186]], "assertion failed"
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_187]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_189]], @params = %[[VAL_188]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_191]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_180]]{{\[}}%[[VAL_192]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_194]], %[[VAL_182]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_195]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_197]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_180]]{{\[}}%[[VAL_198]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_196]], %[[VAL_199]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_184]][@in] = %[[VAL_200]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_201]], %[[VAL_202]] : index
// CHECK-NEXT:          pod.write %[[VAL_190]][@count] = %[[VAL_203]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_203]], %[[VAL_204]] : index
// CHECK-NEXT:          scf.if %[[VAL_205]] {
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_207]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:            pod.write %[[VAL_190]][@comp] = %[[VAL_208]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_210]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_182]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_211]]{{\[}}%[[VAL_212]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_209]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_181]][@out] = %[[VAL_214]] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_181]][@n2b$inputs] = %[[VAL_184]] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          struct.writem %[[VAL_181]][@n2b] = %[[VAL_215]] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          function.return %[[VAL_181]] : !struct.type<@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_216:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@m]>>, %[[VAL_217:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_216]][@out] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_216]][@n2b] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_216]][@n2b$inputs] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_218]], %[[VAL_223]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_224]], "assertion failed"
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@[[OFFSET0]]" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_225]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_228]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_217]]{{\[}}%[[VAL_229]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_231]], %[[VAL_218]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_230]], %[[VAL_232]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_217]]{{\[}}%[[VAL_235]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_233]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_222]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_238]], %[[VAL_237]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_221]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_240]]{{\[}}%[[VAL_241]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_239]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_220]], %[[VAL_243]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_222]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_221]], %[[VAL_244]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@[[OFFSET0]]"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_245:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_247]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_254:[0-9a-zA-Z_\.]+]] = %[[VAL_251]], %[[VAL_255:[0-9a-zA-Z_\.]+]] = %[[VAL_252]], %[[VAL_256:[0-9a-zA-Z_\.]+]] = %[[VAL_250]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_255]], %[[VAL_248]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_257]]) %[[VAL_254]], %[[VAL_255]], %[[VAL_256]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_258:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_259:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_260:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_245]], %[[VAL_259]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_261]], %[[VAL_262]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_264:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_249]]{{\[}}%[[VAL_264]]] = %[[VAL_263]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_259]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_266:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_265]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_266]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_260]], %[[VAL_267]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_258]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_271:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_259]], %[[VAL_270]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_269]], %[[VAL_271]], %[[VAL_268]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_246]][@out] = %[[VAL_249]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_246]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_272:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_273:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_274]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_272]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_281:[0-9a-zA-Z_\.]+]] = %[[VAL_278]], %[[VAL_282:[0-9a-zA-Z_\.]+]] = %[[VAL_279]], %[[VAL_283:[0-9a-zA-Z_\.]+]] = %[[VAL_277]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_282]], %[[VAL_275]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_284]]) %[[VAL_281]], %[[VAL_282]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_285:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_286:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_287:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_276]]{{\[}}%[[VAL_288]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_276]]{{\[}}%[[VAL_290]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_291]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_289]], %[[VAL_293]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_294]], %[[VAL_295]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_276]]{{\[}}%[[VAL_296]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_297]], %[[VAL_285]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_287]], %[[VAL_298]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_285]], %[[VAL_285]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_286]], %[[VAL_301]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_300]], %[[VAL_302]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_280]]#2, %[[VAL_273]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
