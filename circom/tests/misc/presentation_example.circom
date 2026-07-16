// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.3;

template GetWeight(A) {
    signal input inp;
    signal output out;
    // ...
}

template ComputeValue() {
    signal input in[2];
    signal output ret[2];

    ret[0] <== GetWeight(99)(in[0]);
    ret[1] <== GetWeight(88)(in[1]);
}

component main = ComputeValue();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@ComputeValue::@ComputeValue<[]>>} {
// CHECK-NEXT:    poly.template @ComputeValue {
// CHECK-NEXT:      struct.def @ComputeValue {
// CHECK-NEXT:        struct.member @ret : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @GetWeight_17_409 : !struct.type<@GetWeight::@GetWeight<[99]>>
// CHECK-NEXT:        struct.member @GetWeight_17_409$inputs : !pod.type<[@inp: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        struct.member @GetWeight_18_446 : !struct.type<@GetWeight::@GetWeight<[88]>>
// CHECK-NEXT:        struct.member @GetWeight_18_446$inputs : !pod.type<[@inp: !felt.type<"bn128">]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@ComputeValue::@ComputeValue<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@ComputeValue::@ComputeValue<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_5]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_7]], @params = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_3]][@inp] = %[[VAL_11]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_12]], %[[VAL_13]] : index
// CHECK-NEXT:          pod.write %[[VAL_8]][@count] = %[[VAL_14]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_14]], %[[VAL_15]] : index
// CHECK-NEXT:          scf.if %[[VAL_16]] {
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@params] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !pod.type<[@A: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute(%[[VAL_18]]) : (!felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[99]>>
// CHECK-NEXT:            pod.write %[[VAL_8]][@comp] = %[[VAL_19]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[99]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[99]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@out] : <@GetWeight::@GetWeight<[99]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_23]]] = %[[VAL_21]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  88 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_24]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_26]], @params = %[[VAL_25]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_29]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          pod.write %[[VAL_4]][@inp] = %[[VAL_30]] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@count] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_31]], %[[VAL_32]] : index
// CHECK-NEXT:          pod.write %[[VAL_27]][@count] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:          scf.if %[[VAL_35]] {
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@params] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !pod.type<[@A: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute(%[[VAL_37]]) : (!felt.type<"bn128">) -> !struct.type<@GetWeight::@GetWeight<[88]>>
// CHECK-NEXT:            pod.write %[[VAL_27]][@comp] = %[[VAL_38]] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[88]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[88]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_39]][@out] : <@GetWeight::@GetWeight<[88]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_41]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_42]]] = %[[VAL_40]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@GetWeight_17_409$inputs] = %[[VAL_3]] : <@ComputeValue::@ComputeValue<[]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[99]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@GetWeight_17_409] = %[[VAL_43]] : <@ComputeValue::@ComputeValue<[]>>, !struct.type<@GetWeight::@GetWeight<[99]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@GetWeight_18_446$inputs] = %[[VAL_4]] : <@ComputeValue::@ComputeValue<[]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[88]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@GetWeight_18_446] = %[[VAL_44]] : <@ComputeValue::@ComputeValue<[]>>, !struct.type<@GetWeight::@GetWeight<[88]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@ret] = %[[VAL_2]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@ComputeValue::@ComputeValue<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !struct.type<@ComputeValue::@ComputeValue<[]>>, %[[VAL_46:[0-9a-zA-Z_\.]+]]: !array.type<2 x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@ret] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@GetWeight_17_409] : <@ComputeValue::@ComputeValue<[]>>, !struct.type<@GetWeight::@GetWeight<[99]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@GetWeight_17_409$inputs] : <@ComputeValue::@ComputeValue<[]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@GetWeight_18_446] : <@ComputeValue::@ComputeValue<[]>>, !struct.type<@GetWeight::@GetWeight<[88]>>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_45]][@GetWeight_18_446$inputs] : <@ComputeValue::@ComputeValue<[]>>, !pod.type<[@inp: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_52]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[99]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_56]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_58]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_48]][@out] : <@GetWeight::@GetWeight<[99]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_61]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_62]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  88 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_63]] }  : <[@A: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[88]>>, @params: !pod.type<[@A: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_67]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_69]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_50]][@out] : <@GetWeight::@GetWeight<[88]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_47]]{{\[}}%[[VAL_72]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_73]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_49]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @GetWeight::@GetWeight::@constrain(%[[VAL_48]], %[[VAL_74]]) : (!struct.type<@GetWeight::@GetWeight<[99]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@inp] : <[@inp: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:          function.call @GetWeight::@GetWeight::@constrain(%[[VAL_50]], %[[VAL_75]]) : (!struct.type<@GetWeight::@GetWeight<[88]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @GetWeight {
// CHECK-NEXT:      poly.param @A
// CHECK-NEXT:      struct.def @GetWeight {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) -> !struct.type<@GetWeight::@GetWeight<[@A]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.new : <@GetWeight::@GetWeight<[@A]>>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_77]] : !struct.type<@GetWeight::@GetWeight<[@A]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !struct.type<@GetWeight::@GetWeight<[@A]>>, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_79]][@out] : <@GetWeight::@GetWeight<[@A]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
