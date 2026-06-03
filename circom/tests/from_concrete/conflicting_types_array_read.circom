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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Outer_2::@Outer_2<[]>>} {
// CHECK-NEXT:    poly.template @Inner_0 {
// CHECK-NEXT:      struct.def @Inner_0 {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Inner_0::@Inner_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
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
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner_0::@Inner_0<[]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
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
// CHECK-NEXT:        function.def @compute(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Inner_1::@Inner_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
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
// CHECK-NEXT:        function.def @constrain(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner_1::@Inner_1<[]>>, %[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
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
// CHECK-NEXT:        function.def @compute(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Outer_2::@Outer_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.new : <@Outer_2::@Outer_2<[]>>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_75]], @params = %[[VAL_74]] }  : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_77]], @params = %[[VAL_74]] }  : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_76]], @idx_1 = %[[VAL_78]] }  : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_81]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_83]], %[[VAL_84]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_85]]) %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_87]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_72]]{{\[}}%[[VAL_89]]] = %[[VAL_88]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_91]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_94:[0-9a-zA-Z_\.]+]] = %[[VAL_92]], %[[VAL_95:[0-9a-zA-Z_\.]+]] = %[[VAL_79]], %[[VAL_96:[0-9a-zA-Z_\.]+]] = %[[VAL_80]]) : (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) -> (!felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_94]], %[[VAL_97]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_98]]) %[[VAL_94]], %[[VAL_95]], %[[VAL_96]] : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_99:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_100:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_101:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>):
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_100]], %[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_101]], %[[VAL_106:[0-9a-zA-Z_\.]+]] = %[[VAL_102]]) : (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_106]], %[[VAL_107]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_108]]) %[[VAL_104]], %[[VAL_105]], %[[VAL_106]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_109:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, %[[VAL_110:[0-9a-zA-Z_\.]+]]: !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, %[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_99]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_113]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_72]]{{\[}}%[[VAL_115]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_117]], %[[VAL_119]] : index
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_118]], %[[VAL_120]] : i1, i1
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_117]], %[[VAL_122]] : index
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_118]], %[[VAL_123]] : i1, i1
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]]:2 = scf.execute_region -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                %[[VAL_126:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_124]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                  %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_129]]{{\[}}%[[VAL_130]]] = %[[VAL_116]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  pod.write %[[VAL_128]][@in] = %[[VAL_129]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  pod.write %[[VAL_110]][@idx_1] = %[[VAL_128]] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@count] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                  %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_131]], %[[VAL_132]] : index
// CHECK-NEXT:                  pod.write %[[VAL_127]][@count] = %[[VAL_133]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                  %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                  %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_133]], %[[VAL_134]] : index
// CHECK-NEXT:                  scf.if %[[VAL_135]] {
// CHECK-NEXT:                    %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@params] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                    %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_138:[0-9a-zA-Z_\.]+]] = function.call @Inner_1::@Inner_1::@compute(%[[VAL_137]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                    pod.write %[[VAL_127]][@comp] = %[[VAL_138]] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  pod.write %[[VAL_109]][@idx_1] = %[[VAL_127]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  scf.yield %[[VAL_109]], %[[VAL_110]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_139:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_121]] -> (!pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>) {
// CHECK-NEXT:                    %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:                    array.write %[[VAL_142]]{{\[}}%[[VAL_143]]] = %[[VAL_116]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    pod.write %[[VAL_141]][@in] = %[[VAL_142]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    pod.write %[[VAL_110]][@idx_0] = %[[VAL_141]] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@count] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                    %[[VAL_146:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_144]], %[[VAL_145]] : index
// CHECK-NEXT:                    pod.write %[[VAL_140]][@count] = %[[VAL_146]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                    %[[VAL_147:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                    %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_146]], %[[VAL_147]] : index
// CHECK-NEXT:                    scf.if %[[VAL_148]] {
// CHECK-NEXT:                      %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@params] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                      %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                      %[[VAL_151:[0-9a-zA-Z_\.]+]] = function.call @Inner_0::@Inner_0::@compute(%[[VAL_150]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                      pod.write %[[VAL_140]][@comp] = %[[VAL_151]] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    }
// CHECK-NEXT:                    pod.write %[[VAL_109]][@idx_0] = %[[VAL_140]] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_109]], %[[VAL_110]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_152:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>
// CHECK-NEXT:                    %[[VAL_153:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                    scf.yield %[[VAL_152]], %[[VAL_153]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_139]]#0, %[[VAL_139]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_126]]#0, %[[VAL_126]]#1 : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_111]], %[[VAL_154]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_125]]#0, %[[VAL_125]]#1, %[[VAL_155]] : !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_99]], %[[VAL_156]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_157]], %[[VAL_103]]#0, %[[VAL_103]]#1 : !felt.type<"bn128">, !pod.type<[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_160:[0-9a-zA-Z_\.]+]] = %[[VAL_158]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_160]], %[[VAL_161]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_162]]) %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_163:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_166:[0-9a-zA-Z_\.]+]] = %[[VAL_164]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_166]], %[[VAL_167]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_168]]) %[[VAL_166]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_169:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_172]] : index
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_171]], %[[VAL_173]] : i1, i1
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_175]] : index
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_171]], %[[VAL_176]] : i1, i1
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_177]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                  %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@comp] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  %[[VAL_182:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_181]][@out] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_183:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_184:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_182]]{{\[}}%[[VAL_183]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_185:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_174]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                    %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                    %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@comp] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    %[[VAL_188:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_187]][@out] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_169]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_189]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_191:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_191]] : !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_185]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_179]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_163]], %[[VAL_192]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_73]]{{\[}}%[[VAL_195]]] = %[[VAL_178]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_169]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_197]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_163]], %[[VAL_198]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_71]][@inner$inputs] = %[[VAL_93]]#2 : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]]#1[@idx_0] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@comp] : <[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]]#1[@idx_1] : <[@idx_0: !pod.type<[@count: index, @comp: !struct.type<@Inner_0::@Inner_0<[]>>, @params: !pod.type<[]>]>, @idx_1: !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>]>, !pod.type<[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@comp] : <[@count: index, @comp: !struct.type<@Inner_1::@Inner_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.new { @idx_0 = %[[VAL_201]], @idx_1 = %[[VAL_203]] }  : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@inner] = %[[VAL_204]] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@mid] = %[[VAL_72]] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_71]][@out] = %[[VAL_73]] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_71]] : !struct.type<@Outer_2::@Outer_2<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_205:[0-9a-zA-Z_\.]+]]: !struct.type<@Outer_2::@Outer_2<[]>>, %[[VAL_206:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@out] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@mid] : <@Outer_2::@Outer_2<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@inner] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_205]][@inner$inputs] : <@Outer_2::@Outer_2<[]>>, !pod.type<[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_213:[0-9a-zA-Z_\.]+]] = %[[VAL_211]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_213]], %[[VAL_214]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_215]]) %[[VAL_213]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_216:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_216]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_206]]{{\[}}%[[VAL_217]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_216]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_219]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_220]], %[[VAL_218]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_216]], %[[VAL_221]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_222]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_225:[0-9a-zA-Z_\.]+]] = %[[VAL_223]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_225]], %[[VAL_226]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_227]]) %[[VAL_225]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_228:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_231:[0-9a-zA-Z_\.]+]] = %[[VAL_229]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_231]], %[[VAL_232]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_233]]) %[[VAL_231]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_234:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_228]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_236]], %[[VAL_234]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_238]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_228]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_240]], %[[VAL_242]] : index
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_241]], %[[VAL_243]] : i1, i1
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_246:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_240]], %[[VAL_245]] : index
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_241]], %[[VAL_246]] : i1, i1
// CHECK-NEXT:              scf.execute_region {
// CHECK-NEXT:                scf.if %[[VAL_247]] {
// CHECK-NEXT:                  %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                  %[[VAL_249:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_248]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_250]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  constrain.eq %[[VAL_251]], %[[VAL_239]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  scf.if %[[VAL_244]] {
// CHECK-NEXT:                    %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:                    %[[VAL_253:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_252]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_254:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_255:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_254]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    constrain.eq %[[VAL_255]], %[[VAL_239]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                  }
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_256:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_234]], %[[VAL_256]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_257]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_228]], %[[VAL_258]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_259]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_262:[0-9a-zA-Z_\.]+]] = %[[VAL_260]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_264:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_262]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_264]]) %[[VAL_262]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_265:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_266:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_268:[0-9a-zA-Z_\.]+]] = %[[VAL_266]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_270:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_268]], %[[VAL_269]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_270]]) %[[VAL_268]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_271:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_272:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_265]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_273:[0-9a-zA-Z_\.]+]] = arith.constant true
// CHECK-NEXT:              %[[VAL_274:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_275:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_272]], %[[VAL_274]] : index
// CHECK-NEXT:              %[[VAL_276:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_273]], %[[VAL_275]] : i1, i1
// CHECK-NEXT:              %[[VAL_277:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_278:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_272]], %[[VAL_277]] : index
// CHECK-NEXT:              %[[VAL_279:[0-9a-zA-Z_\.]+]] = bool.and %[[VAL_273]], %[[VAL_278]] : i1, i1
// CHECK-NEXT:              %[[VAL_280:[0-9a-zA-Z_\.]+]] = scf.execute_region -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_281:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_279]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                  %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@idx_1] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:                  %[[VAL_283:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_282]][@out] : <@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_271]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_283]]{{\[}}%[[VAL_284]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                  scf.yield %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:                } else {
// CHECK-NEXT:                  %[[VAL_286:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_276]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                    %[[VAL_287:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@idx_0] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:                    %[[VAL_288:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_287]][@out] : <@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                    %[[VAL_289:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_271]] : !felt.type<"bn128">
// CHECK-NEXT:                    %[[VAL_290:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_288]]{{\[}}%[[VAL_289]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:                  } else {
// CHECK-NEXT:                    %[[VAL_291:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:                    scf.yield %[[VAL_291]] : !felt.type<"bn128">
// CHECK-NEXT:                  }
// CHECK-NEXT:                  scf.yield %[[VAL_286]] : !felt.type<"bn128">
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_281]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_265]], %[[VAL_292]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_293]], %[[VAL_271]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_294]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_207]]{{\[}}%[[VAL_295]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_296]], %[[VAL_280]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_271]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_298]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_265]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_300]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@idx_0] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_0::@Inner_0<[]>>
// CHECK-NEXT:          %[[VAL_302:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@idx_0] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_303:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_302]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Inner_0::@Inner_0::@constrain(%[[VAL_301]], %[[VAL_303]]) : (!struct.type<@Inner_0::@Inner_0<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_304:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@idx_1] : <[@idx_0: !struct.type<@Inner_0::@Inner_0<[]>>, @idx_1: !struct.type<@Inner_1::@Inner_1<[]>>]>, !struct.type<@Inner_1::@Inner_1<[]>>
// CHECK-NEXT:          %[[VAL_305:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_210]][@idx_1] : <[@idx_0: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>, @idx_1: !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>]>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_305]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Inner_1::@Inner_1::@constrain(%[[VAL_304]], %[[VAL_306]]) : (!struct.type<@Inner_1::@Inner_1<[]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
