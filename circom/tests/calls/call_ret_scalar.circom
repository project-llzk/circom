// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.1.0;

function sum(a) {
    var b = a;
    return b;
}

template CallRetTest() {
    signal input x;
    signal output y;

    y <-- sum(x);
}

component main = CallRetTest();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@CallRetTest<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @sum(
// CHECK-SAME:                      %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }
//
// CHECK-LABEL:   struct.def @CallRetTest<[]> {
// CHECK-NEXT:      struct.field @y : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@CallRetTest<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@CallRetTest<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = function.call @sum(%[[VAL_0]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %self[@y] = %[[VAL_2]] : <@CallRetTest<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@CallRetTest<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@CallRetTest<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_3]][@y] : <@CallRetTest<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
