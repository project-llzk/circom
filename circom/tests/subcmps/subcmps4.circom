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

template SubCmps4(n) {
    signal input inp[n*2];
    signal output outp[2];

    component a = Sum(n);
    component b = Sum(n);

    for (var i = 0; i < n*2; i++) {
        if (i % 2 == 0) {
            a.inp[i\2] <== inp[i];
        } else {
            b.inp[i\2] <== inp[i];
        }
    }
    outp[0] <-- a.outp;
    outp[1] <-- b.outp;
}

component main = SubCmps4(3);

// CHECK-LABEL: module attributes {llzk.lang, llzk.main = !struct.type<@SubCmps4::@SubCmps4<[3]>>} {
// CHECK-NEXT:    poly.template @SubCmps4 {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      poly.expr @"n_Mul_2@443" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_1]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_2]] : !felt.type<"bn128">
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @SubCmps4 {
// CHECK-NEXT:        struct.member @outp : !array.type<2 x !felt.type<"bn128">> {llzk.pub}
// CHECK-NEXT:        struct.member @a : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:        struct.member @b : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:        function.def @compute(%[[VAL_3:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_2@443" x !felt.type<"bn128">>) -> !struct.type<@SubCmps4::@SubCmps4<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps4::@SubCmps4<[@n]>>
// CHECK-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@443" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_10]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_12]], @params = %[[VAL_11]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_14]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_16]], @params = %[[VAL_15]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_8]], %[[VAL_21:[0-9a-zA-Z_\.]+]] = %[[VAL_9]], %[[VAL_22:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_5]], %[[VAL_23]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_22]], %[[VAL_24]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_25]]) %[[VAL_20]], %[[VAL_21]], %[[VAL_22]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_26:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, %[[VAL_27:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, %[[VAL_28:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_28]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_30]], %[[VAL_31]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_32]] -> (!pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>) {
// CHECK-NEXT:              %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_34]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_28]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_36]]{{\[}}%[[VAL_39]]] = %[[VAL_35]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_26]][@inp] = %[[VAL_36]] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_40]], %[[VAL_41]] : index
// CHECK-NEXT:              pod.write %[[VAL_13]][@count] = %[[VAL_42]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_42]], %[[VAL_43]] : index
// CHECK-NEXT:              scf.if %[[VAL_44]] {
// CHECK-NEXT:                %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:                %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_47:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_46]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:                pod.write %[[VAL_13]][@comp] = %[[VAL_47]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_26]], %[[VAL_27]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_48]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_51:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_28]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_52]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_50]]{{\[}}%[[VAL_53]]] = %[[VAL_49]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_27]][@inp] = %[[VAL_50]] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_54]], %[[VAL_55]] : index
// CHECK-NEXT:              pod.write %[[VAL_17]][@count] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_56]], %[[VAL_57]] : index
// CHECK-NEXT:              scf.if %[[VAL_58]] {
// CHECK-NEXT:                %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:                %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_27]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_61:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_60]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:                pod.write %[[VAL_17]][@comp] = %[[VAL_61]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:              } else {
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_26]], %[[VAL_27]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_63:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_28]], %[[VAL_62]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_33]]#0, %[[VAL_33]]#1, %[[VAL_63]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_7]]{{\[}}%[[VAL_67]]] = %[[VAL_65]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_7]]{{\[}}%[[VAL_71]]] = %[[VAL_69]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_4]][@a$inputs] = %[[VAL_19]]#0 : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_13]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_4]][@a] = %[[VAL_72]] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_4]][@b$inputs] = %[[VAL_19]]#1 : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_4]][@b] = %[[VAL_73]] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_4]][@outp] = %[[VAL_7]] : <@SubCmps4::@SubCmps4<[@n]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_4]] : !struct.type<@SubCmps4::@SubCmps4<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_74:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps4::@SubCmps4<[@n]>>, %[[VAL_75:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_2@443" x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@443" : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@outp] : <@SubCmps4::@SubCmps4<[@n]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@a] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@a$inputs] : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@b] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@b$inputs] : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_83]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_85]], @params = %[[VAL_84]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_87]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_89]], @params = %[[VAL_88]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_93:[0-9a-zA-Z_\.]+]] = %[[VAL_91]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_76]], %[[VAL_94]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_93]], %[[VAL_95]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_96]]) %[[VAL_93]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_97:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_97]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_99]], %[[VAL_100]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_101]] {
// CHECK-NEXT:              %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_102]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_97]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_106]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_104]]{{\[}}%[[VAL_107]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_108]], %[[VAL_103]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_75]]{{\[}}%[[VAL_109]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_97]], %[[VAL_112]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_114]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_115]], %[[VAL_110]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_97]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_79]], %[[VAL_118]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_81]], %[[VAL_119]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub}
// CHECK-NEXT:        function.def @compute(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_126:[0-9a-zA-Z_\.]+]] = %[[VAL_124]], %[[VAL_127:[0-9a-zA-Z_\.]+]] = %[[VAL_123]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_126]], %[[VAL_122]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_128]]) %[[VAL_126]], %[[VAL_127]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_129:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_130:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_129]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_131]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_130]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_129]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_135]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_121]][@outp] = %[[VAL_125]]#1 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_121]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_136:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_137:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">>) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = poly.read_const @n : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_143:[0-9a-zA-Z_\.]+]] = %[[VAL_141]], %[[VAL_144:[0-9a-zA-Z_\.]+]] = %[[VAL_140]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_143]], %[[VAL_138]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_145]]) %[[VAL_143]], %[[VAL_144]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_146:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_147:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_146]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_149:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_148]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_147]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_146]], %[[VAL_151]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_152]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_139]], %[[VAL_142]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
