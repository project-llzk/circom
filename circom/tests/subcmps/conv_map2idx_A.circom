// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.3;

template GetWeight(A) {
    signal input inp;
}

template ComputeValue() {
    component getWeights[2];

    getWeights[0] = GetWeight(0);
    getWeights[0].inp <-- 888;

    getWeights[1] = GetWeight(1);
    getWeights[1].inp <-- 999;
}

component main = ComputeValue();

// CHECK-LABEL: #[[$ATTR_0]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ComputeValue::@ComputeValue<[]>>} {
// CHECK-NEXT:    poly.template @ComputeValue {
// CHECK-NEXT:      struct.def @ComputeValue {
// CHECK-NEXT:        struct.member @getWeights : !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @getWeights$inputs : !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ComputeValue::@ComputeValue<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ComputeValue::@ComputeValue<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_3]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[0]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_6]] : (!pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[0]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_8]]] = %[[VAL_9]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  888 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_12]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_13]][@inp] = %[[VAL_10]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_15]]] = %[[VAL_13]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_17]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_20]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@count] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:          pod.write %[[VAL_18]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// CHECK-NEXT:          scf.if %[[VAL_26]] {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@params] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !pod.type<[@A: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@A] : <[@A: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute(%[[VAL_28]]) {(%[[VAL_30]])} : (!felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            pod.write %[[VAL_18]][@comp] = %[[VAL_31]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_33]]] = %[[VAL_18]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_34]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_36]], @params = %[[VAL_35]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[1]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_37]] : (!pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[1]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_39]]] = %[[VAL_40]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_43]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_44]][@inp] = %[[VAL_41]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_46]]] = %[[VAL_44]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_47]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_48]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_51]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@count] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// CHECK-NEXT:          pod.write %[[VAL_49]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// CHECK-NEXT:          scf.if %[[VAL_57]] {
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@params] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !pod.type<[@A: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_58]][@A] : <[@A: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute(%[[VAL_59]]) {(%[[VAL_61]])} : (!felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            pod.write %[[VAL_49]][@comp] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_64]]] = %[[VAL_49]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@getWeights$inputs] = %[[VAL_2]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_67]] to %[[VAL_66]] step %[[VAL_68]] {
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_69]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_65]]{{\[}}%[[VAL_69]]] = %[[VAL_71]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@getWeights] = %[[VAL_65]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ComputeValue::@ComputeValue<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_72:[0-9a-zA-Z_\.]+]]: !struct.type<@ComputeValue::@ComputeValue<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@getWeights] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@getWeights$inputs] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_75]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[0]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_78]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[1]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]] to %[[VAL_81]] step %[[VAL_83]] {
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_73]]{{\[}}%[[VAL_84]]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_84]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @GetWeight::@GetWeight::@constrain(%[[VAL_85]], %[[VAL_87]]) : (!struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @GetWeight {
// CHECK-NEXT:      poly.param @A
// CHECK-NEXT:      struct.def @GetWeight {
// CHECK-NEXT:        function.def @compute(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[@A]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.new : <@GetWeight::@GetWeight<[@A]>>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_89]] : !struct.type<@GetWeight::@GetWeight<[@A]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_91:[0-9a-zA-Z_\.]+]]: !struct.type<@GetWeight::@GetWeight<[@A]>>, %[[VAL_92:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
