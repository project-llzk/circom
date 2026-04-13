// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerConditional3_0::@InnerConditional3_0<[]>>} {
// CHECK-NEXT:    poly.template @InnerConditional3_0 {
// CHECK-NEXT:      struct.def @InnerConditional3_0 {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@InnerConditional3_0::@InnerConditional3_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional3_0::@InnerConditional3_0<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_7]], %[[VAL_8]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_6]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_12]]) : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!felt.type) {
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_15]] : !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_10]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_16]] : !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_14]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_5]]#0 : <@InnerConditional3_0::@InnerConditional3_0<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@InnerConditional3_0::@InnerConditional3_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional3_0::@InnerConditional3_0<[]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out] : <@InnerConditional3_0::@InnerConditional3_0<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_23]], %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_24]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_27]], %[[VAL_28]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_29]]) %[[VAL_26]], %[[VAL_27]] : !felt.type, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_20]], %[[VAL_32]]) : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_33]] -> (!felt.type) {
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_35]] : !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_30]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_36]] : !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_37]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_34]], %[[VAL_38]] : !felt.type, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
