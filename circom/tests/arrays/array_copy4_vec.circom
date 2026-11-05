// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

// Vector copy version of `array_copy1_loop.circom` test.
template Array4(n, m, S) {
    signal output out[n][m];

    out <== S;
}

component main = Array4(3, 2, [[11,22],[33,44],[55,66]]);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Array4$arrays$2_3_2::@Array4$arrays$2_3_2<[3, 2, 11, 22, 33, 44, 55, 66]>>} {
// CHECK-NEXT:    poly.template @Array4$arrays$2_3_2 {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @m : index
// CHECK-NEXT:      poly.param @"$array$S$0"
// CHECK-NEXT:      poly.param @"$array$S$1"
// CHECK-NEXT:      poly.param @"$array$S$2"
// CHECK-NEXT:      poly.param @"$array$S$3"
// CHECK-NEXT:      poly.param @"$array$S$4"
// CHECK-NEXT:      poly.param @"$array$S$5"
// CHECK-NEXT:      struct.def @Array4$arrays$2_3_2 {
// CHECK-NEXT:        struct.member @out : !array.type<@n,@m x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@Array4$arrays$2_3_2::@Array4$arrays$2_3_2<[@n, @m, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4", @"$array$S$5"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@Array4$arrays$2_3_2::@Array4$arrays$2_3_2<[@n, @m, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4", @"$array$S$5"]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$1" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$2" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$3" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$4" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$5" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_9]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_1]], %[[VAL_2]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_3]], %[[VAL_4]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_5]], %[[VAL_6]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.new  : <3,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_14]]{{\[}}%[[VAL_15]]] = %[[VAL_11]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_14]]{{\[}}%[[VAL_16]]] = %[[VAL_12]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_14]]{{\[}}%[[VAL_17]]] = %[[VAL_13]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_14]] : (!array.type<3,2 x !felt.type<"bn128">>) -> !array.type<@n,@m x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_18]] : <@Array4$arrays$2_3_2::@Array4$arrays$2_3_2<[@n, @m, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4", @"$array$S$5"]>>, !array.type<@n,@m x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@Array4$arrays$2_3_2::@Array4$arrays$2_3_2<[@n, @m, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4", @"$array$S$5"]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !struct.type<@Array4$arrays$2_3_2::@Array4$arrays$2_3_2<[@n, @m, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4", @"$array$S$5"]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$0" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$1" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$2" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$3" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$4" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.read_const @"$array$S$5" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_26]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_28]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_19]][@out] : <@Array4$arrays$2_3_2::@Array4$arrays$2_3_2<[@n, @m, @"$array$S$0", @"$array$S$1", @"$array$S$2", @"$array$S$3", @"$array$S$4", @"$array$S$5"]>>, !array.type<@n,@m x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_20]], %[[VAL_21]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_22]], %[[VAL_23]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_24]], %[[VAL_25]] : <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.new  : <3,2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_35]]] = %[[VAL_31]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_36]]] = %[[VAL_32]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          array.insert %[[VAL_34]]{{\[}}%[[VAL_37]]] = %[[VAL_33]] : <3,2 x !felt.type<"bn128">>, <2 x !felt.type<"bn128">>
// CHECK-NEXT:          constrain.eq %[[VAL_30]], %[[VAL_34]] : !array.type<@n,@m x !felt.type<"bn128">>, !array.type<3,2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
