// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template InnerConditional5(N, T) {
    signal output out[N];

    for (var i = 0; i < N; i++) {
        if (T == 0) {
            out[i] <-- 777;
        } else {
            out[i] <-- 999;
        }
    }
}

template runner() {
    signal output out;

    component a = InnerConditional5(4, 0);
    component b = InnerConditional5(5, 1);

    out <-- a.out[1] + b.out[0];
}

component main = runner();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@runner::@runner<[]>>} {
// CHECK-NEXT:    poly.template @InnerConditional5 {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      poly.param @T
// CHECK-NEXT:      struct.def @InnerConditional5 {
// CHECK-NEXT:        struct.member @out : !array.type<@N x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@InnerConditional5::@InnerConditional5<[@N, @T]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@InnerConditional5::@InnerConditional5<[@N, @T]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @T : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_3]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_11]] {
// CHECK-NEXT:              %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  777 : <"bn128">
// CHECK-NEXT:              %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_15]]] = %[[VAL_14]] : <@N x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@out] = %[[VAL_4]] : <@InnerConditional5::@InnerConditional5<[@N, @T]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@InnerConditional5::@InnerConditional5<[@N, @T]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@InnerConditional5::@InnerConditional5<[@N, @T]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @T : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@out] : <@InnerConditional5::@InnerConditional5<[@N, @T]>>, !array.type<@N x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_20]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_21]], %[[VAL_28]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_29]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @runner {
// CHECK-NEXT:      struct.def @runner {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a : !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[]>
// CHECK-NEXT:        struct.member @b : !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[]>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@runner::@runner<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.new : <@runner::@runner<[]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_35]], @T = %[[VAL_36]] }  : <[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @InnerConditional5::@InnerConditional5::@compute() : () -> !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_39]] }  : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_41]], @T = %[[VAL_42]] }  : <[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @InnerConditional5::@InnerConditional5::@compute() : () -> !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_45]] }  : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>, !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_47]][@out] : <@InnerConditional5::@InnerConditional5<[4, 0]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_50]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>, !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@out] : <@InnerConditional5::@InnerConditional5<[5, 1]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_55]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_56]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_32]][@out] = %[[VAL_57]] : <@runner::@runner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_32]][@a$inputs] = %[[VAL_33]] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>, !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>
// CHECK-NEXT:          struct.writem %[[VAL_32]][@a] = %[[VAL_58]] : <@runner::@runner<[]>>, !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>
// CHECK-NEXT:          struct.writem %[[VAL_32]][@b$inputs] = %[[VAL_34]] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_46]][@comp] : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>, !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>
// CHECK-NEXT:          struct.writem %[[VAL_32]][@b] = %[[VAL_59]] : <@runner::@runner<[]>>, !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>
// CHECK-NEXT:          function.return %[[VAL_32]] : !struct.type<@runner::@runner<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !struct.type<@runner::@runner<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@out] : <@runner::@runner<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@a] : <@runner::@runner<[]>>, !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@a$inputs] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@b] : <@runner::@runner<[]>>, !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@b$inputs] : <@runner::@runner<[]>>, !pod.type<[]>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_66]], @T = %[[VAL_67]] }  : <[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new { @N = %[[VAL_70]], @T = %[[VAL_71]] }  : <[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>, @params: !pod.type<[@N: !felt.type<"bn128">, @T: !felt.type<"bn128">]>]>
// CHECK-NEXT:          function.call @InnerConditional5::@InnerConditional5::@constrain(%[[VAL_62]]) : (!struct.type<@InnerConditional5::@InnerConditional5<[4, 0]>>) -> ()
// CHECK-NEXT:          function.call @InnerConditional5::@InnerConditional5::@constrain(%[[VAL_64]]) : (!struct.type<@InnerConditional5::@InnerConditional5<[5, 1]>>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
