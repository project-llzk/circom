// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:   struct.def @ReadFromOutput<[]> {
// CHECK-NEXT:     struct.field @outp : !felt.type {llzk.pub}
// CHECK-NEXT:     struct.field @intermediate : !felt.type
// CHECK-NEXT:     function.def @compute(%[[VAL_0:.*]]: !felt.type) -> !struct.type<@ReadFromOutput<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:       %[[VAL_1:.*]] = struct.new : <@ReadFromOutput<[]>>
// CHECK-NEXT:       %[[VAL_2:.*]] = undef.undef : !felt.type
// CHECK-NEXT:       struct.writef %[[VAL_1]][@outp] = %[[VAL_0]] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       struct.writef %[[VAL_1]][@intermediate] = %[[VAL_2]] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       function.return %[[VAL_1]] : !struct.type<@ReadFromOutput<[]>>
// CHECK-NEXT:     }
// CHECK-NEXT:     function.def @constrain(%[[VAL_3:.*]]: !struct.type<@ReadFromOutput<[]>>, %[[VAL_4:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:       %[[VAL_5:.*]] = undef.undef : !felt.type
// CHECK-NEXT:       %[[VAL_6:.*]] = struct.readf %[[VAL_3]][@outp] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       constrain.eq %[[VAL_6]], %[[VAL_4]] : !felt.type, !felt.type
// CHECK-NEXT:       %[[VAL_7:.*]] = struct.readf %[[VAL_3]][@intermediate] : <@ReadFromOutput<[]>>, !felt.type
// CHECK-NEXT:       constrain.eq %[[VAL_7]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:       function.return
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: }
