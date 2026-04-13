// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ReadFromOutputWithFeltCast() {
    signal input inp;
    signal output outp;
    signal intermediate;
    outp <== inp == 0;
    intermediate <== outp;
}

component main = ReadFromOutputWithFeltCast();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>} {
// CHECK-NEXT:    poly.template @ReadFromOutputWithFeltCast {
// CHECK-NEXT:      struct.def @ReadFromOutputWithFeltCast {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        struct.member @intermediate : !felt.type
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : i1, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_4]] : <@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@intermediate] = %[[VAL_4]] : <@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !struct.type<@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@outp] : <@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_5]][@intermediate] : <@ReadFromOutputWithFeltCast::@ReadFromOutputWithFeltCast<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_6]], %[[VAL_9]]) : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_10]] : i1, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_7]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
