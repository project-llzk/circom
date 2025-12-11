// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BitwiseShiftLeft() {
    signal input v;
    signal output type;
    type <-- v << 5;
}

component main = BitwiseShiftLeft();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK:         struct.def @BitwiseShiftLeft<[]> {
// CHECK:           struct.field @type : !felt.type {llzk.pub}
// CHECK:           function.def @compute(%[[VAL_0:.*]]: !felt.type) -> !struct.type<@BitwiseShiftLeft<[]>> attributes {function.allow_witness} {
// CHECK:             %[[VAL_1:.*]] = struct.new : <@BitwiseShiftLeft<[]>>
// CHECK:             %[[VAL_2:.*]] = felt.const  5
// CHECK:             %[[VAL_3:.*]] = felt.shl %[[VAL_0]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK:             struct.writef %[[VAL_1]][@type] = %[[VAL_3]] : <@BitwiseShiftLeft<[]>>, !felt.type
// CHECK:             function.return %[[VAL_1]] : !struct.type<@BitwiseShiftLeft<[]>>
// CHECK:           }
// CHECK:           function.def @constrain(%[[VAL_4:.*]]: !struct.type<@BitwiseShiftLeft<[]>>, %[[VAL_5:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK:             function.return
// CHECK:           }
// CHECK:         }
// CHECK:       }
