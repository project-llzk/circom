// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
  _ <-- 99;
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@A<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:.*]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:.*]] = felt.const  99
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:    function.def @constrain
// CHECK-SAME:      (%[[VAL_2:.*]]: !struct.type<@A<[]>>) attributes {function.allow_constraint} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
