// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template SimpleVariantIdx(n) {
    signal input in;
    signal output out[n];

	var lc;
    for (var i = 0; i < n; i++) {
        out[i] <-- in;
        lc = out[i];
    }
}

component main = SimpleVariantIdx(3);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SimpleVariantIdx::@SimpleVariantIdx<[3]>>} {
// CHECK-NEXT:    poly.template @SimpleVariantIdx {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @SimpleVariantIdx {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@SimpleVariantIdx::@SimpleVariantIdx<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@SimpleVariantIdx::@SimpleVariantIdx<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_12]]] = %[[VAL_0]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_13]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@SimpleVariantIdx::@SimpleVariantIdx<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@SimpleVariantIdx::@SimpleVariantIdx<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@SimpleVariantIdx::@SimpleVariantIdx<[@n]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@SimpleVariantIdx::@SimpleVariantIdx<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]], %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_24]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_29]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
