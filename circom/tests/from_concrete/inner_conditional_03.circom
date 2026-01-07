// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional3(N) {
    signal output out;
    signal input in;

    var acc = 0;
    for (var i = 1; i <= N; i++) {
        if (in == 0) { // unknown condition
            acc += i;
        } else {
            acc -= i;
        }
    }

    out <-- acc;
}

component main = InnerConditional3(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @InnerConditional3<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@InnerConditional3<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional3<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_6]], %[[VAL_7]])
// CHECK-NEXT:          scf.condition(%[[VAL_8]]) %[[VAL_5]], %[[VAL_6]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_11]])
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_12]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_2]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_14]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_2]], %[[VAL_3]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_16]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_13]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_4]]#0 : <@InnerConditional3<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@InnerConditional3<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional3<[]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_24]], %[[VAL_25]])
// CHECK-NEXT:          scf.condition(%[[VAL_26]]) %[[VAL_23]], %[[VAL_24]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_19]], %[[VAL_29]])
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_30]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_32]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_20]], %[[VAL_21]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_33]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_31]], %[[VAL_35]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_18]][@out] : <@InnerConditional3<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
