// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    var x = 0;
    if (in < 10) {
        if (in == 0) {
            return in + 1;
        } else {
            x = 2;
        }
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
// CHECK-NEXT:    function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  10
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_0]], %[[VAL_3]]) : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_4]] -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_6]]) : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_7]] -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_11]], %[[VAL_10]], %[[VAL_2]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          scf.yield %[[VAL_13]], %[[VAL_1]], %[[VAL_12]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]]:3 = scf.if %[[VAL_8]]#0 -> (i1, !felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_15]], %[[VAL_8]]#1, %[[VAL_16]] : i1, !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          scf.yield %[[VAL_17]], %[[VAL_1]], %[[VAL_8]]#2 : i1, !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        scf.yield %[[VAL_14]]#0, %[[VAL_14]]#1, %[[VAL_14]]#2 : i1, !felt.type, !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[VAL_20]], %[[VAL_19]], %[[VAL_2]] : i1, !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[VAL_5]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        scf.yield %[[VAL_5]]#2 : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_21]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_22]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_23]][@outp] = %[[VAL_24]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_23]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:           %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-DAG:           %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_26]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_27]], %[[VAL_28]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
