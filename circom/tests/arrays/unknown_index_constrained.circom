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
// CHECK-NEXT:      poly.param @y : index
// CHECK-NEXT:      struct.def @ForUnknownIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @get : !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:        struct.member @get$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@y]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]], %[[VAL_6]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]], %[[VAL_12]], %[[VAL_13]], %[[VAL_14]], %[[VAL_15]], %[[VAL_16]], %[[VAL_17]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_19]] }  : <[@x: index]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_21]], @params = %[[VAL_20]] }  : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_23]]{{\[}}%[[VAL_25]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_23]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_26]], %[[VAL_27]] : index
// CHECK-NEXT:          pod.write %[[VAL_22]][@count] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_28]], %[[VAL_29]] : index
// CHECK-NEXT:          scf.if %[[VAL_30]] {
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@params] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, !pod.type<[@x: index]>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_32]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_22]][@comp] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_35]]{{\[}}%[[VAL_37]]] = %[[VAL_34]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_35]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@count] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_38]], %[[VAL_39]] : index
// CHECK-NEXT:          pod.write %[[VAL_22]][@count] = %[[VAL_40]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_40]], %[[VAL_41]] : index
// CHECK-NEXT:          scf.if %[[VAL_42]] {
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@params] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, !pod.type<[@x: index]>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @GreaterEqThan::@GreaterEqThan::@compute(%[[VAL_44]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_22]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_46]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_48]], @params = %[[VAL_47]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_50]]{{\[}}%[[VAL_52]]] = %[[VAL_0]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_5]][@in] = %[[VAL_50]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:          pod.write %[[VAL_49]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:          scf.if %[[VAL_57]] {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !pod.type<[@m: index]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_59]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_49]][@comp] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_62]]{{\[}}%[[VAL_64]]] = %[[VAL_61]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_5]][@in] = %[[VAL_62]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_65]], %[[VAL_66]] : index
// CHECK-NEXT:          pod.write %[[VAL_49]][@count] = %[[VAL_67]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_67]], %[[VAL_68]] : index
// CHECK-NEXT:          scf.if %[[VAL_69]] {
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !pod.type<[@m: index]>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_71]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:            pod.write %[[VAL_49]][@comp] = %[[VAL_72]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_73]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_74]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get$inputs] = %[[VAL_4]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@comp] : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@get] = %[[VAL_75]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt$inputs] = %[[VAL_5]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@lt] = %[[VAL_76]] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@y]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknownIndex::@ForUnknownIndex<[@y]>>, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_79]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@out] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@get] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@get$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@lt] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !struct.type<@LessThan::@LessThan<[@y]>>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@lt$inputs] : <@ForUnknownIndex::@ForUnknownIndex<[@y]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_86]], %[[VAL_86]], %[[VAL_86]], %[[VAL_86]], %[[VAL_86]], %[[VAL_86]], %[[VAL_86]], %[[VAL_86]], %[[VAL_86]], %[[VAL_86]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_88]], %[[VAL_89]], %[[VAL_90]], %[[VAL_91]], %[[VAL_92]], %[[VAL_93]], %[[VAL_94]], %[[VAL_95]], %[[VAL_96]], %[[VAL_97]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.new { @x = %[[VAL_99]] }  : <[@x: index]>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, @params: !pod.type<[@x: index]>]>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_104]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_105]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_107]]{{\[}}%[[VAL_109]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_110]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_82]][@out] : <@GreaterEqThan::@GreaterEqThan<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_111]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = poly.read_const @y : index
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_113]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@y]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_118]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_119]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_123]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_124]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@out] : <@LessThan::@LessThan<[@y]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_125]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @GreaterEqThan::@GreaterEqThan::@constrain(%[[VAL_82]], %[[VAL_127]]) : (!struct.type<@GreaterEqThan::@GreaterEqThan<[@y]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_85]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_84]], %[[VAL_128]]) : (!struct.type<@LessThan::@LessThan<[@y]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @GreaterEqThan {
// CHECK-NEXT:      poly.param @x : index
// CHECK-NEXT:      struct.def @GreaterEqThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @lt : !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:        struct.member @lt$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_129:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@GreaterEqThan::@GreaterEqThan<[@x]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = struct.new : <@GreaterEqThan::@GreaterEqThan<[@x]>>
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = poly.read_const @x : index
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_131]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = poly.read_const @x : index
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_134]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_136]], @params = %[[VAL_135]] }  : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_139]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_141]]{{\[}}%[[VAL_143]]] = %[[VAL_140]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_133]][@in] = %[[VAL_141]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_144]], %[[VAL_145]] : index
// CHECK-NEXT:          pod.write %[[VAL_137]][@count] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// CHECK-NEXT:          scf.if %[[VAL_148]] {
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, !pod.type<[@m: index]>
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_150]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:            pod.write %[[VAL_137]][@comp] = %[[VAL_151]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_153]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_154]], %[[VAL_155]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_157]]{{\[}}%[[VAL_159]]] = %[[VAL_156]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_133]][@in] = %[[VAL_157]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@count] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_160]], %[[VAL_161]] : index
// CHECK-NEXT:          pod.write %[[VAL_137]][@count] = %[[VAL_162]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, index
// CHECK-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_163]] : index
// CHECK-NEXT:          scf.if %[[VAL_164]] {
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@params] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, !pod.type<[@m: index]>
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = function.call @LessThan::@LessThan::@compute(%[[VAL_166]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:            pod.write %[[VAL_137]][@comp] = %[[VAL_167]] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@out] : <@LessThan::@LessThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_130]][@out] = %[[VAL_169]] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_130]][@lt$inputs] = %[[VAL_133]] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@comp] : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          struct.writem %[[VAL_130]][@lt] = %[[VAL_170]] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          function.return %[[VAL_130]] : !struct.type<@GreaterEqThan::@GreaterEqThan<[@x]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_171:[0-9a-zA-Z_\.]+]]: !struct.type<@GreaterEqThan::@GreaterEqThan<[@x]>>, %[[VAL_172:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = poly.read_const @x : index
// CHECK-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_173]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@out] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@lt] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !struct.type<@LessThan::@LessThan<[@x]>>
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@lt$inputs] : <@GreaterEqThan::@GreaterEqThan<[@x]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = poly.read_const @x : index
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.new { @m = %[[VAL_178]] }  : <[@m: index]>
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@LessThan::@LessThan<[@x]>>, @params: !pod.type<[@m: index]>]>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_182]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_185]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_184]]{{\[}}%[[VAL_186]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_187]], %[[VAL_183]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_172]]{{\[}}%[[VAL_189]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_190]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_193]]{{\[}}%[[VAL_195]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_196]], %[[VAL_192]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@out] : <@LessThan::@LessThan<[@x]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_175]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @LessThan::@LessThan::@constrain(%[[VAL_176]], %[[VAL_198]]) : (!struct.type<@LessThan::@LessThan<[@x]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @LessThan {
// CHECK-NEXT:      poly.param @m : index
// CHECK-NEXT:      poly.expr @"m_Add_1@633" {
// CHECK-NEXT:        %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:        %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_201:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:        %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_201]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_203:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_202]], %[[VAL_199]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        bool.assert %[[VAL_203]], "assertion failed"
// CHECK-NEXT:        %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_202]], %[[VAL_200]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @LessThan {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @n2b : !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:        struct.member @n2b$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_205:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@LessThan::@LessThan<[@m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = struct.new : <@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_207]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_208]], %[[VAL_211]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_212]], "assertion failed"
// CHECK-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_213]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_214]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_216]], @params = %[[VAL_215]] }  : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_205]]{{\[}}%[[VAL_219]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_221]], %[[VAL_208]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_220]], %[[VAL_222]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_224]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_205]]{{\[}}%[[VAL_225]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_223]], %[[VAL_226]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_210]][@in] = %[[VAL_227]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@count] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_228]], %[[VAL_229]] : index
// CHECK-NEXT:          pod.write %[[VAL_217]][@count] = %[[VAL_230]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_230]], %[[VAL_231]] : index
// CHECK-NEXT:          scf.if %[[VAL_232]] {
// CHECK-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@params] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:            %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_235:[0-9a-zA-Z_\.]+]] = function.call @Num2Bits::@Num2Bits::@compute(%[[VAL_234]]) : (!felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:            pod.write %[[VAL_217]][@comp] = %[[VAL_235]] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_237]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_208]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_238]]{{\[}}%[[VAL_239]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_236]], %[[VAL_240]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_206]][@out] = %[[VAL_241]] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_206]][@n2b$inputs] = %[[VAL_210]] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@comp] : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          struct.writem %[[VAL_206]][@n2b] = %[[VAL_242]] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          function.return %[[VAL_206]] : !struct.type<@LessThan::@LessThan<[@m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_243:[0-9a-zA-Z_\.]+]]: !struct.type<@LessThan::@LessThan<[@m]>>, %[[VAL_244:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_245]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_243]][@out] : <@LessThan::@LessThan<[@m]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_243]][@n2b] : <@LessThan::@LessThan<[@m]>>, !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_243]][@n2b$inputs] : <@LessThan::@LessThan<[@m]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  252 : <"bn128">
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_246]], %[[VAL_251]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_252]], "assertion failed"
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = poly.read_const @"m_Add_1@633" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_253]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_254]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_257]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_244]]{{\[}}%[[VAL_258]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.shl %[[VAL_260]], %[[VAL_246]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_259]], %[[VAL_261]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_263]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_244]]{{\[}}%[[VAL_264]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_262]], %[[VAL_265]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_250]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_267]], %[[VAL_266]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_249]][@out] : <@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_246]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_270]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_268]], %[[VAL_271]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_248]], %[[VAL_272]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_250]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @Num2Bits::@Num2Bits::@constrain(%[[VAL_249]], %[[VAL_273]]) : (!struct.type<@Num2Bits::@Num2Bits<[@"m_Add_1@633"]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_274:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_276]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_283:[0-9a-zA-Z_\.]+]] = %[[VAL_280]], %[[VAL_284:[0-9a-zA-Z_\.]+]] = %[[VAL_281]], %[[VAL_285:[0-9a-zA-Z_\.]+]] = %[[VAL_279]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_284]], %[[VAL_277]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_286]]) %[[VAL_283]], %[[VAL_284]], %[[VAL_285]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_287:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_288:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_289:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_274]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_290]], %[[VAL_291]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_278]]{{\[}}%[[VAL_293]]] = %[[VAL_292]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_294]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_295]], %[[VAL_287]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_289]], %[[VAL_296]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_287]], %[[VAL_287]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_288]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_298]], %[[VAL_300]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_275]][@out] = %[[VAL_278]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_275]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_301:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_302:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_303:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_304:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_303]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_305:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_301]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_309:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_310:[0-9a-zA-Z_\.]+]] = %[[VAL_307]], %[[VAL_311:[0-9a-zA-Z_\.]+]] = %[[VAL_308]], %[[VAL_312:[0-9a-zA-Z_\.]+]] = %[[VAL_306]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_311]], %[[VAL_304]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_313]]) %[[VAL_310]], %[[VAL_311]], %[[VAL_312]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_314:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_315:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_316:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_305]]{{\[}}%[[VAL_317]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_305]]{{\[}}%[[VAL_319]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_321:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_320]], %[[VAL_321]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_318]], %[[VAL_322]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_323]], %[[VAL_324]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_305]]{{\[}}%[[VAL_325]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_326]], %[[VAL_314]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_316]], %[[VAL_327]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_314]], %[[VAL_314]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_315]], %[[VAL_330]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_329]], %[[VAL_331]], %[[VAL_328]] : !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_309]]#2, %[[VAL_302]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
