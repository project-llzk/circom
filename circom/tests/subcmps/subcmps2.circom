// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@Caller::@Caller<[]>>} {
// CHECK-NEXT:    poly.template @nop {
// CHECK-NEXT:      poly.param @T_arg0 : !poly.tvar<@T_arg0>
// CHECK-NEXT:      poly.param @T_return : !poly.tvar<@T_return>
// CHECK-NEXT:      function.def @nop(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !poly.tvar<@T_arg0>) -> !poly.tvar<@T_return> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.unifiable_cast %[[VAL_0]] : (!poly.tvar<@T_arg0>) -> !poly.tvar<@T_return>
// CHECK-NEXT:        function.return %[[VAL_1]] : !poly.tvar<@T_return>
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Caller {
// CHECK-NEXT:      struct.def @Caller {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @s : !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:        struct.member @s$inputs : !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_2:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Caller::@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[]>>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_7]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_6]]) : (!felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_9]], %[[VAL_11]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_12]]) %[[VAL_9]], %[[VAL_10]] : !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_2]]{{\[}}%[[VAL_15]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = function.call @nop::@nop(%[[VAL_16]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_18]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_14]][@inp] = %[[VAL_18]] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_20]], %[[VAL_21]] : index
// CHECK-NEXT:            pod.write %[[VAL_5]][@count] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:            scf.if %[[VAL_24]] {
// CHECK-NEXT:              %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_25]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:              pod.write %[[VAL_5]][@comp] = %[[VAL_26]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_28]], %[[VAL_14]] : !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_29]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@outp] = %[[VAL_30]] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_3]][@s$inputs] = %[[VAL_8]]#1 : <@Caller::@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          struct.writem %[[VAL_3]][@s] = %[[VAL_31]] : <@Caller::@Caller<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          function.return %[[VAL_3]] : !struct.type<@Caller::@Caller<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_32:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[]>>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@outp] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@s] : <@Caller::@Caller<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_32]][@s$inputs] : <@Caller::@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_39:[0-9a-zA-Z_\.]+]] = %[[VAL_37]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_39]], %[[VAL_40]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_41]]) %[[VAL_39]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_42:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_43]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = function.call @nop::@nop(%[[VAL_44]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_46]]{{\[}}%[[VAL_47]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_48]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_42]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_50]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_34]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_35]], %[[VAL_52]]) : (!struct.type<@Sum::@Sum<[4]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_59:[0-9a-zA-Z_\.]+]] = %[[VAL_57]], %[[VAL_60:[0-9a-zA-Z_\.]+]] = %[[VAL_56]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_59]], %[[VAL_55]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_61]]) %[[VAL_59]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_62:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_63:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_64:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_65:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_53]]{{\[}}%[[VAL_64]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_63]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_62]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_68]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_54]][@outp] = %[[VAL_58]]#1 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_54]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_69:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_70:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_76:[0-9a-zA-Z_\.]+]] = %[[VAL_74]], %[[VAL_77:[0-9a-zA-Z_\.]+]] = %[[VAL_73]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_76]], %[[VAL_71]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_78]]) %[[VAL_76]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_79]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_81]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_80]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_79]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_85]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_72]], %[[VAL_75]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
