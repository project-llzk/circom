// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
  var x = 7;
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A<[]>>} {
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
