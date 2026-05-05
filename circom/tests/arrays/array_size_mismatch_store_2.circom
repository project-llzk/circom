// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>} {
// CHECK-NEXT:    poly.template @arr_0 {
// CHECK-NEXT:      function.def @arr_0() -> !array.type<1,1,1 x !felt.type<"bn128">> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_4]]] = %[[VAL_2]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_7]]] = %[[VAL_5]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_1]]{{\[}}%[[VAL_10]]] = %[[VAL_8]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_11]]{{\[}}%[[VAL_13]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_11]]{{\[}}%[[VAL_15]]] = %[[VAL_1]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_0]]{{\[}}%[[VAL_17]]] = %[[VAL_11]] : <1,2,3 x !felt.type<"bn128">>, <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_18]]{{\[}}%[[VAL_21]]] = %[[VAL_19]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_18]]{{\[}}%[[VAL_24]]] = %[[VAL_22]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:        %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_18]]{{\[}}%[[VAL_27]]] = %[[VAL_25]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_28]]{{\[}}%[[VAL_31]]] = %[[VAL_29]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  6 : <"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_28]]{{\[}}%[[VAL_34]]] = %[[VAL_32]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_28]]{{\[}}%[[VAL_37]]] = %[[VAL_35]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_38]]{{\[}}%[[VAL_40]]] = %[[VAL_18]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_38]]{{\[}}%[[VAL_42]]] = %[[VAL_28]] : <2,3 x !felt.type<"bn128">>, <3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_0]]{{\[}}%[[VAL_44]]] = %[[VAL_38]] : <1,2,3 x !felt.type<"bn128">>, <2,3 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:        array.write %[[VAL_46]]{{\[}}%[[VAL_49]]] = %[[VAL_47]] : <1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_50:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_50]]{{\[}}%[[VAL_52]]] = %[[VAL_46]] : <1,1 x !felt.type<"bn128">>, <1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:        array.insert %[[VAL_45]]{{\[}}%[[VAL_54]]] = %[[VAL_50]] : <1,1,1 x !felt.type<"bn128">>, <1,1 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_57]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_55]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_56]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_59]], %[[VAL_60]] : index
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_61]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_59]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_60]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 3 : index
// CHECK-NEXT:        %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_63]], %[[VAL_64]] : index
// CHECK-NEXT:        %[[VAL_66:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_65]] -> (index) {
// CHECK-NEXT:          scf.yield %[[VAL_63]] : index
// CHECK-NEXT:        } else {
// CHECK-NEXT:          scf.yield %[[VAL_64]] : index
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_67]] to %[[VAL_58]] step %[[VAL_68]] {
// CHECK-NEXT:          scf.for %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_67]] to %[[VAL_62]] step %[[VAL_68]] {
// CHECK-NEXT:            scf.for %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_67]] to %[[VAL_66]] step %[[VAL_68]] {
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_69]], %[[VAL_70]], %[[VAL_71]]] : <1,2,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_45]]{{\[}}%[[VAL_69]], %[[VAL_70]], %[[VAL_71]]] = %[[VAL_72]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return %[[VAL_45]] : !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @ArrayShenanigans_0 {
// CHECK-NEXT:      struct.def @ArrayShenanigans_0 {
// CHECK-NEXT:        struct.member @outp : !array.type<2,2,2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_75]]{{\[}}%[[VAL_78]]] = %[[VAL_76]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_75]]{{\[}}%[[VAL_81]]] = %[[VAL_79]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_82]]{{\[}}%[[VAL_84]]] = %[[VAL_75]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_82]]{{\[}}%[[VAL_86]]] = %[[VAL_75]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_74]]{{\[}}%[[VAL_88]]] = %[[VAL_82]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_74]]{{\[}}%[[VAL_90]]] = %[[VAL_82]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = function.call @arr_0::@arr_0() : () -> !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_92]], %[[VAL_93]] : index
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_94]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_92]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_93]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_96]], %[[VAL_97]] : index
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_98]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_96]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_97]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_100]], %[[VAL_101]] : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_102]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_100]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_101]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_106:[0-9a-zA-Z_\.]+]] = %[[VAL_104]] to %[[VAL_95]] step %[[VAL_105]] {
// CHECK-NEXT:            scf.for %[[VAL_107:[0-9a-zA-Z_\.]+]] = %[[VAL_104]] to %[[VAL_99]] step %[[VAL_105]] {
// CHECK-NEXT:              scf.for %[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_104]] to %[[VAL_103]] step %[[VAL_105]] {
// CHECK-NEXT:                %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_106]], %[[VAL_107]], %[[VAL_108]]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_74]]{{\[}}%[[VAL_106]], %[[VAL_107]], %[[VAL_108]]] = %[[VAL_109]] : <2,2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_73]][@outp] = %[[VAL_74]] : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_73]] : !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_110:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_110]][@outp] : <@ArrayShenanigans_0::@ArrayShenanigans_0<[]>>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_113]]{{\[}}%[[VAL_116]]] = %[[VAL_114]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_118]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_113]]{{\[}}%[[VAL_119]]] = %[[VAL_117]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_120]]{{\[}}%[[VAL_122]]] = %[[VAL_113]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_120]]{{\[}}%[[VAL_124]]] = %[[VAL_113]] : <2,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_112]]{{\[}}%[[VAL_126]]] = %[[VAL_120]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:          array.insert %[[VAL_112]]{{\[}}%[[VAL_128]]] = %[[VAL_120]] : <2,2,2 x !felt.type<"bn128">>, <2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = function.call @arr_0::@arr_0() : () -> !array.type<1,1,1 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_130]], %[[VAL_131]] : index
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_132]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_130]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_131]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_134]], %[[VAL_135]] : index
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_136]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_134]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_135]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.cmpi ult, %[[VAL_138]], %[[VAL_139]] : index
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_140]] -> (index) {
// CHECK-NEXT:            scf.yield %[[VAL_138]] : index
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_139]] : index
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_142]] to %[[VAL_133]] step %[[VAL_143]] {
// CHECK-NEXT:            scf.for %[[VAL_145:[0-9a-zA-Z_\.]+]] = %[[VAL_142]] to %[[VAL_137]] step %[[VAL_143]] {
// CHECK-NEXT:              scf.for %[[VAL_146:[0-9a-zA-Z_\.]+]] = %[[VAL_142]] to %[[VAL_141]] step %[[VAL_143]] {
// CHECK-NEXT:                %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_144]], %[[VAL_145]], %[[VAL_146]]] : <1,1,1 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_112]]{{\[}}%[[VAL_144]], %[[VAL_145]], %[[VAL_146]]] = %[[VAL_147]] : <2,2,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_111]], %[[VAL_112]] : !array.type<2,2,2 x !felt.type<"bn128">>, !array.type<2,2,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
