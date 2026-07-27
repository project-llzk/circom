// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithAdd() {
    signal input a;
    signal input b;
    signal output x;
    x <== a + b;
}

component main = ArithAdd();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArithAdd::@ArithAdd<[]>>} {
// CHECK-NEXT:    poly.template @ArithAdd {
// CHECK-NEXT:      struct.def @ArithAdd {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) -> !struct.type<@ArithAdd::@ArithAdd<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithAdd::@ArithAdd<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@x] = %[[VAL_3]] : <@ArithAdd::@ArithAdd<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@ArithAdd::@ArithAdd<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithAdd::@ArithAdd<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@x] : <@ArithAdd::@ArithAdd<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
