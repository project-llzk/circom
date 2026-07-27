// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Foo(N) {
  signal input inp[N];
  signal output outp[N];

  signal internal[N];

  for (var i = 0; i < N; i++) {
    internal[i] <== inp[i];
  }

  for (var i = 0; i < N; i++) {
    internal[i] ==> outp[i];
  }
}

component main = Foo(3);

// COM: Lit variables cannot be set at the "llzk.nondet : !array.type<@N x !felt.type<"bn128">>" instances because their
// COM: ordering is non-deterministic. The lit variable is instead set at the first use of the MLIR value.
//
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Foo::@Foo<[3]>>} {
// CHECK-NEXT:    poly.template @Foo {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @Foo {
// CHECK-NEXT:        struct.member @outp : !array.type<@N x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @internal : !array.type<@N x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Foo::@Foo<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo::@Foo<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_11]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_16]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_18]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_19]]) %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_21]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_23]]] = %[[VAL_22]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@internal] = %[[VAL_4]] : <@Foo::@Foo<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_5]] : <@Foo::@Foo<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Foo::@Foo<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo::@Foo<[@N]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_28]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@outp] : <@Foo::@Foo<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@internal] : <@Foo::@Foo<[@N]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_29]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_35]]) %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_37]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_39]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_40]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_36]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_43]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_45]], %[[VAL_29]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_46]]) %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_48]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_50]]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_51]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_52]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
