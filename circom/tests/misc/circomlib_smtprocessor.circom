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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SMTProcessor::@SMTProcessor<[2]>>} {
// CHECK-NEXT:    poly.template @SMTProcessor {
// CHECK-NEXT:      poly.param @nLevels
// CHECK-NEXT:      struct.def @SMTProcessor {
// CHECK-NEXT:        struct.member @sm : !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:        struct.member @sm$inputs : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessor::@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]], %[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_7]], %[[VAL_8]] : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_11:[0-9a-zA-Z_\.]+]]: !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_13]], @params = %[[VAL_12]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_15]]] = %[[VAL_14]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_10]], %[[VAL_16]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_17]] -> (!array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:              %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_20]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_21]][@prev_new1] = %[[VAL_19]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_11]]{{\[}}%[[VAL_22]]] = %[[VAL_21]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_23]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_25]], %[[VAL_26]] : index
// CHECK-NEXT:              pod.write %[[VAL_24]][@count] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_27]], %[[VAL_28]] : index
// CHECK-NEXT:              scf.if %[[VAL_29]] {
// CHECK-NEXT:                %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_31]], %[[VAL_32]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_24]][@comp] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_34]]] = %[[VAL_24]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_35]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_37]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_38]][@prev_na] = %[[VAL_36]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_11]]{{\[}}%[[VAL_39]]] = %[[VAL_38]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_40]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:              pod.write %[[VAL_41]][@count] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:              scf.if %[[VAL_46]] {
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_50:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_48]], %[[VAL_49]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_41]][@comp] = %[[VAL_50]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_51]]] = %[[VAL_41]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_11]] : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_53]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_54]][@prev_new1] = %[[VAL_52]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_11]]{{\[}}%[[VAL_55]]] = %[[VAL_54]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_56]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_58]], %[[VAL_59]] : index
// CHECK-NEXT:              pod.write %[[VAL_57]][@count] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_60]], %[[VAL_61]] : index
// CHECK-NEXT:              scf.if %[[VAL_62]] {
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_54]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_64]], %[[VAL_65]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_57]][@comp] = %[[VAL_66]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_67]]] = %[[VAL_57]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_11]]{{\[}}%[[VAL_69]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_70]][@prev_na] = %[[VAL_68]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_11]]{{\[}}%[[VAL_71]]] = %[[VAL_70]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_72]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_74]], %[[VAL_75]] : index
// CHECK-NEXT:              pod.write %[[VAL_73]][@count] = %[[VAL_76]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_76]], %[[VAL_77]] : index
// CHECK-NEXT:              scf.if %[[VAL_78]] {
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_80]], %[[VAL_81]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_73]][@comp] = %[[VAL_82]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_3]]{{\[}}%[[VAL_83]]] = %[[VAL_73]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_11]] : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_85]], %[[VAL_18]] : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm$inputs] = %[[VAL_6]]#1 : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_90:[0-9a-zA-Z_\.]+]] = %[[VAL_88]] to %[[VAL_87]] step %[[VAL_89]] {
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_90]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@comp] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            array.write %[[VAL_86]]{{\[}}%[[VAL_90]]] = %[[VAL_92]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm] = %[[VAL_86]] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_93:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>, %[[VAL_94:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@sm] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@sm$inputs] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_98]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_100]], %[[VAL_95]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_101]]) %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_102:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_102]], %[[VAL_105]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_106]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_102]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_112:[0-9a-zA-Z_\.]+]] = %[[VAL_110]] to %[[VAL_109]] step %[[VAL_111]] {
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_112]]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_112]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @SMTProcessorSM::@SMTProcessorSM::@constrain(%[[VAL_113]], %[[VAL_115]], %[[VAL_116]]) : (!struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SMTProcessorSM {
// CHECK-NEXT:      struct.def @SMTProcessorSM {
// CHECK-NEXT:        function.def @compute(%[[VAL_117:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_118:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          function.return %[[VAL_119]] : !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, %[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_122:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
