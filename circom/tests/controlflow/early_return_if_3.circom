// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    if (in < 10) {
        if (in == 0) {
            return in + 1;
        } else {
            return in + 2;
        }
    } else {
        return in + 3;
    }
    return -1; // Syntactically unreachable because all branches above return
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EarlyReturn::@EarlyReturn<[]>>} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_1]]) : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_2]] -> (!felt.type) {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_4]]) : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]] -> (!felt.type) {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_8]] : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_10]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        scf.yield %[[VAL_6]] : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_12]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_3]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_13]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_14]][@outp] = %[[VAL_15]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_14]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:           %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-DAG:           %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_17]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_18]], %[[VAL_19]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
