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
// CHECK-NEXT:        struct.member @as : !array.type<2,@j x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:        struct.member @as$inputs : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>> {signal}
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
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_54:[0-9a-zA-Z_\.]+]] = %[[VAL_52]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_54]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_55]]) %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_57]] }  : <[@n: index]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_59]], @params = %[[VAL_58]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_60]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_62]], %[[VAL_63]]] = %[[VAL_64]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_67]], %[[VAL_71:[0-9a-zA-Z_\.]+]] = %[[VAL_53]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_70]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_72]]) %[[VAL_69]], %[[VAL_70]], %[[VAL_71]] : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_75:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_73]], %[[VAL_79:[0-9a-zA-Z_\.]+]] = %[[VAL_76]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_79]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_80]]) %[[VAL_78]], %[[VAL_79]] : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_82:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_83]], %[[VAL_84]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_87]], %[[VAL_88]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_90]]{{\[}}%[[VAL_91]]] = %[[VAL_85]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_93]], %[[VAL_94]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_95]][@a] = %[[VAL_90]] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_81]]{{\[}}%[[VAL_97]], %[[VAL_98]]] = %[[VAL_95]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_99]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_100]], %[[VAL_101]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_103]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_104]], %[[VAL_105]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_107]], %[[VAL_108]] : index
// CHECK-NEXT:              pod.write %[[VAL_102]][@count] = %[[VAL_109]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_109]], %[[VAL_110]] : index
// CHECK-NEXT:              scf.if %[[VAL_111]] {
// CHECK-NEXT:                %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:                %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@n] : <[@n: index]>, index
// CHECK-NEXT:                %[[VAL_115:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_113]]) {(%[[VAL_114]])} : (!array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:                pod.write %[[VAL_102]][@comp] = %[[VAL_115]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:                %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:                %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_116]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_48]]{{\[}}%[[VAL_117]], %[[VAL_118]]] = %[[VAL_102]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_82]], %[[VAL_119]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_81]], %[[VAL_120]] : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_74]], %[[VAL_121]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_77]]#0, %[[VAL_122]], %[[VAL_77]]#1 : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_125:[0-9a-zA-Z_\.]+]] = %[[VAL_123]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_125]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_126]]) %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_127:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_128]] }  : <[@n: index]>
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_43]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_130]], @params = %[[VAL_129]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_132]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_131]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_133]], %[[VAL_134]]] = %[[VAL_135]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_127]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_137]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_140:[0-9a-zA-Z_\.]+]] = %[[VAL_68]]#0, %[[VAL_141:[0-9a-zA-Z_\.]+]] = %[[VAL_138]], %[[VAL_142:[0-9a-zA-Z_\.]+]] = %[[VAL_124]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_141]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_143]]) %[[VAL_140]], %[[VAL_141]], %[[VAL_142]] : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_144:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_145:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_146:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_149:[0-9a-zA-Z_\.]+]] = %[[VAL_144]], %[[VAL_150:[0-9a-zA-Z_\.]+]] = %[[VAL_147]]) : (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_151:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_150]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_151]]) %[[VAL_149]], %[[VAL_150]] : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_152:[0-9a-zA-Z_\.]+]]: !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_153:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_155:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_38]]{{\[}}%[[VAL_154]], %[[VAL_155]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_157]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_160:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_158]], %[[VAL_159]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_160]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_145]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_161]]{{\[}}%[[VAL_162]]] = %[[VAL_156]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_164]], %[[VAL_165]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              pod.write %[[VAL_166]][@a] = %[[VAL_161]] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_167:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_167]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_152]]{{\[}}%[[VAL_168]], %[[VAL_169]]] = %[[VAL_166]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_173:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_171]], %[[VAL_172]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:              %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_175:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_174]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_177:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_175]], %[[VAL_176]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_178]], %[[VAL_179]] : index
// CHECK-NEXT:              pod.write %[[VAL_173]][@count] = %[[VAL_180]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_180]], %[[VAL_181]] : index
// CHECK-NEXT:              scf.if %[[VAL_182]] {
// CHECK-NEXT:                %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:                %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_183]][@n] : <[@n: index]>, index
// CHECK-NEXT:                %[[VAL_186:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_184]]) {(%[[VAL_185]])} : (!array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:                pod.write %[[VAL_173]][@comp] = %[[VAL_186]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:                %[[VAL_187:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:                %[[VAL_188:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_187]] : !felt.type<"bn128">
// CHECK-NEXT:                %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:                array.write %[[VAL_48]]{{\[}}%[[VAL_188]], %[[VAL_189]]] = %[[VAL_173]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:              }
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_153]], %[[VAL_190]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_152]], %[[VAL_191]] : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_145]], %[[VAL_192]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_148]]#0, %[[VAL_193]], %[[VAL_148]]#1 : !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_196:[0-9a-zA-Z_\.]+]] = %[[VAL_194]], %[[VAL_197:[0-9a-zA-Z_\.]+]] = %[[VAL_139]]#2) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_196]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_198]]) %[[VAL_196]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_199:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_200:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_203:[0-9a-zA-Z_\.]+]] = %[[VAL_201]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_204:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_203]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_204]]) %[[VAL_203]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_205:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_207:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_206]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_205]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_207]], %[[VAL_208]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_210]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_212:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_213:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_211]]{{\[}}%[[VAL_212]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_205]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_46]]{{\[}}%[[VAL_214]], %[[VAL_215]]] = %[[VAL_213]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_216:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_205]], %[[VAL_216]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_199]], %[[VAL_218]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_219]], %[[VAL_202]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_222:[0-9a-zA-Z_\.]+]] = %[[VAL_220]], %[[VAL_223:[0-9a-zA-Z_\.]+]] = %[[VAL_195]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_222]], %[[VAL_43]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_224]]) %[[VAL_222]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_225:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_226:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_228:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_229:[0-9a-zA-Z_\.]+]] = %[[VAL_227]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_229]], %[[VAL_41]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_230]]) %[[VAL_229]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_231:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_232]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_231]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_233]], %[[VAL_234]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:              %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_235]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_237:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_236]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_238:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_225]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_239:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_237]]{{\[}}%[[VAL_238]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_225]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_241:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_231]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_47]]{{\[}}%[[VAL_240]], %[[VAL_241]]] = %[[VAL_239]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_242:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_231]], %[[VAL_242]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_243]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_225]], %[[VAL_244]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_245]], %[[VAL_228]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_39]][@as$inputs] = %[[VAL_139]]#0 : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = array.new  : <2,@j x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_251:[0-9a-zA-Z_\.]+]] = %[[VAL_249]] to %[[VAL_247]] step %[[VAL_250]] {
// CHECK-NEXT:            scf.for %[[VAL_252:[0-9a-zA-Z_\.]+]] = %[[VAL_249]] to %[[VAL_248]] step %[[VAL_250]] {
// CHECK-NEXT:              %[[VAL_253:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_251]], %[[VAL_252]]] : <2,@j x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:              %[[VAL_254:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_253]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              array.write %[[VAL_246]]{{\[}}%[[VAL_251]], %[[VAL_252]]] = %[[VAL_254]] : <2,@j x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_39]][@as] = %[[VAL_246]] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          struct.writem %[[VAL_39]][@b] = %[[VAL_46]] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          struct.writem %[[VAL_39]][@d] = %[[VAL_47]] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_39]] : !struct.type<@B::@B<[@n, @m, @j]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_255:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n, @m, @j]>>, %[[VAL_256:[0-9a-zA-Z_\.]+]]: !array.type<@n,@j x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_257:[0-9a-zA-Z_\.]+]]: !array.type<@m,@j x !felt.type<"bn128">> {function.arg_name = "c"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_258]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_260]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_262]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_255]][@b] : <@B::@B<[@n, @m, @j]>>, !array.type<@n,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_255]][@d] : <@B::@B<[@n, @m, @j]>>, !array.type<@m,@j x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_255]][@as] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_255]][@as$inputs] : <@B::@B<[@n, @m, @j]>>, !array.type<2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_272:[0-9a-zA-Z_\.]+]] = %[[VAL_270]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_273:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_272]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_273]]) %[[VAL_272]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_274:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_275:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:            %[[VAL_276:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_275]] }  : <[@n: index]>
// CHECK-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_274]], %[[VAL_278]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_279]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_281:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_282:[0-9a-zA-Z_\.]+]] = %[[VAL_280]], %[[VAL_283:[0-9a-zA-Z_\.]+]] = %[[VAL_271]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_282]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_284]]) %[[VAL_282]], %[[VAL_283]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_285:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_286:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_289:[0-9a-zA-Z_\.]+]] = %[[VAL_287]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_290:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_289]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_290]]) %[[VAL_289]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_291:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_292:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_293:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_291]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_294:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_256]]{{\[}}%[[VAL_292]], %[[VAL_293]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_295:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_296:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_295]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_297:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_291]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_298:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_296]], %[[VAL_297]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_299:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_298]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_300:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_285]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_301:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_299]]{{\[}}%[[VAL_300]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_301]], %[[VAL_294]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_303:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_291]], %[[VAL_302]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_303]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_304:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_285]], %[[VAL_304]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_305]], %[[VAL_288]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_308:[0-9a-zA-Z_\.]+]] = %[[VAL_306]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_308]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_309]]) %[[VAL_308]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_310:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = poly.read_const @m : index
// CHECK-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_311]] }  : <[@n: index]>
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@m]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_310]], %[[VAL_314]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_315]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_316:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_317:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_318:[0-9a-zA-Z_\.]+]] = %[[VAL_316]], %[[VAL_319:[0-9a-zA-Z_\.]+]] = %[[VAL_307]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_318]], %[[VAL_261]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_320]]) %[[VAL_318]], %[[VAL_319]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_321:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_322:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_325:[0-9a-zA-Z_\.]+]] = %[[VAL_323]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_326:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_325]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_326]]) %[[VAL_325]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_327:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_328:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_329:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_327]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_330:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_257]]{{\[}}%[[VAL_328]], %[[VAL_329]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_331:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_332:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_331]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_333:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_327]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_334:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_332]], %[[VAL_333]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_335:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_334]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_336:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_321]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_337:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_335]]{{\[}}%[[VAL_336]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_337]], %[[VAL_330]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_338:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_339:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_327]], %[[VAL_338]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_339]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_340:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_341:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_321]], %[[VAL_340]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_341]], %[[VAL_324]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_342:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_343:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_344:[0-9a-zA-Z_\.]+]] = %[[VAL_342]], %[[VAL_345:[0-9a-zA-Z_\.]+]] = %[[VAL_317]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_344]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_346]]) %[[VAL_344]], %[[VAL_345]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_347:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_348:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_349:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_350:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_351:[0-9a-zA-Z_\.]+]] = %[[VAL_349]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_352:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_351]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_352]]) %[[VAL_351]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_353:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_354:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_355:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_354]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_356:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_353]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_357:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_266]]{{\[}}%[[VAL_355]], %[[VAL_356]]] : <2,@j x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_358:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_357]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_359:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_360:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_358]]{{\[}}%[[VAL_359]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_361:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_347]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_362:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_353]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_363:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_264]]{{\[}}%[[VAL_361]], %[[VAL_362]]] : <@n,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_363]], %[[VAL_360]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_364:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_365:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_353]], %[[VAL_364]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_365]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_366:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_367:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_347]], %[[VAL_366]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_367]], %[[VAL_350]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_368:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_369:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_370:[0-9a-zA-Z_\.]+]] = %[[VAL_368]], %[[VAL_371:[0-9a-zA-Z_\.]+]] = %[[VAL_343]]#1) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_372:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_370]], %[[VAL_261]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_372]]) %[[VAL_370]], %[[VAL_371]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_373:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_374:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_375:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_376:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_377:[0-9a-zA-Z_\.]+]] = %[[VAL_375]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:              %[[VAL_378:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_377]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.condition(%[[VAL_378]]) %[[VAL_377]] : !felt.type<"bn128">
// CHECK-NEXT:            } do {
// CHECK-NEXT:            ^bb0(%[[VAL_379:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:              %[[VAL_380:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_381:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_380]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_382:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_383:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_266]]{{\[}}%[[VAL_381]], %[[VAL_382]]] : <2,@j x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_384:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_383]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_385:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_373]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_386:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_384]]{{\[}}%[[VAL_385]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_387:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_373]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_388:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_379]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_389:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_265]]{{\[}}%[[VAL_387]], %[[VAL_388]]] : <@m,@j x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_389]], %[[VAL_386]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_390:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_391:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_379]], %[[VAL_390]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_391]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_392:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_393:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_373]], %[[VAL_392]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_393]], %[[VAL_376]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_394:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_395:[0-9a-zA-Z_\.]+]] = poly.read_const @j : index
// CHECK-NEXT:          %[[VAL_396:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_397:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_398:[0-9a-zA-Z_\.]+]] = %[[VAL_396]] to %[[VAL_394]] step %[[VAL_397]] {
// CHECK-NEXT:            scf.for %[[VAL_399:[0-9a-zA-Z_\.]+]] = %[[VAL_396]] to %[[VAL_395]] step %[[VAL_397]] {
// CHECK-NEXT:              %[[VAL_400:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_266]]{{\[}}%[[VAL_398]], %[[VAL_399]]] : <2,@j x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_401:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_398]], %[[VAL_399]]] : <2,@j x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:              %[[VAL_402:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_401]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              function.call @A::@A::@constrain(%[[VAL_400]], %[[VAL_402]]) : (!struct.type<@A::@A<[#map]>>, !array.type<#map x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:            }
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
