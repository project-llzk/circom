// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Sigma() {
    signal input inp;
    signal output out;
}

template Poseidon() {
    signal input inp;

    component sigmaF[2];
    for (var i=0; i<4; i++) {
        if (i < 1 || i >= 3) {
            var k = i < 1 ? 0 : 1;
            sigmaF[k] = Sigma();
            sigmaF[k].inp <== inp;
        }
    }
}

component main = Poseidon();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Poseidon::@Poseidon<[]>>} {
// CHECK-NEXT:    poly.template @Poseidon {
// CHECK-NEXT:      struct.def @Poseidon {
// CHECK-NEXT:        struct.member @sigmaF : !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:        struct.member @sigmaF$inputs : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
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
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_17]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_20]], %[[VAL_22]] : i1, i1
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_23]] -> (!array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>) {
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_26]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_31]], @params = %[[VAL_30]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_2]]{{\[}}%[[VAL_33]]] = %[[VAL_32]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_34]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_35]][@inp] = %[[VAL_0]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_18]]{{\[}}%[[VAL_36]]] = %[[VAL_35]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_37]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_39]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@count] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_41]], %[[VAL_42]] : index
// CHECK-NEXT:              pod.write %[[VAL_38]][@count] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_43]], %[[VAL_44]] : index
// CHECK-NEXT:              scf.if %[[VAL_45]] {
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@params] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_48:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@Sigma::@compute(%[[VAL_47]]) : (!felt.type<"bn128">) -> !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                pod.write %[[VAL_38]][@comp] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_2]]{{\[}}%[[VAL_49]]] = %[[VAL_38]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_18]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              scf.yield %[[VAL_18]] : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_50]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_51]], %[[VAL_24]] : !felt.type<"bn128">, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF$inputs] = %[[VAL_12]]#1 : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_54]] to %[[VAL_53]] step %[[VAL_55]] {
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_56]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@comp] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            array.write %[[VAL_52]]{{\[}}%[[VAL_56]]] = %[[VAL_58]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF] = %[[VAL_52]] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Poseidon::@Poseidon<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon::@Poseidon<[]>>, %[[VAL_60:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@sigmaF] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_59]][@sigmaF$inputs] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_63]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_65]], %[[VAL_66]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_67]]) %[[VAL_65]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_68]], %[[VAL_69]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_68]], %[[VAL_71]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_70]], %[[VAL_72]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_73]] {
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_68]], %[[VAL_74]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_75]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                scf.yield %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_81]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_83]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_68]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_89:[0-9a-zA-Z_\.]+]] = %[[VAL_87]] to %[[VAL_86]] step %[[VAL_88]] {
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_89]]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_89]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Sigma::@Sigma::@constrain(%[[VAL_90]], %[[VAL_92]]) : (!struct.type<@Sigma::@Sigma<[]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sigma {
// CHECK-NEXT:      struct.def @Sigma {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_93:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@Sigma::@Sigma<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.new : <@Sigma::@Sigma<[]>>
// CHECK-NEXT:          function.return %[[VAL_94]] : !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_95:[0-9a-zA-Z_\.]+]]: !struct.type<@Sigma::@Sigma<[]>>, %[[VAL_96:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_95]][@out] : <@Sigma::@Sigma<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
