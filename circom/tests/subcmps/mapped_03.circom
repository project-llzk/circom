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
// CHECK-NEXT:      poly.param @q
// CHECK-NEXT:      struct.def @ArrayOp {
// CHECK-NEXT:        struct.member @outp : !array.type<15 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@ArrayOp::@ArrayOp<[@q]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ArrayOp::@ArrayOp<[@q]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @q : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_6]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_13]]] = %[[VAL_12]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@outp] = %[[VAL_3]] : <@ArrayOp::@ArrayOp<[@q]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ArrayOp::@ArrayOp<[@q]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !struct.type<@ArrayOp::@ArrayOp<[@q]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @q : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_16]][@outp] : <@ArrayOp::@ArrayOp<[@q]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_20]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_24]]) %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_25:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_26]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_29]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_30]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]] : !felt.type<"bn128">
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
// CHECK-NEXT:        function.def @compute(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Wrapper::@Wrapper<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.new : <@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_36]], %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_37]]) : (!array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_40]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_42]]) %[[VAL_39]], %[[VAL_40]] : !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, %[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_44]] }  : <[@q: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_47]], @params = %[[VAL_46]] } (%[[VAL_45]]) : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_35]]{{\[}}%[[VAL_49]]] = %[[VAL_48]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_50]], %[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_43]]) : (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_52]], %[[VAL_54]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_55]]) %[[VAL_52]], %[[VAL_53]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_58]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_60]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_62]]{{\[}}%[[VAL_63]]] = %[[VAL_59]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_64]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_65]][@inp] = %[[VAL_62]] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_57]]{{\[}}%[[VAL_66]]] = %[[VAL_65]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_67]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_69]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@count] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_71]], %[[VAL_72]] : index
// CHECK-NEXT:              pod.write %[[VAL_68]][@count] = %[[VAL_73]] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_73]], %[[VAL_74]] : index
// CHECK-NEXT:              scf.if %[[VAL_75]] {
// CHECK-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@params] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !pod.type<[@q: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@q] : <[@q: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = function.call @ArrayOp::@ArrayOp::@compute(%[[VAL_77]]) {(%[[VAL_79]])} : (!array.type<15 x !felt.type<"bn128">>) -> !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:                pod.write %[[VAL_68]][@comp] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_35]]{{\[}}%[[VAL_81]]] = %[[VAL_68]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_83]], %[[VAL_57]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_44]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_51]]#1, %[[VAL_85]] : !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_87]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@comp] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_89]][@outp] : <@ArrayOp::@ArrayOp<[#map]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_92]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_34]][@outp] = %[[VAL_93]] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_34]][@m$inputs] = %[[VAL_38]]#0 : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_96]] to %[[VAL_95]] step %[[VAL_97]] {
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_98]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@comp] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_94]]{{\[}}%[[VAL_98]]] = %[[VAL_100]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_34]][@m] = %[[VAL_94]] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>
// CHECK-NEXT:          function.return %[[VAL_34]] : !struct.type<@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !struct.type<@Wrapper::@Wrapper<[]>>, %[[VAL_102:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@outp] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@m] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@m$inputs] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_106]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_108]], %[[VAL_109]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_110]]) %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_111]] }  : <[@q: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_112]]) : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#map]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_117]], %[[VAL_118]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_119]]) %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_121]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_123]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_125]]{{\[}}%[[VAL_126]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_127]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_120]], %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_111]], %[[VAL_130]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_131]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_133]]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_134]][@outp] : <@ArrayOp::@ArrayOp<[#map]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_136]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_135]]{{\[}}%[[VAL_137]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_142:[0-9a-zA-Z_\.]+]] = %[[VAL_140]] to %[[VAL_139]] step %[[VAL_141]] {
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_142]]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#map]>>>, !struct.type<@ArrayOp::@ArrayOp<[#map]>>
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_105]]{{\[}}%[[VAL_142]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @ArrayOp::@ArrayOp::@constrain(%[[VAL_143]], %[[VAL_145]]) : (!struct.type<@ArrayOp::@ArrayOp<[#map]>>, !array.type<15 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
