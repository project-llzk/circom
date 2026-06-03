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

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@all::@all<[5]>>} {
// CHECK-NEXT:    poly.template @all {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @all {
// CHECK-NEXT:        struct.member @c : !array.type<@N x !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@N x !pod.type<[]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@all::@all<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@all::@all<[@N]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_1]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_8]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@N] : <[@N: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun::@compute() {(%[[VAL_13]])} : () -> !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_14]] } (%[[VAL_9]]) : <[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_16]]] = %[[VAL_15]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c$inputs] = %[[VAL_3]] : <@all::@all<[@N]>>, !array.type<@N x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_21]] to %[[VAL_20]] step %[[VAL_22]] {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_23]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@comp] : <[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_23]]] = %[[VAL_25]] : <@N x !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>>, !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@c] = %[[VAL_19]] : <@all::@all<[@N]>>, !array.type<@N x !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@all::@all<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@all::@all<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c] : <@all::@all<[@N]>>, !array.type<@N x !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c$inputs] : <@all::@all<[@N]>>, !array.type<@N x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_27]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_33]]) %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_34]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_35]]) : <[@count: index, @comp: !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]] to %[[VAL_40]] step %[[VAL_42]] {
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_43]]] : <@N x !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>>, !struct.type<@fun::@fun<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_43]]] : <@N x !pod.type<[]>>, !pod.type<[]>
// CHECK-NEXT:            function.call @fun::@fun::@constrain(%[[VAL_44]]) : (!struct.type<@fun::@fun<[#[[$ATTR_0]]]>>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @fun {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @fun {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@fun::@fun<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.new : <@fun::@fun<[@N]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_46]][@out] = %[[VAL_47]] : <@fun::@fun<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_46]] : !struct.type<@fun::@fun<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !struct.type<@fun::@fun<[@N]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@out] : <@fun::@fun<[@N]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_50]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
