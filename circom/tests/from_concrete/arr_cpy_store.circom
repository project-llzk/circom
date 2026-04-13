// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Foo_1::@Foo_1<[]>>} {
// CHECK-NEXT:    poly.template @Foo_1 {
// CHECK-NEXT:      struct.def @Foo_1 {
// CHECK-NEXT:        struct.member @c : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@inp: !array.type<2 x !felt.type>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) -> !struct.type<@Foo_1::@Foo_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_7]]) : (!pod.type<[@inp: !array.type<2 x !felt.type>]>, !felt.type) -> (!pod.type<[@inp: !array.type<2 x !felt.type>]>, !felt.type) {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_10]], %[[VAL_11]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_12]]) %[[VAL_9]], %[[VAL_10]] : !pod.type<[@inp: !array.type<2 x !felt.type>]>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<2 x !felt.type>]>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            pod.write %[[VAL_13]][@inp] = %[[VAL_0]] : <[@inp: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_15]], %[[VAL_16]] : index
// CHECK-NEXT:            pod.write %[[VAL_4]][@count] = %[[VAL_17]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_17]], %[[VAL_18]] : index
// CHECK-NEXT:            scf.if %[[VAL_19]] {
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@inp] : <[@inp: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = function.call @Sum_0::@Sum_0::@compute(%[[VAL_20]]) : (!array.type<2 x !felt.type>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:              pod.write %[[VAL_4]][@comp] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            scf.yield %[[VAL_13]], %[[VAL_22]] : !pod.type<[@inp: !array.type<2 x !felt.type>]>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c$inputs] = %[[VAL_8]]#0 : <@Foo_1::@Foo_1<[]>>, !pod.type<[@inp: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_23]] : <@Foo_1::@Foo_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo_1::@Foo_1<[]>>, %[[VAL_25:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@c] : <@Foo_1::@Foo_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@c$inputs] : <@Foo_1::@Foo_1<[]>>, !pod.type<[@inp: !array.type<2 x !felt.type>]>
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_32]], %[[VAL_33]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_34]]) %[[VAL_32]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inp] : <[@inp: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:            constrain.eq %[[VAL_36]], %[[VAL_25]] : !array.type<2 x !felt.type>, !array.type<2 x !felt.type>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            scf.yield %[[VAL_37]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_28]][@inp] : <[@inp: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:          function.call @Sum_0::@Sum_0::@constrain(%[[VAL_27]], %[[VAL_38]]) : (!struct.type<@Sum_0::@Sum_0<[]>>, !array.type<2 x !felt.type>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum_0 {
// CHECK-NEXT:      struct.def @Sum_0 {
// CHECK-NEXT:        function.def @compute(%[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) -> !struct.type<@Sum_0::@Sum_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          function.return %[[VAL_40]] : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_0::@Sum_0<[]>>, %[[VAL_43:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
