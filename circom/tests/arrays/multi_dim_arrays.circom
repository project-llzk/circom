// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Arrays() {
    var default_init[3][2][1];
    var inline_init[2][2] = [[1, 2], [3, 4]];
}

component main = Arrays();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Arrays::@Arrays<[]>>} {
// CHECK-NEXT:    poly.template @Arrays {
// CHECK-NEXT:      struct.def @Arrays {
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Arrays::@Arrays<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Arrays::@Arrays<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_3]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <2,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_3]]{{\[}}%[[VAL_5]]] = %[[VAL_2]] : <2,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.new  : <3,2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_6]]{{\[}}%[[VAL_7]]] = %[[VAL_3]] : <3,2,1 x !felt.type<"bn128">>, <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_6]]{{\[}}%[[VAL_8]]] = %[[VAL_3]] : <3,2,1 x !felt.type<"bn128">>, <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_6]]{{\[}}%[[VAL_9]]] = %[[VAL_3]] : <3,2,1 x !felt.type<"bn128">>, <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_10]], %[[VAL_10]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_12]]{{\[}}%[[VAL_13]]] = %[[VAL_11]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_12]]{{\[}}%[[VAL_14]]] = %[[VAL_11]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Arrays::@Arrays<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@Arrays::@Arrays<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_17]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_19]]{{\[}}%[[VAL_20]]] = %[[VAL_18]] : <2,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_19]]{{\[}}%[[VAL_21]]] = %[[VAL_18]] : <2,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.new  : <3,2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_22]]{{\[}}%[[VAL_23]]] = %[[VAL_19]] : <3,2,1 x !felt.type<"bn128">>, <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_22]]{{\[}}%[[VAL_24]]] = %[[VAL_19]] : <3,2,1 x !felt.type<"bn128">>, <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_22]]{{\[}}%[[VAL_25]]] = %[[VAL_19]] : <3,2,1 x !felt.type<"bn128">>, <2,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_26]], %[[VAL_26]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_28]]{{\[}}%[[VAL_29]]] = %[[VAL_27]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_28]]{{\[}}%[[VAL_30]]] = %[[VAL_27]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<2,2 x !felt.type<"bn128">> = [ 1 : <"bn128">,  2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">]
// CHECK-NEXT:  }
