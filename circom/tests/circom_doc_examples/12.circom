// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template T16() {
    signal output out;
    var y = 0;
    var i = 0;
    while(i < 100){
        i++;
        y += y;
    }
    out <== y;
}

component main = T16();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@T16<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @T16<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      () -> !struct.type<@T16<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@T16<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_1]])
// CHECK-SAME:                                       : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  100
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_3]])
// CHECK-NEXT:          scf.condition(%[[VAL_4]]) %[[VAL_6]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_11]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_0]][@out] = %[[VAL_5]]#1 : <@T16<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@T16<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@T16<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_14]][@out] : <@T16<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_16]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_15]])
// CHECK-SAME:                                        : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  100
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_17]])
// CHECK-NEXT:          scf.condition(%[[VAL_18]]) %[[VAL_20]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_25]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_27]], %[[VAL_19]]#1 : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
