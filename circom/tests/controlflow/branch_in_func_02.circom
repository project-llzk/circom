// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function negative(n){
  if (n < 0) {
    return 1;
  }
  return 0;
}

template C() {
  signal input in;
  signal output out;
  out <-- negative(in);
}

component main = C();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@C::@C<[]>>} {
// CHECK-NEXT:    poly.template @negative {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @negative(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "n"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_3]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_4]] -> (i1, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_7]], %[[VAL_6]] : i1, !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_return>) -> !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_8]], %[[VAL_9]] : i1, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]]#1 : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]]#0 -> (!poly.tvar<@T_return>) {
// CHECK-NEXT:          scf.yield %[[VAL_10]] : !poly.tvar<@T_return>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_12]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !poly.tvar<@T_return>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_11]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @C {
// CHECK-NEXT:      struct.def @C {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@C::@C<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[]>>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = function.call @negative::@negative(%[[VAL_14]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_15]][@out] = %[[VAL_16]] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_15]] : !struct.type<@C::@C<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@C::@C<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
