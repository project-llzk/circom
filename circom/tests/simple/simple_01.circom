// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Simple3() {
    signal input a;
    signal output b;
    signal output c;

    b <== a;
    c <== a;
}

component main = Simple3();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Simple3<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @Simple3<[]> {
// CHECK-NEXT:      struct.field @b : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @c : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Simple3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Simple3<[]>>
// CHECK-NEXT:        struct.writef %[[VAL_1]][@b] = %[[VAL_0]] : <@Simple3<[]>>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@c] = %[[VAL_0]] : <@Simple3<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Simple3<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@Simple3<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_2]][@b] : <@Simple3<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_2]][@c] : <@Simple3<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_5]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
