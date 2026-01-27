// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(a, b, c) {
  var x = a;
  var y = b;
  var z = c;
  return y;
}

template A() {
  _ = f(5, 10, 15);
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type,
// CHECK-SAME:                    %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type,
// CHECK-SAME:                    %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      function.return %[[VAL_1]] : !felt.type
// CHECK-NEXT:    }
//
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_1]], %[[VAL_2]], %[[VAL_3]]) : (!felt.type, !felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  15
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = function.call @f(%[[VAL_6]], %[[VAL_7]], %[[VAL_8]]) : (!felt.type, !felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
