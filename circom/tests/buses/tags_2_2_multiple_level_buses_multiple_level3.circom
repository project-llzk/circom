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

    signal {tag1} s[3];
    s.tag1 = 3;
    s <== [2, 3, 4];
    aux1[0].b <== s;

    signal {tag1} s2[3];
    s2.tag1 = 3;
    s2 <== [12, 0, 0];
    aux1[1].b <== s2;

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
// CONCRETE-NEXT:        struct.member @s : !array.type<3 x !felt.type<"bn128">> {signal}
// CONCRETE-NEXT:        struct.member @s2 : !array.type<3 x !felt.type<"bn128">> {signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {signal}
// CONCRETE-NEXT:        struct.member @s1 : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@A_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_7]], @params = %[[VAL_6]] }  : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_11]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_12]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_11]]] = %[[VAL_12]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_15]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_16]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_15]]] = %[[VAL_16]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_20]]] = %[[VAL_18]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_23]]] = %[[VAL_21]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_25]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_4]]{{\[}}%[[VAL_26]]] = %[[VAL_24]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_28]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_29]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_29]][@b] = %[[VAL_4]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_28]]] = %[[VAL_29]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_32]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_33]]] = %[[VAL_31]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_35]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_36]]] = %[[VAL_34]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_38]] : !felt.type<"bn128">
// CONCRETE-NEXT:          array.write %[[VAL_5]]{{\[}}%[[VAL_39]]] = %[[VAL_37]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_41]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_42]][@b] = %[[VAL_5]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_41]]] = %[[VAL_42]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_44]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_44]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          pod.write %[[VAL_9]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_48]], %[[VAL_49]] : index
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_50]], %[[VAL_51]], %[[VAL_49]] : index
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_52]], %[[VAL_53]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_54]] {
// CONCRETE-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:            %[[VAL_57:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_55]], %[[VAL_56]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_8]][@count] = %[[VAL_57]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_58:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_59:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_57]], %[[VAL_58]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_59]] {
// CONCRETE-NEXT:              %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@params] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_9]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:              %[[VAL_62:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_61]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_8]][@comp] = %[[VAL_62]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_63]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_64]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_9]] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_65]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A_2::@A_2<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_4]] : <@A_2::@A_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s2] = %[[VAL_5]] : <@A_2::@A_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_66:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@A_2<[]>>, %[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@aux1] : <@A_2::@A_2<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@s] : <@A_2::@A_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@s2] : <@A_2::@A_2<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@aux] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@s1] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@B_[[MEMBER0]]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_66]][@B_[[MEMBER0]]$inputs] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_77]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_79]], %[[VAL_67]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_80]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_81]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_83]], %[[VAL_67]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_85]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_86]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_87]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_89]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_90]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_91]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  4 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_93]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_70]]{{\[}}%[[VAL_94]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_95]], %[[VAL_92]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_97]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_99]], %[[VAL_70]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  12 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_102]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_105]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_106]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_107]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_109]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_71]]{{\[}}%[[VAL_110]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_111]], %[[VAL_108]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_113]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_115]], %[[VAL_71]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_73]], %[[VAL_116]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_117]], %[[VAL_73]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_122:[0-9a-zA-Z_\.]+]] = %[[VAL_120]] to %[[VAL_119]] step %[[VAL_121]] {
// CONCRETE-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_118]]{{\[}}%[[VAL_122]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_69]]{{\[}}%[[VAL_122]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_125]], %[[VAL_126]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_123]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_127]], %[[VAL_128]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_130]], %[[VAL_131]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_72]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_137:[0-9a-zA-Z_\.]+]] = %[[VAL_135]] to %[[VAL_134]] step %[[VAL_136]] {
// CONCRETE-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_132]]{{\[}}%[[VAL_137]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_133]]{{\[}}%[[VAL_137]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_139]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_140]], %[[VAL_141]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_139]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_142]], %[[VAL_143]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_74]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_145]], %[[VAL_146]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_144]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_147]], %[[VAL_148]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_75]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_74]], %[[VAL_149]]) : (!struct.type<@B_1::@B_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_150:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute(%[[VAL_150]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_151]][@"$component"] = %[[VAL_152]] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_152]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_151]][@out.a] = %[[VAL_154]] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_151]][@out.b] = %[[VAL_155]] : <@A_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_151]] : !struct.type<@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_156:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@"$bus_entry"<[]>>, %[[VAL_157:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_156]][@"$component"] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          function.call @A_2::@A_2::@constrain(%[[VAL_158]], %[[VAL_157]]) : (!struct.type<@A_2::@A_2<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_156]][@out.a] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_156]][@out.b] : <@A_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_158]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_159]], @b = %[[VAL_160]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_161]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_163]], %[[VAL_164]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_161]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_165]], %[[VAL_166]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:        struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_167:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_170]], @params = %[[VAL_169]] }  : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_174]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_173]]{{\[}}%[[VAL_175]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_168]][@out] = %[[VAL_176]] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_167]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_178]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_179]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_172]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_172]][@in] = %[[VAL_180]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@count] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_182]], %[[VAL_183]] : index
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_184]], %[[VAL_185]], %[[VAL_183]] : index
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_186]], %[[VAL_187]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_188]] {
// CONCRETE-NEXT:            %[[VAL_189:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@count] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_190:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:            %[[VAL_191:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_189]], %[[VAL_190]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_171]][@count] = %[[VAL_191]] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_192:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_193:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_191]], %[[VAL_192]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_193]] {
// CONCRETE-NEXT:              %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@params] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_172]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:              %[[VAL_196:[0-9a-zA-Z_\.]+]] = function.call @C_0::@C_0::@compute(%[[VAL_195]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_171]][@comp] = %[[VAL_196]] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_168]][@C_[[MEMBER1]]$inputs] = %[[VAL_172]] : <@B_1::@B_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_171]][@comp] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_168]][@C_[[MEMBER1]]] = %[[VAL_197]] : <@B_1::@B_1<[]>>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_168]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_198:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_199:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_198]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_198]][@C_[[MEMBER1]]] : <@B_1::@B_1<[]>>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_198]][@C_[[MEMBER1]]$inputs] : <@B_1::@B_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_199]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_203]]{{\[}}%[[VAL_205]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_207]], %[[VAL_208]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_206]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_209]], %[[VAL_210]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_211]], %[[VAL_212]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_199]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_214]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_213]]{{\[}}%[[VAL_215]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_218]], %[[VAL_219]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_216]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_220]], %[[VAL_221]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_222]], %[[VAL_223]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @C_0::@C_0::@constrain(%[[VAL_201]], %[[VAL_224]]) : (!struct.type<@C_0::@C_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @C_0 {
// CONCRETE-NEXT:      struct.def @C_0 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_225:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@C_0::@C_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = struct.new : <@C_0::@C_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_226]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_227:[0-9a-zA-Z_\.]+]]: !struct.type<@C_0::@C_0<[]>>, %[[VAL_228:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_229]], %[[VAL_230]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    module @global {
// TEMPLATED-NEXT:      global.def const @array_const_0 : !array.type<3 x !felt.type<"bn128">> = [ 2 : <"bn128">,  3 : <"bn128">,  4 : <"bn128">]
// TEMPLATED-NEXT:      global.def const @array_const_1 : !array.type<3 x !felt.type<"bn128">> = [ 12 : <"bn128">,  0 : <"bn128">,  0 : <"bn128">]
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>> {signal}
// TEMPLATED-NEXT:        struct.member @s : !array.type<3 x !felt.type<"bn128">> {signal}
// TEMPLATED-NEXT:        struct.member @s2 : !array.type<3 x !felt.type<"bn128">> {signal}
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
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_13]] : <@A::@A<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_14]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_15]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_16]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_16]][@b] = %[[VAL_13]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_15]]] = %[[VAL_16]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s2] = %[[VAL_18]] : <@A::@A<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_19]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_20]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_21]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_21]][@b] = %[[VAL_18]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_20]]] = %[[VAL_21]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_23]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_23]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_26:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_27:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_29:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$a$tag2" = %[[VAL_26]], @"$tag$in$b$b$tag1" = %[[VAL_27]], @"$tag$in$b$tag3" = %[[VAL_28]], @"$tag$in$tag4" = %[[VAL_29]] }  : <[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_31]], @params = %[[VAL_30]] }  : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_33:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_34]], %[[VAL_35]] : index
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_36]], %[[VAL_37]], %[[VAL_35]] : index
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_38]], %[[VAL_39]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_40]] {
// TEMPLATED-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_42:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:            %[[VAL_43:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_41]], %[[VAL_42]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_32]][@count] = %[[VAL_43]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_44:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_45:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_43]], %[[VAL_44]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_45]] {
// TEMPLATED-NEXT:              %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:              %[[VAL_48:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_47]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_32]][@comp] = %[[VAL_48]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_49]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_50]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_4]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_32]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_51]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_52:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_53:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@aux1] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@s] : <@A::@A<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@s2] : <@A::@A<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@aux] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@s1] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_52]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_62]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_63]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_65]], %[[VAL_53]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_66]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_67]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_68]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_69]], %[[VAL_53]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_0 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_55]], %[[VAL_70]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_71]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_72]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_73]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_74]], %[[VAL_55]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = global.read const @global::@array_const_1 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_56]], %[[VAL_75]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_76]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_77]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_79]], %[[VAL_56]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_58]], %[[VAL_80]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_81]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_86:[0-9a-zA-Z_\.]+]] = %[[VAL_84]] to %[[VAL_83]] step %[[VAL_85]] {
// TEMPLATED-NEXT:            %[[VAL_87:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_82]]{{\[}}%[[VAL_86]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_88:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_54]]{{\[}}%[[VAL_86]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_89]], %[[VAL_90]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_87]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_91]], %[[VAL_92]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_94]], %[[VAL_95]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_57]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_101:[0-9a-zA-Z_\.]+]] = %[[VAL_99]] to %[[VAL_98]] step %[[VAL_100]] {
// TEMPLATED-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_96]]{{\[}}%[[VAL_101]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_97]]{{\[}}%[[VAL_101]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_104]], %[[VAL_105]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_107:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_106]], %[[VAL_107]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_60]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_109]], %[[VAL_110]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_108]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_111]], %[[VAL_112]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_60]], %[[VAL_113]]) : (!struct.type<@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_114:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_114]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_115]][@"$component"] = %[[VAL_116]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_116]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_117]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_115]][@out.a] = %[[VAL_118]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_115]][@out.b] = %[[VAL_119]] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_115]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_120:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_121:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_122]], %[[VAL_121]]) : (!struct.type<@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_120]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_122]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_123]], @b = %[[VAL_124]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_127]], %[[VAL_128]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_126]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_129]], %[[VAL_130]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
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
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_131:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_139]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_138]]{{\[}}%[[VAL_140]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_132]][@out] = %[[VAL_141]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$b$tag1" = %[[VAL_142]], @"$tag$in$tag3" = %[[VAL_143]] }  : <[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_145]], @params = %[[VAL_144]] }  : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_131]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_148]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_147]]{{\[}}%[[VAL_149]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_137]][@in] = %[[VAL_150]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_152]], %[[VAL_153]] : index
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_156:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_154]], %[[VAL_155]], %[[VAL_153]] : index
// TEMPLATED-NEXT:          %[[VAL_157:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_156]], %[[VAL_157]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_158]] {
// TEMPLATED-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// TEMPLATED-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_159]], %[[VAL_160]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_146]][@count] = %[[VAL_161]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_163:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_161]], %[[VAL_162]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_163]] {
// TEMPLATED-NEXT:              %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@params] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_166:[0-9a-zA-Z_\.]+]] = function.call @C::@C::@compute(%[[VAL_165]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_146]][@comp] = %[[VAL_166]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_132]][@C_[[MEMBER1]]$inputs] = %[[VAL_137]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_146]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_132]][@C_[[MEMBER1]]] = %[[VAL_167]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          function.return %[[VAL_132]] : !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_168:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, %[[VAL_169:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@out] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@C_[[MEMBER1]]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_168]][@C_[[MEMBER1]]$inputs] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_178]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_177]]{{\[}}%[[VAL_179]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_181]], %[[VAL_182]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_174]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_183]], %[[VAL_184]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_172]], %[[VAL_185]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_169]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_189]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_190]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_191]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_193]], %[[VAL_194]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_192]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_191]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_195]], %[[VAL_196]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_173]], %[[VAL_197]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.call @C::@C::@constrain(%[[VAL_175]], %[[VAL_198]]) : (!struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @C {
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$tag1"
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag3"
// TEMPLATED-NEXT:      struct.def @C {
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_199:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_200]] : !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_203:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>, %[[VAL_204:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_205]], %[[VAL_207]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
