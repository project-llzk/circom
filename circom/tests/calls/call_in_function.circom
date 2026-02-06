// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@CallInFnTest<[]>>} {
// CHECK-LABEL:   function.def @passthrough(
// CHECK-SAME:                              %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }
// CHECK-LABEL:   function.def @sum(
// CHECK-SAME:                      %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type,
// CHECK-SAME:                      %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @passthrough(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @passthrough(%[[VAL_1]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:      function.return %[[VAL_4]] : !felt.type
// CHECK-NEXT:    }
// CHECK-LABEL:   struct.def @CallInFnTest<[]> {
// CHECK-NEXT:      struct.member @z : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@CallInFnTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@CallInFnTest<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @sum(%[[VAL_0]], %[[VAL_1]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_2]][@z] = %[[VAL_3]] : <@CallInFnTest<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@CallInFnTest<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@CallInFnTest<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@z] : <@CallInFnTest<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
