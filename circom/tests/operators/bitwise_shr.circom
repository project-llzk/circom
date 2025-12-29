// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BitwiseShiftRight() {
    signal input v;
    signal output type;
    type <-- v >> 5;
}

component main = BitwiseShiftRight();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK:         struct.def @BitwiseShiftRight<[]> {
// CHECK:           struct.field @type : !felt.type {llzk.pub}
// CHECK:           function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@BitwiseShiftRight<[]>> attributes {function.allow_witness} {
// CHECK:             %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BitwiseShiftRight<[]>>
// CHECK:             %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK:             %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_0]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK:             struct.writef %[[VAL_1]][@type] = %[[VAL_3]] : <@BitwiseShiftRight<[]>>, !felt.type
// CHECK:             function.return %[[VAL_1]] : !struct.type<@BitwiseShiftRight<[]>>
// CHECK:           }
// CHECK:           function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@BitwiseShiftRight<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK:             function.return
// CHECK:           }
// CHECK:         }
// CHECK:       }
