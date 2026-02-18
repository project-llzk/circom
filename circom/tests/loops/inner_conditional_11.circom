// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Sigma() {
    signal input inp;
    signal output out;
}

// Equivalent to inner_conditional_10 but refactored slightly.
template Poseidon() {
    signal input inp;

    component sigmaF[2];

    for (var i=0; i<4; i++) {
        if (i < 1) {
            sigmaF[0] = Sigma();
            sigmaF[0].inp <== inp;
        } else if (i >= 3) {
            sigmaF[1] = Sigma();
            sigmaF[1].inp <== inp;
        }
    }
}

component main = Poseidon();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Poseidon<[]>>} {
// CHECK-NEXT:    struct.def @Poseidon<[]> {
// CHECK-NEXT:      struct.member @sigmaF : !array.type<2 x !struct.type<@Sigma<[]>>>
// CHECK-NEXT:      struct.member @sigmaF$inputs : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Poseidon<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]] to %[[VAL_3]] step %[[VAL_5]] {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_6]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          pod.write %[[VAL_7]][@count] = %[[VAL_8]] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_6]]] = %[[VAL_7]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>) -> (!felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>) {
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_14]])
// CHECK-NEXT:          scf.condition(%[[VAL_15]]) %[[VAL_12]], %[[VAL_13]] : !felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@inp: !felt.type]>>):
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_18]])
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_19]] -> (!array.type<2 x !pod.type<[@inp: !felt.type]>>) {
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]]
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_24]]] = %[[VAL_22]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]]
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_26]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:            pod.write %[[VAL_27]][@inp] = %[[VAL_0]] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]]
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_29]]] = %[[VAL_27]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]]
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_31]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@count] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:            pod.write %[[VAL_32]][@count] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:            scf.if %[[VAL_37]] {
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@compute(%[[VAL_38]]) : (!felt.type) -> !struct.type<@Sigma<[]>>
// CHECK-NEXT:              pod.write %[[VAL_32]][@comp] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma<[]>>
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]]
// CHECK-NEXT:              array.write %[[VAL_2]]{{\[}}%[[VAL_41]]] = %[[VAL_32]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_16]], %[[VAL_42]])
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_43]] -> (!array.type<2 x !pod.type<[@inp: !felt.type]>>) {
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_45]] }  : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]]
// CHECK-NEXT:              array.write %[[VAL_2]]{{\[}}%[[VAL_48]]] = %[[VAL_46]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]]
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_50]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:              pod.write %[[VAL_51]][@inp] = %[[VAL_0]] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]]
// CHECK-NEXT:              array.write %[[VAL_17]]{{\[}}%[[VAL_53]]] = %[[VAL_51]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]]
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_55]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@count] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_57]], %[[VAL_58]] : index
// CHECK-NEXT:              pod.write %[[VAL_56]][@count] = %[[VAL_59]] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_59]], %[[VAL_60]] : index
// CHECK-NEXT:              scf.if %[[VAL_61]] {
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@compute(%[[VAL_62]]) : (!felt.type) -> !struct.type<@Sigma<[]>>
// CHECK-NEXT:                pod.write %[[VAL_56]][@comp] = %[[VAL_63]] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma<[]>>
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]]
// CHECK-NEXT:                array.write %[[VAL_2]]{{\[}}%[[VAL_65]]] = %[[VAL_56]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_17]] : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              scf.yield %[[VAL_17]] : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_44]] : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_66]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_67]], %[[VAL_20]] : !felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@sigmaF$inputs] = %[[VAL_11]]#1 : <@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:        %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Sigma<[]>>>
// CHECK-NEXT:        %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_70]] to %[[VAL_69]] step %[[VAL_71]] {
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_72]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@comp] : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma<[]>>
// CHECK-NEXT:          array.write %[[VAL_68]]{{\[}}%[[VAL_72]]] = %[[VAL_74]] : <2 x !struct.type<@Sigma<[]>>>, !struct.type<@Sigma<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@sigmaF] = %[[VAL_68]] : <@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma<[]>>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@Poseidon<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_75:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon<[]>>, %[[VAL_76:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@sigmaF] : <@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma<[]>>>
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@sigmaF$inputs] : <@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:        %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_80:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_81]], %[[VAL_82]])
// CHECK-NEXT:          scf.condition(%[[VAL_83]]) %[[VAL_81]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_84]], %[[VAL_85]])
// CHECK-NEXT:          scf.if %[[VAL_86]] {
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_87]] }  : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]]
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_90]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_92]], %[[VAL_76]] : !felt.type, !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_84]], %[[VAL_93]])
// CHECK-NEXT:            scf.if %[[VAL_94]] {
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_95]] }  : <[@count: index, @comp: !struct.type<@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]]
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_98]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_100]], %[[VAL_76]] : !felt.type, !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_101]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_102]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:        %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_106:[0-9a-zA-Z_\.]+]] = %[[VAL_104]] to %[[VAL_103]] step %[[VAL_105]] {
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_106]]] : <2 x !struct.type<@Sigma<[]>>>, !struct.type<@Sigma<[]>>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_106]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @Sigma::@constrain(%[[VAL_107]], %[[VAL_109]]) : (!struct.type<@Sigma<[]>>, !felt.type) -> ()
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Sigma<[]> {
// CHECK-NEXT:      struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_110:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Sigma<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.new : <@Sigma<[]>>
// CHECK-NEXT:        function.return %[[VAL_111]] : !struct.type<@Sigma<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_112:[0-9a-zA-Z_\.]+]]: !struct.type<@Sigma<[]>>, %[[VAL_113:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_114:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_112]][@out] : <@Sigma<[]>>, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
