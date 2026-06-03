// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ForUnknownIndex() {
    signal input in;
    signal input arr[10];
    signal output out;

    var acc = 0;
    for (var i = 1; i <= in; i++) {
        acc += i;
    }

    // non-quadractic constraint
    // out <== arr[acc];
    out <-- arr[acc];
}

component main = ForUnknownIndex();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>>} {
// CHECK-NEXT:    poly.template @ForUnknownIndex {
// CHECK-NEXT:      struct.def @ForUnknownIndex {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "arr"}) -> !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@ForUnknownIndex::@ForUnknownIndex<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_7]], %[[VAL_0]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_6]], %[[VAL_7]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_11]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]]#0 : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_14]]] : <10 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@out] = %[[VAL_15]] : <@ForUnknownIndex::@ForUnknownIndex<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@ForUnknownIndex::@ForUnknownIndex<[]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<10 x !felt.type<"bn128">> {function.arg_name = "arr"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@out] : <@ForUnknownIndex::@ForUnknownIndex<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_24]], %[[VAL_17]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
