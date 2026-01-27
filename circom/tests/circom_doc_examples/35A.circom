// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
  signal input in;
  assert(n>0);
  in * in === n;
}

component main = A(0);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_2]], %[[VAL_3]])
// CHECK-NEXT:        bool.assert %[[VAL_4]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_7]], %[[VAL_8]])
// CHECK-NEXT:        bool.assert %[[VAL_9]], "assertion failed"
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_6]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_10]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
