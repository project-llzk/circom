// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(a) {
    return a;
}

template Template(m, n, c) {
    var v[2][2] = m;
    var x[c] = n;
    var ret[2][2] = f(v);
}

component main = Template([[0, 1], [2, 3]], [1, 0], 2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Template_0::@Template_0<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<2 x !felt.type<"bn128">> = [ 1 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_3 : !array.type<2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @f_0 {
// CHECK-NEXT:      function.def @f_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2,2 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !array.type<2,2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        function.return %[[VAL_0]] : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Template_0 {
// CHECK-NEXT:      struct.def @Template_0 {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Template_0::@Template_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Template_0::@Template_0<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = function.call @f_0::@f_0(%[[VAL_3]]) : (!array.type<2,2 x !felt.type<"bn128">>) -> !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Template_0::@Template_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !struct.type<@Template_0::@Template_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = function.call @f_0::@f_0(%[[VAL_39]]) : (!array.type<2,2 x !felt.type<"bn128">>) -> !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
