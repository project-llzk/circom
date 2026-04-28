// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Sum(n) {
    signal input inp[n];
    signal output outp;

    var s = 0;

    for (var i = 0; i < n; i++) {
        s += inp[i];
    }

    outp <== s;
}

template SubCmps3() {
    signal input inp[4];
    signal output outp;

    component s = Sum(4);

    for (var i = 0; i < 4; i++) {
        s.inp[i] <== inp[i];
        if (i == 3) {
            outp <== s.outp;
        }
    }
}

component main = SubCmps3();

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmps3::@SubCmps3<[]>>} {
// CHECK-NEXT:    poly.template @SubCmps3 {
// CHECK-NEXT:      struct.def @SubCmps3 {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        struct.member @s : !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:        struct.member @s$inputs : !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) -> !struct.type<@SubCmps3::@SubCmps3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps3::@SubCmps3<[]>>
// CHECK-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_4]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_6]], @params = %[[VAL_5]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_11:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_12:[0-9a-zA-Z_\.]+]] = %[[VAL_3]]) : (!felt.type<"bn128">, !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) -> (!felt.type<"bn128">, !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>) {
// CHECK-NEXT:            %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_14:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_10]], %[[VAL_13]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_14]]) %[[VAL_10]], %[[VAL_11]], %[[VAL_12]] : !felt.type<"bn128">, !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_15:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_16:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_17:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>):
// CHECK-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_18]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_15]] : !felt.type<"bn128">
// CHECK-NEXT:            array.write %[[VAL_20]]{{\[}}%[[VAL_21]]] = %[[VAL_19]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            pod.write %[[VAL_17]][@inp] = %[[VAL_20]] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:            pod.write %[[VAL_7]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// CHECK-NEXT:            scf.if %[[VAL_26]] {
// CHECK-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_28]]) : (!array.type<4 x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:              pod.write %[[VAL_7]][@comp] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_15]], %[[VAL_30]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_31]] -> (!felt.type<"bn128">) {
// CHECK-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:              struct.writem %[[VAL_1]][@outp] = %[[VAL_34]] : <@SubCmps3::@SubCmps3<[]>>, !felt.type<"bn128">
// CHECK-NEXT:              scf.yield %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              scf.yield %[[VAL_16]] : !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_15]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_36]], %[[VAL_32]], %[[VAL_17]] : !felt.type<"bn128">, !felt.type<"bn128">, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_1]][@s$inputs] = %[[VAL_9]]#2 : <@SubCmps3::@SubCmps3<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_37]] : <@SubCmps3::@SubCmps3<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          function.return %[[VAL_1]] : !struct.type<@SubCmps3::@SubCmps3<[]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_38:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps3::@SubCmps3<[]>>, %[[VAL_39:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@outp] : <@SubCmps3::@SubCmps3<[]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@s] : <@SubCmps3::@SubCmps3<[]>>, !struct.type<@Sum::@Sum<[4]>>
// CHECK-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@s$inputs] : <@SubCmps3::@SubCmps3<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_43]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[4]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_48:[0-9a-zA-Z_\.]+]] = %[[VAL_46]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CHECK-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_48]], %[[VAL_49]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_50]]) %[[VAL_48]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_51:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_39]]{{\[}}%[[VAL_52]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_51]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_55]]] : <4 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            constrain.eq %[[VAL_56]], %[[VAL_53]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CHECK-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_51]], %[[VAL_57]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_58]] {
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_41]][@outp] : <@Sum::@Sum<[4]>>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_40]], %[[VAL_59]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_51]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_61]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@inp] : <[@inp: !array.type<4 x !felt.type<"bn128">>]>, !array.type<4 x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_41]], %[[VAL_62]]) : (!struct.type<@Sum::@Sum<[4]>>, !array.type<4 x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_63:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_69:[0-9a-zA-Z_\.]+]] = %[[VAL_67]], %[[VAL_70:[0-9a-zA-Z_\.]+]] = %[[VAL_66]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_69]], %[[VAL_65]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_71]]) %[[VAL_69]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_72:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_73:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_74]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_73]], %[[VAL_75]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_72]], %[[VAL_77]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_78]], %[[VAL_76]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_64]][@outp] = %[[VAL_68]]#1 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_64]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_79:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_80:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_79]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_86:[0-9a-zA-Z_\.]+]] = %[[VAL_84]], %[[VAL_87:[0-9a-zA-Z_\.]+]] = %[[VAL_83]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_86]], %[[VAL_81]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_88]]) %[[VAL_86]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_89:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_90:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_80]]{{\[}}%[[VAL_91]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_90]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_89]], %[[VAL_94]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_95]], %[[VAL_93]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_82]], %[[VAL_85]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
