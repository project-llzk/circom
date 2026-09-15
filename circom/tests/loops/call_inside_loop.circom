// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function fun(a, n, b, c, d, e, f, g) {
	var x[5];
    for (var i = 0; i < n; i++) {
    	x[i] = a[i] + b + c + d + e + f;
    }
	return x[0] + x[2] + x[4];
}

template CallInLoop(n, m) {
    signal input in;
    signal output out;
    var a[n];
    for (var i = 0; i < n; i++) {
    	a[i] = m + in;
    }
    var b[n];
    for (var i = 0; i < n; i++) {
    	b[i] = fun(a, n, m, m, m, m, m, m);
    }
    out <-- b[0];
}

component main = CallInLoop(2, 3);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@CallInLoop::@CallInLoop<[2, 3]>>} {
// CHECK-NEXT:    poly.template @fun {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_arg2 : !poly.tvar<@T_arg2>
// CHECK-NEXT:      poly.param @T_arg3 : !poly.tvar<@T_arg3>
// CHECK-NEXT:      poly.param @T_arg4 : !poly.tvar<@T_arg4>
// CHECK-NEXT:      poly.param @T_arg5 : !poly.tvar<@T_arg5>
// CHECK-NEXT:      poly.param @T_arg6 : !poly.tvar<@T_arg6>
// CHECK-NEXT:      poly.param @T_arg7 : !poly.tvar<@T_arg7>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @fun(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "a"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "n"}, %[[VAL_2:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg2> {function.arg_name = "b"}, %[[VAL_3:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg3> {function.arg_name = "c"}, %[[VAL_4:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg4> {function.arg_name = "d"}, %[[VAL_5:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg5> {function.arg_name = "e"}, %[[VAL_6:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg6> {function.arg_name = "f"}, %[[VAL_7:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg7> {function.arg_name = "g"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<5 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_9]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_11]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_13]]) %[[VAL_11]] : !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_16]]{{\[}}%[[VAL_15]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_17]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_18]], %[[VAL_19]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_21]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!poly.tvar<@T_arg4>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_22]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!poly.tvar<@T_arg5>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_24]], %[[VAL_25]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_6]] : (!poly.tvar<@T_arg6>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_26]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_8]]{{\[}}%[[VAL_29]]] = %[[VAL_28]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_33]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_36]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_8]]{{\[}}%[[VAL_40]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_38]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_42]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_43]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:    }
// CHECK-NEXT:    module @global {
// CHECK-NEXT:      global.def const @array_const_0 : !array.type<5 x !felt.type<"bn128">> = [ 0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallInLoop {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @m
// CHECK-NEXT:      struct.def @CallInLoop {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_44:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@CallInLoop::@CallInLoop<[@n, @m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.new : <@CallInLoop::@CallInLoop<[@n, @m]>>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_47]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_50]], %[[VAL_51]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_55:[0-9a-zA-Z_\.]+]] = %[[VAL_53]] to %[[VAL_52]] step %[[VAL_54]] {
// CHECK-NEXT:            array.write %[[VAL_50]]{{\[}}%[[VAL_55]]] = %[[VAL_49]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_50]], %[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_56]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_59]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_60]]) %[[VAL_58]], %[[VAL_59]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_46]], %[[VAL_44]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_61]]{{\[}}%[[VAL_64]]] = %[[VAL_63]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_61]], %[[VAL_66]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_68]], %[[VAL_69]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_73:[0-9a-zA-Z_\.]+]] = %[[VAL_71]] to %[[VAL_70]] step %[[VAL_72]] {
// CHECK-NEXT:            array.write %[[VAL_68]]{{\[}}%[[VAL_73]]] = %[[VAL_67]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_68]], %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_74]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_77]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_78]]) %[[VAL_76]], %[[VAL_77]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?]>(%[[VAL_57]]#0, %[[VAL_48]], %[[VAL_46]], %[[VAL_46]], %[[VAL_46]], %[[VAL_46]], %[[VAL_46]], %[[VAL_46]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_79]]{{\[}}%[[VAL_82]]] = %[[VAL_81]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_80]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_79]], %[[VAL_84]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]#0{{\[}}%[[VAL_86]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_45]][@out] = %[[VAL_87]] : <@CallInLoop::@CallInLoop<[@n, @m]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_45]] : !struct.type<@CallInLoop::@CallInLoop<[@n, @m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !struct.type<@CallInLoop::@CallInLoop<[@n, @m]>>, %[[VAL_89:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_91]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_88]][@out] : <@CallInLoop::@CallInLoop<[@n, @m]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_95]], %[[VAL_96]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_100:[0-9a-zA-Z_\.]+]] = %[[VAL_98]] to %[[VAL_97]] step %[[VAL_99]] {
// CHECK-NEXT:            array.write %[[VAL_95]]{{\[}}%[[VAL_100]]] = %[[VAL_94]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_103:[0-9a-zA-Z_\.]+]] = %[[VAL_95]], %[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_101]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_104]], %[[VAL_92]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_105]]) %[[VAL_103]], %[[VAL_104]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_106:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_107:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_90]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_106]]{{\[}}%[[VAL_109]]] = %[[VAL_108]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_107]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_106]], %[[VAL_111]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_113]], %[[VAL_114]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_118:[0-9a-zA-Z_\.]+]] = %[[VAL_116]] to %[[VAL_115]] step %[[VAL_117]] {
// CHECK-NEXT:            array.write %[[VAL_113]]{{\[}}%[[VAL_118]]] = %[[VAL_112]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_113]], %[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_119]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_122]], %[[VAL_92]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_123]]) %[[VAL_121]], %[[VAL_122]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_124:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_125:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?]>(%[[VAL_102]]#0, %[[VAL_92]], %[[VAL_90]], %[[VAL_90]], %[[VAL_90]], %[[VAL_90]], %[[VAL_90]], %[[VAL_90]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_124]]{{\[}}%[[VAL_127]]] = %[[VAL_126]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_125]], %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_124]], %[[VAL_129]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
