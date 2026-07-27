// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function sum(a, b) {
    return a[0] + a[1] + a[2] + a[3] + b[0] + b[1];
}

template CallArgTest() {
    signal input x[4];
    signal input y[2];
    signal output z;

    z <-- sum(x, y);
}

component main = CallArgTest();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@CallArgTest::@CallArgTest<[]>>} {
// CHECK-NEXT:    poly.template @sum {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @sum(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "b"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_3]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e_0">>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_7]]] : <? x !poly.tvar<@"$e_0">>, !poly.tvar<@"$e_0">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_9]] : (!poly.tvar<@"$e_0">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_11]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e_1">>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_15]]{{\[}}%[[VAL_14]]] : <? x !poly.tvar<@"$e_1">>, !poly.tvar<@"$e_1">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_16]] : (!poly.tvar<@"$e_1">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e_2">>
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_20]]] : <? x !poly.tvar<@"$e_2">>, !poly.tvar<@"$e_2">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_22]] : (!poly.tvar<@"$e_2">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !array.type<? x !poly.tvar<@"$e_3">>
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_26]]] : <? x !poly.tvar<@"$e_3">>, !poly.tvar<@"$e_3">
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_28]] : (!poly.tvar<@"$e_3">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !array.type<? x !poly.tvar<@"$e_4">>
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_32]]] : <? x !poly.tvar<@"$e_4">>, !poly.tvar<@"$e_4">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_34]] : (!poly.tvar<@"$e_4">) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_36]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_37]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:      poly.param @"$e_0" : !poly.tvar<@"$e_0">
// CHECK-NEXT:      poly.param @"$e_1" : !poly.tvar<@"$e_1">
// CHECK-NEXT:      poly.param @"$e_2" : !poly.tvar<@"$e_2">
// CHECK-NEXT:      poly.param @"$e_3" : !poly.tvar<@"$e_3">
// CHECK-NEXT:      poly.param @"$e_4" : !poly.tvar<@"$e_4">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallArgTest {
// CHECK-NEXT:      struct.def @CallArgTest {
// CHECK-NEXT:        struct.member @z : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "x"}, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "y"}) -> !struct.type<@CallArgTest::@CallArgTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.new : <@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = function.call @sum::@sum<[?, ?, ?, ?, ?, ?, ?, ?, ?]>(%[[VAL_38]], %[[VAL_39]]) : (!array.type<4 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_40]][@z] = %[[VAL_41]] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_40]] : !struct.type<@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !struct.type<@CallArgTest::@CallArgTest<[]>>, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "x"}, %[[VAL_44:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "y"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_42]][@z] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
