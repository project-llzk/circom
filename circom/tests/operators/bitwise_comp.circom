// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BitwiseComplement() {
    signal input v;
    signal output type;
    signal check_v;
    type <-- ~v;
    check_v <== type*32;
}

component main = BitwiseComplement();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @BitwiseComplement<[]> {
// CHECK-NEXT:      struct.field @type : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.field @check_v : !felt.type
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@BitwiseComplement<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BitwiseComplement<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.bit_not %[[VAL_0]] : !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@type] = %[[VAL_2]] : <@BitwiseComplement<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_2]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@check_v] = %[[VAL_4]] : <@BitwiseComplement<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@BitwiseComplement<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@BitwiseComplement<[]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_5]][@type] : <@BitwiseComplement<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_7]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_5]][@check_v] : <@BitwiseComplement<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_10]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
