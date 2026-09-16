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
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_15:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_4]], %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_12]]) : (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) -> (!felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_15]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_18]]) %[[VAL_15]], %[[VAL_16]], %[[VAL_17]] : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>):
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_23]], @params = %[[VAL_22]] }  : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_25]]] = %[[VAL_24]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_19]], %[[VAL_26]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_27]] -> (!array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>) {
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_30]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_31]][@prev_new1] = %[[VAL_29]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_21]]{{\[}}%[[VAL_32]]] = %[[VAL_31]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_33]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_35]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_37]], %[[VAL_38]] : index
// CHECK-NEXT:              pod.write %[[VAL_34]][@count] = %[[VAL_39]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_39]], %[[VAL_40]] : index
// CHECK-NEXT:              scf.if %[[VAL_41]] {
// CHECK-NEXT:                %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_34]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_43]], %[[VAL_44]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_34]][@comp] = %[[VAL_45]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_20]]{{\[}}%[[VAL_46]]] = %[[VAL_34]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.sub %[[VAL_47]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_49]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_50]][@prev_na] = %[[VAL_48]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_21]]{{\[}}%[[VAL_51]]] = %[[VAL_50]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_52]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_54]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:              pod.write %[[VAL_53]][@count] = %[[VAL_58]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_58]], %[[VAL_59]] : index
// CHECK-NEXT:              scf.if %[[VAL_60]] {
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_53]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_62]], %[[VAL_63]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_53]][@comp] = %[[VAL_64]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_20]]{{\[}}%[[VAL_65]]] = %[[VAL_53]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_20]], %[[VAL_21]] : !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_67]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_68]][@prev_new1] = %[[VAL_66]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_21]]{{\[}}%[[VAL_69]]] = %[[VAL_68]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_70]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_72]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_74]], %[[VAL_75]] : index
// CHECK-NEXT:              pod.write %[[VAL_71]][@count] = %[[VAL_76]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_76]], %[[VAL_77]] : index
// CHECK-NEXT:              scf.if %[[VAL_78]] {
// CHECK-NEXT:                %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_82:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_80]], %[[VAL_81]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_71]][@comp] = %[[VAL_82]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_20]]{{\[}}%[[VAL_83]]] = %[[VAL_71]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_85]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              pod.write %[[VAL_86]][@prev_na] = %[[VAL_84]] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_21]]{{\[}}%[[VAL_87]]] = %[[VAL_86]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_88]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_90]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@count] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_92]], %[[VAL_93]] : index
// CHECK-NEXT:              pod.write %[[VAL_89]][@count] = %[[VAL_94]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_94]], %[[VAL_95]] : index
// CHECK-NEXT:              scf.if %[[VAL_96]] {
// CHECK-NEXT:                %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@params] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CHECK-NEXT:                %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_100:[0-9a-zA-Z_\.]+]] = function.call @SMTProcessorSM::@SMTProcessorSM::@compute(%[[VAL_98]], %[[VAL_99]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:                pod.write %[[VAL_89]][@comp] = %[[VAL_100]] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_20]]{{\[}}%[[VAL_101]]] = %[[VAL_89]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:              scf.yield %[[VAL_20]], %[[VAL_21]] : !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_103]], %[[VAL_28]]#0, %[[VAL_28]]#1 : !felt.type<"bn128">, !array.type<@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm$inputs] = %[[VAL_14]]#2 : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = array.new  : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_106]] to %[[VAL_105]] step %[[VAL_107]] {
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_14]]#1{{\[}}%[[VAL_108]]] : <@nLevels x !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>>, !pod.type<[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_109]][@comp] : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            array.write %[[VAL_104]]{{\[}}%[[VAL_108]]] = %[[VAL_110]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@sm] = %[[VAL_104]] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_111:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessor::@SMTProcessor<[@nLevels]>>, %[[VAL_112:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "enabled"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_113]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_111]][@sm] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_111]][@sm$inputs] : <@SMTProcessor::@SMTProcessor<[@nLevels]>>, !array.type<@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_119:[0-9a-zA-Z_\.]+]] = %[[VAL_117]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_119]], %[[VAL_114]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_120]]) %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_121]], %[[VAL_124]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_125]] {
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_121]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = poly.read_const @nLevels : index
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_131:[0-9a-zA-Z_\.]+]] = %[[VAL_129]] to %[[VAL_128]] step %[[VAL_130]] {
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_115]]{{\[}}%[[VAL_131]]] : <@nLevels x !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>>, !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_131]]] : <@nLevels x !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>>, !pod.type<[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@prev_new1] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_133]][@prev_na] : <[@prev_new1: !felt.type<"bn128">, @prev_na: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @SMTProcessorSM::@SMTProcessorSM::@constrain(%[[VAL_132]], %[[VAL_134]], %[[VAL_135]]) : (!struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @SMTProcessorSM {
// CHECK-NEXT:      struct.def @SMTProcessorSM {
// CHECK-NEXT:        function.def @compute(%[[VAL_136:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_new1"}, %[[VAL_137:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_na"}) -> !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = struct.new : <@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:          function.return %[[VAL_138]] : !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_139:[0-9a-zA-Z_\.]+]]: !struct.type<@SMTProcessorSM::@SMTProcessorSM<[]>>, %[[VAL_140:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_new1"}, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "prev_na"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
