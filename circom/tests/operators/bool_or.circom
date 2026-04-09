// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BoolOr() {
    signal input a, b;
    signal output out;

    out <-- (a > 0 || b > 0);
}

component main = BoolOr();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@BoolOr<[]>>} {
// CHECK-NEXT:    struct.def @BoolOr<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@BoolOr<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@BoolOr<[]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_0]], %[[VAL_3]])
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_1]], %[[VAL_5]])
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_4]], %[[VAL_6]] : i1, i1
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : i1
// CHECK-NEXT:        struct.writem %[[VAL_2]][@out] = %[[VAL_8]] : <@BoolOr<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@BoolOr<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@BoolOr<[]>>, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_9]][@out] : <@BoolOr<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
