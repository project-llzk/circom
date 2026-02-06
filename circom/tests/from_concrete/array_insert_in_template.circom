// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function default_init() {
    var out[3][2];
    return out;
}

template Main() {
    var a[3][2] = default_init();
}

component main = Main();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Main_0<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   function.def @default_init_0() -> !array.type<3,2 x !felt.type> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_0:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,2 x !felt.type>
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type>
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]]
// CHECK-NEXT:      array.write %[[VAL_1]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]]
// CHECK-NEXT:      array.write %[[VAL_1]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:      %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:      array.insert %[[VAL_0]]{{\[}}%[[VAL_9]]] = %[[VAL_1]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]]
// CHECK-NEXT:      array.insert %[[VAL_0]]{{\[}}%[[VAL_11]]] = %[[VAL_1]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:      %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]]
// CHECK-NEXT:      array.insert %[[VAL_0]]{{\[}}%[[VAL_13]]] = %[[VAL_1]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:      function.return %[[VAL_0]] : !array.type<3,2 x !felt.type>
// CHECK-NEXT:    }
// CHECK-LABEL:   struct.def @Main_0<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Main_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_0<[]>>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]]
// CHECK-NEXT:        array.write %[[VAL_16]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]]
// CHECK-NEXT:        array.write %[[VAL_16]]{{\[}}%[[VAL_22]]] = %[[VAL_20]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]]
// CHECK-NEXT:        array.insert %[[VAL_15]]{{\[}}%[[VAL_24]]] = %[[VAL_16]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:        array.insert %[[VAL_15]]{{\[}}%[[VAL_26]]] = %[[VAL_16]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]]
// CHECK-NEXT:        array.insert %[[VAL_15]]{{\[}}%[[VAL_28]]] = %[[VAL_16]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @default_init_0() : () -> !array.type<3,2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_14]] : !struct.type<@Main_0<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]]
// CHECK-NEXT:        array.write %[[VAL_32]]{{\[}}%[[VAL_35]]] = %[[VAL_33]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]]
// CHECK-NEXT:        array.write %[[VAL_32]]{{\[}}%[[VAL_38]]] = %[[VAL_36]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]]
// CHECK-NEXT:        array.insert %[[VAL_31]]{{\[}}%[[VAL_40]]] = %[[VAL_32]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]]
// CHECK-NEXT:        array.insert %[[VAL_31]]{{\[}}%[[VAL_42]]] = %[[VAL_32]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]]
// CHECK-NEXT:        array.insert %[[VAL_31]]{{\[}}%[[VAL_44]]] = %[[VAL_32]] : <3,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @default_init_0() : () -> !array.type<3,2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
