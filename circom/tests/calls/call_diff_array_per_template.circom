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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main::@Main<[]>>} {
// CHECK-NEXT:    poly.template @f {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "a"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
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
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @CallDiffTypeTest {
// CHECK-NEXT:        struct.member @outA : !array.type<@N x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @outB : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !array.type<8,5,@N x !felt.type<"bn128">> {function.arg_name = "inA"}, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !array.type<8,@N x !felt.type<"bn128">> {function.arg_name = "inB"}) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_11]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_8]]) : (!array.type<8,5,@N x !felt.type<"bn128">>) -> !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_10]][@outA] = %[[VAL_13]] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_9]]) : (!array.type<8,@N x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_10]][@outB] = %[[VAL_14]] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_10]] : !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<8,5,@N x !felt.type<"bn128">> {function.arg_name = "inA"}, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<8,@N x !felt.type<"bn128">> {function.arg_name = "inB"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_18]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_16]]) : (!array.type<8,5,@N x !felt.type<"bn128">>) -> !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_20]], %[[VAL_22]] : !array.type<@N x !felt.type<"bn128">>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_17]]) : (!array.type<8,@N x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_21]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Main {
// CHECK-NEXT:      struct.def @Main {
// CHECK-NEXT:        struct.member @outA : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @outB : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @outC : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @outD : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @crt1 : !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:        struct.member @crt1$inputs : !pod.type<[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        struct.member @crt2 : !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:        struct.member @crt2$inputs : !pod.type<[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<8,5,3 x !felt.type<"bn128">> {function.arg_name = "inA"}, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<8,3 x !felt.type<"bn128">> {function.arg_name = "inB"}, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<8,5,2 x !felt.type<"bn128">> {function.arg_name = "inC"}, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<8,2 x !felt.type<"bn128">> {function.arg_name = "inD"}) -> !struct.type<@Main::@Main<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.new : <@Main::@Main<[]>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_31]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 144 : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_33]], @params = %[[VAL_32]] }  : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_29]][@inA] = %[[VAL_24]] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:          pod.write %[[VAL_34]][@count] = %[[VAL_37]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:          scf.if %[[VAL_39]] {
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, !pod.type<[@N: index]>
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_41]], %[[VAL_42]]) : (!array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:            pod.write %[[VAL_34]][@comp] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_29]][@inB] = %[[VAL_25]] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:          pod.write %[[VAL_34]][@count] = %[[VAL_46]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:          scf.if %[[VAL_48]] {
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, !pod.type<[@N: index]>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_50]], %[[VAL_51]]) : (!array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:            pod.write %[[VAL_34]][@comp] = %[[VAL_52]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_53]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_54]] : (!array.type<? x !felt.type<"bn128">>) -> !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_28]][@outA] = %[[VAL_55]] : <@Main::@Main<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_28]][@outB] = %[[VAL_57]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_58]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 96 : index
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_60]], @params = %[[VAL_59]] }  : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          pod.write %[[VAL_30]][@inA] = %[[VAL_26]] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_62]], %[[VAL_63]] : index
// CHECK-NEXT:          pod.write %[[VAL_61]][@count] = %[[VAL_64]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_64]], %[[VAL_65]] : index
// CHECK-NEXT:          scf.if %[[VAL_66]] {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, !pod.type<[@N: index]>
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_68]], %[[VAL_69]]) : (!array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:            pod.write %[[VAL_61]][@comp] = %[[VAL_70]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          pod.write %[[VAL_30]][@inB] = %[[VAL_27]] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@count] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_71]], %[[VAL_72]] : index
// CHECK-NEXT:          pod.write %[[VAL_61]][@count] = %[[VAL_73]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_73]], %[[VAL_74]] : index
// CHECK-NEXT:          scf.if %[[VAL_75]] {
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@params] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, !pod.type<[@N: index]>
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = function.call @CallDiffTypeTest::@CallDiffTypeTest::@compute(%[[VAL_77]], %[[VAL_78]]) : (!array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:            pod.write %[[VAL_61]][@comp] = %[[VAL_79]] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_81]] : (!array.type<? x !felt.type<"bn128">>) -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_28]][@outC] = %[[VAL_82]] : <@Main::@Main<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_83]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_28]][@outD] = %[[VAL_84]] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_28]][@crt1$inputs] = %[[VAL_29]] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          struct.writem %[[VAL_28]][@crt1] = %[[VAL_85]] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          struct.writem %[[VAL_28]][@crt2$inputs] = %[[VAL_30]] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@comp] : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          struct.writem %[[VAL_28]][@crt2] = %[[VAL_86]] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          function.return %[[VAL_28]] : !struct.type<@Main::@Main<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_87:[0-9a-zA-Z_\.]+]]: !struct.type<@Main::@Main<[]>>, %[[VAL_88:[0-9a-zA-Z_\.]+]]: !array.type<8,5,3 x !felt.type<"bn128">> {function.arg_name = "inA"}, %[[VAL_89:[0-9a-zA-Z_\.]+]]: !array.type<8,3 x !felt.type<"bn128">> {function.arg_name = "inB"}, %[[VAL_90:[0-9a-zA-Z_\.]+]]: !array.type<8,5,2 x !felt.type<"bn128">> {function.arg_name = "inC"}, %[[VAL_91:[0-9a-zA-Z_\.]+]]: !array.type<8,2 x !felt.type<"bn128">> {function.arg_name = "inD"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@outA] : <@Main::@Main<[]>>, !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@outB] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@outC] : <@Main::@Main<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@outD] : <@Main::@Main<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@crt1] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@crt1$inputs] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@crt2] : <@Main::@Main<[]>>, !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@crt2$inputs] : <@Main::@Main<[]>>, !pod.type<[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_100]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_88]] : !array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_104]], %[[VAL_89]] : !array.type<8,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_96]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_92]], %[[VAL_105]] : !array.type<3 x !felt.type<"bn128">>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_96]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_93]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_107]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_110]], %[[VAL_90]] : !array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_111]], %[[VAL_91]] : !array.type<8,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_98]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_94]], %[[VAL_112]] : !array.type<2 x !felt.type<"bn128">>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_98]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_95]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inA] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inB] : <[@inA: !array.type<8,5,3 x !felt.type<"bn128">>, @inB: !array.type<8,3 x !felt.type<"bn128">>]>, !array.type<8,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @CallDiffTypeTest::@CallDiffTypeTest::@constrain(%[[VAL_96]], %[[VAL_114]], %[[VAL_115]]) : (!struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[3]>>, !array.type<8,5,3 x !felt.type<"bn128">>, !array.type<8,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@inA] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,5,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@inB] : <[@inA: !array.type<8,5,2 x !felt.type<"bn128">>, @inB: !array.type<8,2 x !felt.type<"bn128">>]>, !array.type<8,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @CallDiffTypeTest::@CallDiffTypeTest::@constrain(%[[VAL_98]], %[[VAL_116]], %[[VAL_117]]) : (!struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[2]>>, !array.type<8,5,2 x !felt.type<"bn128">>, !array.type<8,2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
