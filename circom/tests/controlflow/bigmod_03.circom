// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function long_div2(n, k, m, a) {
    var dividend[5];
    for (var i = m; i >= 0; i--) {
        if (i == m) {
            dividend[k] = 0;
            for (var j = 0; j < k; j++) {
                dividend[j] = a[j + m];
            }
        }
    }
    return dividend;
}

template BigModOld(n, k) {
    signal input a[2 * k];
    var r[5] = long_div2(n, k, k, a);
}

component main = BigModOld(8, 2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@BigModOld::@BigModOld<[8, 2]>>} {
// CHECK-NEXT:    poly.template @long_div2 {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_arg3 : !poly.tvar<@T_arg3>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @long_div2(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "n"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "k"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2> {function.arg_name = "m"}, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg3> {function.arg_name = "a"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]], %[[VAL_4]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_8]], %[[VAL_9]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_10]]) %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_11]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_13]] {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> index
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_15]]] = %[[VAL_14]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_16]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_18]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_20]]) %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_24]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_26]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_5]]{{\[}}%[[VAL_27]]] = %[[VAL_28]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_11]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!array.type<5 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_33]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @BigModOld {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.param @k
// CHECK-NEXT:      poly.expr @"2_Mul_k@[[OFFSET0:[0-9]+]]" {
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_35]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_37]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @BigModOld {
// CHECK-NEXT:        function.def @compute(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<@"2_Mul_k@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@BigModOld::@BigModOld<[@n, @k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.new : <@BigModOld::@BigModOld<[@n, @k]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.read_const @"2_Mul_k@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_40]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_44]], %[[VAL_44]], %[[VAL_44]], %[[VAL_44]], %[[VAL_44]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = function.call @long_div2::@long_div2<[?, ?, ?, ?, ?, ?]>(%[[VAL_43]], %[[VAL_42]], %[[VAL_42]], %[[VAL_38]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !array.type<@"2_Mul_k@[[OFFSET0]]" x !felt.type<"bn128">>) -> !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_39]] : !struct.type<@BigModOld::@BigModOld<[@n, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_47:[0-9a-zA-Z_\.]+]]: !struct.type<@BigModOld::@BigModOld<[@n, @k]>>, %[[VAL_48:[0-9a-zA-Z_\.]+]]: !array.type<@"2_Mul_k@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.read_const @"2_Mul_k@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_49]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_53]], %[[VAL_53]], %[[VAL_53]], %[[VAL_53]], %[[VAL_53]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = function.call @long_div2::@long_div2<[?, ?, ?, ?, ?, ?]>(%[[VAL_52]], %[[VAL_51]], %[[VAL_51]], %[[VAL_48]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !array.type<@"2_Mul_k@[[OFFSET0]]" x !felt.type<"bn128">>) -> !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
