// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithPower() {
    signal input in;
    signal output out <-- in ** 2;
}

component main = ArithPower();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArithPower::@ArithPower<[]>>} {
// CHECK-NEXT:    poly.template @ArithPower {
// CHECK-NEXT:      struct.def @ArithPower {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@ArithPower::@ArithPower<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithPower::@ArithPower<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.pow %[[VAL_0]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@ArithPower::@ArithPower<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ArithPower::@ArithPower<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithPower::@ArithPower<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@ArithPower::@ArithPower<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
