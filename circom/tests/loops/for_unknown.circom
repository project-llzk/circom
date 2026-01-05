// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ForUnknown() {
    signal input in;
    signal output out;

    var acc = 0;
    for (var i = 1; i <= in; i++) {
        acc += i;
    }

    out <-- acc;
}

component main = ForUnknown();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @ForUnknown<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@ForUnknown<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ForUnknown<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]])
// CHECK-SAME:                                       : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_7]], %[[VAL_0]])
// CHECK-NEXT:          scf.condition(%[[VAL_4]]) %[[VAL_6]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_10]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_5]]#0 : <@ForUnknown<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@ForUnknown<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknown<[]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_16]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_17]])
// CHECK-SAME:                                        : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_21]], %[[VAL_15]])
// CHECK-NEXT:          scf.condition(%[[VAL_18]]) %[[VAL_20]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_24]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_14]][@out] : <@ForUnknown<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
