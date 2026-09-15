// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Main_0::@Main_0<[]>>} {
// CHECK-NEXT:    poly.template @default_init_0 {
// CHECK-NEXT:      function.def @default_init_0() -> !array.type<3,2 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_0]]{{\[}}%[[VAL_3]]] = %[[VAL_1]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_4]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_0]]{{\[}}%[[VAL_5]]] = %[[VAL_1]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_0]]{{\[}}%[[VAL_7]]] = %[[VAL_1]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:        function.return %[[VAL_0]] : !array.type<3,2 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    poly.template @Main_0 {
// CHECK-NEXT:      struct.def @Main_0 {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Main_0::@Main_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.new : <@Main_0::@Main_0<[]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_10]]{{\[}}%[[VAL_13]]] = %[[VAL_11]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_10]]{{\[}}%[[VAL_16]]] = %[[VAL_14]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_9]]{{\[}}%[[VAL_18]]] = %[[VAL_10]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_9]]{{\[}}%[[VAL_20]]] = %[[VAL_10]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_9]]{{\[}}%[[VAL_22]]] = %[[VAL_10]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @default_init_0::@default_init_0() : () -> !array.type<3,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_8]] : !struct.type<@Main_0::@Main_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@Main_0::@Main_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_26]]{{\[}}%[[VAL_29]]] = %[[VAL_27]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_26]]{{\[}}%[[VAL_32]]] = %[[VAL_30]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_25]]{{\[}}%[[VAL_34]]] = %[[VAL_26]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_25]]{{\[}}%[[VAL_36]]] = %[[VAL_26]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_25]]{{\[}}%[[VAL_38]]] = %[[VAL_26]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @default_init_0::@default_init_0() : () -> !array.type<3,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
