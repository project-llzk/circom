// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// COM: Lit variables cannot be set at the "undef : !array.type<@N x !felt.type>" instances because their
// COM: ordering is non-deterministic. The lit variable is instead set at the first use of the MLIR value.
//
// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Foo<[@N]> {
// CHECK-NEXT:      struct.field @outp : !array.type<@N x !felt.type> {llzk.pub}
// CHECK-NEXT:      struct.field @internal : !array.type<@N x !felt.type>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) -> !struct.type<@Foo<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo<[@N]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<@N x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<@N x !felt.type>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]]
// CHECK-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_12]]] = %[[VAL_11]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_13]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_14]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_15]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_18]]) %[[VAL_17]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4]]{{\[}}%[[VAL_20]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]]
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_22]]] = %[[VAL_21]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_23]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_24]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@internal] = %[[VAL_4]] : <@Foo<[@N]>>, !array.type<@N x !felt.type>
// CHECK-NEXT:        struct.writef %[[VAL_1]][@outp] = %[[VAL_3]] : <@Foo<[@N]>>, !array.type<@N x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Foo<[@N]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo<[@N]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_28:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<@N x !felt.type>
// CHECK-NEXT:        %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_30:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_31:[0-9a-zA-Z_\.]+]] = %[[VAL_29]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_31]], %[[VAL_27]])
// CHECK-NEXT:          scf.condition(%[[VAL_32]]) %[[VAL_31]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]]
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_26]]{{\[}}%[[VAL_34]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_25]][@internal] : <@Foo<[@N]>>, !array.type<@N x !felt.type>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]]
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_37]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_38]], %[[VAL_35]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_33]], %[[VAL_39]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_40]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_43]], %[[VAL_27]])
// CHECK-NEXT:          scf.condition(%[[VAL_44]]) %[[VAL_43]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]]
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_46]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_25]][@outp] : <@Foo<[@N]>>, !array.type<@N x !felt.type>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]]
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_49]]] : <@N x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_50]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_45]], %[[VAL_51]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_52]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
