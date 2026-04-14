// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function passthrough(x) {
    return x;
}

function sum(a, b) {
    return passthrough(a) + passthrough(b);
}

template CallInFnTest() {
    signal input x, y;
    signal output z;

    z <-- sum(x,y);
}

component main = CallInFnTest();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@CallInFnTest::@CallInFnTest<[]>>} {
// CHECK-NEXT:    function.def @passthrough(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !felt.type<"bn128"> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:    }
// CHECK-NEXT:    function.def @sum(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !felt.type<"bn128"> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @passthrough(%[[VAL_1]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = function.call @passthrough(%[[VAL_2]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_3]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:      function.return %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallInFnTest {
// CHECK-NEXT:      struct.def @CallInFnTest {
// CHECK-NEXT:        struct.member @z : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@CallInFnTest::@CallInFnTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@CallInFnTest::@CallInFnTest<[]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = function.call @sum(%[[VAL_6]], %[[VAL_7]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_8]][@z] = %[[VAL_9]] : <@CallInFnTest::@CallInFnTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_8]] : !struct.type<@CallInFnTest::@CallInFnTest<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@CallInFnTest::@CallInFnTest<[]>>, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@z] : <@CallInFnTest::@CallInFnTest<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
