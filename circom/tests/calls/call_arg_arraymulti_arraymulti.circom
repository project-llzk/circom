// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function sum(a, b) {
    var agg = 0;
    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 2; j++) {
            agg += a[i][j] - b[i][j];
        }
    }
    return agg;
}

template CallArgTest() {
    signal input x[3][2];
    signal input y[3][2];
    signal output a;

    a <-- sum(x, y);
}

component main = CallArgTest();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@CallArgTest::@CallArgTest<[]>>} {
// CHECK-NEXT:    poly.template @sum {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @sum(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "b"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_8]]) %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_9]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_16]]) %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<?,? x !poly.tvar<@"$e">>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_19]], %[[VAL_20]]] : <?,? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !array.type<?,? x !poly.tvar<@"$e_0">>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_23]], %[[VAL_24]]] : <?,? x !poly.tvar<@"$e_0">>, !poly.tvar<@"$e_0">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_22]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_26]] : (!poly.tvar<@"$e_0">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_27]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_30]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_12]]#0, %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]]#0 : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_35]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:      poly.param @"$e_0" : !poly.tvar<@"$e_0">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallArgTest {
// CHECK-NEXT:      struct.def @CallArgTest {
// CHECK-NEXT:        struct.member @a : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type<"bn128">> {function.arg_name = "x"}, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type<"bn128">> {function.arg_name = "y"}) -> !struct.type<@CallArgTest::@CallArgTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.new : <@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @sum::@sum<[?, ?, ?, ?, ?]>(%[[VAL_36]], %[[VAL_37]]) : (!array.type<3,2 x !felt.type<"bn128">>, !array.type<3,2 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_38]][@a] = %[[VAL_39]] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_38]] : !struct.type<@CallArgTest::@CallArgTest<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !struct.type<@CallArgTest::@CallArgTest<[]>>, %[[VAL_41:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type<"bn128">> {function.arg_name = "x"}, %[[VAL_42:[0-9a-zA-Z_\.]+]]: !array.type<3,2 x !felt.type<"bn128">> {function.arg_name = "y"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@a] : <@CallArgTest::@CallArgTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
