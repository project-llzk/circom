// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithNeg() {
    signal input a;
    signal output x;
    x <== -a;
}

component main = ArithNeg();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@ArithNeg<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @ArithNeg<[]> {
// CHECK-NEXT:      struct.member @x : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ArithNeg<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArithNeg<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_0]] : !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_1]][@x] = %[[VAL_2]] : <@ArithNeg<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@ArithNeg<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@ArithNeg<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_4]] : !felt.type
// CHECK-DAG:         %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@x] : <@ArithNeg<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_6]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
