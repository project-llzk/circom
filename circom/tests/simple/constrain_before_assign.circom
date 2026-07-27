// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Template() {
    signal output outp;
    outp === 7;
    outp <-- 7;
}

component main = Template();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Template::@Template<[]>>} {
// CHECK-NEXT:    poly.template @Template {
// CHECK-NEXT:      struct.def @Template {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Template::@Template<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Template::@Template<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          struct.writem %[[VAL_0]][@outp] = %[[VAL_1]] : <@Template::@Template<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Template::@Template<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !struct.type<@Template::@Template<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_2]][@outp] : <@Template::@Template<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          constrain.eq %[[VAL_3]], %[[VAL_4]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
