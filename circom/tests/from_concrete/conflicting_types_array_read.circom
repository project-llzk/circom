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
            // Failed to generate LLZK IR: Conflicting types to read array at loc("conflicting_types_array_read.circom":31:13)
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
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_87]], %[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_75]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_89]], %[[VAL_91]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_92]]) %[[VAL_89]], %[[VAL_90]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_93:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_94:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_94]], %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_95]]) : (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_98]], %[[VAL_99]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_100]]) %[[VAL_97]], %[[VAL_98]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, %[[VAL_102:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_93]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_104]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_106]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_108]], %[[VAL_110]] : index
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_109]], %[[VAL_111]] : i1, i1
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_108]], %[[VAL_113]] : index
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_109]], %[[VAL_114]] : i1, i1
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]> {
// CHECK-NEXT:                %[[VAL_117:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_115]] -> (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_118]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_119]]{{\[}}%[[VAL_120]]] = %[[VAL_107]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                  %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_121]], %[[VAL_123]] : index
// CHECK-NEXT:                  %[[VAL_125:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_122]], %[[VAL_124]] : i1, i1
// CHECK-NEXT:                  %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_121]], %[[VAL_126]] : index
// CHECK-NEXT:                  %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_122]], %[[VAL_127]] : i1, i1
// CHECK-NEXT:                  %[[VAL_129:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]> {
// CHECK-NEXT:                    %[[VAL_130:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_128]] -> (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                      %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                      pod.write %[[VAL_131]][@in] = %[[VAL_119]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_132:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                      scf.yield %[[VAL_101]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    } else {
// CHECK-NEXT:                      %[[VAL_133:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_125]] -> (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                        %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                        pod.write %[[VAL_134]][@in] = %[[VAL_119]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                        %[[VAL_135:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                        scf.yield %[[VAL_101]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                      } else {
// CHECK-NEXT:                        %[[VAL_136:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                        scf.yield %[[VAL_136]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                      }
// CHECK-NEXT:                      scf.yield %[[VAL_133]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    scf.yield %[[VAL_130]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                  %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_137]], %[[VAL_139]] : index
// CHECK-NEXT:                  %[[VAL_141:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_138]], %[[VAL_140]] : i1, i1
// CHECK-NEXT:                  %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_137]], %[[VAL_142]] : index
// CHECK-NEXT:                  %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_138]], %[[VAL_143]] : i1, i1
// CHECK-NEXT:                  scf.execute_region {
// CHECK-NEXT:                    scf.if %[[VAL_144]] {
// CHECK-NEXT:                      %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                      %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                      %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                      %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                      %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_148]] : index
// CHECK-NEXT:                      %[[VAL_150:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_147]], %[[VAL_149]] : i1, i1
// CHECK-NEXT:                      %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                      %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_151]] : index
// CHECK-NEXT:                      %[[VAL_153:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_147]], %[[VAL_152]] : i1, i1
// CHECK-NEXT:                      %[[VAL_154:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {
// CHECK-NEXT:                        %[[VAL_155:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_153]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                          %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          scf.yield %[[VAL_156]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                        } else {
// CHECK-NEXT:                          %[[VAL_157:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_150]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                            %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            scf.yield %[[VAL_158]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          } else {
// CHECK-NEXT:                            %[[VAL_159:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            scf.yield %[[VAL_159]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          }
// CHECK-NEXT:                          scf.yield %[[VAL_157]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                        }
// CHECK-NEXT:                        scf.yield %[[VAL_155]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                      }
// CHECK-NEXT:                      %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@count] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                      %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                      %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_160]], %[[VAL_161]] : index
// CHECK-NEXT:                      pod.write %[[VAL_145]][@count] = %[[VAL_162]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                      %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                      %[[VAL_164:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_162]], %[[VAL_163]] : index
// CHECK-NEXT:                      scf.if %[[VAL_164]] {
// CHECK-NEXT:                        %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@params] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                        %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_154]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                        %[[VAL_167:[0-9a-zA-Z_\.]+]] = function.call @Inner_1::@Inner_1::@compute(%[[VAL_166]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                        pod.write %[[VAL_145]][@comp] = %[[VAL_167]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                        %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                      }
// CHECK-NEXT:                    } else {
// CHECK-NEXT:                      scf.if %[[VAL_141]] {
// CHECK-NEXT:                        %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                        %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                        %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                        %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                        %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_172]] : index
// CHECK-NEXT:                        %[[VAL_174:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_171]], %[[VAL_173]] : i1, i1
// CHECK-NEXT:                        %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                        %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_175]] : index
// CHECK-NEXT:                        %[[VAL_177:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_171]], %[[VAL_176]] : i1, i1
// CHECK-NEXT:                        %[[VAL_178:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {
// CHECK-NEXT:                          %[[VAL_179:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_177]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                            %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            scf.yield %[[VAL_180]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          } else {
// CHECK-NEXT:                            %[[VAL_181:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_174]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                              %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                              scf.yield %[[VAL_182]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            } else {
// CHECK-NEXT:                              %[[VAL_183:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                              scf.yield %[[VAL_183]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            }
// CHECK-NEXT:                            scf.yield %[[VAL_181]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          }
// CHECK-NEXT:                          scf.yield %[[VAL_179]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                        }
// CHECK-NEXT:                        %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@count] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                        %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                        %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_184]], %[[VAL_185]] : index
// CHECK-NEXT:                        pod.write %[[VAL_169]][@count] = %[[VAL_186]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                        %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                        %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_186]], %[[VAL_187]] : index
// CHECK-NEXT:                        scf.if %[[VAL_188]] {
// CHECK-NEXT:                          %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@params] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                          %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_178]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                          %[[VAL_191:[0-9a-zA-Z_\.]+]] = function.call @Inner_0::@Inner_0::@compute(%[[VAL_190]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                          pod.write %[[VAL_169]][@comp] = %[[VAL_191]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                          %[[VAL_192:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                        }
// CHECK-NEXT:                      } else {
// CHECK-NEXT:                      }
// CHECK-NEXT:                    }
// CHECK-NEXT:                    scf.yield
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_101]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_193:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_112]] -> (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_196:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_102]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_195]]{{\[}}%[[VAL_196]]] = %[[VAL_107]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                    %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_197]], %[[VAL_199]] : index
// CHECK-NEXT:                    %[[VAL_201:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_198]], %[[VAL_200]] : i1, i1
// CHECK-NEXT:                    %[[VAL_202:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_203:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_197]], %[[VAL_202]] : index
// CHECK-NEXT:                    %[[VAL_204:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_198]], %[[VAL_203]] : i1, i1
// CHECK-NEXT:                    %[[VAL_205:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]> {
// CHECK-NEXT:                      %[[VAL_206:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_204]] -> (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                        %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                        pod.write %[[VAL_207]][@in] = %[[VAL_195]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                        %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                        scf.yield %[[VAL_101]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                      } else {
// CHECK-NEXT:                        %[[VAL_209:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_201]] -> (!pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                          %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          pod.write %[[VAL_210]][@in] = %[[VAL_195]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                          %[[VAL_211:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                          scf.yield %[[VAL_101]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                        } else {
// CHECK-NEXT:                          %[[VAL_212:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                          scf.yield %[[VAL_212]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                        }
// CHECK-NEXT:                        scf.yield %[[VAL_209]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                      }
// CHECK-NEXT:                      scf.yield %[[VAL_206]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    %[[VAL_213:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                    %[[VAL_215:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_216:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_215]] : index
// CHECK-NEXT:                    %[[VAL_217:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_214]], %[[VAL_216]] : i1, i1
// CHECK-NEXT:                    %[[VAL_218:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_213]], %[[VAL_218]] : index
// CHECK-NEXT:                    %[[VAL_220:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_214]], %[[VAL_219]] : i1, i1
// CHECK-NEXT:                    scf.execute_region {
// CHECK-NEXT:                      scf.if %[[VAL_220]] {
// CHECK-NEXT:                        %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                        %[[VAL_222:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                        %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                        %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                        %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_222]], %[[VAL_224]] : index
// CHECK-NEXT:                        %[[VAL_226:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_223]], %[[VAL_225]] : i1, i1
// CHECK-NEXT:                        %[[VAL_227:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                        %[[VAL_228:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_222]], %[[VAL_227]] : index
// CHECK-NEXT:                        %[[VAL_229:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_223]], %[[VAL_228]] : i1, i1
// CHECK-NEXT:                        %[[VAL_230:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {
// CHECK-NEXT:                          %[[VAL_231:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_229]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                            %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            scf.yield %[[VAL_232]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          } else {
// CHECK-NEXT:                            %[[VAL_233:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_226]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                              %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                              scf.yield %[[VAL_234]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            } else {
// CHECK-NEXT:                              %[[VAL_235:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                              scf.yield %[[VAL_235]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            }
// CHECK-NEXT:                            scf.yield %[[VAL_233]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          }
// CHECK-NEXT:                          scf.yield %[[VAL_231]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                        }
// CHECK-NEXT:                        %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@count] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                        %[[VAL_237:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                        %[[VAL_238:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_236]], %[[VAL_237]] : index
// CHECK-NEXT:                        pod.write %[[VAL_221]][@count] = %[[VAL_238]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                        %[[VAL_239:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                        %[[VAL_240:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_238]], %[[VAL_239]] : index
// CHECK-NEXT:                        scf.if %[[VAL_240]] {
// CHECK-NEXT:                          %[[VAL_241:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@params] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                          %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_230]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                          %[[VAL_243:[0-9a-zA-Z_\.]+]] = function.call @Inner_1::@Inner_1::@compute(%[[VAL_242]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                          pod.write %[[VAL_221]][@comp] = %[[VAL_243]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                          %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                        }
// CHECK-NEXT:                      } else {
// CHECK-NEXT:                        scf.if %[[VAL_217]] {
// CHECK-NEXT:                          %[[VAL_245:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                          %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                          %[[VAL_247:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:                          %[[VAL_248:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                          %[[VAL_249:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_246]], %[[VAL_248]] : index
// CHECK-NEXT:                          %[[VAL_250:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_247]], %[[VAL_249]] : i1, i1
// CHECK-NEXT:                          %[[VAL_251:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                          %[[VAL_252:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_246]], %[[VAL_251]] : index
// CHECK-NEXT:                          %[[VAL_253:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_247]], %[[VAL_252]] : i1, i1
// CHECK-NEXT:                          %[[VAL_254:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]> {
// CHECK-NEXT:                            %[[VAL_255:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_253]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                              %[[VAL_256:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                              scf.yield %[[VAL_256]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            } else {
// CHECK-NEXT:                              %[[VAL_257:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_250]] -> (!pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:                                %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_205]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                                scf.yield %[[VAL_258]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                              } else {
// CHECK-NEXT:                                %[[VAL_259:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                                scf.yield %[[VAL_259]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                              }
// CHECK-NEXT:                              scf.yield %[[VAL_257]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                            }
// CHECK-NEXT:                            scf.yield %[[VAL_255]] : !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                          }
// CHECK-NEXT:                          %[[VAL_260:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@count] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                          %[[VAL_261:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                          %[[VAL_262:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_260]], %[[VAL_261]] : index
// CHECK-NEXT:                          pod.write %[[VAL_245]][@count] = %[[VAL_262]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                          %[[VAL_263:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                          %[[VAL_264:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_262]], %[[VAL_263]] : index
// CHECK-NEXT:                          scf.if %[[VAL_264]] {
// CHECK-NEXT:                            %[[VAL_265:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@params] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                            %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_254]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                            %[[VAL_267:[0-9a-zA-Z_\.]+]] = function.call @Inner_0::@Inner_0::@compute(%[[VAL_266]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                            pod.write %[[VAL_245]][@comp] = %[[VAL_267]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                            %[[VAL_268:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:                          }
// CHECK-NEXT:                        } else {
// CHECK-NEXT:                        }
// CHECK-NEXT:                      }
// CHECK-NEXT:                      scf.yield
// CHECK-NEXT:                    }
// CHECK-NEXT:                    scf.yield %[[VAL_101]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_269:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_269]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_193]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_117]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_271:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_102]], %[[VAL_270]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_116]], %[[VAL_271]] : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_272:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_93]], %[[VAL_272]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_273]], %[[VAL_96]]#0 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_276:[0-9a-zA-Z_\.]+]] = %[[VAL_274]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_276]], %[[VAL_277]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_278]]) %[[VAL_276]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_279:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_282:[0-9a-zA-Z_\.]+]] = %[[VAL_280]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_284:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_282]], %[[VAL_283]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_284]]) %[[VAL_282]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_285:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_286:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_279]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_287:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_288:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_286]], %[[VAL_288]] : index
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_287]], %[[VAL_289]] : i1, i1
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_286]], %[[VAL_291]] : index
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_287]], %[[VAL_292]] : i1, i1
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_295:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_293]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_296:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_296]][@comp] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  %[[VAL_298:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_297]][@out] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_299:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_300:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_298]]{{\[}}%[[VAL_299]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_300]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_301:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_290]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                    %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_302]][@comp] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    %[[VAL_304:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_303]][@out] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_306:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_304]]{{\[}}%[[VAL_305]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_306]] : !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_307:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_307]] : !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_301]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_279]], %[[VAL_308]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_310:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_309]], %[[VAL_285]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_73]]{{\[}}%[[VAL_311]]] = %[[VAL_294]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_285]], %[[VAL_312]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_313]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_279]], %[[VAL_314]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_71]][@inner$inputs] = %[[VAL_88]]#1 : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_316:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_317:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_316]][@comp] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:          %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_318]][@comp] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_317]], @idx_1 = %[[VAL_319]] }  : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@inner] = %[[VAL_320]] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@mid] = %[[VAL_72]] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@out] = %[[VAL_73]] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_71]] : !struct.type<@Outer_2::@Outer_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_321:[0-9a-zA-Z_\.]+]]: !struct.type<@Outer_2::@Outer_2<[]>>, %[[VAL_322:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_321]][@out] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_324:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_321]][@mid] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_325:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_321]][@inner] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          %[[VAL_326:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_321]][@inner$inputs] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_327:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_328:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_329:[0-9a-zA-Z_\.]+]] = %[[VAL_327]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_329]], %[[VAL_330]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_331]]) %[[VAL_329]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_332:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_332]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_322]]{{\[}}%[[VAL_333]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_332]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_336:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_324]]{{\[}}%[[VAL_335]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_336]], %[[VAL_334]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_337:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_338:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_332]], %[[VAL_337]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_338]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_340:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_341:[0-9a-zA-Z_\.]+]] = %[[VAL_339]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_343:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_341]], %[[VAL_342]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_343]]) %[[VAL_341]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_344:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_345:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_347:[0-9a-zA-Z_\.]+]] = %[[VAL_345]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_349:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_347]], %[[VAL_348]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_349]]) %[[VAL_347]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_350:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_351:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_352:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_344]], %[[VAL_351]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_353:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_352]], %[[VAL_350]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_354:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_353]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_355:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_324]]{{\[}}%[[VAL_354]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_356:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_344]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_357:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_358:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_359:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_356]], %[[VAL_358]] : index
// CHECK-NEXT:              %[[VAL_360:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_357]], %[[VAL_359]] : i1, i1
// CHECK-NEXT:              %[[VAL_361:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_362:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_356]], %[[VAL_361]] : index
// CHECK-NEXT:              %[[VAL_363:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_357]], %[[VAL_362]] : i1, i1
// CHECK-NEXT:              scf.execute_region {
// CHECK-NEXT:                scf.if %[[VAL_363]] {
// CHECK-NEXT:                  %[[VAL_364:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_365:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_364]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_366:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_350]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_367:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_365]]{{\[}}%[[VAL_366]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_367]], %[[VAL_355]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  scf.if %[[VAL_360]] {
// CHECK-NEXT:                    %[[VAL_368:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_369:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_368]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_370:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_350]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_371:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_369]]{{\[}}%[[VAL_370]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    constrain.eq %[[VAL_371]], %[[VAL_355]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                  }
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_372:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_373:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_350]], %[[VAL_372]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_373]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_344]], %[[VAL_374]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_375]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_376:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_377:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_378:[0-9a-zA-Z_\.]+]] = %[[VAL_376]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_379:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_380:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_378]], %[[VAL_379]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_380]]) %[[VAL_378]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_381:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_383:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_384:[0-9a-zA-Z_\.]+]] = %[[VAL_382]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_385:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_386:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_384]], %[[VAL_385]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_386]]) %[[VAL_384]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_387:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_388:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_381]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_389:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_390:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_391:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_388]], %[[VAL_390]] : index
// CHECK-NEXT:              %[[VAL_392:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_389]], %[[VAL_391]] : i1, i1
// CHECK-NEXT:              %[[VAL_393:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_388]], %[[VAL_393]] : index
// CHECK-NEXT:              %[[VAL_395:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_389]], %[[VAL_394]] : i1, i1
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_397:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_395]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_398:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_325]][@idx_1] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  %[[VAL_399:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_398]][@out] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_400:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_387]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_401:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_399]]{{\[}}%[[VAL_400]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_401]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_402:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_392]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                    %[[VAL_403:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_325]][@idx_0] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    %[[VAL_404:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_403]][@out] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_405:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_387]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_406:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_404]]{{\[}}%[[VAL_405]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_406]] : !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_407:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_407]] : !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_402]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_397]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_408:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_409:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_381]], %[[VAL_408]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_410:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_409]], %[[VAL_387]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_411:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_410]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_412:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_323]]{{\[}}%[[VAL_411]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_412]], %[[VAL_396]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_413:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_414:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_387]], %[[VAL_413]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_414]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_415:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_416:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_381]], %[[VAL_415]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_416]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_417:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_325]][@idx_0] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:          %[[VAL_418:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_419:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_418]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Inner_0::@Inner_0::@constrain(%[[VAL_417]], %[[VAL_419]]) : (!struct.type<@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_420:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_325]][@idx_1] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:          %[[VAL_421:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_326]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_422:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_421]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Inner_1::@Inner_1::@constrain(%[[VAL_420]], %[[VAL_422]]) : (!struct.type<@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
