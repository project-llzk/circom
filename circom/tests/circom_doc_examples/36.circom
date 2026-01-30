// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Translate(n) {
  signal input in;  
  assert(in<=254);
}

component main = Translate(1);

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Translate<[1]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @Translate<[@n]> {
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Translate<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Translate<[@n]>>
// CHECK-NEXT:        %[[VAL_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  254
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_0]], %[[VAL_2]])
// CHECK-NEXT:        bool.assert %[[VAL_3]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Translate<[@n]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Translate<[@n]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_N:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  254
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_5]], %[[VAL_6]])
// CHECK-NEXT:        bool.assert %[[VAL_7]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
