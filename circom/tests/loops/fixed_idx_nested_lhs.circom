// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template FixIdxNested() {
    var arr[9] = [8, 7, 6, 5, 4, 3, 2, 1, 0];
    signal out[9];
    for (var i = 0; i < 9; i++) {
        out[arr[i]] <-- arr[i];
    }
}

component main = FixIdxNested();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@FixIdxNested::@FixIdxNested<[]>>} {
// CHECK-NEXT:    poly.template @FixIdxNested {
// CHECK-NEXT:      struct.def @FixIdxNested {
// CHECK-NEXT:        struct.member @out : !array.type<9 x !felt.type>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@FixIdxNested::@FixIdxNested<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@FixIdxNested::@FixIdxNested<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<9 x !felt.type>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <9 x !felt.type>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_5]], %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]], %[[VAL_12]] : <9 x !felt.type>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_14]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_17]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_18]]) %[[VAL_16]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_20]]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_13]]{{\[}}%[[VAL_22]]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_24]]] = %[[VAL_21]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_25]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_26]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_1]] : <@FixIdxNested::@FixIdxNested<[]>>, !array.type<9 x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@FixIdxNested::@FixIdxNested<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@FixIdxNested::@FixIdxNested<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@out] : <@FixIdxNested::@FixIdxNested<[]>>, !array.type<9 x !felt.type>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]] : <9 x !felt.type>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_31]], %[[VAL_32]], %[[VAL_33]], %[[VAL_34]], %[[VAL_35]], %[[VAL_36]], %[[VAL_37]], %[[VAL_38]], %[[VAL_39]] : <9 x !felt.type>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_43]], %[[VAL_44]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_45]]) %[[VAL_43]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_48]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
