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
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]], %[[VAL_9]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_11]], %[[VAL_12]], %[[VAL_13]], %[[VAL_14]], %[[VAL_15]], %[[VAL_16]], %[[VAL_17]], %[[VAL_18]], %[[VAL_19]], %[[VAL_20]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_22]]{{\[}}%[[VAL_24]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_5]][@in] = %[[VAL_22]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:          scf.if %[[VAL_29]] {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_30]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_31]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_33]]{{\[}}%[[VAL_35]]] = %[[VAL_32]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_5]][@in] = %[[VAL_33]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_36]], %[[VAL_37]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_38]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_38]], %[[VAL_39]] : index
// CHECK-NEXT:          scf.if %[[VAL_40]] {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_41]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_42]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_43]]{{\[}}%[[VAL_45]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_8]][@in] = %[[VAL_43]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:          pod.write %[[VAL_7]][@count] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:          scf.if %[[VAL_50]] {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_51]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_7]][@comp] = %[[VAL_52]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_54]]{{\[}}%[[VAL_56]]] = %[[VAL_53]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_8]][@in] = %[[VAL_54]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_57]], %[[VAL_58]] : index
// CHECK-NEXT:          pod.write %[[VAL_7]][@count] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_59]], %[[VAL_60]] : index
// CHECK-NEXT:          scf.if %[[VAL_61]] {
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_62]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_7]][@comp] = %[[VAL_63]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_64]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_65]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get$inputs] = %[[VAL_5]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get] = %[[VAL_66]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt$inputs] = %[[VAL_8]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt] = %[[VAL_67]] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@n]>>, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@out] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@get] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@get$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@lt] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@lt$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_76]], %[[VAL_76]], %[[VAL_76]], %[[VAL_76]], %[[VAL_76]], %[[VAL_76]], %[[VAL_76]], %[[VAL_76]], %[[VAL_76]], %[[VAL_76]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_78]], %[[VAL_79]], %[[VAL_80]], %[[VAL_81]], %[[VAL_82]], %[[VAL_83]], %[[VAL_84]], %[[VAL_85]], %[[VAL_86]], %[[VAL_87]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_91]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_92]], %[[VAL_69]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_96]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_97]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@out] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_98]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_100]]{{\[}}%[[VAL_102]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_69]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_107]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_108]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_109]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @GreaterEqThan::@GreaterEqThan::@constrain(%[[VAL_72]], %[[VAL_111]]) : (!struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_74]], %[[VAL_112]]) : (!struct.type<@LessThan::@LessThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
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
// CHECK-NEXT:        function.def @compute(%[[VAL_113:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = struct.new : <@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_116]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_113]]{{\[}}%[[VAL_120]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_122]]{{\[}}%[[VAL_124]]] = %[[VAL_121]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_118]][@in] = %[[VAL_122]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_125]], %[[VAL_126]] : index
// CHECK-NEXT:          pod.write %[[VAL_117]][@count] = %[[VAL_127]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_127]], %[[VAL_128]] : index
// CHECK-NEXT:          scf.if %[[VAL_129]] {
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_130]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_117]][@comp] = %[[VAL_131]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_113]]{{\[}}%[[VAL_133]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_134]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_137]]{{\[}}%[[VAL_139]]] = %[[VAL_136]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_118]][@in] = %[[VAL_137]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_140]], %[[VAL_141]] : index
// CHECK-NEXT:          pod.write %[[VAL_117]][@count] = %[[VAL_142]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_142]], %[[VAL_143]] : index
// CHECK-NEXT:          scf.if %[[VAL_144]] {
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_145]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:            pod.write %[[VAL_117]][@comp] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_147]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_114]][@out] = %[[VAL_148]] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_114]][@lt$inputs] = %[[VAL_118]] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@n]>>, @params: !pod.type<[]>]>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_114]][@lt] = %[[VAL_149]] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          function.return %[[VAL_114]] : !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_150:[0-9a-zA-Z_\.]+]]: !struct.type<@GreaterEqThan::@GreaterEqThan<[@n]>>, %[[VAL_151:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_150]][@out] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_150]][@lt] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_150]][@lt$inputs] : <@GreaterEqThan::@GreaterEqThan<[@n]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_157]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_161]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_162]], %[[VAL_158]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_164]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_165]], %[[VAL_166]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_168]]{{\[}}%[[VAL_170]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_171]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_154]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_153]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_154]], %[[VAL_173]]) : (!struct.type<@LessThan::@LessThan<[@n]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @LessThan {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.expr @"n_Add_1@633" {
// CHECK-NEXT:        %[[VAL_174:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_176:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_174]], %[[VAL_175]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_176]], "assertion failed"
// CHECK-NEXT:        %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_174]], %[[VAL_177]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_178]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @LessThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @n2b : !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:        struct.member @n2b$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute(%[[VAL_179:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = struct.new : <@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_183]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_181]], %[[VAL_186]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_187]], "assertion failed"
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_189]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_191]], %[[VAL_181]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_190]], %[[VAL_192]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_195]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_193]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_185]][@in] = %[[VAL_197]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_198]], %[[VAL_199]] : index
// CHECK-NEXT:          pod.write %[[VAL_184]][@count] = %[[VAL_200]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_200]], %[[VAL_201]] : index
// CHECK-NEXT:          scf.if %[[VAL_202]] {
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_203]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:            pod.write %[[VAL_184]][@comp] = %[[VAL_204]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_206]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_207]]{{\[}}%[[VAL_208]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_205]], %[[VAL_209]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_180]][@out] = %[[VAL_210]] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_180]][@n2b$inputs] = %[[VAL_185]] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, @params: !pod.type<[]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          struct.writem %[[VAL_180]][@n2b] = %[[VAL_211]] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          function.return %[[VAL_180]] : !struct.type<@LessThan::@LessThan<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_212:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@n]>>, %[[VAL_213:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_212]][@out] : <@LessThan::@LessThan<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_212]][@n2b] : <@LessThan::@LessThan<[@n]>>, !struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_212]][@n2b$inputs] : <@LessThan::@LessThan<[@n]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_214]], %[[VAL_219]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_220]], "assertion failed"
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_221]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_213]]{{\[}}%[[VAL_222]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_224]], %[[VAL_214]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_223]], %[[VAL_225]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_227]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_213]]{{\[}}%[[VAL_228]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_226]], %[[VAL_229]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_231]], %[[VAL_230]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_217]][@out] : <@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_233]]{{\[}}%[[VAL_234]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_232]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_216]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_218]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_217]], %[[VAL_237]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"n_Add_1@633"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_238:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_246:[0-9a-zA-Z_\.]+]] = %[[VAL_243]], %[[VAL_247:[0-9a-zA-Z_\.]+]] = %[[VAL_244]], %[[VAL_248:[0-9a-zA-Z_\.]+]] = %[[VAL_242]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_247]], %[[VAL_240]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_249]]) %[[VAL_246]], %[[VAL_247]], %[[VAL_248]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_250:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_251:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_252:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_238]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_253]], %[[VAL_254]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_251]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_241]]{{\[}}%[[VAL_256]]] = %[[VAL_255]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_251]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_241]]{{\[}}%[[VAL_257]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_258]], %[[VAL_243]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_252]], %[[VAL_259]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_250]], %[[VAL_250]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_251]], %[[VAL_262]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_261]], %[[VAL_263]], %[[VAL_260]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_239]][@out] = %[[VAL_241]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_239]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_264:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_265:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_264]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_272:[0-9a-zA-Z_\.]+]] = %[[VAL_269]], %[[VAL_273:[0-9a-zA-Z_\.]+]] = %[[VAL_270]], %[[VAL_274:[0-9a-zA-Z_\.]+]] = %[[VAL_268]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_275:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_273]], %[[VAL_266]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_275]]) %[[VAL_272]], %[[VAL_273]], %[[VAL_274]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_276:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_277:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_278:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_279]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_281]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_282]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_280]], %[[VAL_284]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_285]], %[[VAL_286]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_287]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_288]], %[[VAL_269]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_278]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_276]], %[[VAL_276]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_277]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_291]], %[[VAL_293]], %[[VAL_290]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_271]]#2, %[[VAL_265]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
