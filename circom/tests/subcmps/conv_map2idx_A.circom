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
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_3]] }  : <[@A: index]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[0]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_6]] : (!pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[0]>>, @params: !pod.type<[@A: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_8]]] = %[[VAL_9]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
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
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_17]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@count] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_19]], %[[VAL_20]] : index
// CHECK-NEXT:          pod.write %[[VAL_18]][@count] = %[[VAL_21]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:          scf.if %[[VAL_23]] {
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@params] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, !pod.type<[@A: index]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@A] : <[@A: index]>, index
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute(%[[VAL_25]]) {(%[[VAL_26]])} : (!felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            pod.write %[[VAL_18]][@comp] = %[[VAL_27]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_29]]] = %[[VAL_18]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_30]] }  : <[@A: index]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_32]], @params = %[[VAL_31]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[1]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_33]] : (!pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[1]>>, @params: !pod.type<[@A: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_35]]] = %[[VAL_36]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_39]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          pod.write %[[VAL_40]][@inp] = %[[VAL_37]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_42]]] = %[[VAL_40]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_44]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@count] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, index
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:          pod.write %[[VAL_45]][@count] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:          scf.if %[[VAL_50]] {
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@params] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, !pod.type<[@A: index]>
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_40]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@A] : <[@A: index]>, index
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute(%[[VAL_52]]) {(%[[VAL_53]])} : (!felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            pod.write %[[VAL_45]][@comp] = %[[VAL_54]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_1]]{{\[}}%[[VAL_56]]] = %[[VAL_45]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@getWeights$inputs] = %[[VAL_2]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_61:[0-9a-zA-Z_\.]+]] = %[[VAL_59]] to %[[VAL_58]] step %[[VAL_60]] {
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_61]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, @params: !pod.type<[@A: index]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_57]]{{\[}}%[[VAL_61]]] = %[[VAL_63]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@getWeights] = %[[VAL_57]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ComputeValue::@ComputeValue<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !struct.type<@ComputeValue::@ComputeValue<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@getWeights] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@getWeights$inputs] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !pod.type<[@inp: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_67]] }  : <[@A: index]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_69]], @params = %[[VAL_68]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[0]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_71]] }  : <[@A: index]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_73]], @params = %[[VAL_72]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[1]>>, @params: !pod.type<[@A: index]>]>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_76]] to %[[VAL_75]] step %[[VAL_77]] {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_65]]{{\[}}%[[VAL_78]]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_78]]] : <2 x !pod.type<[@inp: !felt.type<"bn128">]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @GetWeight::@GetWeight::@constrain(%[[VAL_79]], %[[VAL_81]]) : (!struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]]]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @GetWeight {
// CHECK-NEXT:      poly.param @A
// CHECK-NEXT:      struct.def @GetWeight {
// CHECK-NEXT:        function.def @compute(%[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[@A]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.new : <@GetWeight::@GetWeight<[@A]>>
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_83]] : !struct.type<@GetWeight::@GetWeight<[@A]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !struct.type<@GetWeight::@GetWeight<[@A]>>, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
