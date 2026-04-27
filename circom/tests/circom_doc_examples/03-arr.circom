// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

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

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@B::@B<[1]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.param @M
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@A::@A<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@N, @M]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@A::@A<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_8]], %[[VAL_5]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !array.type<1 x !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>>
// CHECK-NEXT:        struct.member @a$inputs : !array.type<1 x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B::@B<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@N]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_10]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_14]] {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_15]], @M = %[[VAL_16]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]], @params = %[[VAL_17]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_19]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_21]]] = %[[VAL_22]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_23]], @M = %[[VAL_24]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]], @params = %[[VAL_25]] }  : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_27]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_29]]] = %[[VAL_30]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_33]]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_34]][@in] = %[[VAL_31]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_12]]{{\[}}%[[VAL_36]]] = %[[VAL_34]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_38]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_40]], %[[VAL_41]] : index
// CHECK-NEXT:          pod.write %[[VAL_39]][@count] = %[[VAL_42]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:          scf.if %[[VAL_44]] {
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !pod.type<[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@N] : <[@N: index, @M: index]>, index
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_46]]) {(%[[VAL_47]])} : (!felt.type<"bn128">) -> !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:            pod.write %[[VAL_39]][@comp] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_50]]] = %[[VAL_39]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_52]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_54]][@out] : <@A::@A<[#[[$ATTR_0]], 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_9]][@out] = %[[VAL_55]] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a$inputs] = %[[VAL_12]] : <@B::@B<[@N]>>, !array.type<1 x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.new  : <1 x !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]] to %[[VAL_57]] step %[[VAL_59]] {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_60]]] : <1 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:            array.write %[[VAL_56]]{{\[}}%[[VAL_60]]] = %[[VAL_62]] : <1 x !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a] = %[[VAL_56]] : <@B::@B<[@N]>>, !array.type<1 x !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@B::@B<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@out] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@a] : <@B::@B<[@N]>>, !array.type<1 x !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@a$inputs] : <@B::@B<[@N]>>, !array.type<1 x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_64]], %[[VAL_68]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_69]] {
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_70]], @M = %[[VAL_71]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_73]], @params = %[[VAL_72]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_75]], @M = %[[VAL_76]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_78]], @params = %[[VAL_77]] }  : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_82]]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_84]], %[[VAL_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_86]]] : <1 x !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_87]][@out] : <@A::@A<[#[[$ATTR_0]], 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_90]] to %[[VAL_89]] step %[[VAL_91]] {
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_92]]] : <1 x !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_92]]] : <1 x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @A::@A::@constrain(%[[VAL_93]], %[[VAL_95]]) : (!struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
