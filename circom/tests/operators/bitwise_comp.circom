// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@BitwiseComplement::@BitwiseComplement<[]>>} {
// CHECK-NEXT:    poly.template @BitwiseComplement {
// CHECK-NEXT:      struct.def @BitwiseComplement {
// CHECK-NEXT:        struct.member @type : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @check_v : !felt.type<"bn128">
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "v"}) -> !struct.type<@BitwiseComplement::@BitwiseComplement<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BitwiseComplement::@BitwiseComplement<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.bit_not %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@type] = %[[VAL_2]] : <@BitwiseComplement::@BitwiseComplement<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_2]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@check_v] = %[[VAL_4]] : <@BitwiseComplement::@BitwiseComplement<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BitwiseComplement::@BitwiseComplement<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@BitwiseComplement::@BitwiseComplement<[]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "v"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@type] : <@BitwiseComplement::@BitwiseComplement<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@check_v] : <@BitwiseComplement::@BitwiseComplement<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_7]], %[[VAL_9]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
