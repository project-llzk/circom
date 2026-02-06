// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmps3<[]>>} {
// CHECK-NEXT:    struct.def @SubCmps3<[]> {
// CHECK-NEXT:      struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      struct.member @s : !struct.type<@Sum<[4]>>
// CHECK-NEXT:      struct.member @s$inputs : !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:      function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) -> !struct.type<@SubCmps3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps3<[]>>
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !felt.type
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = arith.constant 4 : index
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_3]] }  : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>
// CHECK-NEXT:        %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_7:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_8:[0-9a-zA-Z_\.]+]] = %[[VAL_6]], %[[VAL_9:[0-9a-zA-Z_\.]+]] = %[[VAL_2]], %[[VAL_10:[0-9a-zA-Z_\.]+]] = %[[VAL_5]]) : (!felt.type, !felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>) -> (!felt.type, !felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>) {
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_8]], %[[VAL_11]])
// CHECK-NEXT:          scf.condition(%[[VAL_12]]) %[[VAL_8]], %[[VAL_9]], %[[VAL_10]] : !felt.type, !felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_13:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_14:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_15:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<4 x !felt.type>]>):
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_0]]{{\[}}%[[VAL_16]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_13]]
// CHECK-NEXT:          array.write %[[VAL_18]]{{\[}}%[[VAL_19]]] = %[[VAL_17]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          pod.write %[[VAL_15]][@inp] = %[[VAL_18]] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@count] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_20]], %[[VAL_21]] : index
// CHECK-NEXT:          pod.write %[[VAL_4]][@count] = %[[VAL_22]] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, index
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_22]], %[[VAL_23]] : index
// CHECK-NEXT:          scf.if %[[VAL_24]] {
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_15]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = function.call @Sum::@compute(%[[VAL_25]]) : (!array.type<4 x !felt.type>) -> !struct.type<@Sum<[4]>>
// CHECK-NEXT:            pod.write %[[VAL_4]][@comp] = %[[VAL_26]] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_13]], %[[VAL_27]])
// CHECK-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = scf.if %[[VAL_28]] -> (!felt.type) {
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@outp] : <@Sum<[4]>>, !felt.type
// CHECK-NEXT:            struct.writem %[[VAL_1]][@outp] = %[[VAL_31]] : <@SubCmps3<[]>>, !felt.type
// CHECK-NEXT:            scf.yield %[[VAL_31]] : !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:            scf.yield %[[VAL_14]] : !felt.type
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_13]], %[[VAL_32]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_33]], %[[VAL_29]], %[[VAL_15]] : !felt.type, !felt.type, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_1]][@s$inputs] = %[[VAL_7]]#2 : <@SubCmps3<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@comp] : <[@count: index, @comp: !struct.type<@Sum<[4]>>, @params: !pod.type<[]>]>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:        struct.writem %[[VAL_1]][@s] = %[[VAL_34]] : <@SubCmps3<[]>>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:        function.return %[[VAL_1]] : !struct.type<@SubCmps3<[]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_35:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps3<[]>>, %[[VAL_36:[0-9a-zA-Z_\.]+]]: !array.type<4 x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@outp] : <@SubCmps3<[]>>, !felt.type
// CHECK-NEXT:        %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@s] : <@SubCmps3<[]>>, !struct.type<@Sum<[4]>>
// CHECK-NEXT:        %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_35]][@s$inputs] : <@SubCmps3<[]>>, !pod.type<[@inp: !array.type<4 x !felt.type>]>
// CHECK-NEXT:        %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_41:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_42:[0-9a-zA-Z_\.]+]] = %[[VAL_40]]) : (!felt.type) -> !felt.type {
// CHECK-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  4
// CHECK-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_42]], %[[VAL_43]])
// CHECK-NEXT:          scf.condition(%[[VAL_44]]) %[[VAL_42]] : !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_45:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]]
// CHECK-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_36]]{{\[}}%[[VAL_46]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_45]]
// CHECK-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_48]]{{\[}}%[[VAL_49]]] : <4 x !felt.type>, !felt.type
// CHECK-NEXT:          constrain.eq %[[VAL_50]], %[[VAL_47]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  3
// CHECK-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_45]], %[[VAL_51]])
// CHECK-NEXT:          scf.if %[[VAL_52]] {
// CHECK-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_38]][@outp] : <@Sum<[4]>>, !felt.type
// CHECK-NEXT:            constrain.eq %[[VAL_37]], %[[VAL_53]] : !felt.type, !felt.type
// CHECK-NEXT:          } else {
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_45]], %[[VAL_54]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_55]] : !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@inp] : <[@inp: !array.type<4 x !felt.type>]>, !array.type<4 x !felt.type>
// CHECK-NEXT:        function.call @Sum::@constrain(%[[VAL_38]], %[[VAL_56]]) : (!struct.type<@Sum<[4]>>, !array.type<4 x !felt.type>) -> ()
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    struct.def @Sum<[@n]> {
// CHECK-NEXT:      struct.member @outp : !felt.type {llzk.pub}
// CHECK-NEXT:      function.def @compute(%[[VAL_57:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) -> !struct.type<@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:        %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum<[@n]>>
// CHECK-NEXT:        %[[VAL_59:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_62:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_63:[0-9a-zA-Z_\.]+]] = %[[VAL_61]], %[[VAL_64:[0-9a-zA-Z_\.]+]] = %[[VAL_60]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_63]], %[[VAL_59]])
// CHECK-NEXT:          scf.condition(%[[VAL_65]]) %[[VAL_63]], %[[VAL_64]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_67:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]]
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_57]]{{\[}}%[[VAL_68]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_67]], %[[VAL_69]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_66]], %[[VAL_71]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_72]], %[[VAL_70]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        struct.writem %[[VAL_58]][@outp] = %[[VAL_62]]#1 : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        function.return %[[VAL_58]] : !struct.type<@Sum<[@n]>>
// CHECK-NEXT:      }
// CHECK-NEXT:      function.def @constrain(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum<[@n]>>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:        %[[VAL_75:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type
// CHECK-NEXT:        %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@outp] : <@Sum<[@n]>>, !felt.type
// CHECK-NEXT:        %[[VAL_77:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  0
// CHECK-NEXT:        %[[VAL_79:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_80:[0-9a-zA-Z_\.]+]] = %[[VAL_78]], %[[VAL_81:[0-9a-zA-Z_\.]+]] = %[[VAL_77]]) : (!felt.type, !felt.type) -> (!felt.type, !felt.type) {
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_80]], %[[VAL_75]])
// CHECK-NEXT:          scf.condition(%[[VAL_82]]) %[[VAL_80]], %[[VAL_81]] : !felt.type, !felt.type
// CHECK-NEXT:        } do {
// CHECK-NEXT:        ^bb0(%[[VAL_83:[0-9a-zA-Z_\.]+]]: !felt.type, %[[VAL_84:[0-9a-zA-Z_\.]+]]: !felt.type):
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_83]]
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_74]]{{\[}}%[[VAL_85]]] : <@n x !felt.type>, !felt.type
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_84]], %[[VAL_86]] : !felt.type, !felt.type
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  1
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_83]], %[[VAL_88]] : !felt.type, !felt.type
// CHECK-NEXT:          scf.yield %[[VAL_89]], %[[VAL_87]] : !felt.type, !felt.type
// CHECK-NEXT:        }
// CHECK-NEXT:        constrain.eq %[[VAL_76]], %[[VAL_79]]#1 : !felt.type, !felt.type
// CHECK-NEXT:        function.return
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
