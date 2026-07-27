// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Arith2() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a * b * 10;
}

component main = Arith2();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Arith2::@Arith2<[]>>} {
// CHECK-NEXT:    poly.template @Arith2 {
// CHECK-NEXT:      struct.def @Arith2 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "c"}) -> !struct.type<@Arith2::@Arith2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@Arith2::@Arith2<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_4]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@x] = %[[VAL_6]] : <@Arith2::@Arith2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@Arith2::@Arith2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !struct.type<@Arith2::@Arith2<[]>>, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "b"}, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "c"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_7]][@x] : <@Arith2::@Arith2<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_12]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
