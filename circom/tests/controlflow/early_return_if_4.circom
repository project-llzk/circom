// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@EarlyReturn<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[V_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[V_U:[0-9a-zA-Z_\.]+]] = undef.undef : !felt.type
// CHECK-NEXT:      %[[V_X0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_3:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:      %[[V_4:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_0]], %[[V_3]])
// CHECK-NEXT:      %[[V_5:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[V_4]] -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[V_X1:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[V_R0:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:        scf.yield %[[V_R0]], %[[V_U]], %[[V_X1]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = felt.add %[[V_0]], %[[V_8]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_R1:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[V_R1]], %[[V_9]], %[[V_X0]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[V_11:[0-9a-zA-Z_\.]+]] = scf.if %[[V_5]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[V_5]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        scf.yield %[[V_5]]#2 : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[V_11]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @EarlyReturn<[]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[V_12:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn<[]>>
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_12]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[V_13]][@outp] = %[[V_14]] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[V_13]] : !struct.type<@EarlyReturn<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[V_15:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn<[]>>, %[[V_16:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[V_17:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_16]]) : (!felt.type) -> !felt.type
// CHECK-DAG:         %[[V_18:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_15]][@outp] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_18]], %[[V_17]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
