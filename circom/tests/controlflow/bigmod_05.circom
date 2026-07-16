// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function long_div2(n, k, m, a) {
    var dividend[5];
    for (var i = m; i >= 0; i--) {
        if (i == m) {
            dividend[k] = 0;
            for (var j = k - 1; j >= 0; j-=2) {
                dividend[j] = a[j + m];
            }
            for (var j = k - 2; j >= 0; j-=2) {
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
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_17]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_20]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_22]]) %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_26]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_28]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_5]]{{\[}}%[[VAL_29]]] = %[[VAL_30]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_23]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_34]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_37:[0-9a-zA-Z_\.]+]] = %[[VAL_35]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_37]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_39]]) %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !array.type<? x !poly.tvar<@"$e_0">>
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_43]]] : <? x !poly.tvar<@"$e_0">>, !poly.tvar<@"$e_0">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_45]] : (!poly.tvar<@"$e_0">) -> !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_5]]{{\[}}%[[VAL_46]]] = %[[VAL_47]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_40]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_11]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!array.type<5 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_52]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:      poly.param @"$e_0" : !poly.tvar<@"$e_0">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @BigModOld {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.param @k
// CHECK-NEXT:      poly.expr @"2_Mul_k@664" {
// CHECK-NEXT:        %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_54]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_56]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @BigModOld {
// CHECK-NEXT:        function.def @compute(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<@"2_Mul_k@664" x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@BigModOld::@BigModOld<[@n, @k]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.new : <@BigModOld::@BigModOld<[@n, @k]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = poly.read_const @"2_Mul_k@664" : index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_59]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_63]], %[[VAL_63]], %[[VAL_63]], %[[VAL_63]], %[[VAL_63]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = function.call @long_div2::@long_div2<[?, ?, ?, ?, ?, ?, ?]>(%[[VAL_62]], %[[VAL_61]], %[[VAL_61]], %[[VAL_57]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !array.type<@"2_Mul_k@664" x !felt.type<"bn128">>) -> !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_58]] : !struct.type<@BigModOld::@BigModOld<[@n, @k]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !struct.type<@BigModOld::@BigModOld<[@n, @k]>>, %[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<@"2_Mul_k@664" x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = poly.read_const @"2_Mul_k@664" : index
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_68]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = poly.read_const @k : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_72]], %[[VAL_72]], %[[VAL_72]], %[[VAL_72]], %[[VAL_72]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = function.call @long_div2::@long_div2<[?, ?, ?, ?, ?, ?, ?]>(%[[VAL_71]], %[[VAL_70]], %[[VAL_70]], %[[VAL_67]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !array.type<@"2_Mul_k@664" x !felt.type<"bn128">>) -> !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
