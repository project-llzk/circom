// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
    signal output valA;
    signal output valB;

    valA <-- 0;
    valB <== valA * 1;
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @A<[]> {
// CHECK-NEXT:      struct.field @valA : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @valB : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        struct.writef %[[VAL_0]][@valA] = %[[VAL_1]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_0]][@valB] = %[[VAL_3]] : <@A<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@A<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@valA] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@valB] : <@A<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
