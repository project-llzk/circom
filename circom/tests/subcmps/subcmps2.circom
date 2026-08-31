// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.6;

template Sum(n) {
    signal input inp[n];
    signal output outp;

    var s = 0;

    for (var i = 0; i < n; i++) {
        s += inp[i];
    }

    outp <== s;
}

function nop(i) {
    return i;
}

template Caller() {
    signal input inp[4];
    signal output outp;

    component s = Sum(4);

    for (var i = 0; i < 4; i++) {
        s.inp[i] <== nop(inp[i]);
    }

    outp <== s.outp;
}

component main = Caller();

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@Caller::@Caller<[]>>} {
// CHECK-NEXT:    poly.template @nop {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @nop(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0> {function.arg_name = "i"}) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_1]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Caller {
// CHECK-NEXT:      struct.def @Caller {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @s : !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:        struct.member @s$inputs : !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Caller::@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_5]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_7]], @params = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_9]], %[[VAL_8_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_4]]) : (!felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_11]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_14]]) %[[VAL_11]], %[[VAL_8_IN]], %[[VAL_12]] : !felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_8_LCV:[0-9a-zA-Z_\.]+]]: !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_17]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = function.call @nop::@nop(%[[VAL_18]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_21]]] = %[[VAL_19]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_16]][@inp] = %[[VAL_20]] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8_LCV]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:            pod.write %[[VAL_8_LCV]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// CHECK-NEXT:            scf.if %[[VAL_26]] {
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8_LCV]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_28]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:              pod.write %[[VAL_8_LCV]][@comp] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_30]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_31]], %[[VAL_8_LCV]], %[[VAL_16]] : !felt.type<"bn128">, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]]#1[@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@outp] = %[[VAL_33]] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@s$inputs] = %[[VAL_10]]#2 : <@Caller::@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]]#1[@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          struct.writem %[[VAL_3]][@s] = %[[VAL_34]] : <@Caller::@Caller<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@Caller::@Caller<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[]>>, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@outp] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@s] : <@Caller::@Caller<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@s$inputs] : <@Caller::@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_40]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_43]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_45]], %[[VAL_46]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_47]]) %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_49]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = function.call @nop::@nop(%[[VAL_50]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_53]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_54]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_38]], %[[VAL_58]]) : (!struct.type<@Sum::@Sum<[4]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_61]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_64]], %[[VAL_67:[0-9a-zA-Z_\.]+]] = %[[VAL_63]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_66]], %[[VAL_62]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_68]]) %[[VAL_66]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_69]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_71]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_70]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_74]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_75]], %[[VAL_73]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_60]][@outp] = %[[VAL_65]]#1 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_60]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_76:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_77:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_78]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_84:[0-9a-zA-Z_\.]+]] = %[[VAL_82]], %[[VAL_85:[0-9a-zA-Z_\.]+]] = %[[VAL_81]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_84]], %[[VAL_79]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_86]]) %[[VAL_84]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_87:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_88:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_87]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_77]]{{\[}}%[[VAL_89]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_88]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_87]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_93]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_80]], %[[VAL_83]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
