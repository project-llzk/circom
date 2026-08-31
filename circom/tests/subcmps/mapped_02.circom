// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @c : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_2]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_9:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_3]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_9]]) %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_11]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_12]], %[[VAL_13]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_4]]{{\[}}%[[VAL_15]]] = %[[VAL_14]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_17]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@c] = %[[VAL_4]] : <@A::@A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_18:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_20]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_18]][@c] : <@A::@A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_24]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_26]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_27]]) %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_19]]{{\[}}%[[VAL_29]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_30]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_33]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_34]], %[[VAL_32]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @m : index
// CHECK-NEXT:      poly.param @j : index
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @b : !array.type<@n,@j x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @d : !array.type<@m,@j x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @as : !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:        struct.member @as$inputs : !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !array.type<@n,@j x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<@m,@j x !felt.type<"bn128">> {function.arg_name = "c"}) -> !struct.type<@B::@B<[@n, @m, @j]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n, @m, @j]>>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_40]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_42]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_44]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_54]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_55]]) %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_57]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_58]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_60]], @params = %[[VAL_59]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_61]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_63]], %[[VAL_64]]] = %[[VAL_65]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_48]], %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_68]], %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_53]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_72]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_74]]) %[[VAL_70]], %[[VAL_71]], %[[VAL_72]], %[[VAL_73]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_75:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_76:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_75]], %[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_76]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_83]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_84]]) %[[VAL_81]], %[[VAL_82]], %[[VAL_83]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_88]], %[[VAL_89]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_92]], %[[VAL_93]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_77]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_95]]{{\[}}%[[VAL_96]]] = %[[VAL_90]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_98]], %[[VAL_99]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_100]][@a] = %[[VAL_95]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_86]]{{\[}}%[[VAL_102]], %[[VAL_103]]] = %[[VAL_100]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_85]]{{\[}}%[[VAL_105]], %[[VAL_106]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_109]], %[[VAL_110]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_112]], %[[VAL_113]] : index
// CHECK-NEXT:              pod.write %[[VAL_107]][@count] = %[[VAL_114]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_114]], %[[VAL_115]] : index
// CHECK-NEXT:              scf.if %[[VAL_116]] {
// CHECK-NEXT:                %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_121:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_118]]) {(%[[VAL_120]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                pod.write %[[VAL_107]][@comp] = %[[VAL_121]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_85]]{{\[}}%[[VAL_123]], %[[VAL_124]]] = %[[VAL_107]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_85]], %[[VAL_86]], %[[VAL_126]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_77]], %[[VAL_127]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_80]]#0, %[[VAL_80]]#1, %[[VAL_128]], %[[VAL_80]]#2 : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_131:[0-9a-zA-Z_\.]+]] = %[[VAL_129]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_131]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_132]]) %[[VAL_131]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_133:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_134]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_135]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_137]], @params = %[[VAL_136]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_139]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_133]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_138]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            array.write %[[VAL_69]]#0{{\[}}%[[VAL_140]], %[[VAL_141]]] = %[[VAL_142]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_133]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_144]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_147:[0-9a-zA-Z_\.]+]] = %[[VAL_69]]#0, %[[VAL_148:[0-9a-zA-Z_\.]+]] = %[[VAL_69]]#1, %[[VAL_149:[0-9a-zA-Z_\.]+]] = %[[VAL_145]], %[[VAL_150:[0-9a-zA-Z_\.]+]] = %[[VAL_130]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_149]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_151]]) %[[VAL_147]], %[[VAL_148]], %[[VAL_149]], %[[VAL_150]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_152:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_153:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_154:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_155:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_158:[0-9a-zA-Z_\.]+]] = %[[VAL_152]], %[[VAL_159:[0-9a-zA-Z_\.]+]] = %[[VAL_153]], %[[VAL_160:[0-9a-zA-Z_\.]+]] = %[[VAL_156]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_160]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_161]]) %[[VAL_158]], %[[VAL_159]], %[[VAL_160]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_162:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_163:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_164:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_165]], %[[VAL_166]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_168]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_163]]{{\[}}%[[VAL_169]], %[[VAL_170]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_154]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_172]]{{\[}}%[[VAL_173]]] = %[[VAL_167]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_174]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_163]]{{\[}}%[[VAL_175]], %[[VAL_176]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_177]][@a] = %[[VAL_172]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_178]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_163]]{{\[}}%[[VAL_179]], %[[VAL_180]]] = %[[VAL_177]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_183:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_184:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_182]], %[[VAL_183]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_185]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_187:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_163]]{{\[}}%[[VAL_186]], %[[VAL_187]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_189]], %[[VAL_190]] : index
// CHECK-NEXT:              pod.write %[[VAL_184]][@count] = %[[VAL_191]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_191]], %[[VAL_192]] : index
// CHECK-NEXT:              scf.if %[[VAL_193]] {
// CHECK-NEXT:                %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_188]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_198:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_195]]) {(%[[VAL_197]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                pod.write %[[VAL_184]][@comp] = %[[VAL_198]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_200:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_201:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_164]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_162]]{{\[}}%[[VAL_200]], %[[VAL_201]]] = %[[VAL_184]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_203:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_164]], %[[VAL_202]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_162]], %[[VAL_163]], %[[VAL_203]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_154]], %[[VAL_204]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_157]]#0, %[[VAL_157]]#1, %[[VAL_205]], %[[VAL_157]]#2 : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_208:[0-9a-zA-Z_\.]+]] = %[[VAL_206]], %[[VAL_209:[0-9a-zA-Z_\.]+]] = %[[VAL_146]]#3) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_208]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_210]]) %[[VAL_208]], %[[VAL_209]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_211:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_212:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_215:[0-9a-zA-Z_\.]+]] = %[[VAL_213]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_216:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_215]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_216]]) %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_217:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_218]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_220:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_221:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_146]]#0{{\[}}%[[VAL_219]], %[[VAL_220]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_223:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_222]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_224:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_223]]{{\[}}%[[VAL_224]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_211]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_46]]{{\[}}%[[VAL_226]], %[[VAL_227]]] = %[[VAL_225]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_217]], %[[VAL_228]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_211]], %[[VAL_230]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_231]], %[[VAL_214]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_234:[0-9a-zA-Z_\.]+]] = %[[VAL_232]], %[[VAL_235:[0-9a-zA-Z_\.]+]] = %[[VAL_207]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_236:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_234]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_236]]) %[[VAL_234]], %[[VAL_235]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_237:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_238:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_239:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_240:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_241:[0-9a-zA-Z_\.]+]] = %[[VAL_239]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_241]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_242]]) %[[VAL_241]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_243:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_244]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_146]]#0{{\[}}%[[VAL_245]], %[[VAL_246]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_249:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_248]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_251:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_249]]{{\[}}%[[VAL_250]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_252:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_237]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_47]]{{\[}}%[[VAL_252]], %[[VAL_253]]] = %[[VAL_251]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_255:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_243]], %[[VAL_254]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_255]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_256:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_257:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_237]], %[[VAL_256]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_257]], %[[VAL_240]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_39]][@as$inputs] = %[[VAL_146]]#1 : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_263:[0-9a-zA-Z_\.]+]] = %[[VAL_261]] to %[[VAL_259]] step %[[VAL_262]] {
// CHECK-NEXT:            scf.for %[[VAL_264:[0-9a-zA-Z_\.]+]] = %[[VAL_261]] to %[[VAL_260]] step %[[VAL_262]] {
// CHECK-NEXT:              %[[VAL_265:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_146]]#0{{\[}}%[[VAL_263]], %[[VAL_264]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_266:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_265]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              array.write %[[VAL_258]]{{\[}}%[[VAL_263]], %[[VAL_264]]] = %[[VAL_266]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_39]][@as] = %[[VAL_258]] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          struct.writem %[[VAL_39]][@b] = %[[VAL_46]] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_39]][@d] = %[[VAL_47]] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_39]] : !struct.type<@B::@B<[@n, @m, @j]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_267:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n, @m, @j]>>, %[[VAL_268:[0-9a-zA-Z_\.]+]]: !array.type<@n,@j x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_269:[0-9a-zA-Z_\.]+]]: !array.type<@m,@j x !felt.type<"bn128">> {function.arg_name = "c"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_270]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_272]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_274]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_276:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_267]][@b] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_277:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_267]][@d] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_278:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_267]][@as] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_279:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_267]][@as$inputs] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_282:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_283:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_284:[0-9a-zA-Z_\.]+]] = %[[VAL_282]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_284]], %[[VAL_271]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_285]]) %[[VAL_284]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_286:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_287]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_288]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_286]], %[[VAL_291]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_292]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_293:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_294:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_295:[0-9a-zA-Z_\.]+]] = %[[VAL_293]], %[[VAL_296:[0-9a-zA-Z_\.]+]] = %[[VAL_283]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_295]], %[[VAL_275]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_297]]) %[[VAL_295]], %[[VAL_296]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_298:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_299:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_302:[0-9a-zA-Z_\.]+]] = %[[VAL_300]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_302]], %[[VAL_271]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_303]]) %[[VAL_302]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_304:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_306:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_304]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_307:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_268]]{{\[}}%[[VAL_305]], %[[VAL_306]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_309:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_308]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_310:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_304]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_311:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_279]]{{\[}}%[[VAL_309]], %[[VAL_310]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_311]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_313:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_298]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_314:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_312]]{{\[}}%[[VAL_313]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_314]], %[[VAL_307]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_315:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_316:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_304]], %[[VAL_315]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_316]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_298]], %[[VAL_317]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_318]], %[[VAL_301]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_319:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_320:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_321:[0-9a-zA-Z_\.]+]] = %[[VAL_319]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_321]], %[[VAL_271]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_322]]) %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_323:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_324]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_325]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_323]], %[[VAL_328]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_329]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_331:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_332:[0-9a-zA-Z_\.]+]] = %[[VAL_330]], %[[VAL_333:[0-9a-zA-Z_\.]+]] = %[[VAL_320]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_332]], %[[VAL_273]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_334]]) %[[VAL_332]], %[[VAL_333]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_335:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_336:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_337:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_338:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_339:[0-9a-zA-Z_\.]+]] = %[[VAL_337]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_340:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_339]], %[[VAL_271]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_340]]) %[[VAL_339]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_341:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_342:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_335]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_343:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_341]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_344:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_342]], %[[VAL_343]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_345:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_346:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_345]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_347:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_341]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_348:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_279]]{{\[}}%[[VAL_346]], %[[VAL_347]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_349:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_348]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_350:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_335]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_351:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_349]]{{\[}}%[[VAL_350]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_351]], %[[VAL_344]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_352:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_353:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_341]], %[[VAL_352]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_353]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_354:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_335]], %[[VAL_354]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_355]], %[[VAL_338]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_356:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_357:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_358:[0-9a-zA-Z_\.]+]] = %[[VAL_356]], %[[VAL_359:[0-9a-zA-Z_\.]+]] = %[[VAL_331]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_358]], %[[VAL_275]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_360]]) %[[VAL_358]], %[[VAL_359]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_361:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_362:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_363:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_364:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_365:[0-9a-zA-Z_\.]+]] = %[[VAL_363]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_366:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_365]], %[[VAL_271]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_366]]) %[[VAL_365]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_367:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_368:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_369:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_368]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_370:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_367]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_371:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_369]], %[[VAL_370]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_372:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_371]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_373:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_361]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_374:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_372]]{{\[}}%[[VAL_373]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_375:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_361]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_376:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_367]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_377:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_276]]{{\[}}%[[VAL_375]], %[[VAL_376]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_377]], %[[VAL_374]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_378:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_379:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_367]], %[[VAL_378]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_380:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_361]], %[[VAL_380]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_381]], %[[VAL_364]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_382:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_383:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_384:[0-9a-zA-Z_\.]+]] = %[[VAL_382]], %[[VAL_385:[0-9a-zA-Z_\.]+]] = %[[VAL_357]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_386:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_384]], %[[VAL_273]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_386]]) %[[VAL_384]], %[[VAL_385]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_387:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_388:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_389:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_390:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_391:[0-9a-zA-Z_\.]+]] = %[[VAL_389]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_392:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_391]], %[[VAL_271]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_392]]) %[[VAL_391]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_393:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_395:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_394]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_397:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_395]], %[[VAL_396]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_398:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_397]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_399:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_387]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_400:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_398]]{{\[}}%[[VAL_399]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_401:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_387]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_402:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_393]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_403:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_277]]{{\[}}%[[VAL_401]], %[[VAL_402]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_403]], %[[VAL_400]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_404:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_405:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_393]], %[[VAL_404]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_405]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_406:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_407:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_387]], %[[VAL_406]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_407]], %[[VAL_390]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_408:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_409:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_410:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_411:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_412:[0-9a-zA-Z_\.]+]] = %[[VAL_410]] to %[[VAL_408]] step %[[VAL_411]] {
// CHECK-NEXT:            scf.for %[[VAL_413:[0-9a-zA-Z_\.]+]] = %[[VAL_410]] to %[[VAL_409]] step %[[VAL_411]] {
// CHECK-NEXT:              %[[VAL_414:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_278]]{{\[}}%[[VAL_412]], %[[VAL_413]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_415:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_279]]{{\[}}%[[VAL_412]], %[[VAL_413]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_416:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_415]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              function.call @A::@A::@constrain(%[[VAL_414]], %[[VAL_416]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
