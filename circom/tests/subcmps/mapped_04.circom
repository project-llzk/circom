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

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Wrapper::@Wrapper<[]>>} {
// CHECK-NEXT:    poly.template @MatrixOp {
// CHECK-NEXT:      poly.param @q
// CHECK-NEXT:      struct.def @MatrixOp {
// CHECK-NEXT:        struct.member @outp : !array.type<5,3 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@MatrixOp::@MatrixOp<[@q]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@MatrixOp::@MatrixOp<[@q]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @q : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_14]]) %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_16]], %[[VAL_17]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_20]], %[[VAL_21]]] = %[[VAL_19]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_3]] : <@MatrixOp::@MatrixOp<[@q]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@MatrixOp::@MatrixOp<[@q]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !struct.type<@MatrixOp::@MatrixOp<[@q]>>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.read_const @q : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_26]][@outp] : <@MatrixOp::@MatrixOp<[@q]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_32:[0-9a-zA-Z_\.]+]] = %[[VAL_30]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_32]], %[[VAL_33]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_34]]) %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_36]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_39]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_40]]) %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_41:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_42]], %[[VAL_43]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_44]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_29]]{{\[}}%[[VAL_46]], %[[VAL_47]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_48]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_41]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Wrapper {
// CHECK-NEXT:      struct.def @Wrapper {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @m : !array.type<4 x !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @m$inputs : !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Wrapper::@Wrapper<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.new : <@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_56]], %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_57]]) : (!array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_60]], %[[VAL_61]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_62]]) %[[VAL_59]], %[[VAL_60]] : !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, %[[VAL_64:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_64]] }  : <[@q: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_67]], @params = %[[VAL_66]] } (%[[VAL_65]]) : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_55]]{{\[}}%[[VAL_69]]] = %[[VAL_68]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_70]], %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_63]]) : (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_72]], %[[VAL_74]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_75]]) %[[VAL_72]], %[[VAL_73]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_78]], %[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_77]]) : (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_80]], %[[VAL_82]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_83]]) %[[VAL_80]], %[[VAL_81]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_85:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:                %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_86]], %[[VAL_87]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_85]]{{\[}}%[[VAL_89]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_91]]{{\[}}%[[VAL_92]], %[[VAL_93]]] = %[[VAL_88]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_85]]{{\[}}%[[VAL_94]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                pod.write %[[VAL_95]][@inp] = %[[VAL_91]] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_85]]{{\[}}%[[VAL_96]]] = %[[VAL_95]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_97]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_85]]{{\[}}%[[VAL_99]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@count] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:                %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_101]], %[[VAL_102]] : index
// CHECK-NEXT:                pod.write %[[VAL_98]][@count] = %[[VAL_103]] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:                %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_103]], %[[VAL_104]] : index
// CHECK-NEXT:                scf.if %[[VAL_105]] {
// CHECK-NEXT:                  %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@params] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !pod.type<[@q: !felt.type<"bn128">]>
// CHECK-NEXT:                  %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                  %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@q] : <[@q: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_110:[0-9a-zA-Z_\.]+]] = function.call @MatrixOp::@MatrixOp::@compute(%[[VAL_107]]) {(%[[VAL_109]])} : (!array.type<5,3 x !felt.type<"bn128">>) -> !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                  pod.write %[[VAL_98]][@comp] = %[[VAL_110]] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                  %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_55]]{{\[}}%[[VAL_111]]] = %[[VAL_98]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_113]], %[[VAL_85]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_76]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_115]], %[[VAL_79]]#1 : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_64]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_71]]#1, %[[VAL_117]] : !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_118]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_119]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@comp] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_121]][@outp] : <@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_122]]{{\[}}%[[VAL_124]], %[[VAL_126]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_54]][@outp] = %[[VAL_127]] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_54]][@m$inputs] = %[[VAL_58]]#0 : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_132:[0-9a-zA-Z_\.]+]] = %[[VAL_130]] to %[[VAL_129]] step %[[VAL_131]] {
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_132]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@comp] : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_128]]{{\[}}%[[VAL_132]]] = %[[VAL_134]] : <4 x !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>>, !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_54]][@m] = %[[VAL_128]] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          function.return %[[VAL_54]] : !struct.type<@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_135:[0-9a-zA-Z_\.]+]]: !struct.type<@Wrapper::@Wrapper<[]>>, %[[VAL_136:[0-9a-zA-Z_\.]+]]: !array.type<5,3 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@outp] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@m] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@m$inputs] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_142:[0-9a-zA-Z_\.]+]] = %[[VAL_140]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_142]], %[[VAL_143]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_144]]) %[[VAL_142]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_145:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_145]] }  : <[@q: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_146]]) : <[@count: index, @comp: !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_151:[0-9a-zA-Z_\.]+]] = %[[VAL_149]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_151]], %[[VAL_152]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_153]]) %[[VAL_151]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_154:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_157:[0-9a-zA-Z_\.]+]] = %[[VAL_155]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:                %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:                %[[VAL_159:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_157]], %[[VAL_158]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.condition(%[[VAL_159]]) %[[VAL_157]] : !felt.type<"bn128">
// CHECK-NEXT:              } do {
// CHECK-NEXT:              ^bb0(%[[VAL_160:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:                %[[VAL_161:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_161]], %[[VAL_162]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_164]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:                %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_169:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_166]]{{\[}}%[[VAL_167]], %[[VAL_168]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_169]], %[[VAL_163]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_160]], %[[VAL_170]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_171]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_154]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_173]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_145]], %[[VAL_174]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_175]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_177]]] : <4 x !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>>, !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_178]][@outp] : <@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_180]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_182]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_179]]{{\[}}%[[VAL_181]], %[[VAL_183]]] : <5,3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_137]], %[[VAL_184]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_188:[0-9a-zA-Z_\.]+]] = %[[VAL_186]] to %[[VAL_185]] step %[[VAL_187]] {
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_188]]] : <4 x !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>>, !struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_188]]] : <4 x !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<5,3 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@inp] : <[@inp: !array.type<5,3 x !felt.type<"bn128">>]>, !array.type<5,3 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @MatrixOp::@MatrixOp::@constrain(%[[VAL_189]], %[[VAL_191]]) : (!struct.type<@MatrixOp::@MatrixOp<[#[[$ATTR_0]]]>>, !array.type<5,3 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
