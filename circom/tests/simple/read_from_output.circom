// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ReadFromOutput() {
    signal input inp;
    signal output outp;
    signal intermediate;
    outp <== inp;
    intermediate <== outp;
}

component main = ReadFromOutput();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ReadFromOutput::@ReadFromOutput<[]>>} {
// CHECK-NEXT:    poly.template @ReadFromOutput {
// CHECK-NEXT:      struct.def @ReadFromOutput {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @intermediate : !felt.type<"bn128">
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@ReadFromOutput::@ReadFromOutput<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ReadFromOutput::@ReadFromOutput<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_0]] : <@ReadFromOutput::@ReadFromOutput<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@intermediate] = %[[VAL_0]] : <@ReadFromOutput::@ReadFromOutput<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ReadFromOutput::@ReadFromOutput<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@ReadFromOutput::@ReadFromOutput<[]>>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@outp] : <@ReadFromOutput::@ReadFromOutput<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@intermediate] : <@ReadFromOutput::@ReadFromOutput<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_4]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_5]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
