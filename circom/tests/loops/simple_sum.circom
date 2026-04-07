// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
  var sum = 0;
  for (var i = 0; i < 18446744073709551616; i++) {
      sum += i;
  }
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A<[]>>} {
// CHECK-NEXT:    struct.def @A<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_4:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_1]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551616
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_4]], %[[VAL_6]])
// CHECK-NEXT:          scf.condition(%[[VAL_7]]) %[[VAL_4]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_12]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_15]], %[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_14]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  18446744073709551616
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_19]])
// CHECK-NEXT:          scf.condition(%[[VAL_20]]) %[[VAL_17]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_25]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
