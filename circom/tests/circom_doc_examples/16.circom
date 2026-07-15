// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template fun(N){
  signal output out;
  out <== N;
}

template all(N){
  component c[N];
  for(var i = 0; i < N; i++){
     c[i] = fun(i);
  }
}

component main = all(5);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@all::@all<[5]>>} {
// CHECK-NEXT:    poly.template @all {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @all {
// CHECK-NEXT:        struct.member @c : !array.type<@N x !struct.type<@fun::@fun<[#map]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@N x !pod.type<[]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@all::@all<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@all::@all<[@N]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_10]] }  : <[@N: index]>
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@N] : <[@N: index]>, index
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun::@compute() {(%[[VAL_13]])} : () -> !struct.type<@fun::@fun<[#map]>>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_14]] } (%[[VAL_10]]) : <[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_16]]] = %[[VAL_15]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c$inputs] = %[[VAL_4]] : <@all::@all<[@N]>>, !array.type<@N x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !struct.type<@fun::@fun<[#map]>>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_21]] to %[[VAL_20]] step %[[VAL_22]] {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_23]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@comp] : <[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@fun::@fun<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_23]]] = %[[VAL_25]] : <@N x !struct.type<@fun::@fun<[#map]>>>, !struct.type<@fun::@fun<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c] = %[[VAL_19]] : <@all::@all<[@N]>>, !array.type<@N x !struct.type<@fun::@fun<[#map]>>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@all::@all<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@all::@all<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_27]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c] : <@all::@all<[@N]>>, !array.type<@N x !struct.type<@fun::@fun<[#map]>>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c$inputs] : <@all::@all<[@N]>>, !array.type<@N x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_33:[0-9a-zA-Z_\.]+]] = %[[VAL_31]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_33]], %[[VAL_28]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_34]]) %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_36]] }  : <[@N: index]>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_36]]) : <[@count: index, @comp: !struct.type<@fun::@fun<[#map]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_44:[0-9a-zA-Z_\.]+]] = %[[VAL_42]] to %[[VAL_41]] step %[[VAL_43]] {
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_44]]] : <@N x !struct.type<@fun::@fun<[#map]>>>, !struct.type<@fun::@fun<[#map]>>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_44]]] : <@N x !pod.type<[]>>, !pod.type<[]>
// CHECK-NEXT:            function.call @fun::@fun::@constrain(%[[VAL_45]]) : (!struct.type<@fun::@fun<[#map]>>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @fun {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @fun {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@fun::@fun<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.new : <@fun::@fun<[@N]>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_48]] : index, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_47]][@out] = %[[VAL_49]] : <@fun::@fun<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_47]] : !struct.type<@fun::@fun<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !struct.type<@fun::@fun<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_51]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@out] : <@fun::@fun<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
