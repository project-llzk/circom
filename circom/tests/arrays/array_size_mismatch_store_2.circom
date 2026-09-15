// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function arr() {
   var x[1][2][3] = [[[2,3,4], [5,6,7]]];
   var y[1][1][1] = x;
   return y;
}

template ArrayShenanigans() {
   var z[2][2][2] = arr();
   signal output outp[2][2][2] <== z;
}

component main = ArrayShenanigans();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>} {
// CHECK-NEXT:    poly.template @arr {
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @arr() -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_0]], %[[VAL_0]], %[[VAL_0]] : <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_2]]{{\[}}%[[VAL_3]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        array.insert %[[VAL_2]]{{\[}}%[[VAL_4]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new  : <1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_5]]{{\[}}%[[VAL_6]]] = %[[VAL_2]] : <1,2,3 x !felt.type<"bn128">>, <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_8]] : <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_10]]{{\[}}%[[VAL_11]]] = %[[VAL_9]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        array.insert %[[VAL_12]]{{\[}}%[[VAL_13]]] = %[[VAL_10]] : <1,1,1 x !felt.type<"bn128">>, <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_17]] to %[[VAL_14]] step %[[VAL_18]] {
// CHECK-NEXT:          scf.for %[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_17]] to %[[VAL_15]] step %[[VAL_18]] {
// CHECK-NEXT:            scf.for %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_17]] to %[[VAL_16]] step %[[VAL_18]] {
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_7]]{{\[}}%[[VAL_19]], %[[VAL_20]], %[[VAL_21]]] : <1,2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_12]]{{\[}}%[[VAL_19]], %[[VAL_20]], %[[VAL_21]]] = %[[VAL_22]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_12]] : (!array.type<1,1,1 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_23]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<1,2,3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ArrayShenanigans {
// CHECK-NEXT:      struct.def @ArrayShenanigans {
// CHECK-NEXT:        struct.member @outp : !array.type<2,2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_25]], %[[VAL_25]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_28]]] = %[[VAL_26]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_27]]{{\[}}%[[VAL_29]]] = %[[VAL_26]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.new  : <2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_30]]{{\[}}%[[VAL_31]]] = %[[VAL_27]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_30]]{{\[}}%[[VAL_32]]] = %[[VAL_27]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @arr::@arr() : () -> !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_24]][@outp] = %[[VAL_33]] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_24]] : !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@outp] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_36]], %[[VAL_36]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.new  : <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_38]]{{\[}}%[[VAL_39]]] = %[[VAL_37]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_38]]{{\[}}%[[VAL_40]]] = %[[VAL_37]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new  : <2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_41]]{{\[}}%[[VAL_42]]] = %[[VAL_38]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_41]]{{\[}}%[[VAL_43]]] = %[[VAL_38]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @arr::@arr() : () -> !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_35]], %[[VAL_44]] : !array.type<2,2,2 x !felt.type<"bn128">>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
