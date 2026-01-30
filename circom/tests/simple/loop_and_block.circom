// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
  signal input inp[n];
  signal output out[n];

  for ( var i = 0; i < n; i++ ) {
    out[i] <-- inp[i];
  }
}

component main = A(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK-NEXT:    struct.def @A<[@n]> {
// CHECK-NEXT:      struct.field @out : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A<[@n]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = undef.undef : !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_9]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]]
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_11]]] = %[[VAL_10]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_12]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_13]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writef %[[VAL_1]][@out] = %[[VAL_3]] : <@A<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@A<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !struct.type<@A<[@n]>>, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %{{[0-9a-zA-Z_\.]+}} = struct.readf %[[VAL_14]][@out] : <@A<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_19]], %[[VAL_16]])
// CHECK-NEXT:          scf.condition(%[[VAL_20]]) %[[VAL_19]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_23]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
