// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(N, M){
   signal input in;
   signal output out;
   out <== in;
}
template C(N){
   signal output out;
   out <== N;
}
template B(N){
  signal output out;
  component a[1];
  if(N > 0){
     a[0] = A(N, 1);
  }
  else{
     a[0] = A(0, 1);
  }
  a[0].in <== 1;
  a[0].out ==> out;
}

component main = B(1);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[1]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.param @M : index
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_4]] : index, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_6:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@N, @M]>>, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = poly.read_const @M : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_8]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_10]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_6]][@out] : <@A::@A<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_12]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a : !array.type<1 x !struct.type<@A::@A<[#map, 1]>>>
// CHECK-NEXT:        struct.member @a$inputs : !array.type<1 x !pod.type<[@in: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B::@B<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@N]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_14]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_15]], %[[VAL_18]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_19]] {
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_20]], @M = %[[VAL_21]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_24]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_26]]] = %[[VAL_27]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_28]], @M = %[[VAL_29]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_31]], @params = %[[VAL_30]] }  : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_32]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_34]]] = %[[VAL_35]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_38]]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_39]][@in] = %[[VAL_36]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_17]]{{\[}}%[[VAL_41]]] = %[[VAL_39]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_43]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_46]]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:          pod.write %[[VAL_44]][@count] = %[[VAL_50]] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, index
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_50]], %[[VAL_51]] : index
// CHECK-NEXT:          scf.if %[[VAL_52]] {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !pod.type<[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@N] : <[@N: index, @M: index]>, index
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_54]]) {(%[[VAL_55]])} : (!felt.type<"bn128">) -> !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:            pod.write %[[VAL_44]][@comp] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_57]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_16]]{{\[}}%[[VAL_58]]] = %[[VAL_44]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_60]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_62]][@out] : <@A::@A<[#map, 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@out] = %[[VAL_63]] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@a$inputs] = %[[VAL_17]] : <@B::@B<[@N]>>, !array.type<1 x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@A::@A<[#map, 1]>>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_66]] to %[[VAL_65]] step %[[VAL_67]] {
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_68]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:            array.write %[[VAL_64]]{{\[}}%[[VAL_68]]] = %[[VAL_70]] : <1 x !struct.type<@A::@A<[#map, 1]>>>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_13]][@a] = %[[VAL_64]] : <@B::@B<[@N]>>, !array.type<1 x !struct.type<@A::@A<[#map, 1]>>>
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@B::@B<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_72]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@out] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@a] : <@B::@B<[@N]>>, !array.type<1 x !struct.type<@A::@A<[#map, 1]>>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_71]][@a$inputs] : <@B::@B<[@N]>>, !array.type<1 x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_73]], %[[VAL_77]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_78]] {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_79]], @M = %[[VAL_80]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_83]], @M = %[[VAL_84]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_89]]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_91]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_93]]] : <1 x !struct.type<@A::@A<[#map, 1]>>>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_94]][@out] : <@A::@A<[#map, 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_74]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_97]] to %[[VAL_96]] step %[[VAL_98]] {
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_99]]] : <1 x !struct.type<@A::@A<[#map, 1]>>>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_99]]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @A::@A::@constrain(%[[VAL_100]], %[[VAL_102]]) : (!struct.type<@A::@A<[#map, 1]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
