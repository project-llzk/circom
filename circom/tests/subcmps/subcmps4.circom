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

// CHECK-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@SubCmps4::@SubCmps4<[3]>>} {
// CHECK-NEXT:    poly.template @SubCmps4 {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      poly.expr @"n_Mul_2@443" {
// CHECK-NEXT:        %[[VAL_0:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:        %[[VAL_1:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:        %[[VAL_2:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_1]] : index, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_3:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_2]], %[[VAL_0]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:        %[[VAL_4:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_3]] : !felt.type<"bn128">
// CHECK-NEXT:        poly.yield %[[VAL_4]] : index
// CHECK-NEXT:      }
// CHECK-NEXT:      struct.def @SubCmps4 {
// CHECK-NEXT:        struct.member @outp : !array.type<2 x !felt.type<"bn128">> {llzk.pub, signal}
// CHECK-NEXT:        struct.member @a : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        struct.member @a$inputs : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        struct.member @b : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        struct.member @b$inputs : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]> {signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_2@443" x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@SubCmps4::@SubCmps4<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps4::@SubCmps4<[@n]>>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@443" : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_9]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_14]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_16]], @params = %[[VAL_15]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_18]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_20]], @params = %[[VAL_19]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]]:3 = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_25:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_27]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_26]], %[[VAL_28]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_29]]) %[[VAL_24]], %[[VAL_25]], %[[VAL_26]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_30:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, %[[VAL_31:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_32]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_34]], %[[VAL_35]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]]:2 = scf.if %[[VAL_36]] -> (!pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>) {
// CHECK-NEXT:              %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_38]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_32]], %[[VAL_41]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_40]]{{\[}}%[[VAL_43]]] = %[[VAL_39]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_30]][@inp] = %[[VAL_40]] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_44]], %[[VAL_45]] : index
// CHECK-NEXT:              pod.write %[[VAL_17]][@count] = %[[VAL_46]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:              scf.if %[[VAL_48]] {
// CHECK-NEXT:                %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:                %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_50]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:                pod.write %[[VAL_17]][@comp] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_30]], %[[VAL_31]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_52:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_53:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_52]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_32]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_56]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_54]]{{\[}}%[[VAL_57]]] = %[[VAL_53]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_31]][@inp] = %[[VAL_54]] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_58]], %[[VAL_59]] : index
// CHECK-NEXT:              pod.write %[[VAL_21]][@count] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, index
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_60]], %[[VAL_61]] : index
// CHECK-NEXT:              scf.if %[[VAL_62]] {
// CHECK-NEXT:                %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !pod.type<[@n: index]>
// CHECK-NEXT:                %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_31]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_64]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:                pod.write %[[VAL_21]][@comp] = %[[VAL_65]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_30]], %[[VAL_31]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_67:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_32]], %[[VAL_66]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_37]]#0, %[[VAL_37]]#1, %[[VAL_67]] : !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_71]]] = %[[VAL_69]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_75]]] = %[[VAL_73]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_6]][@a$inputs] = %[[VAL_23]]#0 : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@a] = %[[VAL_76]] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@b$inputs] = %[[VAL_23]]#1 : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@b] = %[[VAL_77]] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@outp] = %[[VAL_11]] : <@SubCmps4::@SubCmps4<[@n]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_6]] : !struct.type<@SubCmps4::@SubCmps4<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_78:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps4::@SubCmps4<[@n]>>, %[[VAL_79:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_2@443" x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_80]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@443" : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_82]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@outp] : <@SubCmps4::@SubCmps4<[@n]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@a] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@a$inputs] : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@b] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_78]][@b$inputs] : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_89]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_92]] }  : <[@n: index]>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: index]>]>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_97:[0-9a-zA-Z_\.]+]] = %[[VAL_95]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_81]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_97]], %[[VAL_99]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_100]]) %[[VAL_97]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_101:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_101]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_103]], %[[VAL_104]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_105]] {
// CHECK-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_106]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_101]], %[[VAL_109]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_110]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_108]]{{\[}}%[[VAL_111]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_112]], %[[VAL_107]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_79]]{{\[}}%[[VAL_113]]] : <@"n_Mul_2@443" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_101]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_117]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_115]]{{\[}}%[[VAL_118]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_119]], %[[VAL_114]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_101]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_85]], %[[VAL_122]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_87]], %[[VAL_123]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_124:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_126]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_131:[0-9a-zA-Z_\.]+]] = %[[VAL_129]], %[[VAL_132:[0-9a-zA-Z_\.]+]] = %[[VAL_128]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_133:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_131]], %[[VAL_127]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_133]]) %[[VAL_131]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_134:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_135:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_136:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_134]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_124]]{{\[}}%[[VAL_136]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_135]], %[[VAL_137]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_134]], %[[VAL_139]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_140]], %[[VAL_138]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_125]][@outp] = %[[VAL_130]]#1 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_125]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_141:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_142:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_143]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_141]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_149:[0-9a-zA-Z_\.]+]] = %[[VAL_147]], %[[VAL_150:[0-9a-zA-Z_\.]+]] = %[[VAL_146]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_151:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_149]], %[[VAL_144]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_151]]) %[[VAL_149]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_152:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_153:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_152]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_142]]{{\[}}%[[VAL_154]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_153]], %[[VAL_155]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_152]], %[[VAL_157]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_158]], %[[VAL_156]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_145]], %[[VAL_148]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
