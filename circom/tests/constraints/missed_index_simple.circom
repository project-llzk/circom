// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Mult() {
    signal input in[2];
    signal output out;
}

template Good(N) {
    signal input inp[N][2];
    component c[N];

    for (var i = 0; i < N; i++) {
        c[i] = Mult();
        for (var j = 0; j < 2; j++) {
            c[i].in[j] <== inp[i][j];
        }

        c[i].out === 77;
    }
}

component main = Good(2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Good::@Good<[2]>>} {
// CHECK-NEXT:    poly.template @Good {
// CHECK-NEXT:      poly.param @N : index
// CHECK-NEXT:      struct.def @Good {
// CHECK-NEXT:        struct.member @c : !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N,2 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Good::@Good<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Good::@Good<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_6]] step %[[VAL_8]] {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_10]], @params = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_9]]] = %[[VAL_11]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_4_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_13]]) : (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_17]]) %[[VAL_4_IN]], %[[VAL_15]], %[[VAL_16]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_4_LCV:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_21]], @params = %[[VAL_20]] }  : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_4_LCV]]{{\[}}%[[VAL_23]]] = %[[VAL_22]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_4_IN_2:[0-9a-zA-Z_\.]+]] = %[[VAL_4_LCV]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_18]], %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_24]]) : (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_27]], %[[VAL_28]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_29]]) %[[VAL_4_IN_2]], %[[VAL_26]], %[[VAL_27]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_4_LCV_2:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, %[[VAL_30:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_32]], %[[VAL_33]]] : <@N,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_35]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_37]]{{\[}}%[[VAL_38]]] = %[[VAL_34]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_39]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_40]][@in] = %[[VAL_37]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_30]]{{\[}}%[[VAL_41]]] = %[[VAL_40]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4_LCV_2]]{{\[}}%[[VAL_42]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_44]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@count] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:              pod.write %[[VAL_43]][@count] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:              scf.if %[[VAL_50]] {
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@params] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = function.call @Mult::@Mult::@compute(%[[VAL_52]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:                pod.write %[[VAL_43]][@comp] = %[[VAL_53]] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4_LCV_2]]{{\[}}%[[VAL_54]]] = %[[VAL_43]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_4_LCV_2]], %[[VAL_30]], %[[VAL_56]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_25]]#0, %[[VAL_25]]#1, %[[VAL_58]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c$inputs] = %[[VAL_14]]#1 : <@Good::@Good<[@N]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_63:[0-9a-zA-Z_\.]+]] = %[[VAL_61]] to %[[VAL_60]] step %[[VAL_62]] {
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]#0{{\[}}%[[VAL_63]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@comp] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            array.write %[[VAL_59]]{{\[}}%[[VAL_63]]] = %[[VAL_65]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c] = %[[VAL_59]] : <@Good::@Good<[@N]>>, !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Good::@Good<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !struct.type<@Good::@Good<[@N]>>, %[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<@N,2 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_68]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@c] : <@Good::@Good<[@N]>>, !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@c$inputs] : <@Good::@Good<[@N]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_72]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_74]], %[[VAL_69]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_75]]) %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_81]], %[[VAL_82]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_83]]) %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_67]]{{\[}}%[[VAL_85]], %[[VAL_86]]] : <@N,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_88]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_90]]{{\[}}%[[VAL_91]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_92]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_95]]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_96]][@out] : <@Mult::@Mult<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_97]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_76]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]] to %[[VAL_101]] step %[[VAL_103]] {
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_104]]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_104]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Mult::@Mult::@constrain(%[[VAL_105]], %[[VAL_107]]) : (!struct.type<@Mult::@Mult<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Mult {
// CHECK-NEXT:      struct.def @Mult {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_108:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Mult::@Mult<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.new : <@Mult::@Mult<[]>>
// CHECK-NEXT:          function.return %[[VAL_109]] : !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_110:[0-9a-zA-Z_\.]+]]: !struct.type<@Mult::@Mult<[]>>, %[[VAL_111:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_110]][@out] : <@Mult::@Mult<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
