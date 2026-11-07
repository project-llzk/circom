// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Inner(i,j) {
    signal input in;
    signal output out;

    out <-- (in >> i) & j;
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];

    component c[n];
    for (var i = 0; i < n; i++) {
    	c[i] = Inner(i, i+1);
    	c[i].in <-- in;
    	out[i] <-- c[i].out;
    }
}

component main = Num2Bits(3);

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Num2Bits::@Num2Bits<[3]>>} {
// CHECK-NEXT:    poly.template @Inner {
// CHECK-NEXT:      poly.param @i
// CHECK-NEXT:      poly.param @j
// CHECK-NEXT:      struct.def @Inner {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Inner::@Inner<[@i, @j]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_.-]+]] = struct.new : <@Inner::@Inner<[@i, @j]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_.-]+]] = poly.read_const @j : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_.-]+]] = felt.shr %[[VAL_0]], %[[VAL_2]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_.-]+]] = felt.bit_and %[[VAL_4]], %[[VAL_3]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_5]] : <@Inner::@Inner<[@i, @j]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@Inner::@Inner<[@i, @j]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_6:[0-9a-zA-Z_.-]+]]: !struct.type<@Inner::@Inner<[@i, @j]>>, %[[VAL_7:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_.-]+]] = poly.read_const @i : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_.-]+]] = poly.read_const @j : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_6]][@out] : <@Inner::@Inner<[@i, @j]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Num2Bits {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Num2Bits {
// CHECK-NEXT:        struct.member @out : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @c : !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @c$inputs : !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_11:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@Num2Bits::@Num2Bits<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_.-]+]] = struct.new : <@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_.-]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_13]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_.-]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_.-]+]] = array.new  : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_.-]+]] = array.new  : <@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_.-]+]]:3 = scf.while (%[[VAL_20:[0-9a-zA-Z_.-]+]] = %[[VAL_16]], %[[VAL_21:[0-9a-zA-Z_.-]+]] = %[[VAL_17]], %[[VAL_22:[0-9a-zA-Z_.-]+]] = %[[VAL_18]]) : (!array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) -> (!array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_14]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_23]]) %[[VAL_20]], %[[VAL_21]], %[[VAL_22]] : !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_24:[0-9a-zA-Z_.-]+]]: !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, %[[VAL_25:[0-9a-zA-Z_.-]+]]: !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, %[[VAL_26:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_26]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_.-]+]] = pod.new { @i = %[[VAL_26]], @j = %[[VAL_29]] }  : <[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VAL_32]], @params = %[[VAL_31]] } (%[[VAL_27]]), (%[[VAL_30]]) : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_24]]{{\[}}%[[VAL_34]]] = %[[VAL_33]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_35]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            pod.write %[[VAL_36]][@in] = %[[VAL_11]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_25]]{{\[}}%[[VAL_37]]] = %[[VAL_36]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_38]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_40]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_.-]+]] = arith.subi %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:            pod.write %[[VAL_39]][@count] = %[[VAL_44]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:            scf.if %[[VAL_46]] {
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>, !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_41]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_47]][@i] : <[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_47]][@j] : <[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_.-]+]] = function.call @Inner::@Inner::@compute(%[[VAL_48]]) {(%[[VAL_50]]), (%[[VAL_52]])} : (!felt.type<"bn128">) -> !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:              pod.write %[[VAL_39]][@comp] = %[[VAL_53]] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_24]]{{\[}}%[[VAL_54]]] = %[[VAL_39]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_55]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_56]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_57]][@out] : <@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_15]]{{\[}}%[[VAL_59]]] = %[[VAL_58]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_26]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_24]], %[[VAL_25]], %[[VAL_61]] : !array.type<@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_12]][@c$inputs] = %[[VAL_19]]#1 : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_.-]+]] = array.new  : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_.-]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_66:[0-9a-zA-Z_.-]+]] = %[[VAL_64]] to %[[VAL_63]] step %[[VAL_65]] {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_19]]#0{{\[}}%[[VAL_66]]] : <@n x !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_67]][@comp] : <[@count: index, @comp: !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, @params: !pod.type<[@i: !felt.type<"bn128">, @j: !felt.type<"bn128">]>]>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:            array.write %[[VAL_62]]{{\[}}%[[VAL_66]]] = %[[VAL_68]] : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_12]][@c] = %[[VAL_62]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:          struct.writem %[[VAL_12]][@out] = %[[VAL_15]] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_12]] : !struct.type<@Num2Bits::@Num2Bits<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_69:[0-9a-zA-Z_.-]+]]: !struct.type<@Num2Bits::@Num2Bits<[@n]>>, %[[VAL_70:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_.-]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VAL_71]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_69]][@out] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_69]][@c] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_.-]+]] = struct.readm %[[VAL_69]][@c$inputs] : <@Num2Bits::@Num2Bits<[@n]>>, !array.type<@n x !pod.type<[@in: !felt.type<"bn128">]>>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_.-]+]] = scf.while (%[[VAL_78:[0-9a-zA-Z_.-]+]] = %[[VAL_76]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_.-]+]] = bool.cmp lt(%[[VAL_78]], %[[VAL_72]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_79]]) %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_80:[0-9a-zA-Z_.-]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_80]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_.-]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_.-]+]] = felt.add %[[VAL_80]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_.-]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_90:[0-9a-zA-Z_.-]+]] = %[[VAL_88]] to %[[VAL_87]] step %[[VAL_89]] {
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_90]]] : <@n x !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>, !struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_.-]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_90]]] : <@n x !pod.type<[@in: !felt.type<"bn128">]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_.-]+]] = pod.read %[[VAL_92]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:            function.call @Inner::@Inner::@constrain(%[[VAL_91]], %[[VAL_93]]) : (!struct.type<@Inner::@Inner<[#[[$ATTR_0]], #[[$ATTR_0]]]>>, !felt.type<"bn128">) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
