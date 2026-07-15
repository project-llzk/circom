// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template VariantIndex(n) {
    signal input in;
    signal output out;

    var temp[n];
    for (var i = 0; i<n; i++) {
        temp[i] = (in >> i);
    }
    out <-- temp[0] + temp[1];
}

component main = VariantIndex(2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@VariantIndex::@VariantIndex<[2]>>} {
// CHECK-NEXT:    poly.template @VariantIndex {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @VariantIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@VariantIndex::@VariantIndex<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@VariantIndex::@VariantIndex<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_5]], %[[VAL_6]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_8]] to %[[VAL_7]] step %[[VAL_9]] {
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_10]]] = %[[VAL_4]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_11]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>):
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_0]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_19]]] = %[[VAL_18]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_20]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_21]], %[[VAL_17]] : !felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]#1{{\[}}%[[VAL_23]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]#1{{\[}}%[[VAL_26]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_28]] : <@VariantIndex::@VariantIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@VariantIndex::@VariantIndex<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@VariantIndex::@VariantIndex<[@n]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_31]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@VariantIndex::@VariantIndex<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_35]], %[[VAL_36]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]] to %[[VAL_37]] step %[[VAL_39]] {
// CHECK-NEXT:            array.write %[[VAL_35]]{{\[}}%[[VAL_40]]] = %[[VAL_34]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]], %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_35]]) : (!felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_43]], %[[VAL_32]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_45]]) %[[VAL_43]], %[[VAL_44]] : !felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>):
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_30]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_47]]{{\[}}%[[VAL_49]]] = %[[VAL_48]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_51]], %[[VAL_47]] : !felt.type<"bn128">, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
