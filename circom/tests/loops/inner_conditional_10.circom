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
// CHECK-NEXT:        struct.member @sigmaF$inputs : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Poseidon::@Poseidon<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Poseidon::@Poseidon<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_4]] to %[[VAL_3]] step %[[VAL_5]] {
// CHECK-NEXT:            %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_6]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            pod.write %[[VAL_7]][@count] = %[[VAL_8]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            array.write %[[VAL_2]]{{\[}}%[[VAL_6]]] = %[[VAL_7]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]], %[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>) -> (!felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>) {
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_14]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_15]]) %[[VAL_12]], %[[VAL_13]] : !felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@inp: !felt.type]>>):
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_18]]) : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_16]], %[[VAL_20]]) : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_19]], %[[VAL_21]] : i1, i1
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_22]] -> (!array.type<2 x !pod.type<[@inp: !felt.type]>>) {
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_16]], %[[VAL_24]]) : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_25]] -> (!felt.type) {
// CHECK-NEXT:                %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:                scf.yield %[[VAL_27]] : !felt.type
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:                scf.yield %[[VAL_28]] : !felt.type
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_29]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type
// CHECK-NEXT:              array.write %[[VAL_2]]{{\[}}%[[VAL_31]]] = %[[VAL_30]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_32]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:              pod.write %[[VAL_33]][@inp] = %[[VAL_0]] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type
// CHECK-NEXT:              array.write %[[VAL_17]]{{\[}}%[[VAL_34]]] = %[[VAL_33]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_35]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@count] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:              pod.write %[[VAL_36]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:              scf.if %[[VAL_41]] {
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = function.call @Sigma::@Sigma::@compute(%[[VAL_42]]) : (!felt.type) -> !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                pod.write %[[VAL_36]][@comp] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:                %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type
// CHECK-NEXT:                array.write %[[VAL_2]]{{\[}}%[[VAL_44]]] = %[[VAL_36]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_17]] : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              scf.yield %[[VAL_17]] : !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_45]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_46]], %[[VAL_23]] : !felt.type, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF$inputs] = %[[VAL_11]]#1 : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_51:[0-9a-zA-Z_\.]+]] = %[[VAL_49]] to %[[VAL_48]] step %[[VAL_50]] {
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_51]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@comp] : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            array.write %[[VAL_47]]{{\[}}%[[VAL_51]]] = %[[VAL_53]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sigmaF] = %[[VAL_47]] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Poseidon::@Poseidon<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_54:[0-9a-zA-Z_\.]+]]: !struct.type<@Poseidon::@Poseidon<[]>>, %[[VAL_55:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_54]][@sigmaF] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !struct.type<@Sigma::@Sigma<[]>>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_54]][@sigmaF$inputs] : <@Poseidon::@Poseidon<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type]>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_58]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_60]], %[[VAL_61]]) : !felt.type, !felt.type
// CHECK-NEXT:            scf.condition(%[[VAL_62]]) %[[VAL_60]] : !felt.type
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_63]], %[[VAL_64]]) : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp ge(%[[VAL_63]], %[[VAL_66]]) : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = bool.or %[[VAL_65]], %[[VAL_67]] : i1, i1
// CHECK-NEXT:            scf.if %[[VAL_68]] {
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_63]], %[[VAL_69]]) : !felt.type, !felt.type
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_70]] -> (!felt.type) {
// CHECK-NEXT:                %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:                scf.yield %[[VAL_72]] : !felt.type
// CHECK-NEXT:              } else {
// CHECK-NEXT:                %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:                scf.yield %[[VAL_73]] : !felt.type
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_74]] }  : <[@count: index, @comp: !struct.type<@Sigma::@Sigma<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]] : !felt.type
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_76]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:              constrain.eq %[[VAL_78]], %[[VAL_55]] : !felt.type, !felt.type
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_63]], %[[VAL_79]] : !felt.type, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_80]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]] to %[[VAL_81]] step %[[VAL_83]] {
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_56]]{{\[}}%[[VAL_84]]] : <2 x !struct.type<@Sigma::@Sigma<[]>>>, !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_84]]] : <2 x !pod.type<[@inp: !felt.type]>>, !pod.type<[@inp: !felt.type]>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@inp] : <[@inp: !felt.type]>, !felt.type
// CHECK-NEXT:            function.call @Sigma::@Sigma::@constrain(%[[VAL_85]], %[[VAL_87]]) : (!struct.type<@Sigma::@Sigma<[]>>, !felt.type) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sigma {
// CHECK-NEXT:      struct.def @Sigma {
// CHECK-NEXT:        struct.member @out : !felt.type {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@Sigma::@Sigma<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.new : <@Sigma::@Sigma<[]>>
// CHECK-NEXT:          function.return %[[VAL_89]] : !struct.type<@Sigma::@Sigma<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_90:[0-9a-zA-Z_\.]+]]: !struct.type<@Sigma::@Sigma<[]>>, %[[VAL_91:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_90]][@out] : <@Sigma::@Sigma<[]>>, !felt.type
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
