// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Good::@Good<[2]>>} {
// CHECK-NEXT:    poly.template @Good {
// CHECK-NEXT:      poly.param @N
// CHECK-NEXT:      struct.def @Good {
// CHECK-NEXT:        struct.member @c : !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@N,2 x !felt.type>) -> !struct.type<@Good::@Good<[@N]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Good::@Good<[@N]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]] to %[[VAL_4]] step %[[VAL_6]] {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_7]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            pod.write %[[VAL_8]][@count] = %[[VAL_9]] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_7]]] = %[[VAL_8]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_10]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type) -> (!array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_2]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_13]], %[[VAL_14]] : !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]] }  : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_20]]] = %[[VAL_19]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_23:[0-9a-zA-Z_\.]+]] = %[[VAL_16]], %[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_21]]) : (!array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type) -> (!array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type) {
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_25]]) : !felt.type, !felt.type
// CHECK-NEXT:              scf.condition(%[[VAL_26]]) %[[VAL_23]], %[[VAL_24]] : !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_29]], %[[VAL_30]]] : <@N,2 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_32]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type
// CHECK-NEXT:              array.write %[[VAL_34]]{{\[}}%[[VAL_35]]] = %[[VAL_31]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_36]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:              pod.write %[[VAL_37]][@in] = %[[VAL_34]] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type
// CHECK-NEXT:              array.write %[[VAL_27]]{{\[}}%[[VAL_38]]] = %[[VAL_37]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_39]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@count] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_41]], %[[VAL_42]] : index
// CHECK-NEXT:              pod.write %[[VAL_40]][@count] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_43]], %[[VAL_44]] : index
// CHECK-NEXT:              scf.if %[[VAL_45]] {
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = function.call @Mult::@Mult::@compute(%[[VAL_46]]) : (!array.type<2 x !felt.type>) -> !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:                pod.write %[[VAL_40]][@comp] = %[[VAL_47]] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:                %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_48]]] = %[[VAL_40]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_49]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_27]], %[[VAL_50]] : !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_51]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_22]]#0, %[[VAL_52]] : !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c$inputs] = %[[VAL_12]]#0 : <@Good::@Good<[@N]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.new  : <@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_55]] to %[[VAL_54]] step %[[VAL_56]] {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_57]]] : <@N x !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@comp] : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            array.write %[[VAL_53]]{{\[}}%[[VAL_57]]] = %[[VAL_59]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c] = %[[VAL_53]] : <@Good::@Good<[@N]>>, !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Good::@Good<[@N]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !struct.type<@Good::@Good<[@N]>>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<@N,2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = poly.read_const @N : !felt.type
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@c] : <@Good::@Good<[@N]>>, !array.type<@N x !struct.type<@Mult::@Mult<[]>>>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@c$inputs] : <@Good::@Good<[@N]>>, !array.type<@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_65]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_67]], %[[VAL_62]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_68]]) %[[VAL_67]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_70]] }  : <[@count: index, @comp: !struct.type<@Mult::@Mult<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_72]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  2
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_74]], %[[VAL_75]]) : !felt.type, !felt.type
// CHECK-NEXT:              scf.condition(%[[VAL_76]]) %[[VAL_74]] : !felt.type
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_78]], %[[VAL_79]]] : <@N,2 x !felt.type>, !felt.type
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_81]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_84]]] : <2 x !felt.type>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_85]], %[[VAL_80]] : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_86]] : !felt.type, !felt.type
// CHECK-NEXT:              scf.yield %[[VAL_87]] : !felt.type
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_88]]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_89]][@out] : <@Mult::@Mult<[]>>, !felt.type
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  77
// CHECK-NEXT:            constrain.eq %[[VAL_90]], %[[VAL_91]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_92]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_93]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = poly.read_const @N : index
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_95]] to %[[VAL_94]] step %[[VAL_96]] {
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_97]]] : <@N x !struct.type<@Mult::@Mult<[]>>>, !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_64]]{{\[}}%[[VAL_97]]] : <@N x !pod.type<[@in: !array.type<2 x !felt.type>]>>, !pod.type<[@in: !array.type<2 x !felt.type>]>
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@in] : <[@in: !array.type<2 x !felt.type>]>, !array.type<2 x !felt.type>
// CHECK-NEXT:            function.call @Mult::@Mult::@constrain(%[[VAL_98]], %[[VAL_100]]) : (!struct.type<@Mult::@Mult<[]>>, !array.type<2 x !felt.type>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Mult {
// CHECK-NEXT:      struct.def @Mult {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) -> !struct.type<@Mult::@Mult<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = struct.new : <@Mult::@Mult<[]>>
// CHECK-NEXT:          function.return %[[VAL_102]] : !struct.type<@Mult::@Mult<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_103:[0-9a-zA-Z_\.]+]]: !struct.type<@Mult::@Mult<[]>>, %[[VAL_104:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_103]][@out] : <@Mult::@Mult<[]>>, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
