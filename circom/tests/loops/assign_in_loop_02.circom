// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Inner(i) {
    signal input in;
    signal output out;

    out <-- in & i;
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];

    component c[n];
    for (var i = 0; i < n; i++) {
    	c[i] = Inner(i);
    	c[i].in <-- in;
    	out[i] <-- c[i].out;
    }
}

component main = Num2Bits(3);

// CHECK-LABEL: #[[$ATTR_0]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Num2Bits::@Num2Bits<[3]>>} {
// CHECK-NEXT:    poly.template @Inner {
// CHECK-NEXT:      poly.param @i
// CHECK-NEXT:      struct.def @Inner {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Inner::@Inner<[@i]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@Inner::@Inner<[@i]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.bit_and %[[VAL_0]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_3]] : <@Inner::@Inner<[@i]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Inner::@Inner<[@i]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_4:[0-9a-zA-Z_\.]+]]: !struct.type<@Inner::@Inner<[@i]>>, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_4]][@out] : <@Inner::@Inner<[@i]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @c : !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_8:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_16:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_14]]) : (!array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_10]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_18]]) %[[VAL_16]], %[[VAL_17]] : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, %[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.new { @i = %[[VAL_20]] }  : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_21]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_12]]{{\[}}%[[VAL_25]]] = %[[VAL_24]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_26]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_27]][@in] = %[[VAL_8]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_28]]] = %[[VAL_27]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_29]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_31]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@count] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_33]], %[[VAL_34]] : index
// CHECK-NEXT:            pod.write %[[VAL_30]][@count] = %[[VAL_35]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_35]], %[[VAL_36]] : index
// CHECK-NEXT:            scf.if %[[VAL_37]] {
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@params] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !pod.type<[@i: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@i] : <[@i: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = function.call @Inner::@Inner::@compute(%[[VAL_39]]) {(%[[VAL_41]])} : (!felt.type<"bn128">) -> !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              pod.write %[[VAL_30]][@comp] = %[[VAL_42]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_12]]{{\[}}%[[VAL_43]]] = %[[VAL_30]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_44]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_46]][@out] : <@Inner::@Inner<[#[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_11]]{{\[}}%[[VAL_48]]] = %[[VAL_47]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_19]], %[[VAL_50]] : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@c$inputs] = %[[VAL_15]]#0 : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_53]] to %[[VAL_52]] step %[[VAL_54]] {
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_55]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_51]]{{\[}}%[[VAL_55]]] = %[[VAL_57]] : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_9]][@c] = %[[VAL_51]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          struct.writem %[[VAL_9]][@out] = %[[VAL_11]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_9]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_58:[0-9a-zA-Z_\.]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_59:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@c] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_58]][@c$inputs] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_64]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_66]], %[[VAL_60]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_67]]) %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.new { @i = %[[VAL_68]] }  : <[@i: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.new(%[[VAL_69]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_68]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_73]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_75]] to %[[VAL_74]] step %[[VAL_76]] {
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_62]]{{\[}}%[[VAL_77]]] : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_77]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Inner::@Inner::@constrain(%[[VAL_78]], %[[VAL_80]]) : (!struct.type<@Inner::@Inner<[#[[$ATTR_0]]]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
