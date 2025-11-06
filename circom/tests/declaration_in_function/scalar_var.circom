// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(in) {
  var x = in;
  return x;
}

template A() {
  _ = f(5);
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @f(
// CHECK-SAME:                    %[[VAL_0:.*]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type
// CHECK-NEXT:    }
//
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@A<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:.*]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:.*]] = felt.const  5
// CHECK-NEXT:        %[[VAL_2:.*]] = function.call @f(%[[VAL_1]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:.*]]: !struct.type<@A<[]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_4:.*]] = felt.const  5
// CHECK-NEXT:        %[[VAL_5:.*]] = function.call @f(%[[VAL_4]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
