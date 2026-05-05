// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(inp, n, m, k, a) {
    if (n == 0) {
        return inp;
        // Everything below is unreachable because of the return above
        var dividend[5];
        for (var i = m; i >= 0; i--) {
            if (i == m) {
                dividend[k] = 0;
                for (var j = 0; j < k; j++) {
                    dividend[j] = a[j + m];
                }
            } else {
                for (var j = k; j >= 0; j--) {
                    dividend[j] = a[j + i];
                }
            }
        }
    }
    return 0;
}

template EarlyReturn() {
    signal input inp;
    signal input a[10];
    signal output outp;

    outp <== earlyReturnFn(inp, 0, inp, inp, a);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EarlyReturn::@EarlyReturn<[]>>} {
// CHECK-NEXT:    poly.template @earlyReturnFn {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_arg3 : !poly.tvar<@T_arg3>
// CHECK-NEXT:      poly.param @T_arg4 : !poly.tvar<@T_arg4>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1>, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2>, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg3>, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg4>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_7]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_8]] -> (i1, !poly.tvar<@T_arg0>) {
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_10]], %[[VAL_0]] : i1, !poly.tvar<@T_arg0>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!poly.tvar<@T_return>) -> !poly.tvar<@T_arg0>
// CHECK-NEXT:          scf.yield %[[VAL_11]], %[[VAL_12]] : i1, !poly.tvar<@T_arg0>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_9]]#1 : (!poly.tvar<@T_arg0>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_9]]#0 -> (!poly.tvar<@T_return>) {
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !poly.tvar<@T_return>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_15]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:          scf.yield %[[VAL_16]] : !poly.tvar<@T_return>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_14]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">>) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_17]], %[[VAL_20]], %[[VAL_17]], %[[VAL_17]], %[[VAL_18]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_19]][@outp] = %[[VAL_21]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_19]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn::@earlyReturnFn(%[[VAL_23]], %[[VAL_26]], %[[VAL_23]], %[[VAL_23]], %[[VAL_24]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>) -> !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_25]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
