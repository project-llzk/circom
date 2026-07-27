// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Template(m) {
    signal output ret[2][2] <== m;
}

component main = Template([[0, 1], [2, 3]]);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Template_0::@Template_0<[]>>} {
// CHECK-NEXT:    poly.template @Template_0 {
// CHECK-NEXT:      struct.def @Template_0 {
// CHECK-NEXT:        struct.member @ret : !array.type<2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Template_0::@Template_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Template_0::@Template_0<[]>>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@ret] = %[[VAL_7]] : <@Template_0::@Template_0<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Template_0::@Template_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@Template_0::@Template_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@ret] : <@Template_0::@Template_0<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = global.read @vcp_array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_18]] : !array.type<2,2 x !felt.type<"bn128">>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @vcp_array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [
// CHECK-SAME:      #felt<const 0 : <"bn128">> : !felt.type<"bn128">,
// CHECK-SAME:      #felt<const 1 : <"bn128">> : !felt.type<"bn128">,
// CHECK-SAME:      #felt<const 2 : <"bn128">> : !felt.type<"bn128">,
// CHECK-SAME:      #felt<const 3 : <"bn128">> : !felt.type<"bn128">]
// CHECK-NEXT:  }
