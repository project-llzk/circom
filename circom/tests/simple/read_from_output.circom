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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ReadFromOutput<[]>>} {
// CHECK-NEXT:   struct.def @ReadFromOutput<[]> {
// CHECK-NEXT:     struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:     struct.member @intermediate : !felt.type
// CHECK-LABEL:    function.def @compute
// CHECK-SAME:     (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ReadFromOutput<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:       %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ReadFromOutput<[]>>
// CHECK-NEXT:       struct.writem %[[VAL_1]][@outp] = %[[VAL_0]] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       struct.writem %[[VAL_1]][@intermediate] = %[[VAL_0]] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       function.return %[[VAL_1]] : !struct.type<@ReadFromOutput<[]>>
// CHECK-NEXT:     }
// CHECK-LABEL:    function.def @constrain
// CHECK-SAME:     (%[[VAL_3:[0-9a-zA-Z_\.]+]]: !struct.type<@ReadFromOutput<[]>>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:       %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@outp] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_3]][@intermediate] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       constrain.eq %[[VAL_6]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:       constrain.eq %[[VAL_7]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:       function.return
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: }
