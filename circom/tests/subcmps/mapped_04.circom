// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template MatrixOp(q) {
    signal input inp[5][3];
    signal output outp[5][3];

    for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 3; j++) {
            outp[i][j] <== inp[i][j] + q;
        }
    }
}

template Wrapper() {
    signal input inp[5][3];
    signal output outp;

    component m[4];

    for (var q = 0; q < 4; q++) {
        // This test exhibits the behavior because the array of different subcomponents
        // (differentiated by the template parameter changing)
        m[q] = MatrixOp(q);
        for (var i = 0; i < 5; i++) {
            for (var j = 0; j < 3; j++) {
                m[q].inp[i][j] <== inp[i][j];
            }
        }
    }

    outp <== m[2].outp[1][2];
}

component main = Wrapper();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Wrapper::@Wrapper<[]>>} {
// CHECK-NEXT:    poly.template @MatrixOp {
// CHECK-NEXT:      poly.param @q : index
// CHECK-NEXT:      struct.def @MatrixOp {
// CHECK-NEXT:        struct.member @outp : !array.type<5,3 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@MatrixOp::@MatrixOp<[@q]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@MatrixOp::@MatrixOp<[@q]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @q : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_14]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_15]]) %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_17]], %[[VAL_18]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4]]{{\[}}%[[VAL_21]], %[[VAL_22]]] = %[[VAL_20]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_4]] : <@MatrixOp::@MatrixOp<[@q]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@MatrixOp::@MatrixOp<[@q]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !struct.type<@MatrixOp::@MatrixOp<[@q]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = poly.read_const @q : index
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_29]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_27]][@outp] : <@MatrixOp::@MatrixOp<[@q]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_34:[0-9a-zA-Z_\.]+]] = %[[VAL_32]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_34]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_36]]) %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_40]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_42]]) %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_28]]{{\[}}%[[VAL_44]], %[[VAL_45]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_37]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_48]], %[[VAL_49]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_50]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_43]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_37]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Wrapper {
// CHECK-NEXT:      struct.def @Wrapper {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @m : !array.type<4 x !struct.type<@MatrixOp::@MatrixOp<[#map]>>>
// CHECK-NEXT:        struct.member @m$inputs : !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_55:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Wrapper::@Wrapper<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.new : <@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_58]], %[[VAL_62:[0-9a-zA-Z_\.]+]] = %[[VAL_59]]) : (!array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_62]], %[[VAL_63]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_64]]) %[[VAL_61]], %[[VAL_62]] : !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_65:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, %[[VAL_66:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_67]] }  : <[@q: index]>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_69]], @params = %[[VAL_68]] } (%[[VAL_67]]) : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_57]]{{\[}}%[[VAL_71]]] = %[[VAL_70]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_72]], %[[VAL_75:[0-9a-zA-Z_\.]+]] = %[[VAL_65]]) : (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_74]], %[[VAL_76]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_77]]) %[[VAL_74]], %[[VAL_75]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_80]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_84]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_85]]) %[[VAL_82]], %[[VAL_83]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_88]], %[[VAL_89]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_91]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_93]]{{\[}}%[[VAL_94]], %[[VAL_95]]] = %[[VAL_90]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_96]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_97]][@inp] = %[[VAL_93]] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_87]]{{\[}}%[[VAL_98]]] = %[[VAL_97]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_99]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_101]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@count] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>, index
// CHECK-NEXT:                %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_103]], %[[VAL_104]] : index
// CHECK-NEXT:                pod.write %[[VAL_100]][@count] = %[[VAL_105]] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>, index
// CHECK-NEXT:                %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_105]], %[[VAL_106]] : index
// CHECK-NEXT:                scf.if %[[VAL_107]] {
// CHECK-NEXT:                  %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@params] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !pod.type<[@q: index]>
// CHECK-NEXT:                  %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@q] : <[@q: index]>, index
// CHECK-NEXT:                  %[[VAL_111:[0-9a-zA-Z_\.]+]] = function.call @MatrixOp::@MatrixOp::@compute(%[[VAL_109]]) {(%[[VAL_110]])} : (!array.type<5,3 x !felt.type<"bn128">>) -> !struct.type<@MatrixOp::@MatrixOp<[#map]>>
// CHECK-NEXT:                  pod.write %[[VAL_100]][@comp] = %[[VAL_111]] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !struct.type<@MatrixOp::@MatrixOp<[#map]>>
// CHECK-NEXT:                  %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_57]]{{\[}}%[[VAL_112]]] = %[[VAL_100]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_114]], %[[VAL_87]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_78]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_116]], %[[VAL_81]]#1 : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_66]], %[[VAL_117]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_73]]#1, %[[VAL_118]] : !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_120]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@comp] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !struct.type<@MatrixOp::@MatrixOp<[#map]>>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_122]][@outp] : <@MatrixOp::@MatrixOp<[#map]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_123]]{{\[}}%[[VAL_125]], %[[VAL_127]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_56]][@outp] = %[[VAL_128]] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_56]][@m$inputs] = %[[VAL_60]]#0 : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !struct.type<@MatrixOp::@MatrixOp<[#map]>>>
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]] to %[[VAL_130]] step %[[VAL_132]] {
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_133]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@comp] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !struct.type<@MatrixOp::@MatrixOp<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_129]]{{\[}}%[[VAL_133]]] = %[[VAL_135]] : <4 x !struct.type<@MatrixOp::@MatrixOp<[#map]>>>, !struct.type<@MatrixOp::@MatrixOp<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_56]][@m] = %[[VAL_129]] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@MatrixOp::@MatrixOp<[#map]>>>
// CHECK-NEXT:          function.return %[[VAL_56]] : !struct.type<@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_136:[0-9a-zA-Z_\.]+]]: !struct.type<@Wrapper::@Wrapper<[]>>, %[[VAL_137:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@outp] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@m] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@MatrixOp::@MatrixOp<[#map]>>>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@m$inputs] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_143:[0-9a-zA-Z_\.]+]] = %[[VAL_141]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_143]], %[[VAL_144]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_145]]) %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_146:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_147]] }  : <[@q: index]>
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_147]]) : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_152:[0-9a-zA-Z_\.]+]] = %[[VAL_150]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_152]], %[[VAL_153]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_154]]) %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_155:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_158:[0-9a-zA-Z_\.]+]] = %[[VAL_156]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_160:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_158]], %[[VAL_159]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_160]]) %[[VAL_158]] : !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_161:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_163:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_164:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_162]], %[[VAL_163]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_165]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_166]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_170:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_167]]{{\[}}%[[VAL_168]], %[[VAL_169]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_170]], %[[VAL_164]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_161]], %[[VAL_171]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_172]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_155]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_174]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_146]], %[[VAL_175]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_178]]] : <4 x !struct.type<@MatrixOp::@MatrixOp<[#map]>>>, !struct.type<@MatrixOp::@MatrixOp<[#map]>>
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_179]][@outp] : <@MatrixOp::@MatrixOp<[#map]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_180]]{{\[}}%[[VAL_182]], %[[VAL_184]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_138]], %[[VAL_185]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_189:[0-9a-zA-Z_\.]+]] = %[[VAL_187]] to %[[VAL_186]] step %[[VAL_188]] {
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_189]]] : <4 x !struct.type<@MatrixOp::@MatrixOp<[#map]>>>, !struct.type<@MatrixOp::@MatrixOp<[#map]>>
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_189]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_191]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @MatrixOp::@MatrixOp::@constrain(%[[VAL_190]], %[[VAL_192]]) : (!struct.type<@MatrixOp::@MatrixOp<[#map]>>, !array.type<5,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
