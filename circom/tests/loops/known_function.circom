// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function funWithLoop(n) {
	var acc = 0;
    for (var i = 1; i <= n; i++) {
        acc += i;
    }
    return acc;
}

template KnownFunctionArgs() {
    signal output out[3];

    out[0] <-- funWithLoop(4); // 0 + 1 + 2 + 3 + 4 = 10
    out[1] <-- funWithLoop(5); // 0 + 1 + 2 + 3 + 4 + 5 = 15

    var acc = 1;
    for (var i = 2; i <= funWithLoop(3); i++) { // 0 + 1 + 2 + 3 = 6
        acc *= i;
    }
    out[2] <-- acc; // 1 * 2 * 3 * 4 * 5 * 6 = 720
}

component main = KnownFunctionArgs();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@KnownFunctionArgs<[]>>} {
// CHECK-NEXT:    function.def @funWithLoop(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !felt.type attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      %[[VAL_1:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:      %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:      %[[VAL_3:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_4:[0-9a-zA-Z_\.]+]] = %[[VAL_1]], %[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_5]], %[[VAL_0]])
// CHECK-NEXT:        scf.condition(%[[VAL_6]]) %[[VAL_4]], %[[VAL_5]] : !felt.type, !felt.type
// CHECK-NEXT:      } do {
// CHECK-NEXT:      ^bb0(%[[VAL_7:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_7]], %[[VAL_8]] : !felt.type, !felt.type
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_8]], %[[VAL_10]] : !felt.type, !felt.type
// CHECK-NEXT:        scf.yield %[[VAL_9]], %[[VAL_11]] : !felt.type, !felt.type
// CHECK-NEXT:      }
// CHECK-NEXT:      function.return %[[VAL_3]]#0 : !felt.type
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @KnownFunctionArgs<[]> {
// CHECK-NEXT:      struct.member @out : !array.type<3 x !felt.type> {llzk.pub}
// CHECK-NEXT:      function.def @compute() -> !struct.type<@KnownFunctionArgs<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]] = struct.new : <@KnownFunctionArgs<[]>>
// CHECK-NEXT:        %[[VAL_13:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type>
// CHECK-NEXT:        %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:        %[[VAL_15:[0-9a-zA-Z_\.]+]] = function.call @funWithLoop(%[[VAL_14]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:        array.write %[[VAL_13]]{{\[}}%[[VAL_17]]] = %[[VAL_15]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  5
// CHECK-NEXT:        %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @funWithLoop(%[[VAL_18]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:        %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]]
// CHECK-NEXT:        array.write %[[VAL_13]]{{\[}}%[[VAL_21]]] = %[[VAL_19]] : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_24:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_22]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @funWithLoop(%[[VAL_27]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_26]], %[[VAL_28]])
// CHECK-NEXT:          scf.condition(%[[VAL_29]]) %[[VAL_25]], %[[VAL_26]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_30]], %[[VAL_31]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_33]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_32]], %[[VAL_34]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]]
// CHECK-NEXT:        array.write %[[VAL_13]]{{\[}}%[[VAL_36]]] = %[[VAL_24]]#0 : <3 x !felt.type>, !felt.type
// CHECK-NEXT:        struct.writem %[[VAL_12]][@out] = %[[VAL_13]] : <@KnownFunctionArgs<[]>>, !array.type<3 x !felt.type>
// CHECK-NEXT:        function.return %[[VAL_12]] : !struct.type<@KnownFunctionArgs<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !struct.type<@KnownFunctionArgs<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %{{[0-9a-zA-Z_\.]+}} = struct.readm %[[VAL_37]][@out] : <@KnownFunctionArgs<[]>>, !array.type<3 x !felt.type>
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_38]], %[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_39]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = function.call @funWithLoop(%[[VAL_43]]) : (!felt.type) -> !felt.type
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_42]], %[[VAL_44]])
// CHECK-NEXT:          scf.condition(%[[VAL_45]]) %[[VAL_41]], %[[VAL_42]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_47:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_46]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_48]], %[[VAL_50]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
