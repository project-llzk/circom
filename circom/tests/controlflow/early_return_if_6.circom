// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(i, n) {
    if (n == 0) {
        return i;
    }
    if (n == 1) {
        return i + 2;
    }
    return 0;
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp, 0);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[V_I:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_N:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_U:[0-9a-zA-Z_\.]+]] = undef.undef : !felt.type
// CHECK-NEXT:      %[[V_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_4:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_N]], %[[V_3]])
// CHECK-NEXT:      %[[V_5:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[V_4]] -> (i1, !felt.type) {
// CHECK-NEXT:        %[[V_R0:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[V_R0]], %[[V_I]] : i1, !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[V_R1:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:        scf.yield %[[V_R1]], %[[V_U]] : i1, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[V_8:[0-9a-zA-Z_\.]+]] = scf.if %[[V_5]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[V_5]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_10:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_N]], %[[V_9]])
// CHECK-NEXT:        %[[V_11:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[V_10]] -> (i1, !felt.type) {
// CHECK-NEXT:          %[[V_12:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_13:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I]], %[[V_12]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[V_R2:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[V_R2]], %[[V_13]] : i1, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[V_R3:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          scf.yield %[[V_R3]], %[[V_5]]#1 : i1, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_16:[0-9a-zA-Z_\.]+]] = scf.if %[[V_11]]#0 -> (!felt.type) {
// CHECK-NEXT:          scf.yield %[[V_11]]#1 : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[V_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[V_17]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        scf.yield %[[V_16]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_8]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @EarlyReturn<[]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[V_18:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_19:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn<[]>>
// CHECK-NEXT:        %[[V_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_21:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_18]], %[[V_20]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[V_19]][@outp] = %[[V_21]] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[V_19]] : !struct.type<@EarlyReturn<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[V_22:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn<[]>>, %[[V_23:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[V_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_25:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_23]], %[[V_24]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[V_26:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_22]][@outp] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_26]], %[[V_25]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
