// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus Bus1(){
    signal a[5];
    signal {tag1} b[3];
}

bus Bus2(){
    signal {tag2} a;
    Bus1() {tag3} b[2];
}

template C(){
    input Bus1() {tag3} in;

    in.b.tag1 === 3;
}

template B(){
    Bus2() input {tag4} in;
    Bus1() output out <== in.b[1];

    in.b.tag3 === 5;
    C()(in.b[1]);

    in.tag4 === 99;
}

template A(){
    signal input a[5];

    Bus1() {tag3} aux1[2];
    aux1.tag3 = 5;
    aux1[0].a <== a;
    aux1[1].a <== a;

    signal {tag1} s;
    s.tag1 = 3;
    s <== 1;

    signal {tag1} s2;
    s2.tag1 = 3;
    s2 <== 2;

    for (var i = 0; i < 3; i++){
        aux1[0].b[i] <== s;
        aux1[1].b[i] <== s2;
    }

    Bus2() {tag4} aux;
    aux.tag4 = 99;

    signal {tag2} s1;
    s1.tag2 = 7;
    s1 <== 99;

    aux.a <== s1;
    aux.b <== aux1;

    Bus1 output out <== B()(aux);
}

component main = A();

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_2::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_2 {
// CONCRETE-NEXT:      struct.def @A_2 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>> {signal}
// CONCRETE-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @s2 : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {signal}
// CONCRETE-NEXT:        struct.member @s1 : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@A_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_8]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_9]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_10]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_9]]] = %[[VAL_10]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_13]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_14]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_13]]] = %[[VAL_14]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_16]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s2] = %[[VAL_17]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_20:[0-9a-zA-Z_\.]+]] = %[[VAL_18]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_20]], %[[VAL_21]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_22]]) %[[VAL_20]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_23:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_24]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_25]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_26]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_27]]{{\[}}%[[VAL_28]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_27]]{{\[}}%[[VAL_28]]] = %[[VAL_16]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_26]][@b] = %[[VAL_27]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_25]]] = %[[VAL_26]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_30]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_31]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_23]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_33]]{{\[}}%[[VAL_34]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_33]]{{\[}}%[[VAL_34]]] = %[[VAL_17]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_32]][@b] = %[[VAL_33]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_31]]] = %[[VAL_32]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_23]], %[[VAL_36]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_37]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_38]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_38]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_42]], %[[VAL_43]] : index
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_44]], %[[VAL_45]], %[[VAL_43]] : index
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_46]], %[[VAL_47]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_48]] {
// CONCRETE-NEXT:            %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:            %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_49]], %[[VAL_50]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_51]], %[[VAL_52]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_53]] {
// CONCRETE-NEXT:              %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:              %[[VAL_56:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_55]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_57]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_58]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_7]] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_59]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A_2::@A_2<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_60:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@A_2<[]>>, %[[VAL_61:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@aux1] : <@A_2::@A_2<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@s] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@s2] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@aux] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@s1] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@B_[[MEMBER0]]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@B_[[MEMBER0]]$inputs] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_70]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_71]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_73]], %[[VAL_61]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_75]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_77]], %[[VAL_61]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_64]], %[[VAL_78]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_79]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_82:[0-9a-zA-Z_\.]+]] = %[[VAL_80]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_84:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_82]], %[[VAL_83]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_84]]) %[[VAL_82]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_86:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_86]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_87]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_89]]{{\[}}%[[VAL_90]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_91]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_93]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_95]]{{\[}}%[[VAL_96]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_97]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_85]], %[[VAL_98]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_99]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_67]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_101]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_106:[0-9a-zA-Z_\.]+]] = %[[VAL_104]] to %[[VAL_103]] step %[[VAL_105]] {
// CONCRETE-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_102]]{{\[}}%[[VAL_106]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_63]]{{\[}}%[[VAL_106]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_109]], %[[VAL_110]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_107]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_111]], %[[VAL_112]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_114]], %[[VAL_115]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_66]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_121:[0-9a-zA-Z_\.]+]] = %[[VAL_119]] to %[[VAL_118]] step %[[VAL_120]] {
// CONCRETE-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_121]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_121]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_124]], %[[VAL_125]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_126]], %[[VAL_127]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_68]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_129]], %[[VAL_130]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_62]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_131]], %[[VAL_132]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_68]], %[[VAL_133]]) : (!struct.type<@B_1::@B_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_134:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute(%[[VAL_134]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_135]][@"$component"] = %[[VAL_136]] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_136]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_135]][@out.a] = %[[VAL_138]] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_135]][@out.b] = %[[VAL_139]] : <@A_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_135]] : !struct.type<@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_140:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@"$bus_entry"<[]>>, %[[VAL_141:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_140]][@"$component"] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          function.call @A_2::@A_2::@constrain(%[[VAL_142]], %[[VAL_141]]) : (!struct.type<@A_2::@A_2<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_140]][@out.a] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_140]][@out.b] : <@A_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_142]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_143]], @b = %[[VAL_144]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_147]], %[[VAL_148]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_145]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_149]], %[[VAL_150]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:        struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_151:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_154]], @params = %[[VAL_153]] }  : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_158]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_157]]{{\[}}%[[VAL_159]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_152]][@out] = %[[VAL_160]] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_151]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_162]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_161]]{{\[}}%[[VAL_163]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_156]][@in] = %[[VAL_164]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@count] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_166]], %[[VAL_167]] : index
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_168]], %[[VAL_169]], %[[VAL_167]] : index
// CONCRETE-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_170]], %[[VAL_171]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_172]] {
// CONCRETE-NEXT:            %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@count] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_174:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:            %[[VAL_175:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_173]], %[[VAL_174]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_155]][@count] = %[[VAL_175]] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_176:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_175]], %[[VAL_176]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_177]] {
// CONCRETE-NEXT:              %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@params] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:              %[[VAL_180:[0-9a-zA-Z_\.]+]] = function.call @C_0::@C_0::@compute(%[[VAL_179]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_155]][@comp] = %[[VAL_180]] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_152]][@C_[[MEMBER1]]$inputs] = %[[VAL_156]] : <@B_1::@B_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@comp] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_152]][@C_[[MEMBER1]]] = %[[VAL_181]] : <@B_1::@B_1<[]>>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_152]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_182:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_183:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_182]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_182]][@C_[[MEMBER1]]] : <@B_1::@B_1<[]>>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_182]][@C_[[MEMBER1]]$inputs] : <@B_1::@B_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_183]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_188]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_187]]{{\[}}%[[VAL_189]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_191]], %[[VAL_192]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_184]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_193]], %[[VAL_194]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_195]], %[[VAL_196]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_183]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_198]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_197]]{{\[}}%[[VAL_199]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_201]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_202]], %[[VAL_203]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_201]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_204]], %[[VAL_205]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_206]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @C_0::@C_0::@constrain(%[[VAL_185]], %[[VAL_208]]) : (!struct.type<@C_0::@C_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @C_0 {
// CONCRETE-NEXT:      struct.def @C_0 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_209:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@C_0::@C_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = struct.new : <@C_0::@C_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_210]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_211:[0-9a-zA-Z_\.]+]]: !struct.type<@C_0::@C_0<[]>>, %[[VAL_212:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_213]], %[[VAL_214]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>> {signal}
// TEMPLATED-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @s2 : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {signal}
// TEMPLATED-NEXT:        struct.member @s1 : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_5]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_6]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_7]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_6]]] = %[[VAL_7]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_9]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_10]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_11]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_10]]] = %[[VAL_11]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_13]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s2] = %[[VAL_14]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_17:[0-9a-zA-Z_\.]+]] = %[[VAL_15]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_17]], %[[VAL_18]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_19]]) %[[VAL_17]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_20:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_22]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_23]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_24]]{{\[}}%[[VAL_25]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_24]]{{\[}}%[[VAL_25]]] = %[[VAL_13]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_23]][@b] = %[[VAL_24]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_22]]] = %[[VAL_23]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_28]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_20]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_30]]{{\[}}%[[VAL_31]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_30]]{{\[}}%[[VAL_31]]] = %[[VAL_14]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_29]][@b] = %[[VAL_30]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_28]]] = %[[VAL_29]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_20]], %[[VAL_33]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_34]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_35]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_35]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$a$tag2" = %[[VAL_38]], @"$tag$in$b$b$tag1" = %[[VAL_39]], @"$tag$in$b$tag3" = %[[VAL_40]], @"$tag$in$tag4" = %[[VAL_41]] }  : <[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_43]], @params = %[[VAL_42]] }  : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_46]], %[[VAL_47]] : index
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_48]], %[[VAL_49]], %[[VAL_47]] : index
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_50]], %[[VAL_51]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_52]] {
// TEMPLATED-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_53]], %[[VAL_54]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_44]][@count] = %[[VAL_55]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_55]], %[[VAL_56]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_57]] {
// TEMPLATED-NEXT:              %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_59]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_44]][@comp] = %[[VAL_60]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_61]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_62]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_4]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_63]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_64:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_65:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@aux1] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@s] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@s2] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@aux] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@s1] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_64]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_74]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_75]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_76]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_77]], %[[VAL_65]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_78]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_79]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_80]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_81]], %[[VAL_65]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_67]], %[[VAL_82]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_68]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_86:[0-9a-zA-Z_\.]+]] = %[[VAL_84]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_86]], %[[VAL_87]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_88]]) %[[VAL_86]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_89:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_90]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_91]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_93]]{{\[}}%[[VAL_94]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_95]], %[[VAL_67]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_97]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_99]]{{\[}}%[[VAL_100]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_101]], %[[VAL_68]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_89]], %[[VAL_102]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_103]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_70]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_105]], %[[VAL_70]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_110:[0-9a-zA-Z_\.]+]] = %[[VAL_108]] to %[[VAL_107]] step %[[VAL_109]] {
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_106]]{{\[}}%[[VAL_110]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_66]]{{\[}}%[[VAL_110]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_113]], %[[VAL_114]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_112]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_115]], %[[VAL_116]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_118]], %[[VAL_119]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_69]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_125:[0-9a-zA-Z_\.]+]] = %[[VAL_123]] to %[[VAL_122]] step %[[VAL_124]] {
// TEMPLATED-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_120]]{{\[}}%[[VAL_125]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_125]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_128]], %[[VAL_129]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_130]], %[[VAL_131]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_72]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_133]], %[[VAL_134]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_71]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_132]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_135]], %[[VAL_136]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_72]], %[[VAL_137]]) : (!struct.type<@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_138:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_138]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_139]][@"$component"] = %[[VAL_140]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_140]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_139]][@out.a] = %[[VAL_142]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_139]][@out.b] = %[[VAL_143]] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_139]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_144:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_145:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_144]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_146]], %[[VAL_145]]) : (!struct.type<@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_144]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_144]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_146]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_147]], @b = %[[VAL_148]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_151]], %[[VAL_152]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_149]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_150]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_153]], %[[VAL_154]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.param @"$tag$in$a$tag2"
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$b$tag1"
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$tag3"
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag4"
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:        struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_155:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_163]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_162]]{{\[}}%[[VAL_164]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_156]][@out] = %[[VAL_165]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$b$tag1" = %[[VAL_166]], @"$tag$in$tag3" = %[[VAL_167]] }  : <[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_169]], @params = %[[VAL_168]] }  : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_155]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_172]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_171]]{{\[}}%[[VAL_173]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_161]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_161]][@in] = %[[VAL_174]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_176]], %[[VAL_177]] : index
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_178]], %[[VAL_179]], %[[VAL_177]] : index
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_180]], %[[VAL_181]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_182]] {
// TEMPLATED-NEXT:            %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// TEMPLATED-NEXT:            %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_183]], %[[VAL_184]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_170]][@count] = %[[VAL_185]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_185]], %[[VAL_186]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_187]] {
// TEMPLATED-NEXT:              %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@params] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_161]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_190:[0-9a-zA-Z_\.]+]] = function.call @C::@C::@compute(%[[VAL_189]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_170]][@comp] = %[[VAL_190]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_156]][@C_[[MEMBER1]]$inputs] = %[[VAL_161]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_170]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_156]][@C_[[MEMBER1]]] = %[[VAL_191]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          function.return %[[VAL_156]] : !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_192:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, %[[VAL_193:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_192]][@out] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_192]][@C_[[MEMBER1]]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_192]][@C_[[MEMBER1]]$inputs] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_201]]{{\[}}%[[VAL_203]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_205]], %[[VAL_206]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_198]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_207]], %[[VAL_208]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_196]], %[[VAL_209]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_213]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_212]]{{\[}}%[[VAL_214]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_217]], %[[VAL_218]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_219]], %[[VAL_220]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_197]], %[[VAL_221]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.call @C::@C::@constrain(%[[VAL_199]], %[[VAL_222]]) : (!struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @C {
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$tag1"
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag3"
// TEMPLATED-NEXT:      struct.def @C {
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_223:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_224]] : !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_227:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>, %[[VAL_228:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_229]], %[[VAL_231]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
