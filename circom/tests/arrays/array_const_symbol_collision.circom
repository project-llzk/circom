// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Concrete lowering gives this function the module-level name `array_const_0`, which collides
// with the first requested name for a generated literal global.
function array_const() {
    var out[2] = [1, 2];
    return out;
}

template Main() {
    var out[2] = array_const();
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_0::@Main_0<[]>>} {
// CHECK-NEXT:    poly.template @array_const_0 {
// CHECK-NEXT:      function.def @array_const_0() -> !array.type<2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        function.return %[[VAL_0]] : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0_0 : !array.type<2 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">]
// CHECK-NEXT:    poly.template @Main_0 {
// CHECK-NEXT:      struct.def @Main_0 {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main_0::@Main_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_0::@Main_0<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @array_const_0::@array_const_0() : () -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Main_0::@Main_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_0::@Main_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = function.call @array_const_0::@array_const_0() : () -> !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_1 : !array.type<2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:  }
