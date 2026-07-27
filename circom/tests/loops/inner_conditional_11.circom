// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Poseidon::@Poseidon<[]>>} {
// CHECK-NEXT:    poly.template @Poseidon {
// CHECK-NEXT:      struct.def @Poseidon {
// CHECK-NEXT:        struct.member @sigmaF : !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:        struct.member @sigmaF$inputs : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@Poseidon::@Poseidon<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon::@Poseidon<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]] to %[[VAL_4]] step %[[VAL_6]] {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_8]], @params = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_7]]] = %[[VAL_9]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_11]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_15]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_16]]) %[[VAL_13]], %[[VAL_14]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_20]] -> (!array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) {
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_2]]{{\[}}%[[VAL_26]]] = %[[VAL_24]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_28]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_29]][@inp] = %[[VAL_0]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_18]]{{\[}}%[[VAL_31]]] = %[[VAL_29]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_33]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_36]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_38]], %[[VAL_39]] : index
// CHECK-NEXT:              pod.write %[[VAL_34]][@count] = %[[VAL_40]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_40]], %[[VAL_41]] : index
// CHECK-NEXT:              scf.if %[[VAL_42]] {
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@params] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_37]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@Sigma::@compute(%[[VAL_44]]) : (!felt.type<"bn128">) -> !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                pod.write %[[VAL_34]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_2]]{{\[}}%[[VAL_47]]] = %[[VAL_34]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_18]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_17]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_49]] -> (!array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) {
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:                %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_52]], @params = %[[VAL_51]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_2]]{{\[}}%[[VAL_55]]] = %[[VAL_53]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_57]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:                pod.write %[[VAL_58]][@inp] = %[[VAL_0]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_18]]{{\[}}%[[VAL_60]]] = %[[VAL_58]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_62]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_64]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_65]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@count] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:                %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_67]], %[[VAL_68]] : index
// CHECK-NEXT:                pod.write %[[VAL_63]][@count] = %[[VAL_69]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:                %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:                %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_69]], %[[VAL_70]] : index
// CHECK-NEXT:                scf.if %[[VAL_71]] {
// CHECK-NEXT:                  %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@params] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                  %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                  %[[VAL_74:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@Sigma::@compute(%[[VAL_73]]) : (!felt.type<"bn128">) -> !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                  pod.write %[[VAL_63]][@comp] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                  %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                  %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:                  array.write %[[VAL_2]]{{\[}}%[[VAL_76]]] = %[[VAL_63]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                }
// CHECK-NEXT:                scf.yield %[[VAL_18]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:                scf.yield %[[VAL_18]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_50]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_78]], %[[VAL_21]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF$inputs] = %[[VAL_12]]#1 : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_81]] to %[[VAL_80]] step %[[VAL_82]] {
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_83]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@comp] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            array.write %[[VAL_79]]{{\[}}%[[VAL_83]]] = %[[VAL_85]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF] = %[[VAL_79]] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Poseidon::@Poseidon<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon::@Poseidon<[]>>, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_86]][@sigmaF] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_86]][@sigmaF$inputs] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_92:[0-9a-zA-Z_\.]+]] = %[[VAL_90]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_92]], %[[VAL_93]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_94]]) %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_95:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_95]], %[[VAL_96]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_97]] {
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_101]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_103]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_95]], %[[VAL_104]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.if %[[VAL_105]] {
// CHECK-NEXT:                %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:                %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_109]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                constrain.eq %[[VAL_111]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_95]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]] to %[[VAL_114]] step %[[VAL_116]] {
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_88]]{{\[}}%[[VAL_117]]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_117]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_119]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Sigma::@Sigma::@constrain(%[[VAL_118]], %[[VAL_120]]) : (!struct.type<@Sigma::@Sigma<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sigma {
// CHECK-NEXT:      struct.def @Sigma {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@Sigma::@Sigma<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = struct.new : <@Sigma::@Sigma<[]>>
// CHECK-NEXT:          function.return %[[VAL_122]] : !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_123:[0-9a-zA-Z_\.]+]]: !struct.type<@Sigma::@Sigma<[]>>, %[[VAL_124:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_123]][@out] : <@Sigma::@Sigma<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
