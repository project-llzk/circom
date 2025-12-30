// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BitwiseOr() {
    signal input v;
    signal output type;
    signal check_v;
    type <-- v | 5;
    check_v <== type*32;
}

component main = BitwiseOr();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @BitwiseOr<[]> {
// CHECK-NEXT:      struct.field @type : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @check_v : !felt.type
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@BitwiseOr<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BitwiseOr<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.bit_or %[[VAL_0]], %[[VAL_2]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@type] = %[[VAL_3]] : <@BitwiseOr<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_3]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@check_v] = %[[VAL_5]] : <@BitwiseOr<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@BitwiseOr<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_6:[0-9a-zA-Z_\.]+]]: !struct.type<@BitwiseOr<[]>>, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_6]][@type] : <@BitwiseOr<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_6]][@check_v] : <@BitwiseOr<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_11]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
