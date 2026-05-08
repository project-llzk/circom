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

template GreaterEqThan(n) {
    signal input in[2];
    signal output out;

    component lt = LessThan(n);

    lt.in[0] <== in[1];
    lt.in[1] <== in[0]+1;
    lt.out ==> out;
}

template ForUnknownIndex(n) {
    signal input in;
    signal output out;

    var arr2[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    component get = GreaterEqThan(n);
    get.in[0] <== in;
    get.in[1] <== 0;
    get.out === 1;

    component lt = LessThan(n);
    lt.in[0] <== in;
    lt.in[1] <== 10;
    lt.out === 1;

    // non-quadractic constraint
    // out <== arr[acc];
    out <-- arr2[in];
}

component main = ForUnknownIndex(252);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ForUnknownIndex::@ForUnknownIndex<[252]>>} {
// CHECK-NEXT:    poly.template @ForUnknownIndex {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @ForUnknownIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @get : !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:        struct.member @get$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]], %[[VAL_5]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]], %[[VAL_12]], %[[VAL_13]], %[[VAL_14]], %[[VAL_15]], %[[VAL_16]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_18]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]], @params = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_22]]{{\[}}%[[VAL_24]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_22]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// CHECK-NEXT:          pod.write %[[VAL_21]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:          scf.if %[[VAL_29]] {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@params] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_31]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_21]][@comp] = %[[VAL_32]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_34]]{{\[}}%[[VAL_36]]] = %[[VAL_33]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_3]][@in] = %[[VAL_34]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:          pod.write %[[VAL_21]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:          scf.if %[[VAL_41]] {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@params] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_43]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_21]][@comp] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_45]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_47]], @params = %[[VAL_46]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_49]]{{\[}}%[[VAL_51]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_49]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_52]], %[[VAL_53]] : index
// CHECK-NEXT:          pod.write %[[VAL_48]][@count] = %[[VAL_54]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:          scf.if %[[VAL_56]] {
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_58]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_48]][@comp] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_61]]{{\[}}%[[VAL_63]]] = %[[VAL_60]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_61]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_64]], %[[VAL_65]] : index
// CHECK-NEXT:          pod.write %[[VAL_48]][@count] = %[[VAL_66]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_66]], %[[VAL_67]] : index
// CHECK-NEXT:          scf.if %[[VAL_68]] {
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_70]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_48]][@comp] = %[[VAL_71]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_72]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_73]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get$inputs] = %[[VAL_3]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@comp] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get] = %[[VAL_74]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt$inputs] = %[[VAL_4]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt] = %[[VAL_75]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@n]>>, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@out] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@get] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@get$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@lt] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@lt$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]], %[[VAL_84]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_86]], %[[VAL_87]], %[[VAL_88]], %[[VAL_89]], %[[VAL_90]], %[[VAL_91]], %[[VAL_92]], %[[VAL_93]], %[[VAL_94]], %[[VAL_95]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_97]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_100]]{{\[}}%[[VAL_102]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_107]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_108]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@out] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_109]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_111]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_114]]{{\[}}%[[VAL_116]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_117]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_121]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_122]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_82]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_123]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_81]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @GreaterEqThan::@GreaterEqThan::@constrain(%[[VAL_80]], %[[VAL_125]]) : (!struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_82]], %[[VAL_126]]) : (!struct.type<@LessThan::@LessThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @GreaterEqThan {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @GreaterEqThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_127:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = struct.new : <@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_131]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_133]], @params = %[[VAL_132]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_135]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_136]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_139]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_138]]{{\[}}%[[VAL_140]]] = %[[VAL_137]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_130]][@in] = %[[VAL_138]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_141]], %[[VAL_142]] : index
// CHECK-NEXT:          pod.write %[[VAL_134]][@count] = %[[VAL_143]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_143]], %[[VAL_144]] : index
// CHECK-NEXT:          scf.if %[[VAL_145]] {
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_147]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_134]][@comp] = %[[VAL_148]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_150]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_151]], %[[VAL_152]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_154]]{{\[}}%[[VAL_156]]] = %[[VAL_153]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_130]][@in] = %[[VAL_154]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_157]], %[[VAL_158]] : index
// CHECK-NEXT:          pod.write %[[VAL_134]][@count] = %[[VAL_159]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_159]], %[[VAL_160]] : index
// CHECK-NEXT:          scf.if %[[VAL_161]] {
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_163]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_134]][@comp] = %[[VAL_164]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_165]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_128]][@out] = %[[VAL_166]] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_128]][@lt$inputs] = %[[VAL_130]] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_128]][@lt] = %[[VAL_167]] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_128]] : !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_168:[0-9a-zA-Z_\.]+]]: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, %[[VAL_169:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@out] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@lt] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@lt$inputs] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_174]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_178]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_180]]{{\[}}%[[VAL_182]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_183]], %[[VAL_179]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_169]]{{\[}}%[[VAL_185]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_186]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_189]]{{\[}}%[[VAL_191]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_192]], %[[VAL_188]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_172]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_171]], %[[VAL_193]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_172]], %[[VAL_194]]) : (!struct.type<@LessThan::@LessThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @LessThan {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.expr @"n_Add_1@633" {
// CHECK-NEXT:        %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_197:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_198:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_197]], %[[VAL_195]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_198]], "assertion failed"
// CHECK-NEXT:        %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_197]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @LessThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @n2b : !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:        struct.member @n2b$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_200:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = struct.new : <@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_202]], %[[VAL_205]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_206]], "assertion failed"
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633_0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_207]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_209]], @params = %[[VAL_208]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_210]] : (!pod.type<[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_200]]{{\[}}%[[VAL_213]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_215]], %[[VAL_202]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_214]], %[[VAL_216]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_200]]{{\[}}%[[VAL_219]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_217]], %[[VAL_220]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_204]][@in] = %[[VAL_221]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_222]], %[[VAL_223]] : index
// CHECK-NEXT:          pod.write %[[VAL_211]][@count] = %[[VAL_224]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_224]], %[[VAL_225]] : index
// CHECK-NEXT:          scf.if %[[VAL_226]] {
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_228]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:            pod.write %[[VAL_211]][@comp] = %[[VAL_229]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_231]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_232]]{{\[}}%[[VAL_233]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_230]], %[[VAL_234]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_201]][@out] = %[[VAL_235]] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_201]][@n2b$inputs] = %[[VAL_204]] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_211]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          struct.writem %[[VAL_201]][@n2b] = %[[VAL_236]] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          function.return %[[VAL_201]] : !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_237:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@n]>>, %[[VAL_238:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@n2b] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@n2b$inputs] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_239]], %[[VAL_244]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_245]], "assertion failed"
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633_0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_246]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633_0"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_249]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_238]]{{\[}}%[[VAL_250]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_252]], %[[VAL_239]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_251]], %[[VAL_253]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_238]]{{\[}}%[[VAL_256]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_254]], %[[VAL_257]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_259]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_242]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_239]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_262]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_260]], %[[VAL_263]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_241]], %[[VAL_264]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_242]], %[[VAL_265]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"n_Add_1@633_0" {
// CHECK-NEXT:        %[[VAL_266:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_267:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_268:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_269:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_268]], %[[VAL_266]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_269]], "assertion failed"
// CHECK-NEXT:        %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_268]], %[[VAL_267]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_270]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_271:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_279:[0-9a-zA-Z_\.]+]] = %[[VAL_276]], %[[VAL_280:[0-9a-zA-Z_\.]+]] = %[[VAL_277]], %[[VAL_281:[0-9a-zA-Z_\.]+]] = %[[VAL_275]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_280]], %[[VAL_273]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_282]]) %[[VAL_279]], %[[VAL_280]], %[[VAL_281]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_283:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_284:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_285:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_271]], %[[VAL_284]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_286]], %[[VAL_287]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_284]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_274]]{{\[}}%[[VAL_289]]] = %[[VAL_288]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_284]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_274]]{{\[}}%[[VAL_290]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_291]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_285]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_283]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_284]], %[[VAL_295]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_294]], %[[VAL_296]], %[[VAL_293]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_272]][@out] = %[[VAL_274]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_272]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_297:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_298:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_299:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_300:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_297]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_301:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_303:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_304:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_305:[0-9a-zA-Z_\.]+]] = %[[VAL_302]], %[[VAL_306:[0-9a-zA-Z_\.]+]] = %[[VAL_303]], %[[VAL_307:[0-9a-zA-Z_\.]+]] = %[[VAL_301]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_306]], %[[VAL_299]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_308]]) %[[VAL_305]], %[[VAL_306]], %[[VAL_307]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_309:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_310:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_311:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_300]]{{\[}}%[[VAL_312]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_300]]{{\[}}%[[VAL_314]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_315]], %[[VAL_316]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_313]], %[[VAL_317]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_318]], %[[VAL_319]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_321:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_300]]{{\[}}%[[VAL_320]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_321]], %[[VAL_309]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_311]], %[[VAL_322]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_309]], %[[VAL_309]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_310]], %[[VAL_325]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_324]], %[[VAL_326]], %[[VAL_323]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_304]]#2, %[[VAL_298]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
