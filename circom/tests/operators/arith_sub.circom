// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithSubtract() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a - (b - 10);
}

component main = ArithSubtract();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @ArithSubtract<[]> {
// CHECK-NEXT:      struct.field @x : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type, %[[VAL_1:.*]]: !felt.type, %[[VAL_2:.*]]: !felt.type) -> !struct.type<@ArithSubtract<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:.*]] = struct.new : <@ArithSubtract<[]>>
// CHECK-NEXT:        %[[VAL_4:.*]] = felt.const  10
// CHECK-NEXT:        %[[VAL_5:.*]] = felt.sub %[[VAL_1]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_6:.*]] = felt.sub %[[VAL_0]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@x] = %[[VAL_6]] : <@ArithSubtract<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@ArithSubtract<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_7:.*]]: !struct.type<@ArithSubtract<[]>>, %[[VAL_8:.*]]: !felt.type, %[[VAL_9:.*]]: !felt.type, %[[VAL_10:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_11:.*]] = felt.const  10
// CHECK-NEXT:        %[[VAL_12:.*]] = felt.sub %[[VAL_9]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_13:.*]] = felt.sub %[[VAL_8]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_14:.*]] = struct.readf %[[VAL_7]][@x] : <@ArithSubtract<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_14]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
