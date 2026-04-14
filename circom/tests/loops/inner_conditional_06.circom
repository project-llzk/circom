// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional6(N) {
    signal output out[N];
    signal input in[N];

    for (var i = 0; i < N; i++) {
        var x;
        if (in[i] == 0) {
            x = 999;
        } else {
            x = 888;
        }
        out[i] <-- x;
    }
}

component main = InnerConditional6(4);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@InnerConditional6::@InnerConditional6<[4]>>} {
// CHECK-NEXT:    poly.template @InnerConditional6 {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @InnerConditional6 {
// CHECK-NEXT:        struct.member @out : !array.type<@N x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>) -> !struct.type<@InnerConditional6::@InnerConditional6<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional6::@InnerConditional6<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_11]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:              scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_17]]] = %[[VAL_14]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@InnerConditional6::@InnerConditional6<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@InnerConditional6::@InnerConditional6<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional6::@InnerConditional6<[@N]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@out] : <@InnerConditional6::@InnerConditional6<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_24]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_26]], %[[VAL_22]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_27]]) %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_30]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_31]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_33]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  999
// CHECK-NEXT:              scf.yield %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  888
// CHECK-NEXT:              scf.yield %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
