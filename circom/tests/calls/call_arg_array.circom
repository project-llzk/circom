// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function sum(a) {
    return a[0] + a[1] + a[2] + a[3];
}

template CallArgTest() {
    signal input x[4];
    signal output y;

    y <-- sum(x);
}

component main = CallArgTest();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@CallArgTest::@CallArgTest<[]>>} {
// CHECK-NEXT:    poly.template @sum {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @sum(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "a"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_1]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_2]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e_0">>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_6]]] : <? x !poly.tvar<@"$e_0">>, !poly.tvar<@"$e_0">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_8]] : (!poly.tvar<@"$e_0">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e_1">>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_13]]] : <? x !poly.tvar<@"$e_1">>, !poly.tvar<@"$e_1">
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_15]] : (!poly.tvar<@"$e_1">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e_2">>
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_19]]] : <? x !poly.tvar<@"$e_2">>, !poly.tvar<@"$e_2">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_21]] : (!poly.tvar<@"$e_2">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_23]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_24]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:      poly.param @"$e_0" : !poly.tvar<@"$e_0">
// CHECK-NEXT:      poly.param @"$e_1" : !poly.tvar<@"$e_1">
// CHECK-NEXT:      poly.param @"$e_2" : !poly.tvar<@"$e_2">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallArgTest {
// CHECK-NEXT:      struct.def @CallArgTest {
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "x"}) -> !struct.type<@CallArgTest::@CallArgTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.new : <@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = function.call @sum::@sum<[?, ?, ?, ?, ?, ?]>(%[[VAL_25]]) : (!array.type<4 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_26]][@y] = %[[VAL_27]] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_26]] : !struct.type<@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !struct.type<@CallArgTest::@CallArgTest<[]>>, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "x"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_28]][@y] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
