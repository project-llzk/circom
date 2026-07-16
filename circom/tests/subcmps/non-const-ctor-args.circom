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
// CHECK-NEXT:      poly.param @P
// CHECK-NEXT:      struct.def @Inner {
// CHECK-NEXT:        struct.member @out : !array.type<4 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Inner::@Inner<[@P]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner::@Inner<[@P]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @P : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@Inner::@Inner<[@P]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Inner::@Inner<[@P]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner::@Inner<[@P]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @P : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@out] : <@Inner::@Inner<[@P]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_26]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_29]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_30]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]] : !felt.type<"bn128">
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
// CHECK-NEXT:        function.def @compute(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Outer::@Outer<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.new : <@Outer::@Outer<[]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_39]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_43]]) %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_45]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_35]]{{\[}}%[[VAL_47]]] = %[[VAL_46]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_44]], %[[VAL_48]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_50]], %[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_38]]) : (!felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_52]], %[[VAL_54]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_55]]) %[[VAL_52]], %[[VAL_53]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @P = %[[VAL_56]] }  : <[@P: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_60]], @params = %[[VAL_59]] } (%[[VAL_58]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_37]]{{\[}}%[[VAL_62]]] = %[[VAL_61]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_63]]) : (!array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_66]], %[[VAL_67]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_68]]) %[[VAL_65]], %[[VAL_66]] : !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_56]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_74]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_76]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_78]]{{\[}}%[[VAL_79]]] = %[[VAL_75]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_80]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_81]][@in] = %[[VAL_78]] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_69]]{{\[}}%[[VAL_82]]] = %[[VAL_81]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_83]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_85]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@count] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_87]], %[[VAL_88]] : index
// CHECK-NEXT:              pod.write %[[VAL_84]][@count] = %[[VAL_89]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_89]], %[[VAL_90]] : index
// CHECK-NEXT:              scf.if %[[VAL_91]] {
// CHECK-NEXT:                %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@params] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>, !pod.type<[@P: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@P] : <[@P: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = function.call @Inner::@Inner::@compute(%[[VAL_93]]) {(%[[VAL_95]])} : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:                pod.write %[[VAL_84]][@comp] = %[[VAL_96]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_37]]{{\[}}%[[VAL_97]]] = %[[VAL_84]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_70]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_69]], %[[VAL_99]] : !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_101]], %[[VAL_64]]#0 : !felt.type<"bn128">, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_104]], %[[VAL_105]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_106]]) %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_107:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_108]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_110]], %[[VAL_111]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_112]]) %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_113:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_114]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_116]][@out] : <@Inner::@Inner<[#map]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_118]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_107]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_121]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_36]]{{\[}}%[[VAL_123]]] = %[[VAL_119]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_113]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_107]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_34]][@inner$inputs] = %[[VAL_51]]#1 : <@Outer::@Outer<[]>>, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Inner::@Inner<[#map]>>>
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_132:[0-9a-zA-Z_\.]+]] = %[[VAL_130]] to %[[VAL_129]] step %[[VAL_131]] {
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_132]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_128]]{{\[}}%[[VAL_132]]] = %[[VAL_134]] : <2 x !struct.type<@Inner::@Inner<[#map]>>>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_34]][@inner] = %[[VAL_128]] : <@Outer::@Outer<[]>>, !array.type<2 x !struct.type<@Inner::@Inner<[#map]>>>
// CHECK-NEXT:          struct.writem %[[VAL_34]][@mid] = %[[VAL_35]] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_34]][@out] = %[[VAL_36]] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_34]] : !struct.type<@Outer::@Outer<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_135:[0-9a-zA-Z_\.]+]]: !struct.type<@Outer::@Outer<[]>>, %[[VAL_136:[0-9a-zA-Z_\.]+]]: !array.type<8 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@out] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@mid] : <@Outer::@Outer<[]>>, !array.type<8 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@inner] : <@Outer::@Outer<[]>>, !array.type<2 x !struct.type<@Inner::@Inner<[#map]>>>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@inner$inputs] : <@Outer::@Outer<[]>>, !array.type<2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_143:[0-9a-zA-Z_\.]+]] = %[[VAL_141]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  8 : <"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_143]], %[[VAL_144]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_145]]) %[[VAL_143]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_146:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_147]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_149]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_150]], %[[VAL_148]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_146]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_155:[0-9a-zA-Z_\.]+]] = %[[VAL_153]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_155]], %[[VAL_156]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_157]]) %[[VAL_155]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_158:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.new { @P = %[[VAL_158]] }  : <[@P: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_159]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#map]>>, @params: !pod.type<[@P: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_164:[0-9a-zA-Z_\.]+]] = %[[VAL_162]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_164]], %[[VAL_165]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_166]]) %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_167:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_158]], %[[VAL_168]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_169]], %[[VAL_167]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_171]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_173]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_167]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_175]]{{\[}}%[[VAL_176]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_177]], %[[VAL_172]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_167]], %[[VAL_178]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_179]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_158]], %[[VAL_180]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_184:[0-9a-zA-Z_\.]+]] = %[[VAL_182]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_184]], %[[VAL_185]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_186]]) %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_187:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_190:[0-9a-zA-Z_\.]+]] = %[[VAL_188]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_190]], %[[VAL_191]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_192]]) %[[VAL_190]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_193:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_187]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_194]]] : <2 x !struct.type<@Inner::@Inner<[#map]>>>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_195]][@out] : <@Inner::@Inner<[#map]>>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_193]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_198:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_196]]{{\[}}%[[VAL_197]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:              %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_187]], %[[VAL_199]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_200]], %[[VAL_193]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_201]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_202]]] : <8 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_203]], %[[VAL_198]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_193]], %[[VAL_204]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_205]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_187]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_207]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_211:[0-9a-zA-Z_\.]+]] = %[[VAL_209]] to %[[VAL_208]] step %[[VAL_210]] {
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_211]]] : <2 x !struct.type<@Inner::@Inner<[#map]>>>, !struct.type<@Inner::@Inner<[#map]>>
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_140]]{{\[}}%[[VAL_211]]] : <2 x !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@in] : <[@in: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Inner::@Inner::@constrain(%[[VAL_212]], %[[VAL_214]]) : (!struct.type<@Inner::@Inner<[#map]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
