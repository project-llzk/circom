// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithNeg() {
    signal input a;
    signal output x;
    x <== -a;
}

component main = ArithNeg();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @ArithNeg<[]> {
// CHECK-NEXT:      struct.field @x : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type) -> !struct.type<@ArithNeg<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:.*]] = struct.new : <@ArithNeg<[]>>
// CHECK-NEXT:        %[[VAL_2:.*]] = felt.neg %[[VAL_0]] : !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@x] = %[[VAL_2]] : <@ArithNeg<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@ArithNeg<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_3:.*]]: !struct.type<@ArithNeg<[]>>, %[[VAL_4:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_5:.*]] = felt.neg %[[VAL_4]] : !felt.type
// CHECK-NEXT:        %[[VAL_6:.*]] = struct.readf %[[VAL_3]][@x] : <@ArithNeg<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_6]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
