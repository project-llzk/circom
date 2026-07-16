// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// COM: Adapted from `bigint.circom` in https://github.com/yi-sun/circom-pairing

pragma circom 2.0.0;

function long_sub(k, a, b) {
    var d[9];
    for (var i = 1; i < k; i++) { // 3 iterations b/c k=4
        if (a[i] >= b[i]) {
            d[i] = a[i] - b[i];
        }
    }
    return d;
}

function long_div(k, in) {
    var out[9];
    for (var i = k; i >= 0; i--) { // 5 iterations b/c k=4
        var sub[9] = in;
        var mul[9] = out;
        for (var j = 0; j <= k; j++) { // 5 iterations b/c k=4
            sub[i + j] = mul[j];
        }
        out = long_sub(k, out, sub);
    }
    return out;
}

template BigMod() {
  signal input in[9];
  signal output out[9];
  out <-- long_div(4, in);
}

component main = BigMod();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@BigMod::@BigMod<[]>>} {
// CHECK-NEXT:    poly.template @long_div {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @long_div(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "k"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "in"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]], %[[VAL_2]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">, !array.type<9 x !felt.type<"bn128">>) -> (!felt.type<"bn128">, !array.type<9 x !felt.type<"bn128">>) {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_6]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_9]]) %[[VAL_6]], %[[VAL_7]] : !felt.type<"bn128">, !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !array.type<9 x !felt.type<"bn128">>):
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_12]], %[[VAL_12]], %[[VAL_12]], %[[VAL_12]], %[[VAL_12]], %[[VAL_12]], %[[VAL_12]], %[[VAL_12]], %[[VAL_12]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]], %[[VAL_15]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_19:[0-9a-zA-Z_\.]+]] = %[[VAL_17]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp le(%[[VAL_19]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_21]]) %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_22:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_23]]] : <9 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_14]]{{\[}}%[[VAL_26]]] = %[[VAL_24]] : <9 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @long_sub::@long_sub<[?, ?, ?, ?, ?, ?, ?, ?]>(%[[VAL_0]], %[[VAL_11]], %[[VAL_14]]) : (!poly.tvar<@T_arg0>, !array.type<9 x !felt.type<"bn128">>, !array.type<9 x !felt.type<"bn128">>) -> !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_10]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_31]], %[[VAL_29]] : !felt.type<"bn128">, !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]]#1 : (!array.type<9 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_32]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @long_sub {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @long_sub(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "k"}, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "a"}, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2> {function.arg_name = "b"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_36]], %[[VAL_36]], %[[VAL_36]], %[[VAL_36]], %[[VAL_36]], %[[VAL_36]], %[[VAL_36]], %[[VAL_36]], %[[VAL_36]] : <9 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_33]] : (!poly.tvar<@T_arg0>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_40]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_42]]) %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_34]] : (!poly.tvar<@T_arg1>) -> !array.type<? x !poly.tvar<@"$e_1">>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_44]]] : <? x !poly.tvar<@"$e_1">>, !poly.tvar<@"$e_1">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_35]] : (!poly.tvar<@T_arg2>) -> !array.type<? x !poly.tvar<@"$e_2">>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_47]]] : <? x !poly.tvar<@"$e_2">>, !poly.tvar<@"$e_2">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_46]] : (!poly.tvar<@"$e_1">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_49]] : (!poly.tvar<@"$e_2">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_50]], %[[VAL_51]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.if %[[VAL_52]] {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_34]] : (!poly.tvar<@T_arg1>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_53]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_35]] : (!poly.tvar<@T_arg2>) -> !array.type<? x !poly.tvar<@"$e_0">>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_56]]] : <? x !poly.tvar<@"$e_0">>, !poly.tvar<@"$e_0">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_55]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_58]] : (!poly.tvar<@"$e_0">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_59]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_37]]{{\[}}%[[VAL_62]]] = %[[VAL_61]] : <9 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_63]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_65:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_37]] : (!array.type<9 x !felt.type<"bn128">>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_65]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:      poly.param @"$e_0" : !poly.tvar<@"$e_0">
// CHECK-NEXT:      poly.param @"$e_1" : !poly.tvar<@"$e_1">
// CHECK-NEXT:      poly.param @"$e_2" : !poly.tvar<@"$e_2">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @BigMod {
// CHECK-NEXT:      struct.def @BigMod {
// CHECK-NEXT:        struct.member @out : !array.type<9 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !array.type<9 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@BigMod::@BigMod<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.new : <@BigMod::@BigMod<[]>>
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = function.call @long_div::@long_div(%[[VAL_68]], %[[VAL_66]]) : (!felt.type<"bn128">, !array.type<9 x !felt.type<"bn128">>) -> !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_67]][@out] = %[[VAL_69]] : <@BigMod::@BigMod<[]>>, !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_67]] : !struct.type<@BigMod::@BigMod<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !struct.type<@BigMod::@BigMod<[]>>, %[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<9 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_70]][@out] : <@BigMod::@BigMod<[]>>, !array.type<9 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
