// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function f(a, b, c) {
  var x = a;
  var y = b;
  var z = c;
  return y;
}

template A() {
  _ = f(5, 10, 15);
}

component main = A();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@A::@A<[]>>} {
// CHECK-NEXT:    poly.template @f {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @f(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1>, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_6]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @f::@f(%[[VAL_8]], %[[VAL_9]], %[[VAL_10]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_7]] : !struct.type<@A::@A<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = function.call @f::@f(%[[VAL_13]], %[[VAL_14]], %[[VAL_15]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
