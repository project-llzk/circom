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
// CHECK-SAME:                          %[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type,
// CHECK-SAME:                          %[[VAL_1:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type {
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = undef.undef : !felt.type
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_1]], %[[VAL_3]])
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
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_1]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = function.call @Recurse(%[[VAL_0]], %[[VAL_11]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_12]] : !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_8]] : !felt.type
// CHECK-NEXT:    }
// CHECK-LABEL:   struct.def @FnAssign<[]> {
// CHECK-NEXT:      struct.field @outp : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@FnAssign<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@FnAssign<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @Recurse(%[[VAL_0]], %[[VAL_2]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@outp] = %[[VAL_3]] : <@FnAssign<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@FnAssign<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@FnAssign<[]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  20
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = function.call @Recurse(%[[VAL_5]], %[[VAL_6]]) : (!felt.type, !felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_4]][@outp] : <@FnAssign<[]>>, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_8]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
