// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Arith1() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a + b + 10;
}

component main = Arith1();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @Arith1<[]> {
// CHECK-NEXT:      struct.field @x : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type, %[[VAL_1:.*]]: !felt.type, %[[VAL_2:.*]]: !felt.type) -> !struct.type<@Arith1<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:.*]] = struct.new : <@Arith1<[]>>
// CHECK-NEXT:        %[[VAL_4:.*]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_5:.*]] = felt.const  10
// CHECK-NEXT:        %[[VAL_6:.*]] = felt.add %[[VAL_4]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@x] = %[[VAL_6]] : <@Arith1<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@Arith1<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_7:.*]]: !struct.type<@Arith1<[]>>, %[[VAL_8:.*]]: !felt.type, %[[VAL_9:.*]]: !felt.type, %[[VAL_10:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_11:.*]] = felt.add %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_12:.*]] = felt.const  10
// CHECK-NEXT:        %[[VAL_13:.*]] = felt.add %[[VAL_11]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_14:.*]] = struct.readf %[[VAL_7]][@x] : <@Arith1<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_14]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
