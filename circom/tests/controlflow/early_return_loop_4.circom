// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        if (i == 0) {
            return in + 1;
        } else {
            return in + 2;
        }
    }
    return -1; // Semantically unreachable because `i == 0` will always hit first
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EarlyReturn<[]>>} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_R0:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:      %[[V_4:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[V_R1:[0-9a-zA-Z_\.]+]] = %[[V_R0]], %[[V_6:[0-9a-zA-Z_\.]+]] = %[[V_1]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (i1, !felt.type, !felt.type) -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_8]])
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]] = bool.not %[[V_R1]] : i1
// CHECK-NEXT:        %[[V_12:[0-9a-zA-Z_\.]+]] = bool.and %[[V_10]], %[[V_9]] : i1, i1
// CHECK-NEXT:        scf.condition(%[[V_12]]) %[[V_R1]], %[[V_6]], %[[V_I1]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[V_R2:[0-9a-zA-Z_\.]+]]: i1, %[[V_11:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_I2]], %[[V_13]])
// CHECK-NEXT:        %[[V_15:[0-9a-zA-Z_\.]+]] = scf.if %[[V_14]] -> (!felt.type) {
// CHECK-NEXT:          %[[V_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_17:[0-9a-zA-Z_\.]+]] = felt.add %[[V_0]], %[[V_16]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_17]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[V_18:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_19:[0-9a-zA-Z_\.]+]] = felt.add %[[V_0]], %[[V_18]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_19]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_20]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_R3:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[V_R3]], %[[V_15]], %[[V_I3]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[V_23:[0-9a-zA-Z_\.]+]] = scf.if %[[V_4]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[V_4]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[V_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_25:[0-9a-zA-Z_\.]+]] = felt.neg %[[V_24]] : !felt.type
// CHECK-NEXT:        scf.yield %[[V_25]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_23]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_28]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_29]][@outp] = %[[VAL_30]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_29]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_32]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_33]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
