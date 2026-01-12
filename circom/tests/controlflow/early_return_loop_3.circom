// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[V_IN:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      %[[V_R0:[0-9a-zA-Z_\.]+]] = undef.undef : !felt.type
// CHECK-NEXT:      %[[V_I0:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[V_F0:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:      %[[V_4:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[V_F1:[0-9a-zA-Z_\.]+]] = %[[V_F0]], %[[V_R1:[0-9a-zA-Z_\.]+]] = %[[V_R0]], %[[V_I1:[0-9a-zA-Z_\.]+]] = %[[V_I0]]) : (i1, !felt.type, !felt.type) -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[V_8:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[V_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[V_I1]], %[[V_8]])
// CHECK-NEXT:        scf.condition(%[[V_9]]) %[[V_F1]], %[[V_R1]], %[[V_I1]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[V_F2:[0-9a-zA-Z_\.]+]]: i1, %[[V_R2:[0-9a-zA-Z_\.]+]]: !felt.type, %[[V_I2:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[V_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[V_14:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[V_I2]], %[[V_13]])
// CHECK-NEXT:        %[[V_R3:[0-9a-zA-Z_\.]+]] = scf.if %[[V_14]] -> (!felt.type) {
// CHECK-NEXT:          %[[V_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[V_R4:[0-9a-zA-Z_\.]+]] = felt.add %[[V_IN]], %[[V_16]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_R4]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[V_18:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[V_R5:[0-9a-zA-Z_\.]+]] = felt.add %[[V_IN]], %[[V_18]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[V_R5]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[V_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[V_I3:[0-9a-zA-Z_\.]+]] = felt.add %[[V_I2]], %[[V_20]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[V_F3:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[V_F3]], %[[V_R3]], %[[V_I3]] : i1, !felt.type, !felt.type
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
// CHECK-NEXT:    struct.def @EarlyReturn<[]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[V_26:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[V_27:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn<[]>>
// CHECK-NEXT:        %[[V_28:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_26]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[V_27]][@outp] = %[[V_28]] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[V_27]] : !struct.type<@EarlyReturn<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[V_29:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn<[]>>, %[[V_30:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[V_31:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[V_30]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        %[[V_32:[0-9a-zA-Z_\.]+]] = struct.readf %[[V_29]][@outp] : <@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[V_32]], %[[V_31]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
