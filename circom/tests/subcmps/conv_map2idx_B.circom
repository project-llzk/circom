// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.3;

template GetWeight(A, B) {
    signal output x;    //signal index 0
    signal output y;    //signal index 1
    signal output out;  //signal index 2
    out <-- A;
}

template ComputeValue() {
    component ws[2];
    ws[0] = GetWeight(999, 0);
    ws[1] = GetWeight(888, 1);

    signal ret[2];
    ret[0] <== ws[0].out;
    ret[1] <== ws[1].out;
}

component main = ComputeValue();

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@ComputeValue::@ComputeValue<[]>>} {
// CHECK-NEXT:    poly.template @ComputeValue {
// CHECK-NEXT:      struct.def @ComputeValue {
// CHECK-NEXT:        struct.member @ret : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:        struct.member @ws : !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @ws$inputs : !array.type<2 x !pod.type<[]>>
// CHECK-NEXT:        function.def @compute() -> !struct.type<@ComputeValue::@ComputeValue<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_0:[0-9a-zA-Z_\.]+]] = struct.new : <@ComputeValue::@ComputeValue<[]>>
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_4]], @B = %[[VAL_5]] }  : <[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute() : () -> !struct.type<@GetWeight::@GetWeight<[999, 0]>>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[999, 0]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_9]] : (!pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[999, 0]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_11]]] = %[[VAL_12]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  888 : <"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_13]], @B = %[[VAL_14]] }  : <[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = function.call @GetWeight::@GetWeight::@compute() : () -> !struct.type<@GetWeight::@GetWeight<[888, 1]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new { @comp = %[[VAL_17]] }  : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[888, 1]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_18]] : (!pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[888, 1]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          array.write %[[VAL_2]]{{\[}}%[[VAL_20]]] = %[[VAL_21]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_23]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_25]][@out] : <@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_28]]] = %[[VAL_26]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_30]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@out] : <@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_1]]{{\[}}%[[VAL_35]]] = %[[VAL_33]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_0]][@ws$inputs] = %[[VAL_3]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]] to %[[VAL_37]] step %[[VAL_39]] {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_40]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@comp] : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_36]]{{\[}}%[[VAL_40]]] = %[[VAL_42]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_0]][@ws] = %[[VAL_36]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:          struct.writem %[[VAL_0]][@ret] = %[[VAL_1]] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_0]] : !struct.type<@ComputeValue::@ComputeValue<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !struct.type<@ComputeValue::@ComputeValue<[]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@ret] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@ws] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_43]][@ws$inputs] : <@ComputeValue::@ComputeValue<[]>>, !array.type<2 x !pod.type<[]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  999 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_47]], @B = %[[VAL_48]] }  : <[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[999, 0]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  888 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new { @A = %[[VAL_51]], @B = %[[VAL_52]] }  : <[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@GetWeight::@GetWeight<[888, 1]>>, @params: !pod.type<[@A: !felt.type<"bn128">, @B: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_55]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_56]]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_57]][@out] : <@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_59]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_60]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_61]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_63]]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@out] : <@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_44]]{{\[}}%[[VAL_67]]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_68]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_70]] to %[[VAL_69]] step %[[VAL_71]] {
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_72]]] : <2 x !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_72]]] : <2 x !pod.type<[]>>, !pod.type<[]>
// CHECK-NEXT:            function.call @GetWeight::@GetWeight::@constrain(%[[VAL_73]]) : (!struct.type<@GetWeight::@GetWeight<[#[[$ATTR_0]], #[[$ATTR_0]]]>>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @GetWeight {
// CHECK-NEXT:      poly.param @A
// CHECK-NEXT:      poly.param @B
// CHECK-NEXT:      struct.def @GetWeight {
// CHECK-NEXT:        struct.member @x : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @y : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute() -> !struct.type<@GetWeight::@GetWeight<[@A, @B]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.new : <@GetWeight::@GetWeight<[@A, @B]>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = poly.read_const @B : !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_75]][@out] = %[[VAL_76]] : <@GetWeight::@GetWeight<[@A, @B]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_75]] : !struct.type<@GetWeight::@GetWeight<[@A, @B]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_78:[0-9a-zA-Z_\.]+]]: !struct.type<@GetWeight::@GetWeight<[@A, @B]>>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = poly.read_const @A : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = poly.read_const @B : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@x] : <@GetWeight::@GetWeight<[@A, @B]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@y] : <@GetWeight::@GetWeight<[@A, @B]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@out] : <@GetWeight::@GetWeight<[@A, @B]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
