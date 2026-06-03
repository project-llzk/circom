// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        if (i == 0) {
            return in + 1;
        } else {
            return in + 2; // Semantically unreachable because `i == 0` will always hit first
        }
        return in + 5; // Syntactically unreachable because both branches above return
    }
    return -1; // Semantically unreachable because `i == 0` will always hit first
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@EarlyReturn::@EarlyReturn<[]>>} {
// CHECK-NEXT:    poly.template @earlyReturnFn {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "in"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_1]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) -> (i1, !poly.tvar<@T_return>, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.not %[[VAL_5]] : i1
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_10]], %[[VAL_9]] : i1, i1
// CHECK-NEXT:          scf.condition(%[[VAL_11]]) %[[VAL_5]], %[[VAL_6]], %[[VAL_7]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_12:[0-9a-zA-Z_\.]+]]: i1, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_return>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_14]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_16]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_17]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_27]], %[[VAL_24]], %[[VAL_26]] : i1, !poly.tvar<@T_return>, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_4]]#0 -> (!poly.tvar<@T_return>) {
// CHECK-NEXT:          scf.yield %[[VAL_4]]#1 : !poly.tvar<@T_return>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.neg %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_30]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_31]] : !poly.tvar<@T_return>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_28]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_32]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_33]][@outp] = %[[VAL_34]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_33]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_36]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
