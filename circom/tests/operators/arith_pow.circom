// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArithPower() {
    signal input in;
    signal output out <-- in ** 2;
}

component main = ArithPower();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:   struct.def @ArithPower<[]> {
// CHECK-NEXT:     struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:     function.def @compute(%[[VAL_0:.*]]: !felt.type) -> !struct.type<@ArithPower<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:       %[[VAL_1:.*]] = struct.new : <@ArithPower<[]>>
// CHECK-NEXT:       %[[VAL_2:.*]] = felt.const  2
// CHECK-NEXT:       %[[VAL_3:.*]] = felt.pow %[[VAL_0]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:       struct.writef %[[VAL_1]][@out] = %[[VAL_3]] : <@ArithPower<[]>>, !felt.type
// CHECK-NEXT:       function.return %[[VAL_1]] : !struct.type<@ArithPower<[]>>
// CHECK-NEXT:     }
// CHECK-NEXT:     function.def @constrain(%[[VAL_4:.*]]: !struct.type<@ArithPower<[]>>, %[[VAL_5:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:       %[[VAL_6:.*]] = struct.readf %[[VAL_4]][@out] : <@ArithPower<[]>>, !felt.type
// CHECK-NEXT:       function.return
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: }
