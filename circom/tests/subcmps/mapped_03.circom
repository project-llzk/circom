// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
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
// CHECK-NEXT:        struct.member @m : !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @m$inputs : !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Wrapper::@Wrapper<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.new : <@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_35]], %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_36]], %[[VAL_41:[0-9a-zA-Z_\.]+]] = %[[VAL_37]]) : (!array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_41]], %[[VAL_42]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_43]]) %[[VAL_39]], %[[VAL_40]], %[[VAL_41]] : !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, %[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_46]] }  : <[@q: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 15 : index
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_49]], @params = %[[VAL_48]] } (%[[VAL_47]]) : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_44]]{{\[}}%[[VAL_51]]] = %[[VAL_50]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]], %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_44]], %[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_45]]) : (!felt.type<"bn128">, !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>) -> (!felt.type<"bn128">, !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>) {
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_54]], %[[VAL_57]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_58]]) %[[VAL_54]], %[[VAL_55]], %[[VAL_56]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>):
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_62]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_64]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_66]]{{\[}}%[[VAL_67]]] = %[[VAL_63]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_68]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_69]][@inp] = %[[VAL_66]] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_61]]{{\[}}%[[VAL_70]]] = %[[VAL_69]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_60]]{{\[}}%[[VAL_71]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_73]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@count] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_75]], %[[VAL_76]] : index
// CHECK-NEXT:              pod.write %[[VAL_72]][@count] = %[[VAL_77]] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_77]], %[[VAL_78]] : index
// CHECK-NEXT:              scf.if %[[VAL_79]] {
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@params] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !pod.type<[@q: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@q] : <[@q: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_84:[0-9a-zA-Z_\.]+]] = function.call @ArrayOp::@ArrayOp::@compute(%[[VAL_81]]) {(%[[VAL_83]])} : (!array.type<15 x !felt.type<"bn128">>) -> !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                pod.write %[[VAL_72]][@comp] = %[[VAL_84]] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_60]]{{\[}}%[[VAL_85]]] = %[[VAL_72]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_59]], %[[VAL_86]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_87]], %[[VAL_60]], %[[VAL_61]] : !felt.type<"bn128">, !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_53]]#1, %[[VAL_53]]#2, %[[VAL_89]] : !array.type<4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]#0{{\[}}%[[VAL_91]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@comp] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@outp] : <@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_96]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_34]][@outp] = %[[VAL_97]] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_34]][@m$inputs] = %[[VAL_38]]#1 : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.new  : <4 x !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_102:[0-9a-zA-Z_\.]+]] = %[[VAL_100]] to %[[VAL_99]] step %[[VAL_101]] {
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]#0{{\[}}%[[VAL_102]]] : <4 x !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@comp] : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>, !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_98]]{{\[}}%[[VAL_102]]] = %[[VAL_104]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>>, !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_34]][@m] = %[[VAL_98]] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          function.return %[[VAL_34]] : !struct.type<@Wrapper::@Wrapper<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_105:[0-9a-zA-Z_\.]+]]: !struct.type<@Wrapper::@Wrapper<[]>>, %[[VAL_106:[0-9a-zA-Z_\.]+]]: !array.type<15 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@outp] : <@Wrapper::@Wrapper<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@m] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_105]][@m$inputs] : <@Wrapper::@Wrapper<[]>>, !array.type<4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_112:[0-9a-zA-Z_\.]+]] = %[[VAL_110]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_112]], %[[VAL_113]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_114]]) %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_115:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.new { @q = %[[VAL_115]] }  : <[@q: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_116]]) : <[@count: index, @comp: !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, @params: !pod.type<[@q: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_119]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  15 : <"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_121]], %[[VAL_122]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_123]]) %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_124:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_125]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_109]]{{\[}}%[[VAL_127]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_130]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_131]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_124]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_115]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_135]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_136]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_137]]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>>, !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_138]][@outp] : <@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_140]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_139]]{{\[}}%[[VAL_141]]] : <15 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_107]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_146:[0-9a-zA-Z_\.]+]] = %[[VAL_144]] to %[[VAL_143]] step %[[VAL_145]] {
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_146]]] : <4 x !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>>, !struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_109]]{{\[}}%[[VAL_146]]] : <4 x !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>>, !pod.type<[@inp: !array.type<15 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@inp] : <[@inp: !array.type<15 x !felt.type<"bn128">>]>, !array.type<15 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @ArrayOp::@ArrayOp::@constrain(%[[VAL_147]], %[[VAL_149]]) : (!struct.type<@ArrayOp::@ArrayOp<[#[[$ATTR_0]]]>>, !array.type<15 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
