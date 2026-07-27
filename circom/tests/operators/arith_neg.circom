// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithNeg() {
    signal input a;
    signal output x;
    x <== -a;
}

component main = ArithNeg();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArithNeg::@ArithNeg<[]>>} {
// CHECK-NEXT:    poly.template @ArithNeg {
// CHECK-NEXT:      struct.def @ArithNeg {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) -> !struct.type<@ArithNeg::@ArithNeg<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithNeg::@ArithNeg<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@x] = %[[VAL_2]] : <@ArithNeg::@ArithNeg<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ArithNeg::@ArithNeg<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithNeg::@ArithNeg<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:           %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@x] : <@ArithNeg::@ArithNeg<[]>>, !felt.type<"bn128">
// CHECK-DAG:           %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_4]] : !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
