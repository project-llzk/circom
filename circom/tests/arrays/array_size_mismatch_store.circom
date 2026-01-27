// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// The circom compiler only gives a warning for this:
// warning[T3001]: Typing warning: Mismatched dimensions, assigning to an array an expression of smaller length, the remaining positions are assigned to 0.

template ImplicitExtension() {
    signal output out[10];
    var temp[10] = [99, 98, 97, 96, 95];
    out[0] <-- temp[0];
    out[4] <-- temp[4];
    out[5] <-- temp[5];
    out[9] <-- temp[9];
}

component main = ImplicitExtension();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @ImplicitExtension<[]> {
// CHECK-NEXT:      struct.field @out : !array.type<10 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@ImplicitExtension<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ImplicitExtension<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<10 x !felt.type>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  97
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  96
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  95
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_5]], %[[VAL_6]], %[[VAL_7]], %[[VAL_8]] : <5 x !felt.type>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]]
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_11]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_14]]] = %[[VAL_12]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_16]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]]
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_21]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]]
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_24]]] = %[[VAL_22]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_26]]] : <5 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]]
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_29]]] = %[[VAL_27]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_0]][@out] = %[[VAL_1]] : <@ImplicitExtension<[]>>, !array.type<10 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@ImplicitExtension<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@ImplicitExtension<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_31]], %[[VAL_31]], %[[VAL_31]], %[[VAL_31]], %[[VAL_31]], %[[VAL_31]], %[[VAL_31]], %[[VAL_31]], %[[VAL_31]], %[[VAL_31]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  98
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  97
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  96
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  95
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_33]], %[[VAL_34]], %[[VAL_35]], %[[VAL_36]], %[[VAL_37]] : <5 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
