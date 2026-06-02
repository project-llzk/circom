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
// CHECK-NEXT:        struct.member @c$inputs : !pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inp"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "out"}) -> !struct.type<@Foo_1::@Foo_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_6]], %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_8]]) : (!pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_11]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_13]]) %[[VAL_10]], %[[VAL_11]] : !pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            pod.write %[[VAL_14]][@inp] = %[[VAL_0]] : <[@inp: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_16]], %[[VAL_17]] : index
// CHECK-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_18]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_18]], %[[VAL_19]] : index
// CHECK-NEXT:            scf.if %[[VAL_20]] {
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@params] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inp] : <[@inp: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = function.call @Sum_0::@Sum_0::@compute(%[[VAL_22]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_14]], %[[VAL_24]] : !pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c$inputs] = %[[VAL_9]]#0 : <@Foo_1::@Foo_1<[]>>, !pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_25]] : <@Foo_1::@Foo_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo_1::@Foo_1<[]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inp"}, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "out"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c] : <@Foo_1::@Foo_1<[]>>, !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@c$inputs] : <@Foo_1::@Foo_1<[]>>, !pod.type<[@inp: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_34]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_36]]) %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inp] : <[@inp: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            constrain.eq %[[VAL_38]], %[[VAL_27]] : !array.type<2 x !felt.type<"bn128">>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inp] : <[@inp: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum_0::@Sum_0::@constrain(%[[VAL_29]], %[[VAL_40]]) : (!struct.type<@Sum_0::@Sum_0<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum_0 {
// CHECK-NEXT:      struct.def @Sum_0 {
// CHECK-NEXT:        function.def @compute(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum_0::@Sum_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return %[[VAL_42]] : !struct.type<@Sum_0::@Sum_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum_0::@Sum_0<[]>>, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
