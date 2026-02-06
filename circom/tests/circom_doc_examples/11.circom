// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template T15() {
    signal output out;
    var y = 0;
    for(var i = 0; i < 100; i++){
        y++;
    }
    out <== y;
}

component main = T15();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@T15<[]>>} {
// CHECK-LABEL:   struct.def @T15<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@T15<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@T15<[]>>
// CHECK-NEXT:        %[[VAL_y_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_i_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_i_2:[0-9a-zA-Z_\.]+]] = %[[VAL_i_1]], %[[VAL_y_2:[0-9a-zA-Z_\.]+]] = %[[VAL_y_1]])
// CHECK-SAME:                                       : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  100
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_i_2]], %[[VAL_100]])
// CHECK-NEXT:          scf.condition(%[[VAL_4]]) %[[VAL_i_2]], %[[VAL_y_2]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_i_3:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_y_3:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_y_3]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_i_3]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_13]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_0]][@out] = %[[VAL_5]]#1 : <@T15<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@T15<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_15:[0-9a-zA-Z_\.]+]]: !struct.type<@T15<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_15]][@out] : <@T15<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_y_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_i_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_i_2:[0-9a-zA-Z_\.]+]] = %[[VAL_i_1]], %[[VAL_y_2:[0-9a-zA-Z_\.]+]] = %[[VAL_y_1]])
// CHECK-SAME:                                        : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  100
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_i_2]], %[[VAL_100]])
// CHECK-NEXT:          scf.condition(%[[VAL_19]]) %[[VAL_i_2]], %[[VAL_y_2]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_i_3:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_y_3:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_y_3]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_i_3]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_28]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_29]], %[[VAL_20]]#1 : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
