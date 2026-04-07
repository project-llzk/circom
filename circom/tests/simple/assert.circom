// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
  signal input in;
  assert(in > 0);
}

component main = A(5);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A<[5]>>} {
// CHECK-LABEL:   struct.def @A<[@n]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_0]], %[[VAL_2]])
// CHECK-NEXT:        bool.assert %[[VAL_3]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_5]], %[[VAL_6]])
// CHECK-NEXT:        bool.assert %[[VAL_7]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
