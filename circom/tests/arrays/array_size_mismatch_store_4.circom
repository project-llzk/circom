// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// The circom compiler only gives a warning for this:
// warning[T3001]: Typing warning: Mismatched dimensions, assigning to an array an expression of greater length,
//                 the remaining positions of the expression are not assigned to the array.

template LargeToSmall() {
    signal output out[2];
    var temp[2] = [99, 98, 97, 96, 95];
    assert(temp[0] == 99);
    assert(temp[1] == 98);
    out <== temp;
}

component main = LargeToSmall();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@LargeToSmall::@LargeToSmall<[]>>} {
// CHECK-NEXT:    poly.template @LargeToSmall {
// CHECK-NEXT:      struct.def @LargeToSmall {
// CHECK-NEXT:        struct.member @out : !array.type<2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@LargeToSmall::@LargeToSmall<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@LargeToSmall::@LargeToSmall<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  98 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  97 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  96 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  95 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_4]], %[[VAL_5]], %[[VAL_6]], %[[VAL_7]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]] to %[[VAL_9]] step %[[VAL_11]] {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_12]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_12]]] = %[[VAL_13]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_15]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_16]], %[[VAL_17]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_18]], "assertion failed"
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_20]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  98 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_21]], %[[VAL_22]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_23]], "assertion failed"
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_2]] : <@LargeToSmall::@LargeToSmall<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@LargeToSmall::@LargeToSmall<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@LargeToSmall::@LargeToSmall<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@out] : <@LargeToSmall::@LargeToSmall<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_26]], %[[VAL_26]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  98 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  97 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  96 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  95 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_28]], %[[VAL_29]], %[[VAL_30]], %[[VAL_31]], %[[VAL_32]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_35]] to %[[VAL_34]] step %[[VAL_36]] {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_37]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_37]]] = %[[VAL_38]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_40]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_41]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_43]], "assertion failed"
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_45]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  98 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_46]], %[[VAL_47]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          bool.assert %[[VAL_48]], "assertion failed"
// CHECK-NEXT:          constrain.eq %[[VAL_25]], %[[VAL_27]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
