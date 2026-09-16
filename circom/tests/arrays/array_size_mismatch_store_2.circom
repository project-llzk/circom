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
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<1,2,3 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<1,2,3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<1,1,1 x !felt.type<"bn128">> = [ 0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_3 : !array.type<2,2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @arr {
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @arr() -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_29]] to %[[VAL_26]] step %[[VAL_30]] {
// CHECK-NEXT:          scf.for %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_29]] to %[[VAL_27]] step %[[VAL_30]] {
// CHECK-NEXT:            scf.for %[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_29]] to %[[VAL_28]] step %[[VAL_30]] {
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_31]], %[[VAL_32]], %[[VAL_33]]] : <1,2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_24]]{{\[}}%[[VAL_31]], %[[VAL_32]], %[[VAL_33]]] = %[[VAL_34]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_24]] : (!array.type<1,1,1 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_35]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ArrayShenanigans {
// CHECK-NEXT:      struct.def @ArrayShenanigans {
// CHECK-NEXT:        struct.member @outp : !array.type<2,2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @arr::@arr() : () -> !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@outp] = %[[VAL_45]] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_36]] : !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans::@ArrayShenanigans<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@outp] : <@ArrayShenanigans::@ArrayShenanigans<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_3 : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = function.call @arr::@arr() : () -> !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_47]], %[[VAL_56]] : !array.type<2,2,2 x !felt.type<"bn128">>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
