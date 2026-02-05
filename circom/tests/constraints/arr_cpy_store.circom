// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.main = !struct.type<@Foo<[2]>>, veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @Foo<[@N]> {
// CHECK-NEXT:      struct.field @c : !struct.type<@Sum<[@N]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) -> !struct.type<@Foo<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Foo<[@N]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = function.call @Sum::@compute(%[[VAL_0]]) : (!array.type<@N x !felt.type>) -> !struct.type<@Sum<[@N]>>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_6]], %[[VAL_6]])
// CHECK-NEXT:          scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_9]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_10]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_2]][@c] = %[[VAL_4]] : <@Foo<[@N]>>, !struct.type<@Sum<[@N]>>
// CHECK-NEXT:        function.return %[[VAL_2]] : !struct.type<@Foo<[@N]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !struct.type<@Foo<[@N]>>, %[[VAL_12:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>, %[[VAL_13:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = struct.readf %[[VAL_11]][@c] : <@Foo<[@N]>>, !struct.type<@Sum<[@N]>>
// CHECK-NEXT:        function.call @Sum::@constrain(%[[VAL_15]], %[[VAL_12]]) : (!struct.type<@Sum<[@N]>>, !array.type<@N x !felt.type>) -> ()
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_14]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_17]], %[[VAL_17]])
// CHECK-NEXT:          scf.condition(%[[VAL_18]]) %[[VAL_17]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_20]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_21]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Sum<[@N]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) -> !struct.type<@Sum<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum<[@N]>>
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        function.return %[[VAL_23]] : !struct.type<@Sum<[@N]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum<[@N]>>, %[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<@N x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
