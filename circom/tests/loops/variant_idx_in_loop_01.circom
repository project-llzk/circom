// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template VariantIndex(n) {
    signal input in;
    signal output out[n];

    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i);
    }
}

component main = VariantIndex(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@VariantIndex<[2]>>} {
// CHECK-NEXT:    poly.template @VariantIndex {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @VariantIndex {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@VariantIndex::@VariantIndex<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@VariantIndex::@VariantIndex<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_7]]) %[[VAL_6]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.shr %[[VAL_0]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_10]]] = %[[VAL_9]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_12]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@VariantIndex::@VariantIndex<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@VariantIndex::@VariantIndex<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !struct.type<@VariantIndex::@VariantIndex<[@n]>>, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_13]][@out] : <@VariantIndex::@VariantIndex<[@n]>>, !array.type<@n x !felt.type>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_19]], %[[VAL_15]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_20]]) %[[VAL_19]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_22]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_23]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
