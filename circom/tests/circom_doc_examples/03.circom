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
  component a;
  if(N > 0){
     a = A(N, 1);
  }
  else{
     a = A(0, 1);
  }
  a.in <== 1;
  a.out ==> out;
}

component main = B(1);

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[1]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      poly.param @M
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@A::@A<[@N, @M]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@N, @M]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @M : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_0]] : <@A::@A<[@N, @M]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@N, @M]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@N, @M]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
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
// CHECK-NEXT:        struct.member @a : !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B::@B<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@N]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_10]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_15]], @M = %[[VAL_16]] }  : <[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]], @params = %[[VAL_17]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_19]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:            scf.yield %[[VAL_20]] : !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_21]], @M = %[[VAL_22]] }  : <[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_24]], @params = %[[VAL_23]] }  : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_25]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:            scf.yield %[[VAL_26]] : !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          pod.write %[[VAL_11]][@in] = %[[VAL_27]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_28]], %[[VAL_29]] : index
// CHECK-NEXT:          pod.write %[[VAL_14]][@count] = %[[VAL_30]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_30]], %[[VAL_31]] : index
// CHECK-NEXT:          scf.if %[[VAL_32]] {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@N] : <[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_34]]) {(%[[VAL_36]])} : (!felt.type<"bn128">) -> !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:            pod.write %[[VAL_14]][@comp] = %[[VAL_37]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@out] : <@A::@A<[#[[$ATTR_0]], 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_9]][@out] = %[[VAL_39]] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a$inputs] = %[[VAL_11]] : <@B::@B<[@N]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@a] = %[[VAL_40]] : <@B::@B<[@N]>>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@B::@B<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@out] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@a] : <@B::@B<[@N]>>, !struct.type<@A::@A<[#[[$ATTR_0]], 1]>>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@a$inputs] : <@B::@B<[@N]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_42]], %[[VAL_46]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_47]] {
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_48]], @M = %[[VAL_49]] }  : <[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_52]], @M = %[[VAL_53]] }  : <[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @M: !felt.type<"bn128">]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_57]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@out] : <@A::@A<[#[[$ATTR_0]], 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_43]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_44]], %[[VAL_59]]) : (!struct.type<@A::@A<[#[[$ATTR_0]], 1]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
