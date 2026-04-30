// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function sum(a) {
    var b[2][4][3] = a;
    return b;
}

template CallRetTest() {
    signal input x[2][4][3];
    signal output y[2][4][3];

    y <-- sum(x);
}

component main = CallRetTest();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@CallRetTest::@CallRetTest<[]>>} {
// CHECK-NEXT:    poly.template @sum {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @sum(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]], %[[VAL_1]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <4,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <4,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_5]]] = %[[VAL_2]] : <4,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_6]]] = %[[VAL_2]] : <4,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_7]]] = %[[VAL_2]] : <4,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new  : <2,4,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_8]]{{\[}}%[[VAL_9]]] = %[[VAL_3]] : <2,4,3 x !felt.type<"bn128">>, <4,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_8]]{{\[}}%[[VAL_10]]] = %[[VAL_3]] : <2,4,3 x !felt.type<"bn128">>, <4,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<2,4,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_11]] : (!array.type<2,4,3 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_12]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallRetTest {
// CHECK-NEXT:      struct.def @CallRetTest {
// CHECK-NEXT:        struct.member @y : !array.type<2,4,3 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !array.type<2,4,3 x !felt.type<"bn128">>) -> !struct.type<@CallRetTest::@CallRetTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.new : <@CallRetTest::@CallRetTest<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @sum::@sum(%[[VAL_13]]) : (!array.type<2,4,3 x !felt.type<"bn128">>) -> !array.type<2,4,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_15]] : (!array.type<2,4,3 x !felt.type<"bn128">>) -> !array.type<2,4,3 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_14]][@y] = %[[VAL_16]] : <@CallRetTest::@CallRetTest<[]>>, !array.type<2,4,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_14]] : !struct.type<@CallRetTest::@CallRetTest<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@CallRetTest::@CallRetTest<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<2,4,3 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@y] : <@CallRetTest::@CallRetTest<[]>>, !array.type<2,4,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
