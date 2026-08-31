// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
// CHECK-NEXT:      poly.expr @"n_Mul_2@[[OFFSET0:[0-9]+]]" {
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
// CHECK-NEXT:        function.def @compute(%[[VAL_5:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_2@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@SubCmps4::@SubCmps4<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = struct.new : <@SubCmps4::@SubCmps4<[@n]>>
// CHECK-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_7]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_9]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.new : <[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_14]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_15]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_17]], @params = %[[VAL_16]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_19]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_20]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_22]], @params = %[[VAL_21]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]]:5 = scf.while (%[[VAL_18_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_18]], %[[VAL_26:[0-9a-zA-Z_\.]+]] = %[[VAL_12]], %[[VAL_23_IN:[0-9a-zA-Z_\.]+]] = %[[VAL_23]], %[[VAL_27:[0-9a-zA-Z_\.]+]] = %[[VAL_13]], %[[VAL_28:[0-9a-zA-Z_\.]+]] = %[[VAL_24]]) : (!pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) -> (!pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_8]], %[[VAL_29]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_28]], %[[VAL_30]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_31]]) %[[VAL_18_IN]], %[[VAL_26]], %[[VAL_23_IN]], %[[VAL_27]], %[[VAL_28]] : !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_18_LCV:[0-9a-zA-Z_\.]+]]: !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, %[[VAL_32:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, %[[VAL_23_LCV:[0-9a-zA-Z_\.]+]]: !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, %[[VAL_33:[0-9a-zA-Z_\.]+]]: !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_34]], %[[VAL_35]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_36]], %[[VAL_37]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]]:4 = scf.if %[[VAL_38]] -> (!pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>) {
// CHECK-NEXT:              %[[VAL_40:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_41:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_40]]] : <@"n_Mul_2@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_34]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_42]]{{\[}}%[[VAL_45]]] = %[[VAL_41]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_32]][@inp] = %[[VAL_42]] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18_LCV]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_46]], %[[VAL_47]] : index
// CHECK-NEXT:              pod.write %[[VAL_18_LCV]][@count] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CHECK-NEXT:              scf.if %[[VAL_50]] {
// CHECK-NEXT:                %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18_LCV]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_53:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_52]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:                pod.write %[[VAL_18_LCV]][@comp] = %[[VAL_53]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_18_LCV]], %[[VAL_32]], %[[VAL_23_LCV]], %[[VAL_33]] : !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_5]]{{\[}}%[[VAL_54]]] : <@"n_Mul_2@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_34]], %[[VAL_57]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_58]] : !felt.type<"bn128">
// CHECK-NEXT:              array.write %[[VAL_56]]{{\[}}%[[VAL_59]]] = %[[VAL_55]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              pod.write %[[VAL_33]][@inp] = %[[VAL_56]] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23_LCV]][@count] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CHECK-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_60]], %[[VAL_61]] : index
// CHECK-NEXT:              pod.write %[[VAL_23_LCV]][@count] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, index
// CHECK-NEXT:              %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CHECK-NEXT:              %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_62]], %[[VAL_63]] : index
// CHECK-NEXT:              scf.if %[[VAL_64]] {
// CHECK-NEXT:                %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23_LCV]][@params] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@n: !felt.type<"bn128">]>
// CHECK-NEXT:                %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_33]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:                %[[VAL_67:[0-9a-zA-Z_\.]+]] = function.call @Sum::@Sum::@compute(%[[VAL_66]]) : (!array.type<@n x !felt.type<"bn128">>) -> !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:                pod.write %[[VAL_23_LCV]][@comp] = %[[VAL_67]] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:              }
// CHECK-NEXT:              scf.yield %[[VAL_18_LCV]], %[[VAL_32]], %[[VAL_23_LCV]], %[[VAL_33]] : !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_34]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_39]]#0, %[[VAL_39]]#1, %[[VAL_39]]#2, %[[VAL_39]]#3, %[[VAL_69]] : !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !pod.type<[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]]#0[@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_70]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_72]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_73]]] = %[[VAL_71]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]]#2[@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CHECK-NEXT:          array.write %[[VAL_11]]{{\[}}%[[VAL_77]]] = %[[VAL_75]] : <2 x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:          struct.writem %[[VAL_6]][@a$inputs] = %[[VAL_25]]#1 : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]]#0[@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@a] = %[[VAL_78]] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@b$inputs] = %[[VAL_25]]#3 : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_25]]#2[@comp] : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@b] = %[[VAL_79]] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          struct.writem %[[VAL_6]][@outp] = %[[VAL_11]] : <@SubCmps4::@SubCmps4<[@n]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          function.return %[[VAL_6]] : !struct.type<@SubCmps4::@SubCmps4<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !struct.type<@SubCmps4::@SubCmps4<[@n]>>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<@"n_Mul_2@[[OFFSET0]]" x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_82]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = poly.read_const @"n_Mul_2@[[OFFSET0]]" : index
// CHECK-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_84]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@outp] : <@SubCmps4::@SubCmps4<[@n]>>, !array.type<2 x !felt.type<"bn128">>
// CHECK-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@a] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@a$inputs] : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@b] : <@SubCmps4::@SubCmps4<[@n]>>, !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@b$inputs] : <@SubCmps4::@SubCmps4<[@n]>>, !pod.type<[@inp: !array.type<@n x !felt.type<"bn128">>]>
// CHECK-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_91]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_92]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_95]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.new { @n = %[[VAL_96]] }  : <[@n: !felt.type<"bn128">]>
// CHECK-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.new : <[@count: index, @comp: !struct.type<@Sum::@Sum<[@n]>>, @params: !pod.type<[@n: !felt.type<"bn128">]>]>
// CHECK-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_99]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CHECK-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.mul %[[VAL_83]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_101]], %[[VAL_103]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_104]]) %[[VAL_101]] : !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_105:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.umod %[[VAL_105]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = bool.cmp eq(%[[VAL_107]], %[[VAL_108]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.if %[[VAL_109]] {
// CHECK-NEXT:              %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_110]]] : <@"n_Mul_2@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_105]], %[[VAL_113]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_112]]{{\[}}%[[VAL_115]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_116]], %[[VAL_111]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            } else {
// CHECK-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_81]]{{\[}}%[[VAL_117]]] : <@"n_Mul_2@[[OFFSET0]]" x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:              %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CHECK-NEXT:              %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.uintdiv %[[VAL_105]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_121]] : !felt.type<"bn128">
// CHECK-NEXT:              %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_119]]{{\[}}%[[VAL_122]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:              constrain.eq %[[VAL_123]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            }
// CHECK-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_105]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_125]] : !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_87]], %[[VAL_126]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@inp] : <[@inp: !array.type<@n x !felt.type<"bn128">>]>, !array.type<@n x !felt.type<"bn128">>
// CHECK-NEXT:          function.call @Sum::@Sum::@constrain(%[[VAL_89]], %[[VAL_127]]) : (!struct.type<@Sum::@Sum<[@n]>>, !array.type<@n x !felt.type<"bn128">>) -> ()
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:    poly.template @Sum {
// CHECK-NEXT:      poly.param @n : index
// CHECK-NEXT:      struct.def @Sum {
// CHECK-NEXT:        struct.member @outp : !felt.type<"bn128"> {llzk.pub, signal}
// CHECK-NEXT:        function.def @compute(%[[VAL_128:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "inp"}) -> !struct.type<@Sum::@Sum<[@n]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CHECK-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = struct.new : <@Sum::@Sum<[@n]>>
// CHECK-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_130]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_135:[0-9a-zA-Z_\.]+]] = %[[VAL_133]], %[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_132]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_135]], %[[VAL_131]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_137]]) %[[VAL_135]], %[[VAL_136]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_138:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_139:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_138]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_128]]{{\[}}%[[VAL_140]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_139]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_138]], %[[VAL_143]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_144]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          struct.writem %[[VAL_129]][@outp] = %[[VAL_134]]#1 : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          function.return %[[VAL_129]] : !struct.type<@Sum::@Sum<[@n]>>
// CHECK-NEXT:        }
// CHECK-NEXT:        function.def @constrain(%[[VAL_145:[0-9a-zA-Z_\.]+]]: !struct.type<@Sum::@Sum<[@n]>>, %[[VAL_146:[0-9a-zA-Z_\.]+]]: !array.type<@n x !felt.type<"bn128">> {function.arg_name = "inp"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CHECK-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = poly.read_const @n : index
// CHECK-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = cast.tofelt %[[VAL_147]] : index, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_145]][@outp] : <@Sum::@Sum<[@n]>>, !felt.type<"bn128">
// CHECK-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CHECK-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]]:2 = scf.while (%[[VAL_153:[0-9a-zA-Z_\.]+]] = %[[VAL_151]], %[[VAL_154:[0-9a-zA-Z_\.]+]] = %[[VAL_150]]) : (!felt.type<"bn128">, !felt.type<"bn128">) -> (!felt.type<"bn128">, !felt.type<"bn128">) {
// CHECK-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_153]], %[[VAL_148]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.condition(%[[VAL_155]]) %[[VAL_153]], %[[VAL_154]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          } do {
// CHECK-NEXT:          ^bb0(%[[VAL_156:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">, %[[VAL_157:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CHECK-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_156]] : !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_146]]{{\[}}%[[VAL_158]]] : <@n x !felt.type<"bn128">>, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_157]], %[[VAL_159]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CHECK-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_156]], %[[VAL_161]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:            scf.yield %[[VAL_162]], %[[VAL_160]] : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          }
// CHECK-NEXT:          constrain.eq %[[VAL_149]], %[[VAL_152]]#1 : !felt.type<"bn128">, !felt.type<"bn128">
// CHECK-NEXT:          function.return
// CHECK-NEXT:        }
// CHECK-NEXT:      }
// CHECK-NEXT:    }
// CHECK-NEXT:  }
