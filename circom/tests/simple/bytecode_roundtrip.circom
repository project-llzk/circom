// REQUIRES: circom, llzk-opt
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs llzk-opt | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Verifies that the default bytecode output (no --llzk_plaintext) round-trips
// correctly through llzk-opt, producing valid LLZK IR text.
template BytecodeOutput() {
    signal input a;
    signal output b;
    b <== a;
}

component main = BytecodeOutput();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@BytecodeOutput<[]>>} {
// CHECK-NEXT:    poly.template @BytecodeOutput {
// CHECK-NEXT:      struct.def @BytecodeOutput {
// CHECK-NEXT:        struct.member @b : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@BytecodeOutput::@BytecodeOutput<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@BytecodeOutput::@BytecodeOutput<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@b] = %[[VAL_0]] : <@BytecodeOutput::@BytecodeOutput<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@BytecodeOutput::@BytecodeOutput<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@BytecodeOutput::@BytecodeOutput<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@b] : <@BytecodeOutput::@BytecodeOutput<[]>>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
