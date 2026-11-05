// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template T(n, S) {
    signal output out[n] <== S;
}

component main = T(5, [11,22,33,44,55]);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@T$arrays$1_5::@T$arrays$1_5<[5, 11, 22, 33, 44, 55]>>} {
// CHECK-NEXT:    poly.template @T$arrays$1_5 {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @"$array$S$0"
// CHECK-NEXT:      poly.param @"$array$S$1"
// CHECK-NEXT:      poly.param @"$array$S$2"
// CHECK-NEXT:      poly.param @"$array$S$3"
// CHECK-NEXT:      poly.param @"$array$S$4"
// CHECK-NEXT:      struct.def @T$arrays$1_5 {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$1" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$2" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$3" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$4" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_6]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_2]], %[[VAL_3]], %[[VAL_4]], %[[VAL_5]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_8]] : (!array.type<5 x !felt.type<"bn128">>) -> !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_9]] : <@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !struct.type<@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$1" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$2" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$3" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$4" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_16]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_10]][@out] : <@T$arrays$1_5::@T$arrays$1_5<[@n, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4"]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_11]], %[[VAL_12]], %[[VAL_13]], %[[VAL_14]], %[[VAL_15]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_18]], %[[VAL_19]] : !array.type<@n x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
