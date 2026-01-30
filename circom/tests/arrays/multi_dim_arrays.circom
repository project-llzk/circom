// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Arrays() {
    var default_init[3][2][1];
    var inline_init[2][2] = [[1, 2], [3, 4]];
}

component main = Arrays();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Arrays<[]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Arrays<[]> {
// CHECK-NEXT:      function.def @compute() -> !struct.type<@Arrays<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Arrays<[]>>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]] : <1 x !felt.type>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <2,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_3]]{{\[}}%[[VAL_5]]] = %[[VAL_2]] : <2,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = array.new  : <3,2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_6]]{{\[}}%[[VAL_7]]] = %[[VAL_3]] : <3,2,1 x !felt.type>, <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_6]]{{\[}}%[[VAL_8]]] = %[[VAL_3]] : <3,2,1 x !felt.type>, <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        array.insert %[[VAL_6]]{{\[}}%[[VAL_9]]] = %[[VAL_3]] : <3,2,1 x !felt.type>, <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_10]], %[[VAL_10]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_12]]{{\[}}%[[VAL_13]]] = %[[VAL_11]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_12]]{{\[}}%[[VAL_14]]] = %[[VAL_11]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_15]], %[[VAL_16]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_18]], %[[VAL_19]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_21]]{{\[}}%[[VAL_22]]] = %[[VAL_17]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_21]]{{\[}}%[[VAL_23]]] = %[[VAL_20]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_0]] : !struct.type<@Arrays<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@Arrays<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_25]] : <1 x !felt.type>
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new  : <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_27]]{{\[}}%[[VAL_28]]] = %[[VAL_26]] : <2,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_27]]{{\[}}%[[VAL_29]]] = %[[VAL_26]] : <2,1 x !felt.type>, <1 x !felt.type>
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.new  : <3,2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_30]]{{\[}}%[[VAL_31]]] = %[[VAL_27]] : <3,2,1 x !felt.type>, <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_30]]{{\[}}%[[VAL_32]]] = %[[VAL_27]] : <3,2,1 x !felt.type>, <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        array.insert %[[VAL_30]]{{\[}}%[[VAL_33]]] = %[[VAL_27]] : <3,2,1 x !felt.type>, <2,1 x !felt.type>
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_34]], %[[VAL_34]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_36]]{{\[}}%[[VAL_37]]] = %[[VAL_35]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_36]]{{\[}}%[[VAL_38]]] = %[[VAL_35]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_39]], %[[VAL_40]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_42]], %[[VAL_43]] : <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type>
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_45]]{{\[}}%[[VAL_46]]] = %[[VAL_41]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_45]]{{\[}}%[[VAL_47]]] = %[[VAL_44]] : <2,2 x !felt.type>, <2 x !felt.type>
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
