// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(){
    signal input in1;
    signal input in2;
    signal output out;
    out <== in1 * in2;
}

component main {public [in1]}= A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type {llzk.pub}, %[[VAL_1:.*]]: !felt.type) -> !struct.type<@A<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:.*]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_3:.*]] = felt.mul %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_2]][@out] = %[[VAL_3]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:.*]]: !struct.type<@A<[]>>, %[[VAL_5:.*]]: !felt.type {llzk.pub}, %[[VAL_6:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_7:.*]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_8:.*]] = struct.readf %[[VAL_4]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
