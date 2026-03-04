// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@LargeToSmall<[]>>} {
// CHECK-NEXT:    struct.def @LargeToSmall<[]> {
// CHECK-NEXT:      struct.member @out : !array.type<2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@LargeToSmall<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@LargeToSmall<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  97
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  96
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  95
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_4]], %[[VAL_5]], %[[VAL_6]], %[[VAL_7]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_9]], %[[VAL_10]] : index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_11]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_9]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_10]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]] to %[[VAL_12]] step %[[VAL_14]] {
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_15]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_15]]] = %[[VAL_16]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_18]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_19]], %[[VAL_20]])
// CHECK-NEXT:        bool.assert %[[VAL_21]], "assertion failed"
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_23]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_24]], %[[VAL_25]])
// CHECK-NEXT:        bool.assert %[[VAL_26]], "assertion failed"
// CHECK-NEXT:        struct.writem %[[VAL_0]][@out] = %[[VAL_2]] : <@LargeToSmall<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@LargeToSmall<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@LargeToSmall<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@out] : <@LargeToSmall<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_29]], %[[VAL_29]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  97
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  96
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  95
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_31]], %[[VAL_32]], %[[VAL_33]], %[[VAL_34]], %[[VAL_35]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 5 : index
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_39]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_37]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_38]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]] to %[[VAL_40]] step %[[VAL_42]] {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_43]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:          array.write %[[VAL_30]]{{\[}}%[[VAL_43]]] = %[[VAL_44]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]]
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_46]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_47]], %[[VAL_48]])
// CHECK-NEXT:        bool.assert %[[VAL_49]], "assertion failed"
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]]
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_51]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_52]], %[[VAL_53]])
// CHECK-NEXT:        bool.assert %[[VAL_54]], "assertion failed"
// CHECK-NEXT:        constrain.eq %[[VAL_28]], %[[VAL_30]] : !array.type<2 x !felt.type>, !array.type<2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
