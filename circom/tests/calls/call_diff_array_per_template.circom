// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function f(a) {
    return a[0][0];
}

// The two calls to `f()` have different argument types which requires
// two versions of `f()` to be generated. These functions must also be
// parametric in the size of the last array dimension. The flattened
// circuit thus has 4 versions of `f()`.
template CallDiffTypeTest(N) {
    signal input inA[8][5][N];
    signal input inB[8][N];
    signal output outA[N];
    signal output outB;

    outA <== f(inA); // f: (felt[8][5][N]) -> felt[N]
    outB <== f(inB); // f: (felt[8][N]) -> felt
}

template Main() {
    signal input inA[8][5][3];
    signal input inB[8][3];
    signal input inC[8][5][2];
    signal input inD[8][2];

    signal output outA[3];
    signal output outB;
    signal output outC[2];
    signal output outD;

    component crt1 = CallDiffTypeTest(3);
    crt1.inA <== inA;
    crt1.inB <== inB;
    outA <== crt1.outA;
    outB <== crt1.outB;
    component crt2 = CallDiffTypeTest(2);
    crt2.inA <== inC;
    crt2.inB <== inD;
    outC <== crt2.outA;
    outD <== crt2.outB;
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Main::@Main<[]>>} {
// CHECK-NEXT:    poly.template @f {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_1]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<?,? x !poly.tvar<@"$e">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_2]], %[[VAL_4]]] : <?,? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_6]] : (!poly.tvar<@"$e">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_7]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallDiffTypeTest {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @CallDiffTypeTest {
// CHECK-NEXT:        struct.member @outA : !array.type<@N x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @outB : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !array.type<8,5,@N x !felt.type<"bn128">>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !array.type<8,@N x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_8]]) : (!array.type<8,5,@N x !felt.type<"bn128">>) -> !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_10]][@outA] = %[[VAL_12]] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_9]]) : (!array.type<8,@N x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_10]][@outB] = %[[VAL_13]] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_10]] : !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<8,5,@N x !felt.type<"bn128">>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<8,@N x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_14]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_15]]) : (!array.type<8,5,@N x !felt.type<"bn128">>) -> !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_18]], %[[VAL_20]] : !array.type<@N x !felt.type<"bn128">>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_16]]) : (!array.type<8,@N x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_19]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @outA : !array.type<3 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @outB : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @outC : !array.type<2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @outD : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @crt1 : !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:        struct.member @crt1$inputs : !pod.type<[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:        struct.member @crt2 : !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:        struct.member @crt2$inputs : !pod.type<[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<8,5,3 x !felt.type<"bn128">>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !array.type<8,3 x !felt.type<"bn128">>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<8,5,2 x !felt.type<"bn128">>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<8,2 x !felt.type<"bn128">>) -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_29]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 144 : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_31]], @params = %[[VAL_30]] }  : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_27]][@inA] = %[[VAL_22]] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:          pod.write %[[VAL_32]][@count] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:          scf.if %[[VAL_37]] {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_39]], %[[VAL_40]]) : (!array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:            pod.write %[[VAL_32]][@comp] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_27]][@inB] = %[[VAL_23]] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:          pod.write %[[VAL_32]][@count] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:          scf.if %[[VAL_46]] {
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_48]], %[[VAL_49]]) : (!array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:            pod.write %[[VAL_32]][@comp] = %[[VAL_50]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_51]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_52]] : (!array.type<? x !felt.type<"bn128">>) -> !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_26]][@outA] = %[[VAL_53]] : <@Main::@Main<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_54]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_26]][@outB] = %[[VAL_55]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_56]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 96 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_58]], @params = %[[VAL_57]] }  : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:          pod.write %[[VAL_28]][@inA] = %[[VAL_24]] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_60]], %[[VAL_61]] : index
// CHECK-NEXT:          pod.write %[[VAL_59]][@count] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_62]], %[[VAL_63]] : index
// CHECK-NEXT:          scf.if %[[VAL_64]] {
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_66]], %[[VAL_67]]) : (!array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:            pod.write %[[VAL_59]][@comp] = %[[VAL_68]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_28]][@inB] = %[[VAL_25]] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_69]], %[[VAL_70]] : index
// CHECK-NEXT:          pod.write %[[VAL_59]][@count] = %[[VAL_71]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_71]], %[[VAL_72]] : index
// CHECK-NEXT:          scf.if %[[VAL_73]] {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_75]], %[[VAL_76]]) : (!array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:            pod.write %[[VAL_59]][@comp] = %[[VAL_77]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_79]] : (!array.type<? x !felt.type<"bn128">>) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_26]][@outC] = %[[VAL_80]] : <@Main::@Main<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_81]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_26]][@outD] = %[[VAL_82]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_26]][@crt1$inputs] = %[[VAL_27]] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          struct.writem %[[VAL_26]][@crt1] = %[[VAL_83]] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          struct.writem %[[VAL_26]][@crt2$inputs] = %[[VAL_28]] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          struct.writem %[[VAL_26]][@crt2] = %[[VAL_84]] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          function.return %[[VAL_26]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !array.type<8,5,3 x !felt.type<"bn128">>, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !array.type<8,3 x !felt.type<"bn128">>, %[[VAL_88:[0-9a-zA-Z_\.]+]]: !array.type<8,5,2 x !felt.type<"bn128">>, %[[VAL_89:[0-9a-zA-Z_\.]+]]: !array.type<8,2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@outA] : <@Main::@Main<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@outB] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@outC] : <@Main::@Main<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@outD] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@crt1] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@crt1$inputs] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@crt2] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@crt2$inputs] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_98]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_101]], %[[VAL_86]] : !array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_102]], %[[VAL_87]] : !array.type<8,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_94]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_90]], %[[VAL_103]] : !array.type<3 x !felt.type<"bn128">>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_94]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_91]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_105]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_108]], %[[VAL_88]] : !array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_109]], %[[VAL_89]] : !array.type<8,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_96]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_92]], %[[VAL_110]] : !array.type<2 x !felt.type<"bn128">>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_96]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_93]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @CallDiffTypeTest::@CallDiffTypeTest::@constrain(%[[VAL_94]], %[[VAL_112]], %[[VAL_113]]) : (!struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @CallDiffTypeTest::@CallDiffTypeTest::@constrain(%[[VAL_96]], %[[VAL_114]], %[[VAL_115]]) : (!struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
