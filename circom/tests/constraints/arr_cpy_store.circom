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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Foo::@Foo<[2]>>} {
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        struct.member @c : !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>) -> !struct.type<@Foo::@Foo<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[@N]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_5]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_7]], @params = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_11]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_12]]) %[[VAL_10]], %[[VAL_11]] : !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            pod.write %[[VAL_13]][@inp] = %[[VAL_0]] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:            pod.write %[[VAL_8]][@count] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, index
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_17]], %[[VAL_18]] : index
// CHECK-NEXT:            scf.if %[[VAL_19]] {
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, !pod.type<[@N: index]>
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_21]]) : (!array.type<@N x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:              pod.write %[[VAL_8]][@comp] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_13]], %[[VAL_24]] : !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c$inputs] = %[[VAL_9]]#0 : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_25]] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Foo::@Foo<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[@N]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c$inputs] : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_32]] }  : <[@N: index]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_34]], @params = %[[VAL_33]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[@N: index]>]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_29]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_37]], %[[VAL_37]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_38]]) %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_39:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_40]], %[[VAL_27]] : !array.type<@N x !felt.type<"bn128">>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@inp] : <[@inp: !array.type<@N x !felt.type<"bn128">>]>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_30]], %[[VAL_43]]) : (!struct.type<@Sum::@Sum<[@N]>>, !array.type<@N x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        function.def @compute(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_45]] : !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@N]>>, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
