// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// This test is identical to early_return_loop_2A.circom but uses a while loop instead of a for loop.
// Note that, because of the return inside the loop, the `i++` is unreachable and `i` is not added as a loop-carried variable.
function earlyReturnFn(in) {
    var i = 0;
    while (i < 6) {
        return in;
        assert(0 == 1); // Unreachable because of the early return above
        i++;
    }
    return -1;
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EarlyReturn<[]>>} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_R0:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_E0:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:      %[[V_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[V_E1:[0-9a-zA-Z_\.]+]] = %[[V_E0]], %[[V_R1:[0-9a-zA-Z_\.]+]] = %[[V_R0]]) : (i1, !felt.type) -> (i1, !felt.type) {
// CHECK-NEXT:        %[[V_7:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I0]], %[[V_7]])
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = bool.not %[[V_E1]] : i1
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]] = bool.and %[[V_9]], %[[V_8]] : i1, i1
// CHECK-NEXT:        scf.condition(%[[V_10]]) %[[V_E1]], %[[V_R1]] : i1, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[V_E2:[0-9a-zA-Z_\.]+]]: i1, %[[V_R2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[V_E3:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[V_E3]], %[[V_0]] : i1, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[V_12:[0-9a-zA-Z_\.]+]] = scf.if %[[V_4]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[V_4]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = felt.neg %[[V_13]] : !felt.type
// CHECK-NEXT:        scf.yield %[[V_14]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_12]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_17]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_18]][@outp] = %[[VAL_19]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_18]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_21]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_22]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
