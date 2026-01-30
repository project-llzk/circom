// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template T14() {
    signal output out;
    var x = 0;
    var y = 1;
    if (x >= 0) {
        x = y + 1;
        y += 1;
    } else {
        y = x;
    }
    out <== x + y;
}

component main = T14();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@T14<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @T14<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@T14<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@T14<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_1]], %[[VAL_3]])
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_4]] -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_7]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_1]], %[[VAL_1]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_5]]#0, %[[VAL_5]]#1 : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_0]][@out] = %[[VAL_10]] : <@T14<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@T14<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_12:[0-9a-zA-Z_\.]+]]: !struct.type<@T14<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_12]][@out] : <@T14<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_13]], %[[VAL_15]])
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_16]] -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_19]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_13]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]]#0, %[[VAL_17]]#1 : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_24]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
