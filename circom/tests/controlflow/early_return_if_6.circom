// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@EarlyReturn<[]>>} {
// CHECK-NEXT:    function.def @earlyReturnFn(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_3]]) : !felt.type, !felt.type
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_4]] -> (i1, !felt.type) {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[VAL_6]], %[[VAL_0]] : i1, !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:        scf.yield %[[VAL_7]], %[[VAL_2]] : i1, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_8:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_5]]#0 -> (!felt.type) {
// CHECK-NEXT:        scf.yield %[[VAL_5]]#1 : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_9]]) : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_10]] -> (i1, !felt.type) {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_0]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:          scf.yield %[[VAL_14]], %[[VAL_13]] : i1, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant false
// CHECK-NEXT:          scf.yield %[[VAL_15]], %[[VAL_5]]#1 : i1, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_11]]#0 -> (!felt.type) {
// CHECK-NEXT:          scf.yield %[[VAL_11]]#1 : !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          scf.yield %[[VAL_17]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        scf.yield %[[VAL_16]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_8]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @EarlyReturn {
// CHECK-NEXT:      struct.def @EarlyReturn {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@EarlyReturn::@EarlyReturn<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.new : <@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_18]], %[[VAL_20]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_19]][@outp] = %[[VAL_21]] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_19]] : !struct.type<@EarlyReturn::@EarlyReturn<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@EarlyReturn::@EarlyReturn<[]>>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_22]][@outp] : <@EarlyReturn::@EarlyReturn<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @earlyReturnFn(%[[VAL_23]], %[[VAL_25]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
