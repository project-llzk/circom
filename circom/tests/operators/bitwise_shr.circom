// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template BitwiseShiftRight() {
    signal input v;
    signal output type;
    type <-- v >> 5;
}

component main = BitwiseShiftRight();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@BitwiseShiftRight::@BitwiseShiftRight<[]>>} {
// CHECK-NEXT:    poly.template @BitwiseShiftRight {
// CHECK-NEXT:      struct.def @BitwiseShiftRight {
// CHECK-NEXT:        struct.member @type : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "v"}) -> !struct.type<@BitwiseShiftRight::@BitwiseShiftRight<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BitwiseShiftRight::@BitwiseShiftRight<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_0]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@type] = %[[VAL_3]] : <@BitwiseShiftRight::@BitwiseShiftRight<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BitwiseShiftRight::@BitwiseShiftRight<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@BitwiseShiftRight::@BitwiseShiftRight<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "v"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@type] : <@BitwiseShiftRight::@BitwiseShiftRight<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
