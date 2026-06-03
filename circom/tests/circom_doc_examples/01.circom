// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Multiplier2() {
   //Declaration of signals
   signal input in1;
   signal input in2;
   signal output out;
   out <== in1 * in2;
}

component main {public [in1,in2]} = Multiplier2();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Multiplier2::@Multiplier2<[]>>} {
// CHECK-NEXT:    poly.template @Multiplier2 {
// CHECK-NEXT:      struct.def @Multiplier2 {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1", llzk.pub}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2", llzk.pub}) -> !struct.type<@Multiplier2::@Multiplier2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_3]] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Multiplier2::@Multiplier2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Multiplier2::@Multiplier2<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in1", llzk.pub}, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in2", llzk.pub}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Multiplier2::@Multiplier2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
