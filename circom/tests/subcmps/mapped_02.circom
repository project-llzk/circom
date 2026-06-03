// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
	signal input a[n];
	signal output c[n];

	var i;
	for (i = 0; i < n; i++) {
		c[i] <== a[i] * 2;
	}
}

template B(n, m, j) {
	signal input a[n][j];
	signal output b[n][j];
	signal input c[m][j];
	signal output d[m][j];

	component as[2][j];

	var i;
	var k;
	for (k = 0; k < j; k++) {
		as[0][k] = A(n);
	}
	for (i = 0; i < n; i++) {
		for (k = 0; k < j; k++) {
			as[0][k].a[i] <== a[i][k];
		}
	}


	for (k = 0; k < j; k++) {
		as[1][k] = A(m);
	}
	for(i = 0; i < m; i++) {
		for (k = 0; k < j; k++) {
			as[1][k].a[i] <== c[i][k];
		}
	}

	for (i = 0; i < n; i++) {
		for (k = 0; k < j; k++) {
			b[i][k] <== as[0][k].c[i];
		}
	}

	for (i = 0; i < m; i++) {
		for (k = 0; k < j; k++) {
			d[i][k] <== as[1][k].c[i];
		}
	}
}

component main = B(2, 3, 2);

// CHECK:       #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[2, 3, 2]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @c : !array.type<@n x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_7:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_7]], %[[VAL_2]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_8]]) %[[VAL_7]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_10]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_14]]] = %[[VAL_13]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c] = %[[VAL_3]] : <@A::@A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_17:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_18:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_17]][@c] : <@A::@A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_24]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_18]]{{\[}}%[[VAL_27]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_20]]{{\[}}%[[VAL_31]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_32]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.param @m
// CHECK-NEXT:      poly.param @j
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @b : !array.type<@n,@j x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @d : !array.type<@m,@j x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @as : !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @as$inputs : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<@n,@j x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<@m,@j x !felt.type<"bn128">> {function.arg_name = "c"}) -> !struct.type<@B::@B<[@n, @m, @j]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n, @m, @j]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = poly.read_const @j : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_49:[0-9a-zA-Z_\.]+]] = %[[VAL_47]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_49]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_50]]) %[[VAL_49]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_51:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_52]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_54]], @params = %[[VAL_53]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_55]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            array.write %[[VAL_43]]{{\[}}%[[VAL_57]], %[[VAL_58]]] = %[[VAL_59]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_64:[0-9a-zA-Z_\.]+]] = %[[VAL_44]], %[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_62]], %[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_48]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_65]], %[[VAL_40]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_67]]) %[[VAL_64]], %[[VAL_65]], %[[VAL_66]] : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_68]], %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_71]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_74]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_75]]) %[[VAL_73]], %[[VAL_74]] : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_78]], %[[VAL_79]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_82]], %[[VAL_83]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_85]]{{\[}}%[[VAL_86]]] = %[[VAL_80]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_88]], %[[VAL_89]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_90]][@a] = %[[VAL_85]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_76]]{{\[}}%[[VAL_92]], %[[VAL_93]]] = %[[VAL_90]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_95]], %[[VAL_96]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_98]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_99]], %[[VAL_100]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_102]], %[[VAL_103]] : index
// CHECK-NEXT:              pod.write %[[VAL_97]][@count] = %[[VAL_104]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_104]], %[[VAL_105]] : index
// CHECK-NEXT:              scf.if %[[VAL_106]] {
// CHECK-NEXT:                %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_101]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_111:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_108]]) {(%[[VAL_110]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                pod.write %[[VAL_97]][@comp] = %[[VAL_111]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_43]]{{\[}}%[[VAL_113]], %[[VAL_114]]] = %[[VAL_97]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_76]], %[[VAL_116]] : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_117]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_72]]#0, %[[VAL_118]], %[[VAL_72]]#1 : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_119]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_121]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_122]]) %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_123:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_124]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_126]], @params = %[[VAL_125]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_127]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            array.write %[[VAL_43]]{{\[}}%[[VAL_129]], %[[VAL_130]]] = %[[VAL_131]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_123]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_63]]#0, %[[VAL_137:[0-9a-zA-Z_\.]+]] = %[[VAL_134]], %[[VAL_138:[0-9a-zA-Z_\.]+]] = %[[VAL_120]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_137]], %[[VAL_39]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_139]]) %[[VAL_136]], %[[VAL_137]], %[[VAL_138]] : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_140:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_142:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_145:[0-9a-zA-Z_\.]+]] = %[[VAL_140]], %[[VAL_146:[0-9a-zA-Z_\.]+]] = %[[VAL_143]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_147:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_146]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_147]]) %[[VAL_145]], %[[VAL_146]] : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_148:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_149:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_151:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_150]], %[[VAL_151]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_148]]{{\[}}%[[VAL_154]], %[[VAL_155]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_157]]{{\[}}%[[VAL_158]]] = %[[VAL_152]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_159]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_148]]{{\[}}%[[VAL_160]], %[[VAL_161]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_162]][@a] = %[[VAL_157]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_148]]{{\[}}%[[VAL_164]], %[[VAL_165]]] = %[[VAL_162]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_166]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_167]], %[[VAL_168]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_148]]{{\[}}%[[VAL_171]], %[[VAL_172]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_174]], %[[VAL_175]] : index
// CHECK-NEXT:              pod.write %[[VAL_169]][@count] = %[[VAL_176]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_176]], %[[VAL_177]] : index
// CHECK-NEXT:              scf.if %[[VAL_178]] {
// CHECK-NEXT:                %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_179]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_183:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_180]]) {(%[[VAL_182]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                pod.write %[[VAL_169]][@comp] = %[[VAL_183]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                %[[VAL_184:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_185:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_184]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_149]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_43]]{{\[}}%[[VAL_185]], %[[VAL_186]]] = %[[VAL_169]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_149]], %[[VAL_187]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_148]], %[[VAL_188]] : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_141]], %[[VAL_189]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_144]]#0, %[[VAL_190]], %[[VAL_144]]#1 : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_193:[0-9a-zA-Z_\.]+]] = %[[VAL_191]], %[[VAL_194:[0-9a-zA-Z_\.]+]] = %[[VAL_135]]#2) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_195:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_193]], %[[VAL_40]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_195]]) %[[VAL_193]], %[[VAL_194]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_196:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_197:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_200:[0-9a-zA-Z_\.]+]] = %[[VAL_198]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_201:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_200]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_201]]) %[[VAL_200]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_202:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_204]], %[[VAL_205]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_207]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_208]]{{\[}}%[[VAL_209]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_41]]{{\[}}%[[VAL_211]], %[[VAL_212]]] = %[[VAL_210]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_202]], %[[VAL_213]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_196]], %[[VAL_215]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_216]], %[[VAL_199]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_219:[0-9a-zA-Z_\.]+]] = %[[VAL_217]], %[[VAL_220:[0-9a-zA-Z_\.]+]] = %[[VAL_192]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_219]], %[[VAL_39]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_221]]) %[[VAL_219]], %[[VAL_220]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_222:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_223:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_226:[0-9a-zA-Z_\.]+]] = %[[VAL_224]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_226]], %[[VAL_38]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_227]]) %[[VAL_226]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_228:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_228]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_230]], %[[VAL_231]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_233]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_222]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_234]]{{\[}}%[[VAL_235]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_222]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_228]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_42]]{{\[}}%[[VAL_237]], %[[VAL_238]]] = %[[VAL_236]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_228]], %[[VAL_239]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_222]], %[[VAL_241]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_242]], %[[VAL_225]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_37]][@as$inputs] = %[[VAL_135]]#0 : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_248:[0-9a-zA-Z_\.]+]] = %[[VAL_246]] to %[[VAL_244]] step %[[VAL_247]] {
// CHECK-NEXT:            scf.for %[[VAL_249:[0-9a-zA-Z_\.]+]] = %[[VAL_246]] to %[[VAL_245]] step %[[VAL_247]] {
// CHECK-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_248]], %[[VAL_249]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_250]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              array.write %[[VAL_243]]{{\[}}%[[VAL_248]], %[[VAL_249]]] = %[[VAL_251]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_37]][@as] = %[[VAL_243]] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          struct.writem %[[VAL_37]][@b] = %[[VAL_41]] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_37]][@d] = %[[VAL_42]] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_37]] : !struct.type<@B::@B<[@n, @m, @j]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_252:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n, @m, @j]>>, %[[VAL_253:[0-9a-zA-Z_\.]+]]: !array.type<@n,@j x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_254:[0-9a-zA-Z_\.]+]]: !array.type<@m,@j x !felt.type<"bn128">> {function.arg_name = "c"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = poly.read_const @j : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_252]][@b] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_252]][@d] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_252]][@as] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_252]][@as$inputs] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_266:[0-9a-zA-Z_\.]+]] = %[[VAL_264]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_267:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_266]], %[[VAL_255]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_267]]) %[[VAL_266]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_268:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_269:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_270:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_269]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_272:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_268]], %[[VAL_272]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_273]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_276:[0-9a-zA-Z_\.]+]] = %[[VAL_274]], %[[VAL_277:[0-9a-zA-Z_\.]+]] = %[[VAL_265]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_276]], %[[VAL_257]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_278]]) %[[VAL_276]], %[[VAL_277]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_279:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_280:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_283:[0-9a-zA-Z_\.]+]] = %[[VAL_281]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_284:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_283]], %[[VAL_255]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_284]]) %[[VAL_283]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_285:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_286:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_279]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_288:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_253]]{{\[}}%[[VAL_286]], %[[VAL_287]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_289:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_289]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_291:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_290]], %[[VAL_291]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_292]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_279]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_293]]{{\[}}%[[VAL_294]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_295]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_285]], %[[VAL_296]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_297]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_279]], %[[VAL_298]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_299]], %[[VAL_282]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_301:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_302:[0-9a-zA-Z_\.]+]] = %[[VAL_300]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_303:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_302]], %[[VAL_255]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_303]]) %[[VAL_302]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_304:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_306:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_305]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_307:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_304]], %[[VAL_308]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_309]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_310:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_311:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_312:[0-9a-zA-Z_\.]+]] = %[[VAL_310]], %[[VAL_313:[0-9a-zA-Z_\.]+]] = %[[VAL_301]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_312]], %[[VAL_256]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_314]]) %[[VAL_312]], %[[VAL_313]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_315:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_316:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_319:[0-9a-zA-Z_\.]+]] = %[[VAL_317]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_320:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_319]], %[[VAL_255]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_320]]) %[[VAL_319]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_321:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_322:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_323:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_324:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_254]]{{\[}}%[[VAL_322]], %[[VAL_323]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_325:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_326:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_325]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_328:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_326]], %[[VAL_327]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_329:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_328]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_331:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_329]]{{\[}}%[[VAL_330]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_331]], %[[VAL_324]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_332:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_333:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_321]], %[[VAL_332]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_333]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_315]], %[[VAL_334]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_335]], %[[VAL_318]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_336:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_337:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_338:[0-9a-zA-Z_\.]+]] = %[[VAL_336]], %[[VAL_339:[0-9a-zA-Z_\.]+]] = %[[VAL_311]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_340:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_338]], %[[VAL_257]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_340]]) %[[VAL_338]], %[[VAL_339]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_341:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_342:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_343:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_344:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_345:[0-9a-zA-Z_\.]+]] = %[[VAL_343]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_346:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_345]], %[[VAL_255]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_346]]) %[[VAL_345]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_347:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_349:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_348]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_350:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_351:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_260]]{{\[}}%[[VAL_349]], %[[VAL_350]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_352:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_351]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_353:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_341]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_354:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_352]]{{\[}}%[[VAL_353]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_355:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_341]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_356:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_357:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_258]]{{\[}}%[[VAL_355]], %[[VAL_356]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_357]], %[[VAL_354]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_358:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_359:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_347]], %[[VAL_358]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_359]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_361:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_341]], %[[VAL_360]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_361]], %[[VAL_344]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_362:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_363:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_364:[0-9a-zA-Z_\.]+]] = %[[VAL_362]], %[[VAL_365:[0-9a-zA-Z_\.]+]] = %[[VAL_337]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_366:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_364]], %[[VAL_256]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_366]]) %[[VAL_364]], %[[VAL_365]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_367:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_368:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_369:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_370:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_371:[0-9a-zA-Z_\.]+]] = %[[VAL_369]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_372:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_371]], %[[VAL_255]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_372]]) %[[VAL_371]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_373:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_375:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_374]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_376:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_373]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_377:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_260]]{{\[}}%[[VAL_375]], %[[VAL_376]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_378:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_377]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_379:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_367]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_380:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_378]]{{\[}}%[[VAL_379]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_381:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_367]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_382:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_373]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_383:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_259]]{{\[}}%[[VAL_381]], %[[VAL_382]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_383]], %[[VAL_380]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_384:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_385:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_373]], %[[VAL_384]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_385]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_387:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_367]], %[[VAL_386]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_387]], %[[VAL_370]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_388:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_389:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_390:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_391:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_392:[0-9a-zA-Z_\.]+]] = %[[VAL_390]] to %[[VAL_388]] step %[[VAL_391]] {
// CHECK-NEXT:            scf.for %[[VAL_393:[0-9a-zA-Z_\.]+]] = %[[VAL_390]] to %[[VAL_389]] step %[[VAL_391]] {
// CHECK-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_260]]{{\[}}%[[VAL_392]], %[[VAL_393]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_395:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_392]], %[[VAL_393]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_395]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              function.call @A::@A::@constrain(%[[VAL_394]], %[[VAL_396]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
