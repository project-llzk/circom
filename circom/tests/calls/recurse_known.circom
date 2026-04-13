// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function Recurse(i, n) {
    if (n == 0) {
        return i;
    }
    return Recurse(i, n-1);
}

template FnAssign() {
    signal input inp;
    signal output outp;

    outp <== Recurse(inp, 20);
}

component main = FnAssign();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@FnAssign::@FnAssign<[]>>} {
// CHECK-NEXT:    function.def @Recurse(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
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
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_1]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = function.call @Recurse(%[[VAL_0]], %[[VAL_10]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_11]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_8]] : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @FnAssign {
// CHECK-NEXT:      struct.def @FnAssign {
// CHECK-NEXT:        struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@FnAssign::@FnAssign<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@FnAssign::@FnAssign<[]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @Recurse(%[[VAL_12]], %[[VAL_14]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_13]][@outp] = %[[VAL_15]] : <@FnAssign::@FnAssign<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@FnAssign::@FnAssign<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@FnAssign::@FnAssign<[]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@outp] : <@FnAssign::@FnAssign<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = function.call @Recurse(%[[VAL_17]], %[[VAL_19]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_18]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
