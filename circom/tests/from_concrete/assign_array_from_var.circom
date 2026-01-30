// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Template() {
    var m[2][2] = [[0, 1], [2, 3]];
    signal output ret[2][2] <== m;
}

component main = Template();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Template<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Template<[]> {
// CHECK-NEXT:      struct.field @ret : !array.type<2,2 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Template<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Template<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_4]]
// CHECK-NEXT:        array.write %[[VAL_2]]{{\[}}%[[VAL_5]]] = %[[VAL_3]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]]
// CHECK-NEXT:        array.write %[[VAL_2]]{{\[}}%[[VAL_8]]] = %[[VAL_6]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:        array.insert %[[VAL_1]]{{\[}}%[[VAL_10]]] = %[[VAL_2]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]]
// CHECK-NEXT:        array.insert %[[VAL_1]]{{\[}}%[[VAL_12]]] = %[[VAL_2]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:        array.write %[[VAL_13]]{{\[}}%[[VAL_16]]] = %[[VAL_14]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-NEXT:        array.write %[[VAL_13]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]]
// CHECK-NEXT:        array.write %[[VAL_20]]{{\[}}%[[VAL_23]]] = %[[VAL_21]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:        array.write %[[VAL_20]]{{\[}}%[[VAL_26]]] = %[[VAL_24]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]]
// CHECK-NEXT:        array.insert %[[VAL_1]]{{\[}}%[[VAL_28]]] = %[[VAL_13]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]]
// CHECK-NEXT:        array.insert %[[VAL_1]]{{\[}}%[[VAL_30]]] = %[[VAL_20]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        struct.writef %[[VAL_0]][@ret] = %[[VAL_1]] : <@Template<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Template<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !struct.type<@Template<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_31]][@ret] : <@Template<[]>>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]]
// CHECK-NEXT:        array.write %[[VAL_33]]{{\[}}%[[VAL_36]]] = %[[VAL_34]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]]
// CHECK-NEXT:        array.write %[[VAL_33]]{{\[}}%[[VAL_39]]] = %[[VAL_37]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-NEXT:        array.insert %[[VAL_32]]{{\[}}%[[VAL_41]]] = %[[VAL_33]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]]
// CHECK-NEXT:        array.insert %[[VAL_32]]{{\[}}%[[VAL_43]]] = %[[VAL_33]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]]
// CHECK-NEXT:        array.write %[[VAL_44]]{{\[}}%[[VAL_47]]] = %[[VAL_45]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]]
// CHECK-NEXT:        array.write %[[VAL_44]]{{\[}}%[[VAL_50]]] = %[[VAL_48]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]]
// CHECK-NEXT:        array.write %[[VAL_51]]{{\[}}%[[VAL_54]]] = %[[VAL_52]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]]
// CHECK-NEXT:        array.write %[[VAL_51]]{{\[}}%[[VAL_57]]] = %[[VAL_55]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]]
// CHECK-NEXT:        array.insert %[[VAL_32]]{{\[}}%[[VAL_59]]] = %[[VAL_44]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]]
// CHECK-NEXT:        array.insert %[[VAL_32]]{{\[}}%[[VAL_61]]] = %[[VAL_51]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        constrain.eq %[[VAL_62]], %[[VAL_32]] : !array.type<2,2 x !felt.type>, !array.type<2,2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
