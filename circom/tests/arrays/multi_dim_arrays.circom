// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Arrays() {
    var default_init[3][2][1];
    var inline_init[2][2] = [[1, 2], [3, 4]];
}

component main = Arrays();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Arrays::@Arrays<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<3,2,1 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<2,2 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Arrays {
// CHECK-NEXT:      struct.def @Arrays {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Arrays::@Arrays<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Arrays::@Arrays<[]>>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3,2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Arrays::@Arrays<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@Arrays::@Arrays<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3,2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
