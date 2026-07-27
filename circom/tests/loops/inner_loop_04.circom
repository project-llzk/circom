// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerLoops(n) {
    signal input a[n];
    var b[n];
    var j;
    for (var i = 0; i < n; i++) {
        for (j = 0; j <= i; j++) {
            b[i] = a[i - j];
        }
    }
}

component main = InnerLoops(2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@InnerLoops::@InnerLoops<[2]>>} {
// CHECK-NEXT:    poly.template @InnerLoops {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @InnerLoops {
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@InnerLoops::@InnerLoops<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_5]], %[[VAL_6]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_8]] to %[[VAL_7]] step %[[VAL_9]] {
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_10]]] = %[[VAL_4]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_15]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_17]]) %[[VAL_14]], %[[VAL_15]], %[[VAL_16]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_18]], %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_24]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_25]]) %[[VAL_23]], %[[VAL_24]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_19]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_29]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_26]]{{\[}}%[[VAL_31]]] = %[[VAL_30]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_26]], %[[VAL_33]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_22]]#0, %[[VAL_35]], %[[VAL_22]]#1 : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@InnerLoops::@InnerLoops<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_36:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerLoops::@InnerLoops<[@n]>>, %[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_38]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_41]], %[[VAL_42]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_46:[0-9a-zA-Z_\.]+]] = %[[VAL_44]] to %[[VAL_43]] step %[[VAL_45]] {
// CHECK-NEXT:            array.write %[[VAL_41]]{{\[}}%[[VAL_46]]] = %[[VAL_40]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_50:[0-9a-zA-Z_\.]+]] = %[[VAL_41]], %[[VAL_51:[0-9a-zA-Z_\.]+]] = %[[VAL_48]], %[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_47]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_51]], %[[VAL_39]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_53]]) %[[VAL_50]], %[[VAL_51]], %[[VAL_52]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_54:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_55:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_54]], %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_57]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_60]], %[[VAL_55]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_61]]) %[[VAL_59]], %[[VAL_60]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_63:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_55]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_65]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_62]]{{\[}}%[[VAL_67]]] = %[[VAL_66]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_63]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_62]], %[[VAL_69]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_55]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_58]]#0, %[[VAL_71]], %[[VAL_58]]#1 : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
