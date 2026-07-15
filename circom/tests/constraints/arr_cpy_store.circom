// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Sum(N) {
  signal input inp[N];
}

template Foo(N) {
  signal input inp[N];
  signal input out[N];

  component c = Sum(N);
  for (var i = N; i <= N; i++) {
    c.inp <== inp;
  }
}

component main = Foo(2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Foo::@Foo<[2]>>} {
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        struct.member @c : !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "out"}) -> !struct.type<@Foo::@Foo<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[@N]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_6]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_4]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_8]], @params = %[[VAL_7]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_12]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_13]]) %[[VAL_11]], %[[VAL_12]] : !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            pod.write %[[VAL_14]][@inp] = %[[VAL_0]] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:            pod.write %[[VAL_9]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CHECK-NEXT:            scf.if %[[VAL_20]] {
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, !pod.type<[@N: index]>
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_22]]) : (!array.type<@N x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:              pod.write %[[VAL_9]][@comp] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_14]], %[[VAL_25]] : !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c$inputs] = %[[VAL_10]]#0 : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_26]] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Foo::@Foo<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[@N]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}, %[[VAL_29:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "out"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_30]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@c] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@c$inputs] : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_34]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_31]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_38]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_39]]) %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_41]], %[[VAL_28]] : !array.type<@N x !felt.type<"bn128">>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_32]], %[[VAL_44]]) : (!struct.type<@Sum::@Sum<[@N]>>, !array.type<@N x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        function.def @compute(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum::@Sum<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_47]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_46]] : !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@N]>>, %[[VAL_50:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_51]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
