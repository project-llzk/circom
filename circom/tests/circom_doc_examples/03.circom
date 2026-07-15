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
// CHECK-NEXT:        struct.member @a : !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B::@B<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@N]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_14]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_15]], %[[VAL_17]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_18]] -> (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>) {
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_20]], @M = %[[VAL_21]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_24]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            scf.yield %[[VAL_25]] : !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_26]], @M = %[[VAL_27]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_29]], @params = %[[VAL_28]] }  : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_30]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          pod.write %[[VAL_16]][@in] = %[[VAL_32]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:          pod.write %[[VAL_19]][@count] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:          scf.if %[[VAL_37]] {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !pod.type<[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@N] : <[@N: index, @M: index]>, index
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_39]]) {(%[[VAL_40]])} : (!felt.type<"bn128">) -> !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:            pod.write %[[VAL_19]][@comp] = %[[VAL_41]] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_42]][@out] : <@A::@A<[#map, 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@out] = %[[VAL_43]] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_13]][@a$inputs] = %[[VAL_16]] : <@B::@B<[@N]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          struct.writem %[[VAL_13]][@a] = %[[VAL_44]] : <@B::@B<[@N]>>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          function.return %[[VAL_13]] : !struct.type<@B::@B<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_46]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@out] : <@B::@B<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@a] : <@B::@B<[@N]>>, !struct.type<@A::@A<[#map, 1]>>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@a$inputs] : <@B::@B<[@N]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = bool.cmp gt(%[[VAL_47]], %[[VAL_51]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_52]] {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_53]], @M = %[[VAL_54]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@N, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_57]], @M = %[[VAL_58]] }  : <[@N: index, @M: index]>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[0, 1]>>, @params: !pod.type<[@N: index, @M: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_62]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@out] : <@A::@A<[#map, 1]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_48]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @A::@A::@constrain(%[[VAL_49]], %[[VAL_64]]) : (!struct.type<@A::@A<[#map, 1]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
