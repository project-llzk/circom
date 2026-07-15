// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template TestSetAllUnknownWithinUnknownCondition(k) {
    signal input in;
    var ret[10];

    if (in == 1) {
        for (var i = 0; i < k; i++) {
            ret[i] = 8;
        }
    }
    var x = ret[0];
}

component main = TestSetAllUnknownWithinUnknownCondition(1);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@TestSetAllUnknownWithinUnknownCondition::@TestSetAllUnknownWithinUnknownCondition<[1]>>} {
// CHECK-NEXT:    poly.template @TestSetAllUnknownWithinUnknownCondition {
// CHECK-NEXT:      poly.param @k : index
// CHECK-NEXT:      struct.def @TestSetAllUnknownWithinUnknownCondition {
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@TestSetAllUnknownWithinUnknownCondition::@TestSetAllUnknownWithinUnknownCondition<[@k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@TestSetAllUnknownWithinUnknownCondition::@TestSetAllUnknownWithinUnknownCondition<[@k]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @k : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_6]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_7]] -> (!array.type<10 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_9]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>) {
// CHECK-NEXT:              %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_11]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_13]]) %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">>):
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_15]]{{\[}}%[[VAL_17]]] = %[[VAL_16]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_19]], %[[VAL_15]] : !felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_10]]#1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_5]] : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_21]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@TestSetAllUnknownWithinUnknownCondition::@TestSetAllUnknownWithinUnknownCondition<[@k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@TestSetAllUnknownWithinUnknownCondition::@TestSetAllUnknownWithinUnknownCondition<[@k]>>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @k : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_25]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_27]], %[[VAL_27]], %[[VAL_27]], %[[VAL_27]], %[[VAL_27]], %[[VAL_27]], %[[VAL_27]], %[[VAL_27]], %[[VAL_27]], %[[VAL_27]] : <10 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_24]], %[[VAL_29]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_30]] -> (!array.type<10 x !felt.type<"bn128">>) {
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]], %[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_28]]) : (!felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>) {
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_26]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_36]]) %[[VAL_34]], %[[VAL_35]] : !felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">>):
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_38]]{{\[}}%[[VAL_40]]] = %[[VAL_39]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_37]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_42]], %[[VAL_38]] : !felt.type<"bn128">, !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_33]]#1 : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_28]] : !array.type<10 x !felt.type<"bn128">>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_44]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
