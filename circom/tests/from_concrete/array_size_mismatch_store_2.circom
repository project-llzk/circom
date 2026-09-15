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
// CHECK-NEXT:    poly.template @arr_0 {
// CHECK-NEXT:      function.def @arr_0() -> !array.type<1,1,1 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = global.read const @array_const_0 : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_2]]{{\[}}%[[VAL_4]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_2]]{{\[}}%[[VAL_6]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_0]]{{\[}}%[[VAL_8]]] = %[[VAL_2]] : <1,2,3 x !felt.type<"bn128">>, <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = global.read const @array_const_1 : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = global.read const @array_const_2 : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_11]]{{\[}}%[[VAL_13]]] = %[[VAL_9]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_11]]{{\[}}%[[VAL_15]]] = %[[VAL_10]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_0]]{{\[}}%[[VAL_17]]] = %[[VAL_11]] : <1,2,3 x !felt.type<"bn128">>, <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = global.read const @array_const_3 : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_20]]{{\[}}%[[VAL_22]]] = %[[VAL_19]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_18]]{{\[}}%[[VAL_24]]] = %[[VAL_20]] : <1,1,1 x !felt.type<"bn128">>, <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_28]] to %[[VAL_25]] step %[[VAL_29]] {
// CHECK-NEXT:          scf.for %[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_28]] to %[[VAL_26]] step %[[VAL_29]] {
// CHECK-NEXT:            scf.for %[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_28]] to %[[VAL_27]] step %[[VAL_29]] {
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_30]], %[[VAL_31]], %[[VAL_32]]] : <1,2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_18]]{{\[}}%[[VAL_30]], %[[VAL_31]], %[[VAL_32]]] = %[[VAL_33]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_18]] : !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_1 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_2 : !array.type<3 x !felt.type<"bn128">> = [ 5 : <"bn128">,  6 : <"bn128">,  7 : <"bn128">]
// CHECK-NEXT:    global.def const @array_const_3 : !array.type<1 x !felt.type<"bn128">> = [ 0 : <"bn128">]
// CHECK-NEXT:    poly.template @ArrayShenanigans_0 {
// CHECK-NEXT:      struct.def @ArrayShenanigans_0 {
// CHECK-NEXT:        struct.member @outp : !array.type<2,2,2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_36]]{{\[}}%[[VAL_39]]] = %[[VAL_37]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_36]]{{\[}}%[[VAL_42]]] = %[[VAL_40]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_43]]{{\[}}%[[VAL_45]]] = %[[VAL_36]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_43]]{{\[}}%[[VAL_47]]] = %[[VAL_36]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_35]]{{\[}}%[[VAL_49]]] = %[[VAL_43]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_35]]{{\[}}%[[VAL_51]]] = %[[VAL_43]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = function.call @arr_0::@arr_0() : () -> !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]] to %[[VAL_53]] step %[[VAL_57]] {
// CHECK-NEXT:            scf.for %[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_56]] to %[[VAL_54]] step %[[VAL_57]] {
// CHECK-NEXT:              scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_56]] to %[[VAL_55]] step %[[VAL_57]] {
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_58]], %[[VAL_59]], %[[VAL_60]]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_35]]{{\[}}%[[VAL_58]], %[[VAL_59]], %[[VAL_60]]] = %[[VAL_61]] : <2,2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_34]][@outp] = %[[VAL_35]] : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_34]] : !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@outp] : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_65]]{{\[}}%[[VAL_68]]] = %[[VAL_66]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_65]]{{\[}}%[[VAL_71]]] = %[[VAL_69]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_72]]{{\[}}%[[VAL_74]]] = %[[VAL_65]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_72]]{{\[}}%[[VAL_76]]] = %[[VAL_65]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_64]]{{\[}}%[[VAL_78]]] = %[[VAL_72]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_64]]{{\[}}%[[VAL_80]]] = %[[VAL_72]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = function.call @arr_0::@arr_0() : () -> !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_87:[0-9a-zA-Z_\.]+]] = %[[VAL_85]] to %[[VAL_82]] step %[[VAL_86]] {
// CHECK-NEXT:            scf.for %[[VAL_88:[0-9a-zA-Z_\.]+]] = %[[VAL_85]] to %[[VAL_83]] step %[[VAL_86]] {
// CHECK-NEXT:              scf.for %[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_85]] to %[[VAL_84]] step %[[VAL_86]] {
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_87]], %[[VAL_88]], %[[VAL_89]]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_64]]{{\[}}%[[VAL_87]], %[[VAL_88]], %[[VAL_89]]] = %[[VAL_90]] : <2,2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_63]], %[[VAL_64]] : !array.type<2,2,2 x !felt.type<"bn128">>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
