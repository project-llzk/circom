// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:      poly.param @nLevels : index
// CHECK-NEXT:      struct.def @SMTProcessor {
// CHECK-NEXT:        struct.member @sm : !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:        struct.member @sm$inputs : !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "enabled"}) -> !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessor::@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]] to %[[VAL_6]] step %[[VAL_8]] {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_10]], @params = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_9]]] = %[[VAL_11]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_4_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_12]]) : (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_15]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_17]]) %[[VAL_15]], %[[VAL_4_IN]], %[[VAL_16]] : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_4_LCV:[0-9a-zA-Z_\.]+]]: !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_21]], @params = %[[VAL_20]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_4_LCV]]{{\[}}%[[VAL_23]]] = %[[VAL_22]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_18]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_25]] -> (!array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_28]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_29]][@prev_new1] = %[[VAL_27]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_19]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4_LCV]]{{\[}}%[[VAL_31]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_33]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:              pod.write %[[VAL_32]][@count] = %[[VAL_37]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:              scf.if %[[VAL_39]] {
// CHECK-NEXT:                %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_41]], %[[VAL_42]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_32]][@comp] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4_LCV]]{{\[}}%[[VAL_44]]] = %[[VAL_32]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_45]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_47]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_48]][@prev_na] = %[[VAL_46]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_19]]{{\[}}%[[VAL_49]]] = %[[VAL_48]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4_LCV]]{{\[}}%[[VAL_50]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_52]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:              pod.write %[[VAL_51]][@count] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:              scf.if %[[VAL_58]] {
// CHECK-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_60]], %[[VAL_61]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_51]][@comp] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4_LCV]]{{\[}}%[[VAL_63]]] = %[[VAL_51]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_4_LCV]], %[[VAL_19]] : !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_65]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_66]][@prev_new1] = %[[VAL_64]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_19]]{{\[}}%[[VAL_67]]] = %[[VAL_66]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4_LCV]]{{\[}}%[[VAL_68]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_70]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_72]], %[[VAL_73]] : index
// CHECK-NEXT:              pod.write %[[VAL_69]][@count] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_74]], %[[VAL_75]] : index
// CHECK-NEXT:              scf.if %[[VAL_76]] {
// CHECK-NEXT:                %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_78]], %[[VAL_79]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_69]][@comp] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4_LCV]]{{\[}}%[[VAL_81]]] = %[[VAL_69]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_83]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_84]][@prev_na] = %[[VAL_82]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_19]]{{\[}}%[[VAL_85]]] = %[[VAL_84]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_4_LCV]]{{\[}}%[[VAL_86]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_88]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_90]], %[[VAL_91]] : index
// CHECK-NEXT:              pod.write %[[VAL_87]][@count] = %[[VAL_92]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_92]], %[[VAL_93]] : index
// CHECK-NEXT:              scf.if %[[VAL_94]] {
// CHECK-NEXT:                %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_96]], %[[VAL_97]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_87]][@comp] = %[[VAL_98]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_18]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_4_LCV]]{{\[}}%[[VAL_99]]] = %[[VAL_87]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_4_LCV]], %[[VAL_19]] : !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_101]], %[[VAL_26]]#0, %[[VAL_26]]#1 : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm$inputs] = %[[VAL_14]]#2 : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_106:[0-9a-zA-Z_\.]+]] = %[[VAL_104]] to %[[VAL_103]] step %[[VAL_105]] {
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]#1{{\[}}%[[VAL_106]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@comp] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            array.write %[[VAL_102]]{{\[}}%[[VAL_106]]] = %[[VAL_108]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm] = %[[VAL_102]] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_109:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>, %[[VAL_110:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "enabled"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_111]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@sm] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@sm$inputs] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_117:[0-9a-zA-Z_\.]+]] = %[[VAL_115]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_117]], %[[VAL_112]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_118]]) %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_119:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_119]], %[[VAL_122]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_123]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_119]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_129:[0-9a-zA-Z_\.]+]] = %[[VAL_127]] to %[[VAL_126]] step %[[VAL_128]] {
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_113]]{{\[}}%[[VAL_129]]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_114]]{{\[}}%[[VAL_129]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @SMTProcessorSM::@SMTProcessorSM::@constrain(%[[VAL_130]], %[[VAL_132]], %[[VAL_133]]) : (!struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SMTProcessorSM {
// CHECK-NEXT:      struct.def @SMTProcessorSM {
// CHECK-NEXT:        function.def @compute(%[[VAL_134:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_new1"}, %[[VAL_135:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_na"}) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          function.return %[[VAL_136]] : !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_137:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, %[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_new1"}, %[[VAL_139:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_na"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
