// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(a, b) {
    return a + b;
}

template T() {
    signal input inp1;
    signal input inp2;
    signal input inp3;

    // Circom generates constraint "inp1 = inp2 + inp3"
    inp1 === f(inp2, inp3);
}

component main = T();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@T::@T<[]>>} {
// CHECK-NEXT:    poly.template @f {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "b"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_5]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @T {
// CHECK-NEXT:      struct.def @T {
// CHECK-NEXT:        function.def @compute(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp1"}, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp2"}, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp3"}) -> !struct.type<@T::@T<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@T::@T<[]>>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@T::@T<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@T::@T<[]>>, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp1"}, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp2"}, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp3"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @f::@f(%[[VAL_12]], %[[VAL_13]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
