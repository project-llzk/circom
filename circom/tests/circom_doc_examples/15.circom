// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@mult4<[]>>} {
// CHECK-NEXT:    poly.template @mult {
// CHECK-NEXT:      struct.def @mult {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) -> !struct.type<@mult::@mult<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@mult::@mult<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_3]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_6]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_4]], %[[VAL_7]] : !felt.type, !felt.type
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_8]] : <@mult::@mult<[]>>, !felt.type
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@mult::@mult<[]>>, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_9]][@out] : <@mult::@mult<[]>>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_13]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_16]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_14]], %[[VAL_17]] : !felt.type, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_18]] : !felt.type, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @mult4 {
// CHECK-NEXT:      struct.def @mult4 {
// CHECK-NEXT:        struct.member @comp1 : !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:        struct.member @comp1$inputs : !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:        struct.member @comp2 : !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:        struct.member @comp2$inputs : !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) -> !struct.type<@mult4::@mult4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.new : <@mult4::@mult4<[]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_24]] }  : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_28]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_30]]{{\[}}%[[VAL_32]]] = %[[VAL_29]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_23]][@in] = %[[VAL_30]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:          pod.write %[[VAL_22]][@count] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:          scf.if %[[VAL_37]] {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_38]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_22]][@comp] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_41]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_43]]{{\[}}%[[VAL_45]]] = %[[VAL_42]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_26]][@in] = %[[VAL_43]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:          pod.write %[[VAL_25]][@count] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:          scf.if %[[VAL_50]] {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_51]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_25]][@comp] = %[[VAL_52]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_54]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_56]]{{\[}}%[[VAL_58]]] = %[[VAL_55]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_26]][@in] = %[[VAL_56]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_59]], %[[VAL_60]] : index
// CHECK-NEXT:          pod.write %[[VAL_25]][@count] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_61]], %[[VAL_62]] : index
// CHECK-NEXT:          scf.if %[[VAL_63]] {
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_64]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_25]][@comp] = %[[VAL_65]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_67]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type
// CHECK-NEXT:          array.write %[[VAL_69]]{{\[}}%[[VAL_71]]] = %[[VAL_68]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_23]][@in] = %[[VAL_69]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_72]], %[[VAL_73]] : index
// CHECK-NEXT:          pod.write %[[VAL_22]][@count] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_74]], %[[VAL_75]] : index
// CHECK-NEXT:          scf.if %[[VAL_76]] {
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_77]]) : (!array.type<2 x !felt.type>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_22]][@comp] = %[[VAL_78]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp1$inputs] = %[[VAL_23]] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@comp] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp1] = %[[VAL_79]] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp2$inputs] = %[[VAL_26]] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@comp] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp2] = %[[VAL_80]] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          function.return %[[VAL_20]] : !struct.type<@mult4::@mult4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_81:[0-9a-zA-Z_\.]+]]: !struct.type<@mult4::@mult4<[]>>, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_81]][@comp1] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_81]][@comp1$inputs] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_81]][@comp2] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_81]][@comp2$inputs] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_88]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_92]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_93]], %[[VAL_89]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_95]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_98]] : !felt.type
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_99]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_100]], %[[VAL_96]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_102]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_106]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_107]], %[[VAL_103]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_109]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_113]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_114]], %[[VAL_110]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          function.call @mult::@mult::@constrain(%[[VAL_83]], %[[VAL_115]]) : (!struct.type<@mult::@mult<[]>>, !array.type<2 x !felt.type>) -> ()
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          function.call @mult::@mult::@constrain(%[[VAL_85]], %[[VAL_116]]) : (!struct.type<@mult::@mult<[]>>, !array.type<2 x !felt.type>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
