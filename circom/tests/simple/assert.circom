// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
  signal input in;
  assert(in > 0);
}

component main = A(5);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @A<[@n]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type) -> !struct.type<@A<[@n]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:.*]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_2:.*]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:.*]] = bool.cmp gt(%[[VAL_0]], %[[VAL_2]])
// CHECK-NEXT:        bool.assert %[[VAL_3]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:.*]]: !struct.type<@A<[@n]>>, %[[VAL_5:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_6:.*]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:.*]] = bool.cmp gt(%[[VAL_5]], %[[VAL_6]])
// CHECK-NEXT:        bool.assert %[[VAL_7]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
