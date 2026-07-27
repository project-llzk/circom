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
// CHECK-NEXT:        %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_9:[0-9a-zA-Z_\.]+]] = array.new %[[VAL_8]], %[[VAL_8]], %[[VAL_8]], %[[VAL_8]], %[[VAL_8]] : <5 x !felt.type<"bn128">>
// CHECK-NEXT:        %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_11:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_10]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_12]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_14]]) %[[VAL_12]] : !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_17]]{{\[}}%[[VAL_16]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_18]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_2]] : (!poly.tvar<@T_arg2>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_19]], %[[VAL_20]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_3]] : (!poly.tvar<@T_arg3>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_22]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]] : (!poly.tvar<@T_arg4>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_24]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_5]] : (!poly.tvar<@T_arg5>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_25]], %[[VAL_26]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_6]] : (!poly.tvar<@T_arg6>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_28]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_9]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_33]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_34]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_36]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_37]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_35]], %[[VAL_38]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_9]]{{\[}}%[[VAL_41]]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_39]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_44:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_43]] : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_44]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @CallInLoop {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.param @m
// CHECK-NEXT:      struct.def @CallInLoop {
// CHECK-NEXT:        struct.member @out : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@CallInLoop::@CallInLoop<[@n, @m]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.new : <@CallInLoop::@CallInLoop<[@n, @m]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_48]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_51]], %[[VAL_52]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_54]] to %[[VAL_53]] step %[[VAL_55]] {
// CHECK-NEXT:            array.write %[[VAL_51]]{{\[}}%[[VAL_56]]] = %[[VAL_50]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_51]], %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_57]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_60]], %[[VAL_49]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_61]]) %[[VAL_59]], %[[VAL_60]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_63:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_47]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_63]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_62]]{{\[}}%[[VAL_65]]] = %[[VAL_64]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_63]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_62]], %[[VAL_67]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_69]], %[[VAL_70]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_74:[0-9a-zA-Z_\.]+]] = %[[VAL_72]] to %[[VAL_71]] step %[[VAL_73]] {
// CHECK-NEXT:            array.write %[[VAL_69]]{{\[}}%[[VAL_74]]] = %[[VAL_68]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_69]], %[[VAL_78:[0-9a-zA-Z_\.]+]] = %[[VAL_75]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_78]], %[[VAL_49]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_79]]) %[[VAL_77]], %[[VAL_78]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?]>(%[[VAL_58]]#0, %[[VAL_49]], %[[VAL_47]], %[[VAL_47]], %[[VAL_47]], %[[VAL_47]], %[[VAL_47]], %[[VAL_47]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_81]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_80]]{{\[}}%[[VAL_83]]] = %[[VAL_82]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_81]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_80]], %[[VAL_85]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]#0{{\[}}%[[VAL_87]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_46]][@out] = %[[VAL_88]] : <@CallInLoop::@CallInLoop<[@n, @m]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_46]] : !struct.type<@CallInLoop::@CallInLoop<[@n, @m]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_89:[0-9a-zA-Z_\.]+]]: !struct.type<@CallInLoop::@CallInLoop<[@n, @m]>>, %[[VAL_90:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @m : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_92]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_89]][@out] : <@CallInLoop::@CallInLoop<[@n, @m]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_96]], %[[VAL_97]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_99]] to %[[VAL_98]] step %[[VAL_100]] {
// CHECK-NEXT:            array.write %[[VAL_96]]{{\[}}%[[VAL_101]]] = %[[VAL_95]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_96]], %[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_102]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_105]], %[[VAL_93]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_106]]) %[[VAL_104]], %[[VAL_105]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_107:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_108:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_91]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_107]]{{\[}}%[[VAL_110]]] = %[[VAL_109]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_108]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_107]], %[[VAL_112]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.new  : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.len %[[VAL_114]], %[[VAL_115]] : <@n x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_119:[0-9a-zA-Z_\.]+]] = %[[VAL_117]] to %[[VAL_116]] step %[[VAL_118]] {
// CHECK-NEXT:            array.write %[[VAL_114]]{{\[}}%[[VAL_119]]] = %[[VAL_113]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_114]], %[[VAL_123:[0-9a-zA-Z_\.]+]] = %[[VAL_120]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) -> (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_123]], %[[VAL_93]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_124]]) %[[VAL_122]], %[[VAL_123]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_125:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>, %[[VAL_126:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun<[?, ?, ?, ?, ?, ?, ?, ?, ?, ?]>(%[[VAL_103]]#0, %[[VAL_93]], %[[VAL_91]], %[[VAL_91]], %[[VAL_91]], %[[VAL_91]], %[[VAL_91]], %[[VAL_91]]) : (!array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_125]]{{\[}}%[[VAL_128]]] = %[[VAL_127]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_126]], %[[VAL_129]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_125]], %[[VAL_130]] : !array.type<@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
