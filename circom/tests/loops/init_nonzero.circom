// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Ensure that non-zero initialization of for-loop iteration variable is handled properly.
template NonZeroInit() {
    signal input a[9];
    signal output b[9];

    for (var i = 4; i < 7; i++) {
        b[i] <-- a[i];
    }
    for (var i = 7; i < 9; i++) {
        b[i] <-- a[i];
    }
    for (var i = 0; i < 4; i++) {
        b[i] <-- a[i];
    }
}

component main = NonZeroInit();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @NonZeroInit<[]> {
// CHECK-NEXT:      struct.field @b : !array.type<9 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<9 x !felt.type>) -> !struct.type<@NonZeroInit<[]>> attributes {function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@NonZeroInit<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<9 x !felt.type>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_5]], %[[VAL_6]])
// CHECK-NEXT:          scf.condition(%[[VAL_7]]) %[[VAL_5]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_9]]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_11]]] = %[[VAL_10]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_14]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_17]])
// CHECK-NEXT:          scf.condition(%[[VAL_18]]) %[[VAL_16]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_20]]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_22]]] = %[[VAL_21]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_24]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_25]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_27]], %[[VAL_28]])
// CHECK-NEXT:          scf.condition(%[[VAL_29]]) %[[VAL_27]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]]
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_31]]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]]
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_33]]] = %[[VAL_32]] : <9 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_30]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_35]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@b] = %[[VAL_2]] : <@NonZeroInit<[]>>, !array.type<9 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@NonZeroInit<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !struct.type<@NonZeroInit<[]>>, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<9 x !felt.type>) attributes {function.allow_constraint} {
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_40]], %[[VAL_41]])
// CHECK-NEXT:          scf.condition(%[[VAL_42]]) %[[VAL_40]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_44]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_45]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_48:[0-9a-zA-Z_\.]+]] = %[[VAL_46]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_48]], %[[VAL_49]])
// CHECK-NEXT:          scf.condition(%[[VAL_50]]) %[[VAL_48]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_51:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_52]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_53]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_54]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_56]], %[[VAL_57]])
// CHECK-NEXT:          scf.condition(%[[VAL_58]]) %[[VAL_56]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_59]], %[[VAL_60]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_61]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
