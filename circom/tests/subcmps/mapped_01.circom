// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A(n) {
	signal input a[n];
	signal input b[n];
	signal output c[n];

	var i;
	for (i = 0; i < n; i++) {
		c[i] <== a[i] * b[i];
	}
}

template B(n) {
	signal input a[n * 4];
	signal output b[n];

	component as[2];

	as[0] = A(n * 2);
	var i;
	for (i = 0; i < n * 2; i++) {
		as[0].a[i] <== a[i];
		as[0].b[i] <== a[i + n * 2];
	}

	as[1] = A(n);
	for(i = 0; i < n; i++) {
		as[1].a[i] <== as[0].c[i];
		as[1].b[i] <== as[0].c[i + n];
	}

	for (i = 0; i < n; i++) {
		b[i] <== as[1].c[i];
	}
}

component main = B(2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@B::@B<[2]>>} {
// CHECK-NEXT:    poly.template @A {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @A {
// CHECK-NEXT:        struct.member @c : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "b"}) -> !struct.type<@A::@A<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[@n]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_3]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_10:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_4]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_10]]) %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_11:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_12]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_14]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_13]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_5]]{{\[}}%[[VAL_17]]] = %[[VAL_16]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_11]], %[[VAL_18]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_19]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_2]][@c] = %[[VAL_5]] : <@A::@A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@A::@A<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[@n]>>, %[[VAL_21:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "a"}, %[[VAL_22:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "b"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_23]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_20]][@c] : <@A::@A<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_29:[0-9a-zA-Z_\.]+]] = %[[VAL_27]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_29]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_30]]) %[[VAL_29]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_31:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_21]]{{\[}}%[[VAL_32]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_22]]{{\[}}%[[VAL_34]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_33]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_37]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_38]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_31]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @B {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.expr @"n_Mul_2@469" {
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_42]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_43]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.expr @"n_Mul_4@409" {
// CHECK-NEXT:        %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:        %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_46]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_48:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_47]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_49]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @B {
// CHECK-NEXT:        struct.member @b : !array.type<@n x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @as : !array.type<2 x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:        struct.member @as$inputs : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_50:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_4@409" x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@B::@B<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@n]>>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_52]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@469" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_4@409" : index
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_55]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@469" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_60]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.addi %[[VAL_62]], %[[VAL_63]] : index
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_64]], @params = %[[VAL_61]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@"n_Mul_2@469"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_65]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@"n_Mul_2@469"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          array.write %[[VAL_58]]{{\[}}%[[VAL_67]]] = %[[VAL_68]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_72:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_70]]) : (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_53]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_73]], %[[VAL_75]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_76]]) %[[VAL_72]], %[[VAL_73]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_79]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_82]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_84]]{{\[}}%[[VAL_85]]] = %[[VAL_80]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_87]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_88]][@a] = %[[VAL_84]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_77]]{{\[}}%[[VAL_90]]] = %[[VAL_88]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_91]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_92]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_94]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_95]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_97]], %[[VAL_98]] : index
// CHECK-NEXT:            pod.write %[[VAL_93]][@count] = %[[VAL_99]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_99]], %[[VAL_100]] : index
// CHECK-NEXT:            scf.if %[[VAL_101]] {
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_103]], %[[VAL_104]]) {(%[[VAL_106]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_93]][@comp] = %[[VAL_107]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_109]]] = %[[VAL_93]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_53]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_78]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_113]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_116]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_118]]{{\[}}%[[VAL_119]]] = %[[VAL_114]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_121]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_122]][@b] = %[[VAL_118]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_77]]{{\[}}%[[VAL_124]]] = %[[VAL_122]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_126]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_129]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_131]], %[[VAL_132]] : index
// CHECK-NEXT:            pod.write %[[VAL_127]][@count] = %[[VAL_133]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_133]], %[[VAL_134]] : index
// CHECK-NEXT:            scf.if %[[VAL_135]] {
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_139]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_137]], %[[VAL_138]]) {(%[[VAL_140]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_127]][@comp] = %[[VAL_141]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_143:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_142]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_143]]] = %[[VAL_127]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_78]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_77]], %[[VAL_145]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_146]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_147]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = arith.addi %[[VAL_149]], %[[VAL_150]] : index
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_151]], @params = %[[VAL_148]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_153]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_152]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          array.write %[[VAL_58]]{{\[}}%[[VAL_154]]] = %[[VAL_155]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_158:[0-9a-zA-Z_\.]+]] = %[[VAL_71]]#0, %[[VAL_159:[0-9a-zA-Z_\.]+]] = %[[VAL_156]]) : (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_159]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_160]]) %[[VAL_158]], %[[VAL_159]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_161:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_162:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_164]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_165]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_166]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_167]]{{\[}}%[[VAL_168]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_170]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_171]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_172]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_173]]{{\[}}%[[VAL_174]]] = %[[VAL_169]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_175]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_176]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_177]][@a] = %[[VAL_173]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_178]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_161]]{{\[}}%[[VAL_179]]] = %[[VAL_177]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_181:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_180]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_181]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_183]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_184]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_186]], %[[VAL_187]] : index
// CHECK-NEXT:            pod.write %[[VAL_182]][@count] = %[[VAL_188]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_188]], %[[VAL_189]] : index
// CHECK-NEXT:            scf.if %[[VAL_190]] {
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_185]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_191]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_192]], %[[VAL_193]]) {(%[[VAL_195]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_182]][@comp] = %[[VAL_196]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_198:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_197]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_198]]] = %[[VAL_182]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_199]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_200]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_201]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_202]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_162]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_203]]{{\[}}%[[VAL_205]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_207]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_208]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_209]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_210]]{{\[}}%[[VAL_211]]] = %[[VAL_206]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_213]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_214]][@b] = %[[VAL_210]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_215]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_161]]{{\[}}%[[VAL_216]]] = %[[VAL_214]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_218]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_220]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_221]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_225:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_223]], %[[VAL_224]] : index
// CHECK-NEXT:            pod.write %[[VAL_219]][@count] = %[[VAL_225]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_226:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_227:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_225]], %[[VAL_226]] : index
// CHECK-NEXT:            scf.if %[[VAL_227]] {
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_222]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_222]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_228]][@n] : <[@n: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_232:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_231]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_233:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_229]], %[[VAL_230]]) {(%[[VAL_232]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_219]][@comp] = %[[VAL_233]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_235]]] = %[[VAL_219]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_236:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_162]], %[[VAL_236]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_161]], %[[VAL_237]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_240:[0-9a-zA-Z_\.]+]] = %[[VAL_238]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_240]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_241]]) %[[VAL_240]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_242:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_243]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_244]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_245]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_246]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_242]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_249:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_247]]{{\[}}%[[VAL_248]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_250:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_242]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_57]]{{\[}}%[[VAL_250]]] = %[[VAL_249]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_252:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_242]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_252]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_51]][@as$inputs] = %[[VAL_157]]#0 : <@B::@B<[@n]>>, !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_255:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_257:[0-9a-zA-Z_\.]+]] = %[[VAL_255]] to %[[VAL_254]] step %[[VAL_256]] {
// CHECK-NEXT:            %[[VAL_258:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_257]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_259:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_258]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_253]]{{\[}}%[[VAL_257]]] = %[[VAL_259]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_51]][@as] = %[[VAL_253]] : <@B::@B<[@n]>>, !array.type<2 x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          struct.writem %[[VAL_51]][@b] = %[[VAL_57]] : <@B::@B<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_51]] : !struct.type<@B::@B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_260:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n]>>, %[[VAL_261:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_4@409" x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_262]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@469" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_4@409" : index
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_265]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_260]][@b] : <@B::@B<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_260]][@as] : <@B::@B<[@n]>>, !array.type<2 x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_260]][@as$inputs] : <@B::@B<[@n]>>, !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@469" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_270]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@"n_Mul_2@469"]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_273:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_275:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_276:[0-9a-zA-Z_\.]+]] = %[[VAL_274]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_277:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_263]], %[[VAL_277]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_276]], %[[VAL_278]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_279]]) %[[VAL_276]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_280:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_280]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_281]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_283:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_283]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_284]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_285]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_280]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_286]]{{\[}}%[[VAL_287]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_288]], %[[VAL_282]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_263]], %[[VAL_289]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_280]], %[[VAL_290]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_291]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_261]]{{\[}}%[[VAL_292]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_294]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_295]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_296]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_280]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_299:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_297]]{{\[}}%[[VAL_298]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_299]], %[[VAL_293]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_300:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_301:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_280]], %[[VAL_300]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_301]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_302:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_303:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_302]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_304:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_303]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_305:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_306:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_307:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_308:[0-9a-zA-Z_\.]+]] = %[[VAL_306]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_308]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_309]]) %[[VAL_308]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_310:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_311]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_268]]{{\[}}%[[VAL_312]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_313]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_314]]{{\[}}%[[VAL_315]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_317]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_318]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_319]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_321:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_320]]{{\[}}%[[VAL_321]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_322]], %[[VAL_316]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_323]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_268]]{{\[}}%[[VAL_324]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_325]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_310]], %[[VAL_263]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_327]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_326]]{{\[}}%[[VAL_328]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_330]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_331]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_332]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_334:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_310]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_335:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_333]]{{\[}}%[[VAL_334]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_335]], %[[VAL_329]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_336:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_337:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_310]], %[[VAL_336]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_337]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_338:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_339:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_340:[0-9a-zA-Z_\.]+]] = %[[VAL_338]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_341:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_340]], %[[VAL_263]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_341]]) %[[VAL_340]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_342:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_343:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_344:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_343]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_345:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_268]]{{\[}}%[[VAL_344]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_345]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_347:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_342]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_348:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_346]]{{\[}}%[[VAL_347]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_349:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_342]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_350:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_267]]{{\[}}%[[VAL_349]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_350]], %[[VAL_348]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_351:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_352:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_342]], %[[VAL_351]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_352]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_353:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_354:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_355:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_356:[0-9a-zA-Z_\.]+]] = %[[VAL_354]] to %[[VAL_353]] step %[[VAL_355]] {
// CHECK-NEXT:            %[[VAL_357:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_268]]{{\[}}%[[VAL_356]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_358:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_269]]{{\[}}%[[VAL_356]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_359:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_358]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_360:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_358]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @A::@A::@constrain(%[[VAL_357]], %[[VAL_359]], %[[VAL_360]]) : (!struct.type<@A::@A<[#map]>>, !array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
