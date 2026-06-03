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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B_2::@B_2<[]>>} {
// CHECK-NEXT:    poly.template @B_2 {
// CHECK-NEXT:      struct.def @B_2 {
// CHECK-NEXT:        struct.member @f : !pod.type<[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:        struct.member @f$inputs : !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = function.call @Foo_0::@Foo_0::@compute() : () -> !struct.type<@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = function.call @Foo_1::@Foo_1::@compute() : () -> !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_4]], @idx_1 = %[[VAL_7]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_14]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@f$inputs] = %[[VAL_9]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_19]][@comp] : <[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Foo_0::@Foo_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@comp] : <[@count: index, @comp: !struct.type<@Foo_1::@Foo_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_20]], @idx_1 = %[[VAL_22]] }  : <[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@f] = %[[VAL_23]] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@B_2::@B_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_24:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@f] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_24]][@f$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_28]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_30]], %[[VAL_31]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_32]]) %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_33]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@idx_0] : <[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>, !struct.type<@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@idx_0] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @Foo_0::@Foo_0::@constrain(%[[VAL_36]]) : (!struct.type<@Foo_0::@Foo_0<[]>>) -> ()
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]][@idx_1] : <[@idx_0: !struct.type<@Foo_0::@Foo_0<[]>>, @idx_1: !struct.type<@Foo_1::@Foo_1<[]>>]>, !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@idx_1] : <[@idx_0: !pod.type<[]>, @idx_1: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:          function.call @Foo_1::@Foo_1::@constrain(%[[VAL_38]]) : (!struct.type<@Foo_1::@Foo_1<[]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Foo_0 {
// CHECK-NEXT:      struct.def @Foo_0 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Foo_0::@Foo_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_40]][@x] = %[[VAL_42]] : <@Foo_0::@Foo_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_40]] : !struct.type<@Foo_0::@Foo_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo_0::@Foo_0<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@x] : <@Foo_0::@Foo_0<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_46]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Foo_1 {
// CHECK-NEXT:      struct.def @Foo_1 {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Foo_1::@Foo_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_47]][@x] = %[[VAL_49]] : <@Foo_1::@Foo_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_47]] : !struct.type<@Foo_1::@Foo_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo_1::@Foo_1<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@x] : <@Foo_1::@Foo_1<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_51]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
