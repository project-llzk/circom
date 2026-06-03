// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SMTProcessor::@SMTProcessor<[2]>>} {
// CHECK-NEXT:    poly.template @SMTProcessor {
// CHECK-NEXT:      poly.param @nLevels
// CHECK-NEXT:      struct.def @SMTProcessor {
// CHECK-NEXT:        struct.member @sm : !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:        struct.member @sm$inputs : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "enabled"}) -> !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessor::@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]] to %[[VAL_5]] step %[[VAL_7]] {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_8]]] = %[[VAL_10]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_14:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_11]]) : (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_14]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_16]]) %[[VAL_14]], %[[VAL_15]] : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]], @params = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_22]]] = %[[VAL_21]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_17]], %[[VAL_23]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_24]] -> (!array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_27]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_28]][@prev_new1] = %[[VAL_26]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_18]]{{\[}}%[[VAL_29]]] = %[[VAL_28]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_30]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_32]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_34]], %[[VAL_35]] : index
// CHECK-NEXT:              pod.write %[[VAL_31]][@count] = %[[VAL_36]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_36]], %[[VAL_37]] : index
// CHECK-NEXT:              scf.if %[[VAL_38]] {
// CHECK-NEXT:                %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_40]], %[[VAL_41]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_31]][@comp] = %[[VAL_42]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_43]]] = %[[VAL_31]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_44]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_46]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_47]][@prev_na] = %[[VAL_45]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_18]]{{\[}}%[[VAL_48]]] = %[[VAL_47]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_49]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_51]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:              pod.write %[[VAL_50]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:              scf.if %[[VAL_57]] {
// CHECK-NEXT:                %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_50]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_59]], %[[VAL_60]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_50]][@comp] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_62]]] = %[[VAL_50]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_18]] : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_64]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_65]][@prev_new1] = %[[VAL_63]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_18]]{{\[}}%[[VAL_66]]] = %[[VAL_65]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_67]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_69]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_71]], %[[VAL_72]] : index
// CHECK-NEXT:              pod.write %[[VAL_68]][@count] = %[[VAL_73]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_73]], %[[VAL_74]] : index
// CHECK-NEXT:              scf.if %[[VAL_75]] {
// CHECK-NEXT:                %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_77]], %[[VAL_78]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_68]][@comp] = %[[VAL_79]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_80]]] = %[[VAL_68]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_82]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_83]][@prev_na] = %[[VAL_81]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_18]]{{\[}}%[[VAL_84]]] = %[[VAL_83]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_85]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_87]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_89]], %[[VAL_90]] : index
// CHECK-NEXT:              pod.write %[[VAL_86]][@count] = %[[VAL_91]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_91]], %[[VAL_92]] : index
// CHECK-NEXT:              scf.if %[[VAL_93]] {
// CHECK-NEXT:                %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_95]], %[[VAL_96]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_86]][@comp] = %[[VAL_97]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_98]]] = %[[VAL_86]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_18]] : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_17]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_100]], %[[VAL_25]] : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm$inputs] = %[[VAL_13]]#1 : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_103]] to %[[VAL_102]] step %[[VAL_104]] {
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_105]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@comp] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            array.write %[[VAL_101]]{{\[}}%[[VAL_105]]] = %[[VAL_107]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm] = %[[VAL_101]] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_108:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>, %[[VAL_109:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "enabled"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_108]][@sm] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_108]][@sm$inputs] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_115:[0-9a-zA-Z_\.]+]] = %[[VAL_113]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_115]], %[[VAL_110]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_116]]) %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_117:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_117]], %[[VAL_120]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_121]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_117]], %[[VAL_122]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_127:[0-9a-zA-Z_\.]+]] = %[[VAL_125]] to %[[VAL_124]] step %[[VAL_126]] {
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_127]]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_127]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @SMTProcessorSM::@SMTProcessorSM::@constrain(%[[VAL_128]], %[[VAL_130]], %[[VAL_131]]) : (!struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SMTProcessorSM {
// CHECK-NEXT:      struct.def @SMTProcessorSM {
// CHECK-NEXT:        function.def @compute(%[[VAL_132:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_new1"}, %[[VAL_133:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_na"}) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          function.return %[[VAL_134]] : !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_135:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, %[[VAL_136:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_new1"}, %[[VAL_137:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_na"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
