// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@TestSetAllUnknownWithinUnknownCondition<[1]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @TestSetAllUnknownWithinUnknownCondition<[@k]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@TestSetAllUnknownWithinUnknownCondition<[@k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@TestSetAllUnknownWithinUnknownCondition<[@k]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]], %[[VAL_3]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_0]], %[[VAL_5]])
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_6]] -> (!array.type<10 x !felt.type>) {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type, !array.type<10 x !felt.type>) -> (!felt.type, !array.type<10 x !felt.type>) {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_10]], %[[VAL_2]])
// CHECK-NEXT:            scf.condition(%[[VAL_12]]) %[[VAL_10]], %[[VAL_11]] : !felt.type, !array.type<10 x !felt.type>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>):
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:            array.write %[[VAL_14]]{{\[}}%[[VAL_16]]] = %[[VAL_15]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_18]], %[[VAL_14]] : !felt.type, !array.type<10 x !felt.type>
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_9]]#1 : !array.type<10 x !felt.type>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_4]] : !array.type<10 x !felt.type>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_20]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@TestSetAllUnknownWithinUnknownCondition<[@k]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !struct.type<@TestSetAllUnknownWithinUnknownCondition<[@k]>>, %[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_25]], %[[VAL_25]], %[[VAL_25]], %[[VAL_25]], %[[VAL_25]], %[[VAL_25]], %[[VAL_25]], %[[VAL_25]], %[[VAL_25]], %[[VAL_25]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_23]], %[[VAL_27]])
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_28]] -> (!array.type<10 x !felt.type>) {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_30]], %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!felt.type, !array.type<10 x !felt.type>) -> (!felt.type, !array.type<10 x !felt.type>) {
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_24]])
// CHECK-NEXT:            scf.condition(%[[VAL_34]]) %[[VAL_32]], %[[VAL_33]] : !felt.type, !array.type<10 x !felt.type>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type>):
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]]
// CHECK-NEXT:            array.write %[[VAL_36]]{{\[}}%[[VAL_38]]] = %[[VAL_37]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_40]], %[[VAL_36]] : !felt.type, !array.type<10 x !felt.type>
// CHECK-NEXT:          }
// CHECK-NEXT:          scf.yield %[[VAL_31]]#1 : !array.type<10 x !felt.type>
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_26]] : !array.type<10 x !felt.type>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]]
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_42]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
