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
// CHECK-NEXT:    function.def @nop(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">) -> !felt.type<"bn128"> attributes {function.allow_non_native_field_ops} {
// CHECK-NEXT:      function.return %[[VAL_0]] : !felt.type<"bn128">
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Caller {
// CHECK-NEXT:      struct.def @Caller {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @s : !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:        struct.member @s$inputs : !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_1:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Caller::@Caller<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = struct.new : <@Caller::@Caller<[]>>
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_4]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_6]], @params = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_10]], %[[VAL_12]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_13]]) %[[VAL_10]], %[[VAL_11]] : !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_1]]{{\[}}%[[VAL_16]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = function.call @nop(%[[VAL_17]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_19]]{{\[}}%[[VAL_20]]] = %[[VAL_18]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_15]][@inp] = %[[VAL_19]] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_21]], %[[VAL_22]] : index
// CHECK-NEXT:            pod.write %[[VAL_7]][@count] = %[[VAL_23]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_23]], %[[VAL_24]] : index
// CHECK-NEXT:            scf.if %[[VAL_25]] {
// CHECK-NEXT:              %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_27]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:              pod.write %[[VAL_7]][@comp] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_14]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_30]], %[[VAL_15]] : !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_31]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@outp] = %[[VAL_32]] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_2]][@s$inputs] = %[[VAL_9]]#1 : <@Caller::@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          struct.writem %[[VAL_2]][@s] = %[[VAL_33]] : <@Caller::@Caller<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          function.return %[[VAL_2]] : !struct.type<@Caller::@Caller<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_34:[0-9a-zA-Z_\.]+]]: !struct.type<@Caller::@Caller<[]>>, %[[VAL_35:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@outp] : <@Caller::@Caller<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@s] : <@Caller::@Caller<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@s$inputs] : <@Caller::@Caller<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_39]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_41]], @params = %[[VAL_40]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_45:[0-9a-zA-Z_\.]+]] = %[[VAL_43]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_47:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_45]], %[[VAL_46]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_47]]) %[[VAL_45]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_48:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_35]]{{\[}}%[[VAL_49]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = function.call @nop(%[[VAL_50]]) : (!felt.type<"bn128">) -> !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_52]]{{\[}}%[[VAL_53]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_54]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_48]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:          constrain.eq %[[VAL_36]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_37]], %[[VAL_58]]) : (!struct.type<@Sum::@Sum<[4]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_59:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_65:[0-9a-zA-Z_\.]+]] = %[[VAL_63]], %[[VAL_66:[0-9a-zA-Z_\.]+]] = %[[VAL_62]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_65]], %[[VAL_61]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_67]]) %[[VAL_65]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_68:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_69:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_68]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_59]]{{\[}}%[[VAL_70]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_69]], %[[VAL_71]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_68]], %[[VAL_73]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_74]], %[[VAL_72]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_60]][@outp] = %[[VAL_64]]#1 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_60]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_75:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_76:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_80]], %[[VAL_83:[0-9a-zA-Z_\.]+]] = %[[VAL_79]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_77]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_84]]) %[[VAL_82]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_76]]{{\[}}%[[VAL_87]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_86]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_85]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_91]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_78]], %[[VAL_81]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
