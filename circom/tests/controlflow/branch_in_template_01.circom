// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Conditional() {
    signal input inp;
    var q;
    if (inp) {
        q = 0;
    } else {
        q = 1;
    }
}

component main = Conditional();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Conditional::@Conditional<[]>>} {
// CHECK-NEXT:    poly.template @Conditional {
// CHECK-NEXT:      struct.def @Conditional {
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Conditional::@Conditional<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Conditional::@Conditional<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_0]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_4]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            scf.yield %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Conditional::@Conditional<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !struct.type<@Conditional::@Conditional<[]>>, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_9]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_12]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
