// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayShenanigans() {
   var x[2][2];
   var y[1][3] = [[9,8,7]];
   x = y;
   signal output outp[2][2] <== x;
}

component main = ArrayShenanigans();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>} {
// CHECK-NEXT:    poly.template @ArrayShenanigans {
// CHECK-NEXT:      struct.def @ArrayShenanigans {
// CHECK-NEXT:        struct.member @outp : !array.type<2,2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_1]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_3]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_3]]{{\[}}%[[VAL_5]]] = %[[VAL_2]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_6]], %[[VAL_6]], %[[VAL_6]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_8]]{{\[}}%[[VAL_9]]] = %[[VAL_7]] : <1,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_10]], %[[VAL_11]], %[[VAL_12]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_14]]{{\[}}%[[VAL_15]]] = %[[VAL_13]] : <1,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]] to %[[VAL_16]] step %[[VAL_19]] {
// CHECK-NEXT:            scf.for %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_18]] to %[[VAL_17]] step %[[VAL_19]] {
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]{{\[}}%[[VAL_20]], %[[VAL_21]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_20]], %[[VAL_21]]] = %[[VAL_22]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@outp] = %[[VAL_3]] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@outp] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_25]], %[[VAL_25]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_28]]] = %[[VAL_26]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_29]]] = %[[VAL_26]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_30]], %[[VAL_30]], %[[VAL_30]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_32]]{{\[}}%[[VAL_33]]] = %[[VAL_31]] : <1,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  9 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_34]], %[[VAL_35]], %[[VAL_36]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_38]]{{\[}}%[[VAL_39]]] = %[[VAL_37]] : <1,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_42]] to %[[VAL_40]] step %[[VAL_43]] {
// CHECK-NEXT:            scf.for %[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_42]] to %[[VAL_41]] step %[[VAL_43]] {
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_44]], %[[VAL_45]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_27]]{{\[}}%[[VAL_44]], %[[VAL_45]]] = %[[VAL_46]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_24]], %[[VAL_27]] : !array.type<2,2 x !felt.type<"bn128">>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
