// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Outer::@Outer<[]>>} {
// CHECK-NEXT:    poly.template @Inner {
// CHECK-NEXT:      poly.param @P : index
// CHECK-NEXT:      struct.def @Inner {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Inner::@Inner<[@P]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner::@Inner<[@P]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @P : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_11]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_14]]] = %[[VAL_13]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_4]] : <@Inner::@Inner<[@P]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Inner::@Inner<[@P]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner::@Inner<[@P]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @P : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@out] : <@Inner::@Inner<[@P]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_28]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_20]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_31]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_32]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Outer {
// CHECK-NEXT:      struct.def @Outer {
// CHECK-NEXT:        struct.member @out : !array.type<8 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @mid : !array.type<8 x !felt.type<"bn128">> {signal}
// CHECK-NEXT:        struct.member @inner : !array.type<2 x !struct.type<@Inner::@Inner<[#map]>>>
// CHECK-NEXT:        struct.member @inner$inputs : !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Outer::@Outer<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.new : <@Outer::@Outer<[]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_43:[0-9a-zA-Z_\.]+]] = %[[VAL_41]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_43]], %[[VAL_44]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_45]]) %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_47]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_37]]{{\[}}%[[VAL_49]]] = %[[VAL_48]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]], %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_40]]) : (!felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_54]], %[[VAL_56]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_57]]) %[[VAL_54]], %[[VAL_55]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_58:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_59:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new { @P = %[[VAL_60]] }  : <[@P: index]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_62]], @params = %[[VAL_61]] } (%[[VAL_60]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_39]]{{\[}}%[[VAL_64]]] = %[[VAL_63]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_68:[0-9a-zA-Z_\.]+]] = %[[VAL_65]]) : (!array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_68]], %[[VAL_69]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_70]]) %[[VAL_67]], %[[VAL_68]] : !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, %[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_58]], %[[VAL_73]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_76]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_78]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_80]]{{\[}}%[[VAL_81]]] = %[[VAL_77]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_82]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_83]][@in] = %[[VAL_80]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_71]]{{\[}}%[[VAL_84]]] = %[[VAL_83]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_85]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_87]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@count] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>, index
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_89]], %[[VAL_90]] : index
// CHECK-NEXT:              pod.write %[[VAL_86]][@count] = %[[VAL_91]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>, index
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_91]], %[[VAL_92]] : index
// CHECK-NEXT:              scf.if %[[VAL_93]] {
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@params] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>, !pod.type<[@P: index]>
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@P] : <[@P: index]>, index
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = function.call @Inner::@Inner::@compute(%[[VAL_95]]) {(%[[VAL_96]])} : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:                pod.write %[[VAL_86]][@comp] = %[[VAL_97]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_39]]{{\[}}%[[VAL_98]]] = %[[VAL_86]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_71]], %[[VAL_100]] : !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_58]], %[[VAL_101]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_102]], %[[VAL_66]]#0 : !felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_103]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_105]], %[[VAL_106]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_107]]) %[[VAL_105]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_108:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_111:[0-9a-zA-Z_\.]+]] = %[[VAL_109]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_111]], %[[VAL_112]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_113]]) %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_114:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_115]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_117]][@out] : <@Inner::@Inner<[#map]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_118]]{{\[}}%[[VAL_119]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_108]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_122]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_38]]{{\[}}%[[VAL_124]]] = %[[VAL_120]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_114]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_108]], %[[VAL_127]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@inner$inputs] = %[[VAL_53]]#1 : <@Outer::@Outer<[]>>, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Inner::@Inner<[#map]>>>
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_133:[0-9a-zA-Z_\.]+]] = %[[VAL_131]] to %[[VAL_130]] step %[[VAL_132]] {
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_133]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_134]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_129]]{{\[}}%[[VAL_133]]] = %[[VAL_135]] : <2 x !struct.type<@Inner::@Inner<[#map]>>>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@inner] = %[[VAL_129]] : <@Outer::@Outer<[]>>, !array.type<2 x !struct.type<@Inner::@Inner<[#map]>>>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@mid] = %[[VAL_37]] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_36]][@out] = %[[VAL_38]] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_36]] : !struct.type<@Outer::@Outer<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_136:[0-9a-zA-Z_\.]+]]: !struct.type<@Outer::@Outer<[]>>, %[[VAL_137:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@out] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@mid] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@inner] : <@Outer::@Outer<[]>>, !array.type<2 x !struct.type<@Inner::@Inner<[#map]>>>
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@inner$inputs] : <@Outer::@Outer<[]>>, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_142]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_144]], %[[VAL_145]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_146]]) %[[VAL_144]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_147:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_148]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_147]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_150]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_151]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_147]], %[[VAL_152]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_154]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_156]], %[[VAL_157]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_158]]) %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_159:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.new { @P = %[[VAL_160]] }  : <[@P: index]>
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_160]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: index]>]>
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_165:[0-9a-zA-Z_\.]+]] = %[[VAL_163]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_165]], %[[VAL_166]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_167]]) %[[VAL_165]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_168:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_159]], %[[VAL_169]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_170]], %[[VAL_168]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_171]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_172]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_174]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_175]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_168]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_176]]{{\[}}%[[VAL_177]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_178]], %[[VAL_173]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_168]], %[[VAL_179]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_180]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_159]], %[[VAL_181]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_182]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_185:[0-9a-zA-Z_\.]+]] = %[[VAL_183]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_185]], %[[VAL_186]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_187]]) %[[VAL_185]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_188:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_191:[0-9a-zA-Z_\.]+]] = %[[VAL_189]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_191]], %[[VAL_192]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_193]]) %[[VAL_191]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_194:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_195]]] : <2 x !struct.type<@Inner::@Inner<[#map]>>>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:              %[[VAL_197:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_196]][@out] : <@Inner::@Inner<[#map]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_198:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_199:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_197]]{{\[}}%[[VAL_198]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_188]], %[[VAL_200]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_201]], %[[VAL_194]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_203]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_204]], %[[VAL_199]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_194]], %[[VAL_205]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_188]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_208]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_212:[0-9a-zA-Z_\.]+]] = %[[VAL_210]] to %[[VAL_209]] step %[[VAL_211]] {
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_212]]] : <2 x !struct.type<@Inner::@Inner<[#map]>>>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_141]]{{\[}}%[[VAL_212]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Inner::@Inner::@constrain(%[[VAL_213]], %[[VAL_215]]) : (!struct.type<@Inner::@Inner<[#map]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
