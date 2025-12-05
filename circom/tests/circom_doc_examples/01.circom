// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @Multiplier2<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type {llzk.pub}, %[[VAL_1:.*]]: !felt.type {llzk.pub}) -> !struct.type<@Multiplier2<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:.*]] = struct.new : <@Multiplier2<[]>>
// CHECK-NEXT:        %[[VAL_3:.*]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@out] = %[[VAL_3]] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@Multiplier2<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:.*]]: !struct.type<@Multiplier2<[]>>, %[[VAL_5:.*]]: !felt.type {llzk.pub}, %[[VAL_6:.*]]: !felt.type {llzk.pub}) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_7:.*]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_8:.*]] = struct.readf %[[VAL_4]][@out] : <@Multiplier2<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
