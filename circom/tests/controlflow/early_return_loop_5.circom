// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        if (i == 0) {
            return in;
        }
        assert(0 == 1); // Semantically unreachable because `i == 0` will always hit first
    }
    return -1; // Semantically unreachable because `i == 0` will always hit first
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@EarlyReturn<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[V_IN:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_R0:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[V_F0:[0-9a-zA-Z_\.]+]] = llzk.nondet : i1
// CHECK-NEXT:      %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_4:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[V_F1:[0-9a-zA-Z_\.]+]] = %[[V_F0]], %[[V_R1:[0-9a-zA-Z_\.]+]] = %[[V_R0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (i1, !felt.type, !felt.type) -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_8]])
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]] = bool.not %[[V_F1]] : i1
// CHECK-NEXT:        %[[V_12:[0-9a-zA-Z_\.]+]] = bool.and %[[V_10]], %[[V_9]] : i1, i1
// CHECK-NEXT:        scf.condition(%[[V_12]]) %[[V_F1]], %[[V_R1]], %[[V_I1]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[V_F2:[0-9a-zA-Z_\.]+]]: i1, %[[V_R2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_I2]], %[[V_13]])
// CHECK-NEXT:        %[[V_15:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[V_14]] -> (i1, !felt.type) {
// CHECK-NEXT:          %[[V_F3:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[V_F3]], %[[V_IN]] : i1, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[V_F4:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          scf.yield %[[V_F4]], %[[V_R2]] : i1, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_18:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[V_15]]#0 -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[V_F5:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          %[[V_I3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:          scf.yield %[[V_F5]], %[[V_15]]#1, %[[V_I3]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[V_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[V_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_23:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_21]], %[[V_22]])
// CHECK-NEXT:          bool.assert %[[V_23]], "assertion failed"
// CHECK-NEXT:          %[[V_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_I4:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_24]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_15]]#0, %[[V_15]]#1, %[[V_I4]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        }
// COM:                         flag         return val   loop index,i
// CHECK-NEXT:        scf.yield %[[V_18]]#0, %[[V_18]]#1, %[[V_18]]#2 : i1, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[V_26:[0-9a-zA-Z_\.]+]] = scf.if %[[V_4]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[V_4]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[V_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_28:[0-9a-zA-Z_\.]+]] = felt.neg %[[V_27]] : !felt.type
// CHECK-NEXT:        scf.yield %[[V_28]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_26]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @EarlyReturn<[]> {
// CHECK-NEXT:      struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[V_29:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_30:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn<[]>>
// CHECK-NEXT:        %[[V_31:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_29]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writem %[[V_30]][@outp] = %[[V_31]] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[V_30]] : !struct.type<@EarlyReturn<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[V_32:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn<[]>>, %[[V_33:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[V_34:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_33]]) : (!felt.type) -> !felt.type
// CHECK-DAG:         %[[V_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[V_32]][@outp] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_35]], %[[V_34]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
