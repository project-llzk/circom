// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template mult(){
  signal input in[2];
  signal output out;
  out <== in[0] * in[1];
}

template mult4(){
  signal input in[4];
  component comp1 = mult();
  component comp2 = mult();
  comp1.in[0] <== in[0];
  comp2.in[0] <== in[1];
  comp2.in[1] <== in[2];
  comp1.in[1] <== in[3];
}

component main = mult4();

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@mult4<[]>>, veridise.lang = "llzk"} {
// CHECK-LABEL:   struct.def @mult<[]> {
// CHECK-NEXT:      struct.field @out : !felt.type {llzk.pub}
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) -> !struct.type<@mult<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@mult<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]]
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_3]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]]
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_6]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_4]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_8]] : <@mult<[]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@mult<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@mult<[]>>, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_9]][@out] : <@mult<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]]
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_13]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]]
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_16]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_14]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:        constrain.eq %[[VAL_11]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-LABEL:   struct.def @mult4<[]> {
// CHECK-DAG:       struct.field @comp1 : !struct.type<@mult<[]>>
// CHECK-DAG:       struct.field @comp1$inputs : !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-DAG:       struct.field @comp2 : !struct.type<@mult<[]>>
// CHECK-DAG:       struct.field @comp2$inputs : !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-LABEL:     function.def @compute
// CHECK-SAME:      (%[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) -> !struct.type<@mult4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.new : <@mult4<[]>>
// CHECK-DAG:         %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-DAG:         %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type>]>
// CHECK-DAG:         %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-DAG:         %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_24]] }  : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-DAG:         %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type>]>
// CHECK-DAG:         %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]]
// CHECK-DAG:         %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_28]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]]
// CHECK-DAG:         array.write %[[VAL_30]]{{\[}}%[[VAL_32]]] = %[[VAL_29]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         pod.write %[[VAL_23]][@in] = %[[VAL_30]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@count] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_33]], %[[VAL_34]] : index
// CHECK-DAG:         pod.write %[[VAL_22]][@count] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CHECK-DAG:         scf.if %[[VAL_37]] {
// CHECK-DAG:           %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:           %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @mult::@compute(%[[VAL_38]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult<[]>>
// CHECK-DAG:           pod.write %[[VAL_22]][@comp] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult<[]>>
// CHECK-DAG:         } else {
// CHECK-DAG:         }
// CHECK-DAG:         %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-DAG:         %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-DAG:         %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_41]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]]
// CHECK-DAG:         array.write %[[VAL_43]]{{\[}}%[[VAL_45]]] = %[[VAL_42]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         pod.write %[[VAL_26]][@in] = %[[VAL_43]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@count] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_46]], %[[VAL_47]] : index
// CHECK-DAG:         pod.write %[[VAL_25]][@count] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CHECK-DAG:         scf.if %[[VAL_50]] {
// CHECK-DAG:           %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:           %[[VAL_52:[0-9a-zA-Z_\.]+]] = function.call @mult::@compute(%[[VAL_51]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult<[]>>
// CHECK-DAG:           pod.write %[[VAL_25]][@comp] = %[[VAL_52]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult<[]>>
// CHECK-DAG:         } else {
// CHECK-DAG:         }
// CHECK-DAG:         %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-DAG:         %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]]
// CHECK-DAG:         %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_54]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-DAG:         %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]]
// CHECK-DAG:         array.write %[[VAL_56]]{{\[}}%[[VAL_58]]] = %[[VAL_55]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         pod.write %[[VAL_26]][@in] = %[[VAL_56]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@count] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_59]], %[[VAL_60]] : index
// CHECK-DAG:         pod.write %[[VAL_25]][@count] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_61]], %[[VAL_62]] : index
// CHECK-DAG:         scf.if %[[VAL_63]] {
// CHECK-DAG:           %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:           %[[VAL_65:[0-9a-zA-Z_\.]+]] = function.call @mult::@compute(%[[VAL_64]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult<[]>>
// CHECK-DAG:           pod.write %[[VAL_25]][@comp] = %[[VAL_65]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult<[]>>
// CHECK-DAG:         } else {
// CHECK-DAG:         }
// CHECK-DAG:         %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-DAG:         %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]]
// CHECK-DAG:         %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_67]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-DAG:         %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]]
// CHECK-DAG:         array.write %[[VAL_69]]{{\[}}%[[VAL_71]]] = %[[VAL_68]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         pod.write %[[VAL_23]][@in] = %[[VAL_69]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@count] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-DAG:         %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_72]], %[[VAL_73]] : index
// CHECK-DAG:         pod.write %[[VAL_22]][@count] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-DAG:         %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-DAG:         %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_74]], %[[VAL_75]] : index
// CHECK-DAG:         scf.if %[[VAL_76]] {
// CHECK-DAG:           %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:           %[[VAL_78:[0-9a-zA-Z_\.]+]] = function.call @mult::@compute(%[[VAL_77]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult<[]>>
// CHECK-DAG:           pod.write %[[VAL_22]][@comp] = %[[VAL_78]] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult<[]>>
// CHECK-DAG:         } else {
// CHECK-DAG:         }
// CHECK-DAG:         struct.writef %[[VAL_20]][@comp1$inputs] = %[[VAL_23]] : <@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-DAG:         %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@comp] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult<[]>>
// CHECK-DAG:         struct.writef %[[VAL_20]][@comp1] = %[[VAL_79]] : <@mult4<[]>>, !struct.type<@mult<[]>>
// CHECK-DAG:         struct.writef %[[VAL_20]][@comp2$inputs] = %[[VAL_26]] : <@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-DAG:         %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@comp] : <[@count: index, @comp: !struct.type<@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult<[]>>
// CHECK-DAG:         struct.writef %[[VAL_20]][@comp2] = %[[VAL_80]] : <@mult4<[]>>, !struct.type<@mult<[]>>
// CHECK-NEXT:        function.return %[[VAL_20]] : !struct.type<@mult4<[]>>
// CHECK-NEXT:      }
// CHECK-LABEL:     function.def @constrain
// CHECK-SAME:      (%[[VAL_81:[0-9a-zA-Z_\.]+]]: !struct.type<@mult4<[]>>, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-DAG:         %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_81]][@comp1] : <@mult4<[]>>, !struct.type<@mult<[]>>
// CHECK-DAG:         %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_81]][@comp1$inputs] : <@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-DAG:         %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_81]][@comp2] : <@mult4<[]>>, !struct.type<@mult<[]>>
// CHECK-DAG:         %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_81]][@comp2$inputs] : <@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-DAG:         %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]]
// CHECK-DAG:         %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_88]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]]
// CHECK-DAG:         %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_92]]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         constrain.eq %[[VAL_93]], %[[VAL_89]] : !felt.type, !felt.type
// CHECK-DAG:         %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-DAG:         %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]]
// CHECK-DAG:         %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_95]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-DAG:         %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_98]]
// CHECK-DAG:         %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_99]]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         constrain.eq %[[VAL_100]], %[[VAL_96]] : !felt.type, !felt.type
// CHECK-DAG:         %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-DAG:         %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]]
// CHECK-DAG:         %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_102]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-DAG:         %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]]
// CHECK-DAG:         %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_106]]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         constrain.eq %[[VAL_107]], %[[VAL_103]] : !felt.type, !felt.type
// CHECK-DAG:         %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-DAG:         %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]]
// CHECK-DAG:         %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_109]]] : <4 x !felt.type>, !felt.type
// CHECK-DAG:         %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-DAG:         %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]]
// CHECK-DAG:         %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_113]]] : <2 x !felt.type>, !felt.type
// CHECK-DAG:         constrain.eq %[[VAL_114]], %[[VAL_110]] : !felt.type, !felt.type
// CHECK-DAG:         %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         function.call @mult::@constrain(%[[VAL_83]], %[[VAL_115]]) : (!struct.type<@mult<[]>>, !array.type<2 x !felt.type>) -> ()
// CHECK-DAG:         %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-DAG:         function.call @mult::@constrain(%[[VAL_85]], %[[VAL_116]]) : (!struct.type<@mult<[]>>, !array.type<2 x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
