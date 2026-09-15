// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:        struct.member @outp : !array.type<2,2 x !felt.type<"bn128">> {llzk.pub, signal}
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
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]] to %[[VAL_11]] step %[[VAL_14]] {
// CHECK-NEXT:            scf.for %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_13]] to %[[VAL_12]] step %[[VAL_14]] {
// CHECK-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_15]], %[[VAL_16]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_15]], %[[VAL_16]]] = %[[VAL_17]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@outp] = %[[VAL_3]] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@outp] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_20]], %[[VAL_20]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_22]]{{\[}}%[[VAL_23]]] = %[[VAL_21]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_22]]{{\[}}%[[VAL_24]]] = %[[VAL_21]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_25]], %[[VAL_25]], %[[VAL_25]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new  : <1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_28]]] = %[[VAL_26]] : <1,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<1,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]] to %[[VAL_30]] step %[[VAL_33]] {
// CHECK-NEXT:            scf.for %[[VAL_35:[0-9a-zA-Z_\.]+]] = %[[VAL_32]] to %[[VAL_31]] step %[[VAL_33]] {
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_34]], %[[VAL_35]]] : <1,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_22]]{{\[}}%[[VAL_34]], %[[VAL_35]]] = %[[VAL_36]] : <2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_19]], %[[VAL_22]] : !array.type<2,2 x !felt.type<"bn128">>, !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<1,3 x !felt.type<"bn128">> = [ 9 : <"bn128">,  8 : <"bn128">,  7 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:  }
