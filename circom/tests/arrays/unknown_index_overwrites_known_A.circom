// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template UnknownIndexOverwriteKnown() {
    signal input in;
    signal output out;

    var arr[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    arr[in] = 99;

    // NOTE: The compiler will not allow constraints to be generated using 'arr' since an
    // unknown index was used to assign a value within 'arr'. The following are not allowed:
    //      arr[in] === 99;
    //      arr[9] === 9;
    //      out <== arr[9];

    // We can however use assert statements...
    // Neither of the below can be known at compile time since index 'in' is overwritten.
    // In fact, either assert could fail in certain runs, depends on the value of 'in'.
    assert(arr[9] == 9);
    assert(arr[9] == 99);
}

component main = UnknownIndexOverwriteKnown();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @UnknownIndexOverwriteKnown<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@UnknownIndexOverwriteKnown<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_5]], %[[VAL_6]], %[[VAL_7]], %[[VAL_8]], %[[VAL_9]], %[[VAL_10]], %[[VAL_11]], %[[VAL_12]], %[[VAL_13]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_0]]
// CHECK-NEXT:        array.write %[[VAL_14]]{{\[}}%[[VAL_16]]] = %[[VAL_15]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]]
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_18]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_19]], %[[VAL_20]])
// CHECK-NEXT:        bool.assert %[[VAL_21]], "assertion failed"
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_23]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_24]], %[[VAL_25]])
// CHECK-NEXT:        bool.assert %[[VAL_26]], "assertion failed"
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@UnknownIndexOverwriteKnown<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@UnknownIndexOverwriteKnown<[]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]], %[[VAL_29]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  6
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  7
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  8
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_31]], %[[VAL_32]], %[[VAL_33]], %[[VAL_34]], %[[VAL_35]], %[[VAL_36]], %[[VAL_37]], %[[VAL_38]], %[[VAL_39]], %[[VAL_40]] : <10 x !felt.type>
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]]
// CHECK-NEXT:        array.write %[[VAL_41]]{{\[}}%[[VAL_43]]] = %[[VAL_42]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]]
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_45]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_46]], %[[VAL_47]])
// CHECK-NEXT:        bool.assert %[[VAL_48]], "assertion failed"
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  9
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]]
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_41]]{{\[}}%[[VAL_50]]] : <10 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  99
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_51]], %[[VAL_52]])
// CHECK-NEXT:        bool.assert %[[VAL_53]], "assertion failed"
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
