// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    var x = 0;
    if (in < 10) {
        x = 2;
    } else {
        return in + 3;
    }
    return x;
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EarlyReturn::@EarlyReturn<[]>>} {
// CHECK-NEXT:    poly.template @earlyReturnFn {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "in"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  10 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_4]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_5]] -> (i1, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_return>) -> !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_8]], %[[VAL_9]], %[[VAL_7]] : i1, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_13]], %[[VAL_12]], %[[VAL_2]] : i1, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_6]]#1 : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_6]]#0 -> (!poly.tvar<@T_return>) {
// CHECK-NEXT:          scf.yield %[[VAL_14]] : !poly.tvar<@T_return>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_6]]#2 : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !poly.tvar<@T_return>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_15]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_17]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_18]][@outp] = %[[VAL_19]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_18]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_21]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
