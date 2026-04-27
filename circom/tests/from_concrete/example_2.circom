// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Foo(n) {
  signal output x;
  x <== n;
}

template B(N) {
  component f[N];
  for(var i = 0; i < N; i++){
    f[i] = Foo(4*i+1);
  }
}

component main = B(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@B_2::@B_2<[]>>} {
// CHECK-NEXT:    poly.template @B_2 {
// CHECK-NEXT:      struct.def @B_2 {
// CHECK-NEXT:        struct.member @f : !pod.type<[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:        struct.member @f$inputs : !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@f$inputs] = %[[VAL_2]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@comp] : <[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_1]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@comp] : <[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_13]], @idx_1 = %[[VAL_15]] }  : <[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@f] = %[[VAL_16]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@f] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@f$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@idx_0] : <[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>, !struct.type<@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@idx_0] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @Foo_0::@Foo_0::@constrain(%[[VAL_29]]) : (!struct.type<@Foo_0::@Foo_0<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@idx_1] : <[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>, !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@idx_1] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @Foo_1::@Foo_1::@constrain(%[[VAL_31]]) : (!struct.type<@Foo_1::@Foo_1<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Foo_0 {
// CHECK-NEXT:      struct.def @Foo_0 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Foo_0::@Foo_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_33]][@x] = %[[VAL_35]] : <@Foo_0::@Foo_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_33]] : !struct.type<@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo_0::@Foo_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_36]][@x] : <@Foo_0::@Foo_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Foo_1 {
// CHECK-NEXT:      struct.def @Foo_1 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Foo_1::@Foo_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_40]][@x] = %[[VAL_42]] : <@Foo_1::@Foo_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_40]] : !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo_1::@Foo_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@x] : <@Foo_1::@Foo_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
