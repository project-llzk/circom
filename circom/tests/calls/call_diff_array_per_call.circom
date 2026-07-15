// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function f(a) {
    return a[0][0];
}

// The two calls to `f()` have different argument types which requires
// two versions of `f()` to be generated.
template CallDiffTypeTest() {
    signal input inA[10][5][5];
    signal input inB[10][5];
    signal output outA[5];
    signal output outB;

    outA <== f(inA); // f: (felt[10][5][5]) -> felt[5]
    outB <== f(inB); // f: (felt[10][5]) -> felt
}

component main = CallDiffTypeTest();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[]>>} {
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
// CHECK-NEXT:      struct.def @CallDiffTypeTest {
// CHECK-NEXT:        struct.member @outA : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @outB : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !array.type<10,5,5 x !felt.type<"bn128">> {function.arg_name = "inA"}, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !array.type<10,5 x !felt.type<"bn128">> {function.arg_name = "inB"}) -> !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.new : <@CallDiffTypeTest::@CallDiffTypeTest<[]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_8]]) : (!array.type<10,5,5 x !felt.type<"bn128">>) -> !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_10]][@outA] = %[[VAL_11]] : <@CallDiffTypeTest::@CallDiffTypeTest<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_9]]) : (!array.type<10,5 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_10]][@outB] = %[[VAL_12]] : <@CallDiffTypeTest::@CallDiffTypeTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_10]] : !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@CallDiffTypeTest::@CallDiffTypeTest<[]>>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !array.type<10,5,5 x !felt.type<"bn128">> {function.arg_name = "inA"}, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<10,5 x !felt.type<"bn128">> {function.arg_name = "inB"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@outA] : <@CallDiffTypeTest::@CallDiffTypeTest<[]>>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@outB] : <@CallDiffTypeTest::@CallDiffTypeTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_14]]) : (!array.type<10,5,5 x !felt.type<"bn128">>) -> !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_16]], %[[VAL_18]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @f::@f<[?, ?, ?]>(%[[VAL_15]]) : (!array.type<10,5 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_17]], %[[VAL_19]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
