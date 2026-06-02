// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BitwiseAnd() {
    signal input v;
    signal output type;
    signal check_v;
    type <-- v & 5;
    check_v <== type*32;
}

component main = BitwiseAnd();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@BitwiseAnd::@BitwiseAnd<[]>>} {
// CHECK-NEXT:    poly.template @BitwiseAnd {
// CHECK-NEXT:      struct.def @BitwiseAnd {
// CHECK-NEXT:        struct.member @type : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @check_v : !felt.type<"bn128">
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "v"}) -> !struct.type<@BitwiseAnd::@BitwiseAnd<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BitwiseAnd::@BitwiseAnd<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_0]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@type] = %[[VAL_3]] : <@BitwiseAnd::@BitwiseAnd<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_3]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@check_v] = %[[VAL_5]] : <@BitwiseAnd::@BitwiseAnd<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BitwiseAnd::@BitwiseAnd<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !struct.type<@BitwiseAnd::@BitwiseAnd<[]>>, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "v"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_6]][@type] : <@BitwiseAnd::@BitwiseAnd<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_6]][@check_v] : <@BitwiseAnd::@BitwiseAnd<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  32
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_9]], %[[VAL_11]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
