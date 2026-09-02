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
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_48_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_48]], %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_68]], %[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_53]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_71]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_73]]) %[[VAL_48_IN]], %[[VAL_70]], %[[VAL_71]], %[[VAL_72]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_48_LCV:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_75:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_76:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_48_IN_2:[0-9a-zA-Z_\.]+]] = %[[VAL_48_LCV]], %[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_74]], %[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_77]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_81:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_80]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_81]]) %[[VAL_48_IN_2]], %[[VAL_79]], %[[VAL_80]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_48_LCV_2:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_83:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_84]], %[[VAL_85]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_88]], %[[VAL_89]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_75]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_91]]{{\[}}%[[VAL_92]]] = %[[VAL_86]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_94]], %[[VAL_95]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_96]][@a] = %[[VAL_91]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_82]]{{\[}}%[[VAL_98]], %[[VAL_99]]] = %[[VAL_96]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48_LCV_2]]{{\[}}%[[VAL_101]], %[[VAL_102]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_104]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_105]], %[[VAL_106]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_108]], %[[VAL_109]] : index
// CHECK-NEXT:              pod.write %[[VAL_103]][@count] = %[[VAL_110]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_110]], %[[VAL_111]] : index
// CHECK-NEXT:              scf.if %[[VAL_112]] {
// CHECK-NEXT:                %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_117:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_114]]) {(%[[VAL_116]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                pod.write %[[VAL_103]][@comp] = %[[VAL_117]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_118]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_48_LCV_2]]{{\[}}%[[VAL_119]], %[[VAL_120]]] = %[[VAL_103]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_48_LCV_2]], %[[VAL_82]], %[[VAL_122]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_75]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_78]]#0, %[[VAL_78]]#1, %[[VAL_124]], %[[VAL_78]]#2 : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_127:[0-9a-zA-Z_\.]+]] = %[[VAL_125]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_127]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_128]]) %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_129:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_130]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_131]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_133]], @params = %[[VAL_132]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_135]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_134]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            array.write %[[VAL_69]]#0{{\[}}%[[VAL_136]], %[[VAL_137]]] = %[[VAL_138]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_129]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_140]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]]:4 = scf.while (%[[VAL_48_IN_3:[0-9a-zA-Z_\.]+]] = %[[VAL_69]]#0, %[[VAL_143:[0-9a-zA-Z_\.]+]] = %[[VAL_69]]#1, %[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_141]], %[[VAL_145:[0-9a-zA-Z_\.]+]] = %[[VAL_126]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_144]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_146]]) %[[VAL_48_IN_3]], %[[VAL_143]], %[[VAL_144]], %[[VAL_145]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_48_LCV_3:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_147:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_148:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_149:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_48_IN_4:[0-9a-zA-Z_\.]+]] = %[[VAL_48_LCV_3]], %[[VAL_152:[0-9a-zA-Z_\.]+]] = %[[VAL_147]], %[[VAL_153:[0-9a-zA-Z_\.]+]] = %[[VAL_150]]) : (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_153]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_154]]) %[[VAL_48_IN_4]], %[[VAL_152]], %[[VAL_153]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_48_LCV_4:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, %[[VAL_155:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, %[[VAL_156:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_157]], %[[VAL_158]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_155]]{{\[}}%[[VAL_161]], %[[VAL_162]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_164]]{{\[}}%[[VAL_165]]] = %[[VAL_159]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_166]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_155]]{{\[}}%[[VAL_167]], %[[VAL_168]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_169]][@a] = %[[VAL_164]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_155]]{{\[}}%[[VAL_171]], %[[VAL_172]]] = %[[VAL_169]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_173]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48_LCV_4]]{{\[}}%[[VAL_174]], %[[VAL_175]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_177]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_155]]{{\[}}%[[VAL_178]], %[[VAL_179]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_181]], %[[VAL_182]] : index
// CHECK-NEXT:              pod.write %[[VAL_176]][@count] = %[[VAL_183]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_183]], %[[VAL_184]] : index
// CHECK-NEXT:              scf.if %[[VAL_185]] {
// CHECK-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_190:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_187]]) {(%[[VAL_189]])} : (!array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:                pod.write %[[VAL_176]][@comp] = %[[VAL_190]] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_191]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_48_LCV_4]]{{\[}}%[[VAL_192]], %[[VAL_193]]] = %[[VAL_176]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_156]], %[[VAL_194]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_48_LCV_4]], %[[VAL_155]], %[[VAL_195]] : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_148]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_151]]#0, %[[VAL_151]]#1, %[[VAL_197]], %[[VAL_151]]#2 : !array.type<2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_200:[0-9a-zA-Z_\.]+]] = %[[VAL_198]], %[[VAL_201:[0-9a-zA-Z_\.]+]] = %[[VAL_142]]#3) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_200]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_202]]) %[[VAL_200]], %[[VAL_201]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_203:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_204:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_207:[0-9a-zA-Z_\.]+]] = %[[VAL_205]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_207]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_208]]) %[[VAL_207]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_209:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_210]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_209]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]#0{{\[}}%[[VAL_211]], %[[VAL_212]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_214:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_213]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_215:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_214]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_216:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_217:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_215]]{{\[}}%[[VAL_216]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_218:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_203]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_219:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_209]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_46]]{{\[}}%[[VAL_218]], %[[VAL_219]]] = %[[VAL_217]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_209]], %[[VAL_220]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_221]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_203]], %[[VAL_222]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_223]], %[[VAL_206]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_226:[0-9a-zA-Z_\.]+]] = %[[VAL_224]], %[[VAL_227:[0-9a-zA-Z_\.]+]] = %[[VAL_199]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_226]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_228]]) %[[VAL_226]], %[[VAL_227]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_229:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_230:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_233:[0-9a-zA-Z_\.]+]] = %[[VAL_231]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_233]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_234]]) %[[VAL_233]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_235:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_236]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]#0{{\[}}%[[VAL_237]], %[[VAL_238]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_239]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_240]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_241]]{{\[}}%[[VAL_242]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_245:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_235]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_47]]{{\[}}%[[VAL_244]], %[[VAL_245]]] = %[[VAL_243]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_246:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_235]], %[[VAL_246]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_247]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_229]], %[[VAL_248]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_249]], %[[VAL_232]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_39]][@as$inputs] = %[[VAL_142]]#1 : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_255:[0-9a-zA-Z_\.]+]] = %[[VAL_253]] to %[[VAL_251]] step %[[VAL_254]] {
// CHECK-NEXT:            scf.for %[[VAL_256:[0-9a-zA-Z_\.]+]] = %[[VAL_253]] to %[[VAL_252]] step %[[VAL_254]] {
// CHECK-NEXT:              %[[VAL_257:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]#0{{\[}}%[[VAL_255]], %[[VAL_256]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:              %[[VAL_258:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_257]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#[[$ATTR_0]]]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              array.write %[[VAL_250]]{{\[}}%[[VAL_255]], %[[VAL_256]]] = %[[VAL_258]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_39]][@as] = %[[VAL_250]] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          struct.writem %[[VAL_39]][@b] = %[[VAL_46]] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_39]][@d] = %[[VAL_47]] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_39]] : !struct.type<@B::@B<[@n, @m, @j]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_259:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n, @m, @j]>>, %[[VAL_260:[0-9a-zA-Z_\.]+]]: !array.type<@n,@j x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_261:[0-9a-zA-Z_\.]+]]: !array.type<@m,@j x !felt.type<"bn128">> {function.arg_name = "c"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_262]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_264]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_266]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_259]][@b] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_259]][@d] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_259]][@as] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_259]][@as$inputs] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_276:[0-9a-zA-Z_\.]+]] = %[[VAL_274]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_276]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_277]]) %[[VAL_276]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_278:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_279]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_280]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_278]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_284]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_285:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_286:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_287:[0-9a-zA-Z_\.]+]] = %[[VAL_285]], %[[VAL_288:[0-9a-zA-Z_\.]+]] = %[[VAL_275]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_287]], %[[VAL_267]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_289]]) %[[VAL_287]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_290:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_291:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_294:[0-9a-zA-Z_\.]+]] = %[[VAL_292]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_294]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_295]]) %[[VAL_294]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_296:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_296]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_299:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_260]]{{\[}}%[[VAL_297]], %[[VAL_298]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_301:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_300]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_296]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_271]]{{\[}}%[[VAL_301]], %[[VAL_302]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_304:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_303]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_305:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_290]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_306:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_304]]{{\[}}%[[VAL_305]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_306]], %[[VAL_299]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_307:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_308:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_296]], %[[VAL_307]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_308]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_310:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_290]], %[[VAL_309]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_310]], %[[VAL_293]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_311:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_312:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_313:[0-9a-zA-Z_\.]+]] = %[[VAL_311]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_313]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_314]]) %[[VAL_313]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_315:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_316]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_317]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_321:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_315]], %[[VAL_320]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_322:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_323:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_324:[0-9a-zA-Z_\.]+]] = %[[VAL_322]], %[[VAL_325:[0-9a-zA-Z_\.]+]] = %[[VAL_312]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_324]], %[[VAL_265]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_326]]) %[[VAL_324]], %[[VAL_325]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_327:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_328:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_331:[0-9a-zA-Z_\.]+]] = %[[VAL_329]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_332:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_331]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_332]]) %[[VAL_331]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_333:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_334:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_327]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_335:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_333]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_336:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_334]], %[[VAL_335]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_337:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_338:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_337]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_339:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_333]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_340:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_271]]{{\[}}%[[VAL_338]], %[[VAL_339]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_341:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_340]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_342:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_327]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_343:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_341]]{{\[}}%[[VAL_342]]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_343]], %[[VAL_336]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_344:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_345:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_333]], %[[VAL_344]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_345]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_347:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_327]], %[[VAL_346]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_347]], %[[VAL_330]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_350:[0-9a-zA-Z_\.]+]] = %[[VAL_348]], %[[VAL_351:[0-9a-zA-Z_\.]+]] = %[[VAL_323]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_352:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_350]], %[[VAL_267]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_352]]) %[[VAL_350]], %[[VAL_351]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_353:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_354:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_356:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_357:[0-9a-zA-Z_\.]+]] = %[[VAL_355]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_358:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_357]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_358]]) %[[VAL_357]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_359:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_360:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_361:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_360]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_362:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_359]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_363:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_270]]{{\[}}%[[VAL_361]], %[[VAL_362]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_364:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_363]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_365:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_353]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_366:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_364]]{{\[}}%[[VAL_365]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_367:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_353]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_368:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_359]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_369:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_268]]{{\[}}%[[VAL_367]], %[[VAL_368]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_369]], %[[VAL_366]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_370:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_371:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_359]], %[[VAL_370]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_371]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_372:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_373:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_353]], %[[VAL_372]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_373]], %[[VAL_356]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_374:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_375:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_376:[0-9a-zA-Z_\.]+]] = %[[VAL_374]], %[[VAL_377:[0-9a-zA-Z_\.]+]] = %[[VAL_349]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_378:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_376]], %[[VAL_265]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_378]]) %[[VAL_376]], %[[VAL_377]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_379:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_380:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_381:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_382:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_383:[0-9a-zA-Z_\.]+]] = %[[VAL_381]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_384:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_383]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_384]]) %[[VAL_383]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_385:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_386:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_387:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_386]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_388:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_385]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_389:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_270]]{{\[}}%[[VAL_387]], %[[VAL_388]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_390:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_389]][@c] : <@A::@A<[#[[$ATTR_0]]]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_391:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_392:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_390]]{{\[}}%[[VAL_391]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_393:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_394:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_385]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_395:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_393]], %[[VAL_394]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_395]], %[[VAL_392]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_396:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_397:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_385]], %[[VAL_396]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_397]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_398:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_399:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_379]], %[[VAL_398]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_399]], %[[VAL_382]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_400:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_401:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_402:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_403:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_404:[0-9a-zA-Z_\.]+]] = %[[VAL_402]] to %[[VAL_400]] step %[[VAL_403]] {
// CHECK-NEXT:            scf.for %[[VAL_405:[0-9a-zA-Z_\.]+]] = %[[VAL_402]] to %[[VAL_401]] step %[[VAL_403]] {
// CHECK-NEXT:              %[[VAL_406:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_270]]{{\[}}%[[VAL_404]], %[[VAL_405]]] : <2,@j x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>, !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// CHECK-NEXT:              %[[VAL_407:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_271]]{{\[}}%[[VAL_404]], %[[VAL_405]]] : <2,@j x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_408:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_407]][@a] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// CHECK-NEXT:              function.call @A::@A::@constrain(%[[VAL_406]], %[[VAL_408]]) : (!struct.type<@A::@A<[#[[$ATTR_0]]]>>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
