// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template ArrayOp(q) {
    signal input inp[15];
    signal output outp[15];

    for (var i = 0; i < 15; i++) {
        outp[i] <== inp[i] + q;
    }
}

template Wrapper() {
    signal input inp[15];
    signal output outp;

    component m[4];

    for (var q = 0; q < 4; q++) {
        // This test exhibits the behavior because the array of different subcomponents
        // (differentiated by the template parameter changing)
        m[q] = ArrayOp(q);
        for (var i = 0; i < 15; i++) {
            m[q].inp[i] <== inp[i];
        }
    }

    outp <== m[2].outp[3];
}

component main = Wrapper();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Wrapper::@Wrapper<[]>>} {
// CHECK-NEXT:    poly.template @ArrayOp {
// CHECK-NEXT:      poly.param @q : index
// CHECK-NEXT:      struct.def @ArrayOp {
// CHECK-NEXT:        struct.member @outp : !array.type<15 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@ArrayOp::@ArrayOp<[@q]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayOp::@ArrayOp<[@q]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @q : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_11]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_12]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_14]]] = %[[VAL_13]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_4]] : <@ArrayOp::@ArrayOp<[@q]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ArrayOp::@ArrayOp<[@q]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayOp::@ArrayOp<[@q]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @q : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@outp] : <@ArrayOp::@ArrayOp<[@q]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_28]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_29]], %[[VAL_20]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_31]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_32]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Wrapper {
// CHECK-NEXT:      struct.def @Wrapper {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @m : !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>
// CHECK-NEXT:        struct.member @m$inputs : !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Wrapper::@Wrapper<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.new : <@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_38]], %[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_39]]) : (!array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_42]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_44]]) %[[VAL_41]], %[[VAL_42]] : !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_47]] }  : <[@q: index]>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_49]], @params = %[[VAL_48]] } (%[[VAL_47]]) : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_37]]{{\[}}%[[VAL_51]]] = %[[VAL_50]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]], %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_45]]) : (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_54]], %[[VAL_56]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_57]]) %[[VAL_54]], %[[VAL_55]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_58:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_59:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_60]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_62]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_64]]{{\[}}%[[VAL_65]]] = %[[VAL_61]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_66]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_67]][@inp] = %[[VAL_64]] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_59]]{{\[}}%[[VAL_68]]] = %[[VAL_67]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_69]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_71]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@count] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>, index
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_73]], %[[VAL_74]] : index
// CHECK-NEXT:              pod.write %[[VAL_70]][@count] = %[[VAL_75]] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>, index
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_75]], %[[VAL_76]] : index
// CHECK-NEXT:              scf.if %[[VAL_77]] {
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@params] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !pod.type<[@q: index]>
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@q] : <[@q: index]>, index
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = function.call @ArrayOp::@ArrayOp::@compute(%[[VAL_79]]) {(%[[VAL_80]])} : (!array.type<15 x !felt.type<"bn128">>) -> !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:                pod.write %[[VAL_70]][@comp] = %[[VAL_81]] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_37]]{{\[}}%[[VAL_82]]] = %[[VAL_70]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_58]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_84]], %[[VAL_59]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_53]]#1, %[[VAL_86]] : !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_88]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@comp] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_90]][@outp] : <@ArrayOp::@ArrayOp<[#map]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_91]]{{\[}}%[[VAL_93]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_36]][@outp] = %[[VAL_94]] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_36]][@m$inputs] = %[[VAL_40]]#0 : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_99:[0-9a-zA-Z_\.]+]] = %[[VAL_97]] to %[[VAL_96]] step %[[VAL_98]] {
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_99]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@comp] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_95]]{{\[}}%[[VAL_99]]] = %[[VAL_101]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_36]][@m] = %[[VAL_95]] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>
// CHECK-NEXT:          function.return %[[VAL_36]] : !struct.type<@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_102:[0-9a-zA-Z_\.]+]]: !struct.type<@Wrapper::@Wrapper<[]>>, %[[VAL_103:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_102]][@outp] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_102]][@m] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_102]][@m$inputs] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_107]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_109]], %[[VAL_110]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_111]]) %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_112:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_113]] }  : <[@q: index]>
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_113]]) : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: index]>]>
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_118:[0-9a-zA-Z_\.]+]] = %[[VAL_116]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_118]], %[[VAL_119]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_120]]) %[[VAL_118]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_103]]{{\[}}%[[VAL_122]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_124]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_126]]{{\[}}%[[VAL_127]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_128]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_121]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_112]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_134]]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_135]][@outp] : <@ArrayOp::@ArrayOp<[#map]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_137]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_138]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_104]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_143:[0-9a-zA-Z_\.]+]] = %[[VAL_141]] to %[[VAL_140]] step %[[VAL_142]] {
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_143]]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_143]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @ArrayOp::@ArrayOp::@constrain(%[[VAL_144]], %[[VAL_146]]) : (!struct.type<@ArrayOp::@ArrayOp<[#map]>>, !array.type<15 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
