// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_7]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_4]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_14]], %[[VAL_14]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_12]], %[[VAL_13]], %[[VAL_14]] : !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            pod.write %[[VAL_17]][@inp] = %[[VAL_0]] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_19]], %[[VAL_20]] : index
// CHECK-NEXT:            pod.write %[[VAL_16]][@count] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:            scf.if %[[VAL_23]] {
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@N: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_25]]) : (!array.type<@N x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:              pod.write %[[VAL_16]][@comp] = %[[VAL_26]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]], %[[VAL_17]], %[[VAL_28]] : !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c$inputs] = %[[VAL_11]]#1 : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]]#0[@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_29]] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Foo::@Foo<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[@N]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "out"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_33]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@c] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@c$inputs] : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_37]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_38]] }  : <[@N: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_34]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_42]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_43]]) %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_45]], %[[VAL_31]] : !array.type<@N x !felt.type<"bn128">>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_44]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_35]], %[[VAL_48]]) : (!struct.type<@Sum::@Sum<[@N]>>, !array.type<@N x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        function.def @compute(%[[VAL_49:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum::@Sum<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_51]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_50]] : !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@N]>>, %[[VAL_54:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_55]] : index, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
