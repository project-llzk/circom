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
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_8]], %[[VAL_9]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_11]] to %[[VAL_13]] step %[[VAL_12]] {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_14]], %[[VAL_10]] : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_15]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_14]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_18]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_14]]] = %[[VAL_16]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_20]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_21]], %[[VAL_22]])
// CHECK-NEXT:        bool.assert %[[VAL_23]], "assertion failed"
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]]
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_25]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_26]], %[[VAL_27]])
// CHECK-NEXT:        bool.assert %[[VAL_28]], "assertion failed"
// CHECK-NEXT:        struct.writem %[[VAL_0]][@out] = %[[VAL_2]] : <@LargeToSmall<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@LargeToSmall<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_29:[0-9a-zA-Z_\.]+]]: !struct.type<@LargeToSmall<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@out] : <@LargeToSmall<[]>>, !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_31]], %[[VAL_31]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  97
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  96
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  95
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_33]], %[[VAL_34]], %[[VAL_35]], %[[VAL_36]], %[[VAL_37]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_38]], %[[VAL_39]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        scf.for %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_41]] to %[[VAL_43]] step %[[VAL_42]] {
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_44]], %[[VAL_40]] : index
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_45]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_44]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_47]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            scf.yield %[[VAL_48]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          array.write %[[VAL_32]]{{\[}}%[[VAL_44]]] = %[[VAL_46]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]]
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_50]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_51]], %[[VAL_52]])
// CHECK-NEXT:        bool.assert %[[VAL_53]], "assertion failed"
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]]
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_32]]{{\[}}%[[VAL_55]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_56]], %[[VAL_57]])
// CHECK-NEXT:        bool.assert %[[VAL_58]], "assertion failed"
// CHECK-NEXT:        constrain.eq %[[VAL_30]], %[[VAL_32]] : !array.type<2 x !felt.type>, !array.type<2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
