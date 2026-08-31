// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

function fun(in, len) {
	var sum = 0;
    for (var j = 0; j < len; j++) {
    	sum += in[j];
    }
	return sum;
}

template Ark(t) {
    signal input in[t];
    signal output out[t];

    for (var i = 0; i < t; i++) {
        out[i] <-- fun(in, i);
    }
}

template NeedsStackContext(a, b) {
    signal input in[a][b];
    signal output out[a][b];
    component arks[a];
    for (var j = 0; j < a; j++) {
        arks[j] = Ark(b);
        arks[j].in <-- in[j];
    }
    for (var k = 0; k < a; k++) {
    	out[k] <-- arks[k].out;
    }
}

component main = NeedsStackContext(3, 2);

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@NeedsStackContext::@NeedsStackContext<[3, 2]>>} {
// CHECK-NEXT:    poly.template @fun {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @fun(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "in"}, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1> {function.arg_name = "len"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_5:[0-9a-zA-Z_\.]+]] = %[[VAL_3]], %[[VAL_6:[0-9a-zA-Z_\.]+]] = %[[VAL_2]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_1]] : (!poly.tvar<@T_arg1>) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_5]], %[[VAL_7]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.condition(%[[VAL_8]]) %[[VAL_5]], %[[VAL_6]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_9:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_10:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !array.type<? x !poly.tvar<@"$e">>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_12]]{{\[}}%[[VAL_11]]] : <? x !poly.tvar<@"$e">>, !poly.tvar<@"$e">
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_13]] : (!poly.tvar<@"$e">) -> !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_10]], %[[VAL_14]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_9]], %[[VAL_16]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          scf.yield %[[VAL_17]], %[[VAL_15]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_4]]#1 : (!felt.type<"bn128">) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_18]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:      poly.param @"$e" : !poly.tvar<@"$e">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Ark {
// CHECK-NEXT:      poly.param @t : index
// CHECK-NEXT:      struct.def @Ark {
// CHECK-NEXT:        struct.member @out : !array.type<@t x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@t x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@Ark::@Ark<[@t]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.new : <@Ark::@Ark<[@t]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @t : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_21]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@t x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_24]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_26]], %[[VAL_22]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_27]]) %[[VAL_26]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun<[?, ?, ?, ?]>(%[[VAL_19]], %[[VAL_28]]) : (!array.type<@t x !felt.type<"bn128">>, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_23]]{{\[}}%[[VAL_30]]] = %[[VAL_29]] : <@t x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_31]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_20]][@out] = %[[VAL_23]] : <@Ark::@Ark<[@t]>>, !array.type<@t x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_20]] : !struct.type<@Ark::@Ark<[@t]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !struct.type<@Ark::@Ark<[@t]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !array.type<@t x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = poly.read_const @t : index
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_35]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@out] : <@Ark::@Ark<[@t]>>, !array.type<@t x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_40:[0-9a-zA-Z_\.]+]] = %[[VAL_38]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_40]], %[[VAL_36]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_41]]) %[[VAL_40]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NeedsStackContext {
// CHECK-NEXT:      poly.param @a : index
// CHECK-NEXT:      poly.param @b : index
// CHECK-NEXT:      struct.def @NeedsStackContext {
// CHECK-NEXT:        struct.member @out : !array.type<@a,@b x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @arks : !array.type<@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:        struct.member @arks$inputs : !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !array.type<@a,@b x !felt.type<"bn128">> {function.arg_name = "in"}) -> !struct.type<@NeedsStackContext::@NeedsStackContext<[@a, @b]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = struct.new : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_47]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = poly.read_const @b : index
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_49]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = array.new  : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.new  : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_56:[0-9a-zA-Z_\.]+]] = %[[VAL_52]], %[[VAL_57:[0-9a-zA-Z_\.]+]] = %[[VAL_53]], %[[VAL_58:[0-9a-zA-Z_\.]+]] = %[[VAL_54]]) : (!array.type<@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_58]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_59]]) %[[VAL_56]], %[[VAL_57]], %[[VAL_58]] : !array.type<@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !array.type<@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, %[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = poly.read_const @b : index
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_63]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.new { @t = %[[VAL_64]] }  : <[@t: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_66]], @params = %[[VAL_65]] }  : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_60]]{{\[}}%[[VAL_68]]] = %[[VAL_67]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_45]]{{\[}}%[[VAL_69]]] : <@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_71]]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_72]][@in] = %[[VAL_70]] : <[@in: !array.type<@b x !felt.type<"bn128">>]>, !array.type<@b x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_61]]{{\[}}%[[VAL_73]]] = %[[VAL_72]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_60]]{{\[}}%[[VAL_74]]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_61]]{{\[}}%[[VAL_76]]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@count] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_79:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_78]], %[[VAL_79]] : index
// CHECK-NEXT:            pod.write %[[VAL_75]][@count] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_80]], %[[VAL_81]] : index
// CHECK-NEXT:            scf.if %[[VAL_82]] {
// CHECK-NEXT:              %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@params] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !pod.type<[@t: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_77]][@in] : <[@in: !array.type<@b x !felt.type<"bn128">>]>, !array.type<@b x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_85:[0-9a-zA-Z_\.]+]] = function.call @Ark::@Ark::@compute(%[[VAL_84]]) : (!array.type<@b x !felt.type<"bn128">>) -> !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:              pod.write %[[VAL_75]][@comp] = %[[VAL_85]] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_60]]{{\[}}%[[VAL_86]]] = %[[VAL_75]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_60]], %[[VAL_61]], %[[VAL_88]] : !array.type<@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_91:[0-9a-zA-Z_\.]+]] = %[[VAL_89]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_91]], %[[VAL_48]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_92]]) %[[VAL_91]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_93:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]#0{{\[}}%[[VAL_94]]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@comp] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_96]][@out] : <@Ark::@Ark<[@b]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_51]]{{\[}}%[[VAL_98]]] = %[[VAL_97]] : <@a,@b x !felt.type<"bn128">>, <? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_93]], %[[VAL_99]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_100]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_46]][@arks$inputs] = %[[VAL_55]]#1 : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.new  : <@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_105:[0-9a-zA-Z_\.]+]] = %[[VAL_103]] to %[[VAL_102]] step %[[VAL_104]] {
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]#0{{\[}}%[[VAL_105]]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_106]][@comp] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:            array.write %[[VAL_101]]{{\[}}%[[VAL_105]]] = %[[VAL_107]] : <@a x !struct.type<@Ark::@Ark<[@b]>>>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_46]][@arks] = %[[VAL_101]] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:          struct.writem %[[VAL_46]][@out] = %[[VAL_51]] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_46]] : !struct.type<@NeedsStackContext::@NeedsStackContext<[@a, @b]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_108:[0-9a-zA-Z_\.]+]]: !struct.type<@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, %[[VAL_109:[0-9a-zA-Z_\.]+]]: !array.type<@a,@b x !felt.type<"bn128">> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_110]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = poly.read_const @b : index
// CHECK-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_112]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_108]][@out] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_108]][@arks] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_108]][@arks$inputs] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_119:[0-9a-zA-Z_\.]+]] = %[[VAL_117]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_119]], %[[VAL_111]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_120]]) %[[VAL_119]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_121:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = poly.read_const @b : index
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_122]] : index, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.new { @t = %[[VAL_123]] }  : <[@t: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_121]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_127]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_130:[0-9a-zA-Z_\.]+]] = %[[VAL_128]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_130]], %[[VAL_111]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_131]]) %[[VAL_130]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_132:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_132]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_138:[0-9a-zA-Z_\.]+]] = %[[VAL_136]] to %[[VAL_135]] step %[[VAL_137]] {
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_115]]{{\[}}%[[VAL_138]]] : <@a x !struct.type<@Ark::@Ark<[@b]>>>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_138]]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_140]][@in] : <[@in: !array.type<@b x !felt.type<"bn128">>]>, !array.type<@b x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Ark::@Ark::@constrain(%[[VAL_139]], %[[VAL_141]]) : (!struct.type<@Ark::@Ark<[@b]>>, !array.type<@b x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
