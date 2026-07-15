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
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>
// CHECK-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@469" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_60]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_61]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_54]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.addi %[[VAL_63]], %[[VAL_64]] : index
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_65]], @params = %[[VAL_62]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@"n_Mul_2@469"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_67]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_66]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@"n_Mul_2@469"]>>, @params: !pod.type<[@n: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          array.write %[[VAL_58]]{{\[}}%[[VAL_68]]] = %[[VAL_69]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_59]], %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_71]]) : (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_53]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_74]], %[[VAL_76]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_77]]) %[[VAL_73]], %[[VAL_74]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_78:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_80]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_82]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_83]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_85]]{{\[}}%[[VAL_86]]] = %[[VAL_81]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_88]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_89]][@a] = %[[VAL_85]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_78]]{{\[}}%[[VAL_91]]] = %[[VAL_89]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_93]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_95]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_96]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_98]], %[[VAL_99]] : index
// CHECK-NEXT:            pod.write %[[VAL_94]][@count] = %[[VAL_100]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_100]], %[[VAL_101]] : index
// CHECK-NEXT:            scf.if %[[VAL_102]] {
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_97]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@n] : <[@n: index]>, index
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_104]], %[[VAL_105]]) {(%[[VAL_106]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_94]][@comp] = %[[VAL_107]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_109]]] = %[[VAL_94]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_53]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_79]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_50]]{{\[}}%[[VAL_113]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_115]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_116]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_118]]{{\[}}%[[VAL_119]]] = %[[VAL_114]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_121]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_122]][@b] = %[[VAL_118]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_123]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_78]]{{\[}}%[[VAL_124]]] = %[[VAL_122]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_126]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_128]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_78]]{{\[}}%[[VAL_129]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_131]], %[[VAL_132]] : index
// CHECK-NEXT:            pod.write %[[VAL_127]][@count] = %[[VAL_133]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_133]], %[[VAL_134]] : index
// CHECK-NEXT:            scf.if %[[VAL_135]] {
// CHECK-NEXT:              %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:              %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@n] : <[@n: index]>, index
// CHECK-NEXT:              %[[VAL_140:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_137]], %[[VAL_138]]) {(%[[VAL_139]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_127]][@comp] = %[[VAL_140]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:              %[[VAL_142:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_141]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_142]]] = %[[VAL_127]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_79]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_78]], %[[VAL_144]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_145]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_53]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.addi %[[VAL_147]], %[[VAL_148]] : index
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_149]], @params = %[[VAL_146]] }  : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_151]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_150]] : (!pod.type<[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>) -> !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          array.write %[[VAL_58]]{{\[}}%[[VAL_152]]] = %[[VAL_153]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_72]]#0, %[[VAL_157:[0-9a-zA-Z_\.]+]] = %[[VAL_154]]) : (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_157]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_158]]) %[[VAL_156]], %[[VAL_157]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_159:[0-9a-zA-Z_\.]+]]: !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, %[[VAL_160:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_161]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_162]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_165:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_164]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_166:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_167:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_165]]{{\[}}%[[VAL_166]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_168:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_169:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_168]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_170:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_169]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_172:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_171]]{{\[}}%[[VAL_172]]] = %[[VAL_167]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_173]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_174]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_175]][@a] = %[[VAL_171]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_176]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_159]]{{\[}}%[[VAL_177]]] = %[[VAL_175]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_178]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_179]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_181:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_182:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_181]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_182]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_184]], %[[VAL_185]] : index
// CHECK-NEXT:            pod.write %[[VAL_180]][@count] = %[[VAL_186]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_186]], %[[VAL_187]] : index
// CHECK-NEXT:            scf.if %[[VAL_188]] {
// CHECK-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_183]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_183]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@n] : <[@n: index]>, index
// CHECK-NEXT:              %[[VAL_193:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_190]], %[[VAL_191]]) {(%[[VAL_192]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_180]][@comp] = %[[VAL_193]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_194]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_195]]] = %[[VAL_180]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_197:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_196]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_198:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_197]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_199:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_200:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_199]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_160]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_202:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_201]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_203:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_200]]{{\[}}%[[VAL_202]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_205]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_160]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_207]]{{\[}}%[[VAL_208]]] = %[[VAL_203]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_210:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_209]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_211:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_210]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_211]][@b] = %[[VAL_207]] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_213:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_212]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_159]]{{\[}}%[[VAL_213]]] = %[[VAL_211]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_215]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_217]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_159]]{{\[}}%[[VAL_218]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@count] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_221:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_222:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_220]], %[[VAL_221]] : index
// CHECK-NEXT:            pod.write %[[VAL_216]][@count] = %[[VAL_222]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_223:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_224:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_222]], %[[VAL_223]] : index
// CHECK-NEXT:            scf.if %[[VAL_224]] {
// CHECK-NEXT:              %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@params] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:              %[[VAL_226:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_227:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_219]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@n] : <[@n: index]>, index
// CHECK-NEXT:              %[[VAL_229:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_226]], %[[VAL_227]]) {(%[[VAL_228]])} : (!array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              pod.write %[[VAL_216]][@comp] = %[[VAL_229]] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:              %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:              %[[VAL_231:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_230]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_58]]{{\[}}%[[VAL_231]]] = %[[VAL_216]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_232:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_233:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_160]], %[[VAL_232]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_159]], %[[VAL_233]] : !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_236:[0-9a-zA-Z_\.]+]] = %[[VAL_234]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_237:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_236]], %[[VAL_53]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_237]]) %[[VAL_236]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_238:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_239:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_240:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_239]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_241:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_240]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_242:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_241]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_243:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_242]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_244:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_238]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_245:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_243]]{{\[}}%[[VAL_244]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_238]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_57]]{{\[}}%[[VAL_246]]] = %[[VAL_245]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_247:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_248:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_238]], %[[VAL_247]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_248]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_51]][@as$inputs] = %[[VAL_155]]#0 : <@B::@B<[@n]>>, !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = array.new  : <2 x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_253:[0-9a-zA-Z_\.]+]] = %[[VAL_251]] to %[[VAL_250]] step %[[VAL_252]] {
// CHECK-NEXT:            %[[VAL_254:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_58]]{{\[}}%[[VAL_253]]] : <2 x !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>>, !pod.type<[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:            %[[VAL_255:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_254]][@comp] : <[@count: index, @comp: !struct.type<@A::@A<[#map]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            array.write %[[VAL_249]]{{\[}}%[[VAL_253]]] = %[[VAL_255]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_51]][@as] = %[[VAL_249]] : <@B::@B<[@n]>>, !array.type<2 x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          struct.writem %[[VAL_51]][@b] = %[[VAL_57]] : <@B::@B<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_51]] : !struct.type<@B::@B<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_256:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@n]>>, %[[VAL_257:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_4@409" x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_259:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_258]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_260:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@469" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_4@409" : index
// CHECK-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_261]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_256]][@b] : <@B::@B<[@n]>>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_264:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_256]][@as] : <@B::@B<[@n]>>, !array.type<2 x !struct.type<@A::@A<[#map]>>>
// CHECK-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_256]][@as$inputs] : <@B::@B<[@n]>>, !array.type<2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@469" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_267:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_266]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_268:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_267]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@"n_Mul_2@469"]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_271:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_272:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_273:[0-9a-zA-Z_\.]+]] = %[[VAL_271]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_274:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_275:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_259]], %[[VAL_274]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_276:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_273]], %[[VAL_275]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_276]]) %[[VAL_273]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_277:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_278:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_279:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_257]]{{\[}}%[[VAL_278]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_280:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_281:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_280]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_282:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_265]]{{\[}}%[[VAL_281]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_283:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_282]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_284:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_285:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_283]]{{\[}}%[[VAL_284]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_285]], %[[VAL_279]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_286:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_287:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_259]], %[[VAL_286]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_288:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_277]], %[[VAL_287]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_289:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_288]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_290:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_257]]{{\[}}%[[VAL_289]]] : <@"n_Mul_4@409" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_291:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_292:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_291]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_293:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_265]]{{\[}}%[[VAL_292]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_294:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_293]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_295:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_277]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_296:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_294]]{{\[}}%[[VAL_295]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_296]], %[[VAL_290]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_297:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_298:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_277]], %[[VAL_297]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_298]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_299:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_300:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_299]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_301:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@A::@A<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_302:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_303:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_304:[0-9a-zA-Z_\.]+]] = %[[VAL_302]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_305:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_304]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_305]]) %[[VAL_304]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_306:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_307:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_308:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_307]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_309:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_264]]{{\[}}%[[VAL_308]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_310:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_309]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_311:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_306]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_312:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_310]]{{\[}}%[[VAL_311]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_313:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_314:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_313]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_315:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_265]]{{\[}}%[[VAL_314]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_316:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_315]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_317:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_306]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_318:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_316]]{{\[}}%[[VAL_317]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_318]], %[[VAL_312]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_319:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_320:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_319]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_321:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_264]]{{\[}}%[[VAL_320]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_322:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_321]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_323:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_306]], %[[VAL_259]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_324:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_323]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_325:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_322]]{{\[}}%[[VAL_324]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_326:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_327:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_326]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_328:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_265]]{{\[}}%[[VAL_327]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_329:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_328]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_330:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_306]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_331:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_329]]{{\[}}%[[VAL_330]]] : <#map x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_331]], %[[VAL_325]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_332:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_333:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_306]], %[[VAL_332]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_333]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_334:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_335:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_336:[0-9a-zA-Z_\.]+]] = %[[VAL_334]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_337:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_336]], %[[VAL_259]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_337]]) %[[VAL_336]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_338:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_339:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_340:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_339]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_341:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_264]]{{\[}}%[[VAL_340]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_342:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_341]][@c] : <@A::@A<[#map]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_343:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_338]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_344:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_342]]{{\[}}%[[VAL_343]]] : <? x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_345:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_338]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_346:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_263]]{{\[}}%[[VAL_345]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_346]], %[[VAL_344]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_347:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_348:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_338]], %[[VAL_347]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_348]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_349:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CHECK-NEXT:          %[[VAL_350:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_351:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_352:[0-9a-zA-Z_\.]+]] = %[[VAL_350]] to %[[VAL_349]] step %[[VAL_351]] {
// CHECK-NEXT:            %[[VAL_353:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_264]]{{\[}}%[[VAL_352]]] : <2 x !struct.type<@A::@A<[#map]>>>, !struct.type<@A::@A<[#map]>>
// CHECK-NEXT:            %[[VAL_354:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_265]]{{\[}}%[[VAL_352]]] : <2 x !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_355:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_354]][@a] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_356:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_354]][@b] : <[@a: !array.type<#map x !felt.type<"bn128">>, @b: !array.type<#map x !felt.type<"bn128">>]>, !array.type<#map x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @A::@A::@constrain(%[[VAL_353]], %[[VAL_355]], %[[VAL_356]]) : (!struct.type<@A::@A<[#map]>>, !array.type<#map x !felt.type<"bn128">>, !array.type<#map x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
