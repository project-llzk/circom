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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@mult4::@mult4<[]>>} {
// CHECK-NEXT:    poly.template @mult {
// CHECK-NEXT:      struct.def @mult {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) -> !struct.type<@mult::@mult<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@mult::@mult<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_3]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_6]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_4]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_8]] : <@mult::@mult<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !struct.type<@mult::@mult<[]>>, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_9]][@out] : <@mult::@mult<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_13]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_10]]{{\[}}%[[VAL_16]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_14]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_11]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @mult4 {
// CHECK-NEXT:      struct.def @mult4 {
// CHECK-NEXT:        struct.member @comp1 : !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:        struct.member @comp1$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        struct.member @comp2 : !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:        struct.member @comp2$inputs : !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) -> !struct.type<@mult4::@mult4<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.new : <@mult4::@mult4<[]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_22]], @params = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]], @params = %[[VAL_25]] }  : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_36]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_38]]{{\[}}%[[VAL_40]]] = %[[VAL_37]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_24]][@in] = %[[VAL_38]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_41]], %[[VAL_42]] : index
// CHECK-NEXT:          pod.write %[[VAL_31]][@count] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_43]], %[[VAL_44]] : index
// CHECK-NEXT:          scf.if %[[VAL_45]] {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@params] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_47]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_31]][@comp] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_50]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_52]]{{\[}}%[[VAL_54]]] = %[[VAL_51]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_28]][@in] = %[[VAL_52]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:          pod.write %[[VAL_34]][@count] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_57]], %[[VAL_58]] : index
// CHECK-NEXT:          scf.if %[[VAL_59]] {
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@params] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_61]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_34]][@comp] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_64]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_66]]{{\[}}%[[VAL_68]]] = %[[VAL_65]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_28]][@in] = %[[VAL_66]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_69]], %[[VAL_70]] : index
// CHECK-NEXT:          pod.write %[[VAL_34]][@count] = %[[VAL_71]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_71]], %[[VAL_72]] : index
// CHECK-NEXT:          scf.if %[[VAL_73]] {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@params] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_75]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_34]][@comp] = %[[VAL_76]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_78]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_80]]{{\[}}%[[VAL_82]]] = %[[VAL_79]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_24]][@in] = %[[VAL_80]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@count] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_83]], %[[VAL_84]] : index
// CHECK-NEXT:          pod.write %[[VAL_31]][@count] = %[[VAL_85]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_85]], %[[VAL_86]] : index
// CHECK-NEXT:          scf.if %[[VAL_87]] {
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@params] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = function.call @mult::@mult::@compute(%[[VAL_89]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:            pod.write %[[VAL_31]][@comp] = %[[VAL_90]] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp1$inputs] = %[[VAL_24]] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@comp] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp1] = %[[VAL_91]] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp2$inputs] = %[[VAL_28]] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@comp] : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_20]][@comp2] = %[[VAL_92]] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          function.return %[[VAL_20]] : !struct.type<@mult4::@mult4<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_93:[0-9a-zA-Z_\.]+]]: !struct.type<@mult4::@mult4<[]>>, %[[VAL_94:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@comp1] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@comp1$inputs] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@comp2] : <@mult4::@mult4<[]>>, !struct.type<@mult::@mult<[]>>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@comp2$inputs] : <@mult4::@mult4<[]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@mult::@mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_104]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_108]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_109]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_111]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_113]]{{\[}}%[[VAL_115]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_116]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_118]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_122]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_123]], %[[VAL_119]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_125]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_127]]{{\[}}%[[VAL_129]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_130]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @mult::@mult::@constrain(%[[VAL_95]], %[[VAL_131]]) : (!struct.type<@mult::@mult<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @mult::@mult::@constrain(%[[VAL_97]], %[[VAL_132]]) : (!struct.type<@mult::@mult<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
