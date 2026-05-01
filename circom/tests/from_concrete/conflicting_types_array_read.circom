// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Inner(P) {
    signal input in[4];
    signal output out[4];
    for (var k = 0; k < 4; k++) {
        out[k] <== in[k] + P;
    }
}

template Outer() {
    signal input in[8];
    signal output out[8];

    component inner[2];
    signal mid[2 * 4];

    for (var i = 0; i < 8; i++) {
        mid[i] <== in[i];
    }

    for (var i = 0; i < 2; i++) {
        inner[i] = Inner(i);
        for (var k = 0; k < 4; k++) {
            inner[i].in[k] <== mid[i * 4 + k];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var k = 0; k < 4; k++) {
            out[i * 4 + k] <== inner[i].out[k];
        }
    }
}

component main = Outer();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Outer_2::@Outer_2<[]>>} {
// CHECK-NEXT:    poly.template @Inner_0 {
// CHECK-NEXT:      struct.def @Inner_0 {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_0::@Inner_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_14]]] = %[[VAL_13]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_2]] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner_0::@Inner_0<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_23]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_27]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_31]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_32]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Inner_1 {
// CHECK-NEXT:      struct.def @Inner_1 {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_1::@Inner_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_39]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_43]]) %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_45]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_37]]{{\[}}%[[VAL_49]]] = %[[VAL_48]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_44]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@out] = %[[VAL_37]] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_36]] : !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner_1::@Inner_1<[]>>, %[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@out] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_56]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_58]], %[[VAL_59]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_60]]) %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_62]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_63]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_66]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_67]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_61]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Outer_2 {
// CHECK-NEXT:      struct.def @Outer_2 {
// CHECK-NEXT:        struct.member @out : !array.type<8 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @mid : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:        struct.member @inner : !pod.type<[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:        struct.member @inner$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">>) -> !struct.type<@Outer_2::@Outer_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.new : <@Outer_2::@Outer_2<[]>>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_76]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_78]], %[[VAL_79]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_80]]) %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_82]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_72]]{{\[}}%[[VAL_84]]] = %[[VAL_83]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_81]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_87]], %[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_74]], %[[VAL_91:[0-9a-zA-Z_\.]+]] = %[[VAL_75]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_89]], %[[VAL_92]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_93]]) %[[VAL_89]], %[[VAL_90]], %[[VAL_91]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_96:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_95]], %[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_96]], %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_97]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_101]], %[[VAL_102]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_103]]) %[[VAL_99]], %[[VAL_100]], %[[VAL_101]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_104:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_105:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, %[[VAL_106:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_94]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_108]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_110]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_112]], %[[VAL_114]] : index
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_113]], %[[VAL_115]] : i1, i1
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_112]], %[[VAL_117]] : index
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_113]], %[[VAL_118]] : i1, i1
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_121:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_119]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_104]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_124]]{{\[}}%[[VAL_125]]] = %[[VAL_111]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  pod.write %[[VAL_123]][@in] = %[[VAL_124]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_105]][@idx_1] = %[[VAL_123]] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@count] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_126]], %[[VAL_127]] : index
// CHECK-NEXT:                  pod.write %[[VAL_122]][@count] = %[[VAL_128]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_128]], %[[VAL_129]] : index
// CHECK-NEXT:                  scf.if %[[VAL_130]] {
// CHECK-NEXT:                    %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@params] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_133:[0-9a-zA-Z_\.]+]] = function.call @Inner_1::@Inner_1::@compute(%[[VAL_132]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_122]][@comp] = %[[VAL_133]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_104]][@idx_1] = %[[VAL_122]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_104]], %[[VAL_105]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_134:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_116]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_104]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_105]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_137]]{{\[}}%[[VAL_138]]] = %[[VAL_111]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    pod.write %[[VAL_136]][@in] = %[[VAL_137]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_105]][@idx_0] = %[[VAL_136]] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@count] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_139]], %[[VAL_140]] : index
// CHECK-NEXT:                    pod.write %[[VAL_135]][@count] = %[[VAL_141]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_141]], %[[VAL_142]] : index
// CHECK-NEXT:                    scf.if %[[VAL_143]] {
// CHECK-NEXT:                      %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_135]][@params] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_146:[0-9a-zA-Z_\.]+]] = function.call @Inner_0::@Inner_0::@compute(%[[VAL_145]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_135]][@comp] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_104]][@idx_0] = %[[VAL_135]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_104]], %[[VAL_105]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_147:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_148:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_147]], %[[VAL_148]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_134]]#0, %[[VAL_134]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_121]]#0, %[[VAL_121]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_106]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_120]]#0, %[[VAL_120]]#1, %[[VAL_150]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_94]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_152]], %[[VAL_98]]#0, %[[VAL_98]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_155:[0-9a-zA-Z_\.]+]] = %[[VAL_153]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_155]], %[[VAL_156]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_157]]) %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_158:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_161:[0-9a-zA-Z_\.]+]] = %[[VAL_159]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_163:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_161]], %[[VAL_162]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_163]]) %[[VAL_161]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_164:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_167]] : index
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_166]], %[[VAL_168]] : i1, i1
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_165]], %[[VAL_170]] : index
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_166]], %[[VAL_171]] : i1, i1
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_174:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_172]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_175]][@comp] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  %[[VAL_177:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@out] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_178]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_179]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_180:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_169]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                    %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@comp] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    %[[VAL_183:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_182]][@out] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_185:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_183]]{{\[}}%[[VAL_184]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_185]] : !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_186:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_186]] : !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_180]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_174]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_158]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_188]], %[[VAL_164]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_189]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_73]]{{\[}}%[[VAL_190]]] = %[[VAL_173]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_164]], %[[VAL_191]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_192]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_158]], %[[VAL_193]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_71]][@inner$inputs] = %[[VAL_88]]#2 : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_195]][@comp] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_197]][@comp] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_196]], @idx_1 = %[[VAL_198]] }  : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@inner] = %[[VAL_199]] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@mid] = %[[VAL_72]] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@out] = %[[VAL_73]] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_71]] : !struct.type<@Outer_2::@Outer_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_200:[0-9a-zA-Z_\.]+]]: !struct.type<@Outer_2::@Outer_2<[]>>, %[[VAL_201:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_200]][@out] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_200]][@mid] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_200]][@inner] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_200]][@inner$inputs] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_208:[0-9a-zA-Z_\.]+]] = %[[VAL_206]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_208]], %[[VAL_209]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_210]]) %[[VAL_208]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_211:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_201]]{{\[}}%[[VAL_212]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_203]]{{\[}}%[[VAL_214]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_215]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_211]], %[[VAL_216]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_220:[0-9a-zA-Z_\.]+]] = %[[VAL_218]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_220]], %[[VAL_221]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_222]]) %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_223:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_226:[0-9a-zA-Z_\.]+]] = %[[VAL_224]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_226]], %[[VAL_227]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_228]]) %[[VAL_226]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_229:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_223]], %[[VAL_230]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_231]], %[[VAL_229]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_203]]{{\[}}%[[VAL_233]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_223]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_235]], %[[VAL_237]] : index
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_236]], %[[VAL_238]] : i1, i1
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_235]], %[[VAL_240]] : index
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_236]], %[[VAL_241]] : i1, i1
// CHECK-NEXT:              scf.execute_region {
// CHECK-NEXT:                scf.if %[[VAL_242]] {
// CHECK-NEXT:                  %[[VAL_243:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_243]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_246:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_244]]{{\[}}%[[VAL_245]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_246]], %[[VAL_234]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  scf.if %[[VAL_239]] {
// CHECK-NEXT:                    %[[VAL_247:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_249:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_250:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_248]]{{\[}}%[[VAL_249]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    constrain.eq %[[VAL_250]], %[[VAL_234]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                  }
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_229]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_252]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_223]], %[[VAL_253]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_254]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_257:[0-9a-zA-Z_\.]+]] = %[[VAL_255]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_257]], %[[VAL_258]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_259]]) %[[VAL_257]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_260:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_261:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_262:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_263:[0-9a-zA-Z_\.]+]] = %[[VAL_261]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_265:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_263]], %[[VAL_264]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_265]]) %[[VAL_263]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_266:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_260]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_268:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_267]], %[[VAL_269]] : index
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_268]], %[[VAL_270]] : i1, i1
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_267]], %[[VAL_272]] : index
// CHECK-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_268]], %[[VAL_273]] : i1, i1
// CHECK-NEXT:              %[[VAL_275:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_276:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_274]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@idx_1] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  %[[VAL_278:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_277]][@out] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_279:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_266]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_280:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_279]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_280]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_281:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_271]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                    %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@idx_0] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    %[[VAL_283:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_282]][@out] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_266]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_283]]{{\[}}%[[VAL_284]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_286:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_281]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_276]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_287:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_260]], %[[VAL_287]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_288]], %[[VAL_266]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_289]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_202]]{{\[}}%[[VAL_290]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_291]], %[[VAL_275]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_266]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_293]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_260]], %[[VAL_294]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@idx_0] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:          %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_298:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_297]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Inner_0::@Inner_0::@constrain(%[[VAL_296]], %[[VAL_298]]) : (!struct.type<@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_299:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@idx_1] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:          %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_300]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Inner_1::@Inner_1::@constrain(%[[VAL_299]], %[[VAL_301]]) : (!struct.type<@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
