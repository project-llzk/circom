// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @Recurse(
// CHECK-SAME:                          %[[VAL_0:.*]]: !felt.type,
// CHECK-SAME:                          %[[VAL_1:.*]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      %[[VAL_2:.*]] = undef.undef : !felt.type
// CHECK-NEXT:      %[[VAL_3:.*]] = felt.const  0
// CHECK-NEXT:      %[[VAL_4:.*]] = bool.cmp eq(%[[VAL_1]], %[[VAL_3]])
// CHECK-NEXT:      %[[VAL_5:.*]]:2 = scf.if %[[VAL_4]] -> (i1, !felt.type) {
// CHECK-NEXT:        %[[VAL_6:.*]] = arith.constant false
// CHECK-NEXT:        scf.yield %[[VAL_6]], %[[VAL_0]] : i1, !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        %[[VAL_7:.*]] = arith.constant true
// CHECK-NEXT:        scf.yield %[[VAL_7]], %[[VAL_2]] : i1, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      %[[VAL_8:.*]] = scf.if %[[VAL_9:.*]]#0 -> (!felt.type) {
// CHECK-NEXT:        %[[VAL_10:.*]] = felt.const  1
// CHECK-NEXT:        %[[VAL_11:.*]] = felt.sub %[[VAL_1]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_12:.*]] = function.call @Recurse(%[[VAL_0]], %[[VAL_11]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_12]] : !felt.type
// CHECK-NEXT:      } else {
// CHECK-NEXT:        scf.yield %[[VAL_13:.*]]#1 : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_8]] : !felt.type
// CHECK-NEXT:    }

// CHECK-LABEL:   struct.def @FnAssign<[]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:.*]]: !felt.type) -> !struct.type<@FnAssign<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:.*]] = struct.new : <@FnAssign<[]>>
// CHECK-NEXT:        %[[VAL_2:.*]] = felt.const  20
// CHECK-NEXT:        %[[VAL_3:.*]] = function.call @Recurse(%[[VAL_0]], %[[VAL_2]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@outp] = %[[VAL_3]] : <@FnAssign<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@FnAssign<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_4:.*]]: !struct.type<@FnAssign<[]>>, %[[VAL_5:.*]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_6:.*]] = felt.const  20
// CHECK-NEXT:        %[[VAL_7:.*]] = function.call @Recurse(%[[VAL_5]], %[[VAL_6]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_8:.*]] = struct.readf %[[VAL_4]][@outp] : <@FnAssign<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT: }
