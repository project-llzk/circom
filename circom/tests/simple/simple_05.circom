// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
	signal input a, b, d;
	signal output out;

	out <== (a + b) * d;
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:.*]]: !felt.type, %[[VAL_1:.*]]: !felt.type, %[[VAL_2:.*]]: !felt.type) -> !struct.type<@A<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_3:.*]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_4:.*]] = felt.add %[[VAL_0]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_5:.*]] = felt.mul %[[VAL_4]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_3]][@out] = %[[VAL_5]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_3]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_6:.*]]: !struct.type<@A<[]>>, %[[VAL_7:.*]]: !felt.type, %[[VAL_8:.*]]: !felt.type, %[[VAL_9:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_10:.*]] = felt.add %[[VAL_7]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_11:.*]] = felt.mul %[[VAL_10]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_12:.*]] = struct.readf %[[VAL_6]][@out] : <@A<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_12]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
