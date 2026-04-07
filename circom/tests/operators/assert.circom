// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(nBits) {
    assert(nBits <= 512);
}

component main = A(32);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A<[32]>>} {
// CHECK-NEXT:    struct.def @A<[@nBits]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[@nBits]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@nBits]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @nBits : !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  512
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_1]], %[[VAL_2]])
// CHECK-NEXT:        bool.assert %[[VAL_3]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[@nBits]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@nBits]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @nBits : !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  512
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_5]], %[[VAL_6]])
// CHECK-NEXT:        bool.assert %[[VAL_7]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
