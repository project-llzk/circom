// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.6;

template SMTProcessorSM() {
  signal input prev_new1;
  signal input prev_na;
}

template SMTProcessor(nLevels) {
    signal input enabled;

    component sm[nLevels];
    for (var i=0; i<nLevels; i++) {
        sm[i] = SMTProcessorSM();
        if (i==0) {
            sm[i].prev_new1 <-- 0;
            sm[i].prev_na <-- 1 - enabled;
        } else {
            sm[i].prev_new1 <-- 0;
            sm[i].prev_na <-- 0;
        }
    }
}

component main = SMTProcessor(2);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SMTProcessor<[2]>>} {
// CHECK-NEXT:    struct.def @SMTProcessor<[@nLevels]> {
// CHECK-NEXT:      struct.member @sm : !array.type<@nLevels x !struct.type<@SMTProcessorSM<[]>>>
// CHECK-NEXT:      struct.member @sm$inputs : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@SMTProcessor<[@nLevels]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]] to %[[VAL_4]] step %[[VAL_6]] {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_7]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          pod.write %[[VAL_8]][@count] = %[[VAL_9]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_7]]] = %[[VAL_8]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_12:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_13:[0-9a-zA-Z_\.]+]] = %[[VAL_11]], %[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>) -> (!felt.type, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>) {
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_13]], %[[VAL_2]])
// CHECK-NEXT:          scf.condition(%[[VAL_15]]) %[[VAL_13]], %[[VAL_14]] : !felt.type, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>):
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_18]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_20]]] = %[[VAL_19]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_16]], %[[VAL_21]])
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_22]] -> (!array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>) {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_25]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            pod.write %[[VAL_26]][@prev_new1] = %[[VAL_24]] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_27]]] = %[[VAL_26]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_28]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_30]], %[[VAL_31]] : index
// CHECK-NEXT:            pod.write %[[VAL_29]][@count] = %[[VAL_32]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_32]], %[[VAL_33]] : index
// CHECK-NEXT:            scf.if %[[VAL_34]] {
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@prev_new1] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@prev_na] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@compute(%[[VAL_35]], %[[VAL_36]]) : (!felt.type, !felt.type) -> !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              pod.write %[[VAL_29]][@comp] = %[[VAL_37]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_38]]] = %[[VAL_29]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_39]], %[[VAL_0]] : !felt.type, !felt.type
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_41]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            pod.write %[[VAL_42]][@prev_na] = %[[VAL_40]] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_43]]] = %[[VAL_42]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_44]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:            pod.write %[[VAL_45]][@count] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:            scf.if %[[VAL_50]] {
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@prev_new1] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@prev_na] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@compute(%[[VAL_51]], %[[VAL_52]]) : (!felt.type, !felt.type) -> !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              pod.write %[[VAL_45]][@comp] = %[[VAL_53]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_54]]] = %[[VAL_45]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_56]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            pod.write %[[VAL_57]][@prev_new1] = %[[VAL_55]] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_58]]] = %[[VAL_57]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_59]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_61]], %[[VAL_62]] : index
// CHECK-NEXT:            pod.write %[[VAL_60]][@count] = %[[VAL_63]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_63]], %[[VAL_64]] : index
// CHECK-NEXT:            scf.if %[[VAL_65]] {
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@prev_new1] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@prev_na] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@compute(%[[VAL_66]], %[[VAL_67]]) : (!felt.type, !felt.type) -> !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              pod.write %[[VAL_60]][@comp] = %[[VAL_68]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_69]]] = %[[VAL_60]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_71]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            pod.write %[[VAL_72]][@prev_na] = %[[VAL_70]] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            array.write %[[VAL_17]]{{\[}}%[[VAL_73]]] = %[[VAL_72]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_74]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_76]], %[[VAL_77]] : index
// CHECK-NEXT:            pod.write %[[VAL_75]][@count] = %[[VAL_78]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_78]], %[[VAL_79]] : index
// CHECK-NEXT:            scf.if %[[VAL_80]] {
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@prev_new1] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@prev_na] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@compute(%[[VAL_81]], %[[VAL_82]]) : (!felt.type, !felt.type) -> !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              pod.write %[[VAL_75]][@comp] = %[[VAL_83]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]]
// CHECK-NEXT:              array.write %[[VAL_3]]{{\[}}%[[VAL_84]]] = %[[VAL_75]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_16]], %[[VAL_85]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_86]], %[[VAL_23]] : !felt.type, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@sm$inputs] = %[[VAL_12]]#1 : <@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:        %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !struct.type<@SMTProcessorSM<[]>>>
// CHECK-NEXT:        %[[VAL_88:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:        %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_91:[0-9a-zA-Z_\.]+]] = %[[VAL_89]] to %[[VAL_88]] step %[[VAL_90]] {
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_91]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@comp] : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:          array.write %[[VAL_87]]{{\[}}%[[VAL_91]]] = %[[VAL_93]] : <@nLevels x !struct.type<@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@sm] = %[[VAL_87]] : <@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM<[]>>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_94:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessor<[@nLevels]>>, %[[VAL_95:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_96:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : !felt.type
// CHECK-NEXT:        %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_94]][@sm] : <@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM<[]>>>
// CHECK-NEXT:        %[[VAL_98:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_94]][@sm$inputs] : <@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>
// CHECK-NEXT:        %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_100:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_99]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_101]], %[[VAL_96]])
// CHECK-NEXT:          scf.condition(%[[VAL_102]]) %[[VAL_101]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_103:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_104]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_103]], %[[VAL_106]])
// CHECK-NEXT:          scf.if %[[VAL_107]] {
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_103]], %[[VAL_108]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_109]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_110:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:        %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:        %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:        scf.for %[[VAL_113:[0-9a-zA-Z_\.]+]] = %[[VAL_111]] to %[[VAL_110]] step %[[VAL_112]] {
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_113]]] : <@nLevels x !struct.type<@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_98]]{{\[}}%[[VAL_113]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>>, !pod.type<[@prev_new1: !felt.type, @prev_na: !felt.type]>
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@prev_new1] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@prev_na] : <[@prev_new1: !felt.type, @prev_na: !felt.type]>, !felt.type
// CHECK-NEXT:          function.call @SMTProcessorSM::@constrain(%[[VAL_114]], %[[VAL_116]], %[[VAL_117]]) : (!struct.type<@SMTProcessorSM<[]>>, !felt.type, !felt.type) -> ()
// CHECK-NEXT:        }
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @SMTProcessorSM<[]> {
// CHECK-NEXT:      function.def @compute(%[[VAL_118:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_119:[0-9a-zA-Z_\.]+]]: !felt.type) -> !struct.type<@SMTProcessorSM<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_120:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessorSM<[]>>
// CHECK-NEXT:        function.return %[[VAL_120]] : !struct.type<@SMTProcessorSM<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_121:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessorSM<[]>>, %[[VAL_122:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_123:[0-9a-zA-Z_\.]+]]: !felt.type) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
