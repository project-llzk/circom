// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// COM: Only works for llzk=concrete mode for now, pending larger template support

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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>} {
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<1,2,3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">,  5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_1 : !array.type<1,1,1 x !felt.type<"bn128">> = [ 0 : <"bn128">]
// CHECK-NEXT:      global.def const @array_const_2 : !array.type<2,2,2 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @arr_0 {
// CHECK-NEXT:      function.def @arr_0() -> !array.type<1,1,1 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_55]] step %[[VAL_59]] {
// CHECK-NEXT:          scf.for %[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_56]] step %[[VAL_59]] {
// CHECK-NEXT:            scf.for %[[VAL_62:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_57]] step %[[VAL_59]] {
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_60]], %[[VAL_61]], %[[VAL_62]]] : <1,2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_45]]{{\[}}%[[VAL_60]], %[[VAL_61]], %[[VAL_62]]] = %[[VAL_63]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_45]] : !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ArrayShenanigans_0 {
// CHECK-NEXT:      struct.def @ArrayShenanigans_0 {
// CHECK-NEXT:        struct.member @outp : !array.type<2,2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = function.call @arr_0::@arr_0() : () -> !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_88:[0-9a-zA-Z_\.]+]] = %[[VAL_86]] to %[[VAL_83]] step %[[VAL_87]] {
// CHECK-NEXT:            scf.for %[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_86]] to %[[VAL_84]] step %[[VAL_87]] {
// CHECK-NEXT:              scf.for %[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_86]] to %[[VAL_85]] step %[[VAL_87]] {
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_88]], %[[VAL_89]], %[[VAL_90]]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_65]]{{\[}}%[[VAL_88]], %[[VAL_89]], %[[VAL_90]]] = %[[VAL_91]] : <2,2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_64]][@outp] = %[[VAL_65]] : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_64]] : !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_92:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_92]][@outp] : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_2 : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = function.call @arr_0::@arr_0() : () -> !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_112]] step %[[VAL_116]] {
// CHECK-NEXT:            scf.for %[[VAL_118:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_113]] step %[[VAL_116]] {
// CHECK-NEXT:              scf.for %[[VAL_119:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_114]] step %[[VAL_116]] {
// CHECK-NEXT:                %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_117]], %[[VAL_118]], %[[VAL_119]]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_94]]{{\[}}%[[VAL_117]], %[[VAL_118]], %[[VAL_119]]] = %[[VAL_120]] : <2,2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_93]], %[[VAL_94]] : !array.type<2,2,2 x !felt.type<"bn128">>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
