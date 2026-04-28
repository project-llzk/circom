// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Poseidon::@Poseidon<[]>>} {
// CHECK-NEXT:    poly.template @Poseidon {
// CHECK-NEXT:      struct.def @Poseidon {
// CHECK-NEXT:        struct.member @sigmaF : !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:        struct.member @sigmaF$inputs : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Poseidon::@Poseidon<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon::@Poseidon<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_6]], %[[VAL_8]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_6]], %[[VAL_7]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_10]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_13]] -> (!array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) {
// CHECK-NEXT:              %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_16]], @params = %[[VAL_15]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_2]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_21]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_22]][@inp] = %[[VAL_0]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_11]]{{\[}}%[[VAL_24]]] = %[[VAL_22]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_26]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@count] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_28]], %[[VAL_29]] : index
// CHECK-NEXT:              pod.write %[[VAL_27]][@count] = %[[VAL_30]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_30]], %[[VAL_31]] : index
// CHECK-NEXT:              scf.if %[[VAL_32]] {
// CHECK-NEXT:                %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@params] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_22]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_35:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@Sigma::@compute(%[[VAL_34]]) : (!felt.type<"bn128">) -> !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                pod.write %[[VAL_27]][@comp] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_2]]{{\[}}%[[VAL_37]]] = %[[VAL_27]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_11]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_10]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_39]] -> (!array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) {
// CHECK-NEXT:                %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_42]], @params = %[[VAL_41]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_2]]{{\[}}%[[VAL_45]]] = %[[VAL_43]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_47]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_48]][@inp] = %[[VAL_0]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_11]]{{\[}}%[[VAL_50]]] = %[[VAL_48]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_52]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@count] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:                pod.write %[[VAL_53]][@count] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:                scf.if %[[VAL_58]] {
// CHECK-NEXT:                  %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@params] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_48]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_61:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@Sigma::@compute(%[[VAL_60]]) : (!felt.type<"bn128">) -> !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_53]][@comp] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                  %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                  %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_2]]{{\[}}%[[VAL_63]]] = %[[VAL_53]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_11]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                scf.yield %[[VAL_11]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_40]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_65]], %[[VAL_14]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF$inputs] = %[[VAL_5]]#1 : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_68]] to %[[VAL_67]] step %[[VAL_69]] {
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_70]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@comp] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            array.write %[[VAL_66]]{{\[}}%[[VAL_70]]] = %[[VAL_72]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF] = %[[VAL_66]] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Poseidon::@Poseidon<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon::@Poseidon<[]>>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@sigmaF] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@sigmaF$inputs] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_77]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_79]], %[[VAL_80]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_81]]) %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_83]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_84]] {
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_88]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_90]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_82]], %[[VAL_91]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.if %[[VAL_92]] {
// CHECK-NEXT:                %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_96]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_98]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_82]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]] to %[[VAL_101]] step %[[VAL_103]] {
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_104]]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_104]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Sigma::@Sigma::@constrain(%[[VAL_105]], %[[VAL_107]]) : (!struct.type<@Sigma::@Sigma<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sigma {
// CHECK-NEXT:      struct.def @Sigma {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_108:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Sigma::@Sigma<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = struct.new : <@Sigma::@Sigma<[]>>
// CHECK-NEXT:          function.return %[[VAL_109]] : !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_110:[0-9a-zA-Z_\.]+]]: !struct.type<@Sigma::@Sigma<[]>>, %[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_110]][@out] : <@Sigma::@Sigma<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
