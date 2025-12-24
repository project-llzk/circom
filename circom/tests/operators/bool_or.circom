// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BoolOr() {
    signal input a, b;
    signal output out;

    out <-- (a > 0 || b > 0);
}

component main = BoolOr();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @BoolOr<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:.*]]: !felt.type, %[[VAL_1:.*]]: !felt.type) -> !struct.type<@BoolOr<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:.*]] = struct.new : <@BoolOr<[]>>
// CHECK-NEXT:        %[[VAL_3:.*]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:.*]] = bool.cmp gt(%[[VAL_0]], %[[VAL_3]])
// CHECK-NEXT:        %[[VAL_5:.*]] = felt.const  0
// CHECK-NEXT:        %[[VAL_6:.*]] = bool.cmp gt(%[[VAL_1]], %[[VAL_5]])
// CHECK-NEXT:        %[[VAL_7:.*]] = bool.or %[[VAL_4]], %[[VAL_6]] : i1, i1
// CHECK-NEXT:        %[[VAL_8:.*]] = cast.tofelt %[[VAL_7]] : i1
// CHECK-NEXT:        struct.writef %[[VAL_2]][@out] = %[[VAL_8]] : <@BoolOr<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@BoolOr<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_9:.*]]: !struct.type<@BoolOr<[]>>, %[[VAL_10:.*]]: !felt.type, %[[VAL_11:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
