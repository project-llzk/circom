// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function binop_bool_array(a, b) {
  var arr[10];
  for (var i = 0; i < 10; i++) {
    arr[i] = a[i] || b[i];
  }
  return arr;
}

template A() {
  signal input in1[10];
  signal input in2[10];
  signal output out[10];

  out <-- binop_bool_array(in1, in2);
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_0::@A_0<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<10 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @binop_bool_array_0 {
// CHECK-NEXT:      function.def @binop_bool_array_0(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "b"}) -> !array.type<10 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_33]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_35]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_37]]) %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_39]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_41]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_40]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp ne(%[[VAL_42]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_44]], %[[VAL_46]] : i1, i1
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_47]] : i1, !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_48]]] = %[[VAL_49]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_2]] : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A_0 {
// CHECK-NEXT:      struct.def @A_0 {
// CHECK-NEXT:        struct.member @out : !array.type<10 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "in1"}, %[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "in2"}) -> !struct.type<@A_0::@A_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.new : <@A_0::@A_0<[]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = function.call @binop_bool_array_0::@binop_bool_array_0(%[[VAL_52]], %[[VAL_53]]) : (!array.type<10 x !felt.type<"bn128">>, !array.type<10 x !felt.type<"bn128">>) -> !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_54]][@out] = %[[VAL_55]] : <@A_0::@A_0<[]>>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_54]] : !struct.type<@A_0::@A_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !struct.type<@A_0::@A_0<[]>>, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "in1"}, %[[VAL_58:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "in2"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_56]][@out] : <@A_0::@A_0<[]>>, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
