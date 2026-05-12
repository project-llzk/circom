// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@NeedsStackContext::@NeedsStackContext<[3, 2]>>} {
// CHECK-NEXT:    poly.template @fun {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_arg1 : !poly.tvar<@T_arg1>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @fun(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>, %[[VAL_1:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg1>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
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
// CHECK-NEXT:      poly.param @t
// CHECK-NEXT:      struct.def @Ark {
// CHECK-NEXT:        struct.member @out : !array.type<@t x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_19:[0-9a-zA-Z_\.]+]]: !array.type<@t x !felt.type<"bn128">>) -> !struct.type<@Ark::@Ark<[@t]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = struct.new : <@Ark::@Ark<[@t]>>
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = poly.read_const @t : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@t x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_23]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_25]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_25]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @fun::@fun<[?, ?, ?, ?]>(%[[VAL_19]], %[[VAL_27]]) : (!array.type<@t x !felt.type<"bn128">>, !felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_22]]{{\[}}%[[VAL_29]]] = %[[VAL_28]] : <@t x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_20]][@out] = %[[VAL_22]] : <@Ark::@Ark<[@t]>>, !array.type<@t x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_20]] : !struct.type<@Ark::@Ark<[@t]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@Ark::@Ark<[@t]>>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<@t x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = poly.read_const @t : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@out] : <@Ark::@Ark<[@t]>>, !array.type<@t x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_38:[0-9a-zA-Z_\.]+]] = %[[VAL_36]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_38]], %[[VAL_34]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_39]]) %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_40:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_40]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @NeedsStackContext {
// CHECK-NEXT:      poly.param @a
// CHECK-NEXT:      poly.param @b
// CHECK-NEXT:      struct.def @NeedsStackContext {
// CHECK-NEXT:        struct.member @out : !array.type<@a,@b x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @arks : !array.type<@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:        struct.member @arks$inputs : !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>
// CHECK-NEXT:        function.def @compute(%[[VAL_43:[0-9a-zA-Z_\.]+]]: !array.type<@a,@b x !felt.type<"bn128">>) -> !struct.type<@NeedsStackContext::@NeedsStackContext<[@a, @b]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.new : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = poly.read_const @a : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = poly.read_const @b : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.new  : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.new  : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_52:[0-9a-zA-Z_\.]+]] = %[[VAL_49]], %[[VAL_53:[0-9a-zA-Z_\.]+]] = %[[VAL_50]]) : (!array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">) -> (!array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_53]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_54]]) %[[VAL_52]], %[[VAL_53]] : !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_55:[0-9a-zA-Z_\.]+]]: !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, %[[VAL_56:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = poly.read_const @b : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.new { @t = %[[VAL_57]] }  : <[@t: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_59]], @params = %[[VAL_58]] }  : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_48]]{{\[}}%[[VAL_61]]] = %[[VAL_60]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = array.extract %[[VAL_43]]{{\[}}%[[VAL_62]]] : <@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_64]]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            pod.write %[[VAL_65]][@in] = %[[VAL_63]] : <[@in: !array.type<@b x !felt.type<"bn128">>]>, !array.type<@b x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_55]]{{\[}}%[[VAL_66]]] = %[[VAL_65]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_67]]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_55]]{{\[}}%[[VAL_69]]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@count] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_71]], %[[VAL_72]] : index
// CHECK-NEXT:            pod.write %[[VAL_68]][@count] = %[[VAL_73]] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_73]], %[[VAL_74]] : index
// CHECK-NEXT:            scf.if %[[VAL_75]] {
// CHECK-NEXT:              %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@params] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !pod.type<[@t: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@in] : <[@in: !array.type<@b x !felt.type<"bn128">>]>, !array.type<@b x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = function.call @Ark::@Ark::@compute(%[[VAL_77]]) : (!array.type<@b x !felt.type<"bn128">>) -> !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:              pod.write %[[VAL_68]][@comp] = %[[VAL_78]] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_48]]{{\[}}%[[VAL_79]]] = %[[VAL_68]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_56]], %[[VAL_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_55]], %[[VAL_81]] : !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_84]], %[[VAL_45]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_85]]) %[[VAL_84]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_87]]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@comp] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_89]][@out] : <@Ark::@Ark<[@b]>>, !array.type<? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CHECK-NEXT:            array.insert %[[VAL_47]]{{\[}}%[[VAL_91]]] = %[[VAL_90]] : <@a,@b x !felt.type<"bn128">>, <? x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_44]][@arks$inputs] = %[[VAL_51]]#0 : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.new  : <@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_98:[0-9a-zA-Z_\.]+]] = %[[VAL_96]] to %[[VAL_95]] step %[[VAL_97]] {
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_98]]] : <@a x !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>>, !pod.type<[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@comp] : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:            array.write %[[VAL_94]]{{\[}}%[[VAL_98]]] = %[[VAL_100]] : <@a x !struct.type<@Ark::@Ark<[@b]>>>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_44]][@arks] = %[[VAL_94]] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:          struct.writem %[[VAL_44]][@out] = %[[VAL_47]] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_44]] : !struct.type<@NeedsStackContext::@NeedsStackContext<[@a, @b]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !struct.type<@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, %[[VAL_102:[0-9a-zA-Z_\.]+]]: !array.type<@a,@b x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = poly.read_const @a : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = poly.read_const @b : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@out] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a,@b x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@arks] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !struct.type<@Ark::@Ark<[@b]>>>
// CHECK-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_101]][@arks$inputs] : <@NeedsStackContext::@NeedsStackContext<[@a, @b]>>, !array.type<@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>
// CHECK-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_108]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_110]], %[[VAL_103]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_111]]) %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_112:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = poly.read_const @b : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.new { @t = %[[VAL_113]] }  : <[@t: !felt.type<"bn128">]>
// CHECK-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Ark::@Ark<[@b]>>, @params: !pod.type<[@t: !felt.type<"bn128">]>]>
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_112]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_120:[0-9a-zA-Z_\.]+]] = %[[VAL_118]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_120]], %[[VAL_103]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_121]]) %[[VAL_120]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_122:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_122]], %[[VAL_123]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_124]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = poly.read_const @a : index
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          scf.for %[[VAL_128:[0-9a-zA-Z_\.]+]] = %[[VAL_126]] to %[[VAL_125]] step %[[VAL_127]] {
// CHECK-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_128]]] : <@a x !struct.type<@Ark::@Ark<[@b]>>>, !struct.type<@Ark::@Ark<[@b]>>
// CHECK-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_107]]{{\[}}%[[VAL_128]]] : <@a x !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>>, !pod.type<[@in: !array.type<@b x !felt.type<"bn128">>]>
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_130]][@in] : <[@in: !array.type<@b x !felt.type<"bn128">>]>, !array.type<@b x !felt.type<"bn128">>
// CHECK-NEXT:            function.call @Ark::@Ark::@constrain(%[[VAL_129]], %[[VAL_131]]) : (!struct.type<@Ark::@Ark<[@b]>>, !array.type<@b x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          }
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
