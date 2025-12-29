// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Div() {
    signal input in;
    signal output out;
    out <-- in / 5;
}

component main = Div();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK:         struct.def @Div<[]> {
// CHECK:           struct.field @out : !felt.type {llzk.pub}
// CHECK:           function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Div<[]>> attributes {function.allow_witness} {
// CHECK:             %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Div<[]>>
// CHECK:             %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK:             %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.div %[[VAL_0]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK:             struct.writef %[[VAL_1]][@out] = %[[VAL_3]] : <@Div<[]>>, !felt.type
// CHECK:             function.return %[[VAL_1]] : !struct.type<@Div<[]>>
// CHECK:           }
// CHECK:           function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Div<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK:             function.return
// CHECK:           }
// CHECK:         }
// CHECK:       }

