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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Foo<[2]>>} {
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        struct.member @c : !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@inp: !array.type<@N x !felt.type>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) -> !struct.type<@Foo::@Foo<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[@N]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]] : !felt.type
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@N x !felt.type>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!pod.type<[@inp: !array.type<@N x !felt.type>]>, !felt.type) -> (!pod.type<[@inp: !array.type<@N x !felt.type>]>, !felt.type) {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_9]], %[[VAL_9]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_10]]) %[[VAL_8]], %[[VAL_9]] : !pod.type<[@inp: !array.type<@N x !felt.type>]>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@N x !felt.type>]>, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            pod.write %[[VAL_11]][@inp] = %[[VAL_0]] : <[@inp: !array.type<@N x !felt.type>]>, !array.type<@N x !felt.type>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_13]], %[[VAL_14]] : index
// CHECK-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_15]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:            scf.if %[[VAL_17]] {
// CHECK-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@inp] : <[@inp: !array.type<@N x !felt.type>]>, !array.type<@N x !felt.type>
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_18]]) : (!array.type<@N x !felt.type>) -> !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_19]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_11]], %[[VAL_21]] : !pod.type<[@inp: !array.type<@N x !felt.type>]>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c$inputs] = %[[VAL_7]]#0 : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@N]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_22]] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Foo::@Foo<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[@N]>>, %[[VAL_24:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@c] : <@Foo::@Foo<[@N]>>, !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_23]][@c$inputs] : <@Foo::@Foo<[@N]>>, !pod.type<[@inp: !array.type<@N x !felt.type>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_30]], %[[VAL_30]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_31]]) %[[VAL_30]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inp] : <[@inp: !array.type<@N x !felt.type>]>, !array.type<@N x !felt.type>
// CHECK-NEXT:            constrain.eq %[[VAL_33]], %[[VAL_24]] : !array.type<@N x !felt.type>, !array.type<@N x !felt.type>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_32]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_35]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inp] : <[@inp: !array.type<@N x !felt.type>]>, !array.type<@N x !felt.type>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_27]], %[[VAL_36]]) : (!struct.type<@Sum::@Sum<[@N]>>, !array.type<@N x !felt.type>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        function.def @compute(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) -> !struct.type<@Sum::@Sum<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@N]>>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          function.return %[[VAL_38]] : !struct.type<@Sum::@Sum<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@N]>>, %[[VAL_41:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
