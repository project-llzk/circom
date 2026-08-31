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
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_13]]) : (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_18]]) %[[VAL_15]], %[[VAL_16]], %[[VAL_17]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_25]]] = %[[VAL_24]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_19]], %[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_20]], %[[VAL_30:[0-9a-zA-Z_\.]+]] = %[[VAL_26]]) : (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_30]], %[[VAL_31]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_32]]) %[[VAL_28]], %[[VAL_29]], %[[VAL_30]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_36]], %[[VAL_37]]] : <@N,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_39]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_41]]{{\[}}%[[VAL_42]]] = %[[VAL_38]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_43]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_44]][@in] = %[[VAL_41]] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_34]]{{\[}}%[[VAL_45]]] = %[[VAL_44]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_46]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_34]]{{\[}}%[[VAL_48]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@count] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_50]], %[[VAL_51]] : index
// CHECK-NEXT:              pod.write %[[VAL_47]][@count] = %[[VAL_52]] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_53]] : index
// CHECK-NEXT:              scf.if %[[VAL_54]] {
// CHECK-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@params] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = function.call @Mult::@Mult::@compute(%[[VAL_56]]) : (!array.type<2 x !felt.type<"bn128">>) -> !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:                pod.write %[[VAL_47]][@comp] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_33]]{{\[}}%[[VAL_58]]] = %[[VAL_47]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_33]], %[[VAL_34]], %[[VAL_60]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_61]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_27]]#0, %[[VAL_27]]#1, %[[VAL_62]] : !array.type<@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c$inputs] = %[[VAL_14]]#1 : <@Good::@Good<[@N]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_65]] to %[[VAL_64]] step %[[VAL_66]] {
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]#0{{\[}}%[[VAL_67]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@comp] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            array.write %[[VAL_63]]{{\[}}%[[VAL_67]]] = %[[VAL_69]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c] = %[[VAL_63]] : <@Good::@Good<[@N]>>, !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Good::@Good<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_70:[0-9a-zA-Z_\.]+]]: !struct.type<@Good::@Good<[@N]>>, %[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<@N,2 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_72]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_70]][@c] : <@Good::@Good<[@N]>>, !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_70]][@c$inputs] : <@Good::@Good<[@N]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_76]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_78]], %[[VAL_73]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_79]]) %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_85:[0-9a-zA-Z_\.]+]] = %[[VAL_83]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_85]], %[[VAL_86]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_87]]) %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_89]], %[[VAL_90]]] : <@N,2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_92]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_88]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_94]]{{\[}}%[[VAL_95]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_96]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_88]], %[[VAL_97]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_98]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_99]]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_100]][@out] : <@Mult::@Mult<[]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  77 : <"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_101]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_80]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_106]] to %[[VAL_105]] step %[[VAL_107]] {
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_108]]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_108]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<2 x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@in] : <[@in: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Mult::@Mult::@constrain(%[[VAL_109]], %[[VAL_111]]) : (!struct.type<@Mult::@Mult<[]>>, !array.type<2 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Mult {
// CHECK-NEXT:      struct.def @Mult {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_112:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Mult::@Mult<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = struct.new : <@Mult::@Mult<[]>>
// CHECK-NEXT:          function.return %[[VAL_113]] : !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_114:[0-9a-zA-Z_\.]+]]: !struct.type<@Mult::@Mult<[]>>, %[[VAL_115:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_114]][@out] : <@Mult::@Mult<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
