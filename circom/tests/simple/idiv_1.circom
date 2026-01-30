// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
    var c = 1 \ -1;
    assert(c == 0); // 0 quotient means circom uses unsigned division
}

component main = A();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@A<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_2]] : !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_1]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_4]], %[[VAL_5]])
// CHECK-NEXT:        bool.assert %[[VAL_6]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_9]] : !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_8]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_11]], %[[VAL_12]])
// CHECK-NEXT:        bool.assert %[[VAL_13]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
