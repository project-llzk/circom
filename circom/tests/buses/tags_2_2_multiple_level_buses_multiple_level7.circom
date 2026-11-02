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

template D(){
    signal input {tag1} in;

    in.tag1 === 3;
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

    D()(aux1[1].b[0]);

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

// CONCRETE-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A_3::@"$bus_entry"<[]>>} {
// CONCRETE-NEXT:    poly.template @A_3 {
// CONCRETE-NEXT:      struct.def @A_3 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>> {signal}
// CONCRETE-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @s2 : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {signal}
// CONCRETE-NEXT:        struct.member @s1 : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]> {signal}
// CONCRETE-NEXT:        struct.member @D_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:        struct.member @D_[[MEMBER1]]$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_3::@A_3<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_3::@A_3<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_9]], @params = %[[VAL_8]] }  : <[@count: index, @comp: !struct.type<@D_0::@D_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_12]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_13]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_14]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_14]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_13]]] = %[[VAL_14]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_16]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_17]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_18]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_18]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_17]]] = %[[VAL_18]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_20]] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s2] = %[[VAL_21]] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_24:[0-9a-zA-Z_\.]+]] = %[[VAL_22]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_24]], %[[VAL_25]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_26]]) %[[VAL_24]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_27:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_29]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_32]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_31]]{{\[}}%[[VAL_32]]] = %[[VAL_20]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_30]][@b] = %[[VAL_31]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_29]]] = %[[VAL_30]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_34]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_36:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_35]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_38:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_27]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_39:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_37]]{{\[}}%[[VAL_38]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            array.write %[[VAL_37]]{{\[}}%[[VAL_38]]] = %[[VAL_21]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            pod.write %[[VAL_36]][@b] = %[[VAL_37]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_35]]] = %[[VAL_36]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_41:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_27]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_41]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_42]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_43]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_44]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_46]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_45]]{{\[}}%[[VAL_47]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_11]][@in] = %[[VAL_48]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@count] : <[@count: index, @comp: !struct.type<@D_0::@D_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_49]], %[[VAL_50]] : index
// CONCRETE-NEXT:          pod.write %[[VAL_10]][@count] = %[[VAL_51]] : <[@count: index, @comp: !struct.type<@D_0::@D_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_51]], %[[VAL_52]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_53]] {
// CONCRETE-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@params] : <[@count: index, @comp: !struct.type<@D_0::@D_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:            %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_11]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_56:[0-9a-zA-Z_\.]+]] = function.call @D_0::@D_0::@compute(%[[VAL_55]]) : (!felt.type<"bn128">) -> !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:            pod.write %[[VAL_10]][@comp] = %[[VAL_56]] : <[@count: index, @comp: !struct.type<@D_0::@D_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_57]] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_57]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_61]], %[[VAL_62]] : index
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_63]], %[[VAL_64]], %[[VAL_62]] : index
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_65]], %[[VAL_66]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_67]] {
// CONCRETE-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_68]], %[[VAL_69]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_70]] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_70]], %[[VAL_71]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_72]] {
// CONCRETE-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = function.call @B_2::@B_2::@compute(%[[VAL_74]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_75]] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@out] : <@B_2::@B_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_77]] : <@A_3::@A_3<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_7]] : <@A_3::@A_3<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_2::@B_2<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_78]] : <@A_3::@A_3<[]>>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]$inputs] = %[[VAL_11]] : <@A_3::@A_3<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@D_0::@D_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]] = %[[VAL_79]] : <@A_3::@A_3<[]>>, !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A_3::@A_3<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A_3::@A_3<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_3::@A_3<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !struct.type<@A_3::@A_3<[]>>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@out] : <@A_3::@A_3<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@aux1] : <@A_3::@A_3<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@s] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@s2] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@aux] : <@A_3::@A_3<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@s1] : <@A_3::@A_3<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@B_[[MEMBER0]]] : <@A_3::@A_3<[]>>, !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@B_[[MEMBER0]]$inputs] : <@A_3::@A_3<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@D_[[MEMBER1]]] : <@A_3::@A_3<[]>>, !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@D_[[MEMBER1]]$inputs] : <@A_3::@A_3<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_92]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_93]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_95]], %[[VAL_81]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_97]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_99]], %[[VAL_81]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_84]], %[[VAL_100]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_85]], %[[VAL_101]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_104:[0-9a-zA-Z_\.]+]] = %[[VAL_102]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// CONCRETE-NEXT:            %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_106:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_104]], %[[VAL_105]]) : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.condition(%[[VAL_106]]) %[[VAL_104]] : !felt.type<"bn128">
// CONCRETE-NEXT:          } do {
// CONCRETE-NEXT:          ^bb0(%[[VAL_107:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// CONCRETE-NEXT:            %[[VAL_108:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_108]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_109]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_111]]{{\[}}%[[VAL_112]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_113]], %[[VAL_84]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_114]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_115]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_116]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_107]] : !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_117]]{{\[}}%[[VAL_118]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:            constrain.eq %[[VAL_119]], %[[VAL_85]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_107]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:            scf.yield %[[VAL_121]] : !felt.type<"bn128">
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_122]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_123]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_124]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_125]]{{\[}}%[[VAL_127]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_129]], %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_87]], %[[VAL_130]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_131]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_136:[0-9a-zA-Z_\.]+]] = %[[VAL_134]] to %[[VAL_133]] step %[[VAL_135]] {
// CONCRETE-NEXT:            %[[VAL_137:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_132]]{{\[}}%[[VAL_136]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_138:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_83]]{{\[}}%[[VAL_136]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_139]], %[[VAL_140]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_138]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_141]], %[[VAL_142]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_144]], %[[VAL_145]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_86]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// CONCRETE-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          scf.for %[[VAL_151:[0-9a-zA-Z_\.]+]] = %[[VAL_149]] to %[[VAL_148]] step %[[VAL_150]] {
// CONCRETE-NEXT:            %[[VAL_152:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_146]]{{\[}}%[[VAL_151]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_153:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_147]]{{\[}}%[[VAL_151]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:            %[[VAL_154:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_155:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_154]], %[[VAL_155]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_152]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_153]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:            constrain.eq %[[VAL_156]], %[[VAL_157]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_88]][@out] : <@B_2::@B_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_159]], %[[VAL_160]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_161]], %[[VAL_162]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.call @B_2::@B_2::@constrain(%[[VAL_88]], %[[VAL_163]]) : (!struct.type<@B_2::@B_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @D_0::@D_0::@constrain(%[[VAL_90]], %[[VAL_164]]) : (!struct.type<@D_0::@D_0<[]>>, !felt.type<"bn128">) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_3::@A_3<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_165:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_3::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = struct.new : <@A_3::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = function.call @A_3::@A_3::@compute(%[[VAL_165]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A_3::@A_3<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_166]][@"$component"] = %[[VAL_167]] : <@A_3::@"$bus_entry"<[]>>, !struct.type<@A_3::@A_3<[]>>
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_167]][@out] : <@A_3::@A_3<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_166]][@out.a] = %[[VAL_169]] : <@A_3::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_166]][@out.b] = %[[VAL_170]] : <@A_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_166]] : !struct.type<@A_3::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_171:[0-9a-zA-Z_\.]+]]: !struct.type<@A_3::@"$bus_entry"<[]>>, %[[VAL_172:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@"$component"] : <@A_3::@"$bus_entry"<[]>>, !struct.type<@A_3::@A_3<[]>>
// CONCRETE-NEXT:          function.call @A_3::@A_3::@constrain(%[[VAL_173]], %[[VAL_172]]) : (!struct.type<@A_3::@A_3<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CONCRETE-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@out.a] : <@A_3::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@out.b] : <@A_3::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_173]][@out] : <@A_3::@A_3<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_174]], @b = %[[VAL_175]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_178]], %[[VAL_179]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_176]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_177]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_180]], %[[VAL_181]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_2 {
// CONCRETE-NEXT:      struct.def @B_2 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @C_[[MEMBER2:[0-9]+_[0-9]+]] : !struct.type<@C_1::@C_1<[]>>
// CONCRETE-NEXT:        struct.member @C_[[MEMBER2]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_182:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B_2::@B_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = struct.new : <@B_2::@B_2<[]>>
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_185]], @params = %[[VAL_184]] }  : <[@count: index, @comp: !struct.type<@C_1::@C_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_189]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_188]]{{\[}}%[[VAL_190]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_183]][@out] = %[[VAL_191]] : <@B_2::@B_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_193]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_192]]{{\[}}%[[VAL_194]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          pod.write %[[VAL_187]][@in] = %[[VAL_195]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@count] : <[@count: index, @comp: !struct.type<@C_1::@C_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_197]], %[[VAL_198]] : index
// CONCRETE-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_199]], %[[VAL_200]], %[[VAL_198]] : index
// CONCRETE-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_201]], %[[VAL_202]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_203]] {
// CONCRETE-NEXT:            %[[VAL_204:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@count] : <[@count: index, @comp: !struct.type<@C_1::@C_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_205:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// CONCRETE-NEXT:            %[[VAL_206:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_204]], %[[VAL_205]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_186]][@count] = %[[VAL_206]] : <[@count: index, @comp: !struct.type<@C_1::@C_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_207:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_208:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_206]], %[[VAL_207]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_208]] {
// CONCRETE-NEXT:              %[[VAL_209:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@params] : <[@count: index, @comp: !struct.type<@C_1::@C_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_210:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:              %[[VAL_211:[0-9a-zA-Z_\.]+]] = function.call @C_1::@C_1::@compute(%[[VAL_210]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C_1::@C_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_186]][@comp] = %[[VAL_211]] : <[@count: index, @comp: !struct.type<@C_1::@C_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_1::@C_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_183]][@C_[[MEMBER2]]$inputs] = %[[VAL_187]] : <@B_2::@B_2<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@comp] : <[@count: index, @comp: !struct.type<@C_1::@C_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_1::@C_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_183]][@C_[[MEMBER2]]] = %[[VAL_212]] : <@B_2::@B_2<[]>>, !struct.type<@C_1::@C_1<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_183]] : !struct.type<@B_2::@B_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_213:[0-9a-zA-Z_\.]+]]: !struct.type<@B_2::@B_2<[]>>, %[[VAL_214:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_215:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_213]][@out] : <@B_2::@B_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_213]][@C_[[MEMBER2]]] : <@B_2::@B_2<[]>>, !struct.type<@C_1::@C_1<[]>>
// CONCRETE-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_213]][@C_[[MEMBER2]]$inputs] : <@B_2::@B_2<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE-NEXT:          %[[VAL_218:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_219:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_220:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_219]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_221:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_218]]{{\[}}%[[VAL_220]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_222:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_222]], %[[VAL_223]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_224:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_215]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_225:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_221]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_224]], %[[VAL_225]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_226]], %[[VAL_227]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_214]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_229]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_228]]{{\[}}%[[VAL_230]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_231]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_233]], %[[VAL_234]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_231]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_235]], %[[VAL_236]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_237]], %[[VAL_238]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_217]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.call @C_1::@C_1::@constrain(%[[VAL_216]], %[[VAL_239]]) : (!struct.type<@C_1::@C_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @C_1 {
// CONCRETE-NEXT:      struct.def @C_1 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_240:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@C_1::@C_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = struct.new : <@C_1::@C_1<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_241]] : !struct.type<@C_1::@C_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_242:[0-9a-zA-Z_\.]+]]: !struct.type<@C_1::@C_1<[]>>, %[[VAL_243:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_244]], %[[VAL_245]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @D_0 {
// CONCRETE-NEXT:      struct.def @D_0 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_246:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@D_0::@D_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = struct.new : <@D_0::@D_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_247]] : !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_248:[0-9a-zA-Z_\.]+]]: !struct.type<@D_0::@D_0<[]>>, %[[VAL_249:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_250]], %[[VAL_251]] : !felt.type<"bn128">, !felt.type<"bn128">
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
// TEMPLATED-NEXT:        struct.member @D_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:        struct.member @D_[[MEMBER1]]$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_6]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_7]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_8]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_8]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_7]]] = %[[VAL_8]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_10]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_11]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_12]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_12]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          array.write %[[VAL_3]]{{\[}}%[[VAL_11]]] = %[[VAL_12]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_14]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s2] = %[[VAL_15]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_18:[0-9a-zA-Z_\.]+]] = %[[VAL_16]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_19:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_20:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_18]], %[[VAL_19]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_20]]) %[[VAL_18]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_21:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_22]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_23]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_24]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_25]]{{\[}}%[[VAL_26]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_25]]{{\[}}%[[VAL_26]]] = %[[VAL_14]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_24]][@b] = %[[VAL_25]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_23]]] = %[[VAL_24]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_28]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_29]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_30]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_32:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_21]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_33:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_31]]{{\[}}%[[VAL_32]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            array.write %[[VAL_31]]{{\[}}%[[VAL_32]]] = %[[VAL_15]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            pod.write %[[VAL_30]][@b] = %[[VAL_31]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            array.write %[[VAL_3]]{{\[}}%[[VAL_29]]] = %[[VAL_30]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_34:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_35:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_21]], %[[VAL_34]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_35]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$tag1" = %[[VAL_36]] }  : <[@"$tag$in$tag1": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_38]], @params = %[[VAL_37]] }  : <[@count: index, @comp: !struct.type<@D::@D<[3]>>, @params: !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_40]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_3]]{{\[}}%[[VAL_41]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_42]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_44]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_43]]{{\[}}%[[VAL_45]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_5]][@in] = %[[VAL_46]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@count] : <[@count: index, @comp: !struct.type<@D::@D<[3]>>, @params: !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_47]], %[[VAL_48]] : index
// TEMPLATED-NEXT:          pod.write %[[VAL_39]][@count] = %[[VAL_49]] : <[@count: index, @comp: !struct.type<@D::@D<[3]>>, @params: !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_49]], %[[VAL_50]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_51]] {
// TEMPLATED-NEXT:            %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@params] : <[@count: index, @comp: !struct.type<@D::@D<[3]>>, @params: !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>
// TEMPLATED-NEXT:            %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_5]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_54:[0-9a-zA-Z_\.]+]] = function.call @D::@D::@compute(%[[VAL_53]]) : (!felt.type<"bn128">) -> !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:            pod.write %[[VAL_39]][@comp] = %[[VAL_54]] : <[@count: index, @comp: !struct.type<@D::@D<[3]>>, @params: !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>]>, !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_55]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_55]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$a$tag2" = %[[VAL_58]], @"$tag$in$b$b$tag1" = %[[VAL_59]], @"$tag$in$b$tag3" = %[[VAL_60]], @"$tag$in$tag4" = %[[VAL_61]] }  : <[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_63]], @params = %[[VAL_62]] }  : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_66]], %[[VAL_67]] : index
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_68]], %[[VAL_69]], %[[VAL_67]] : index
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_70]], %[[VAL_71]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_72]] {
// TEMPLATED-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_73]], %[[VAL_74]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_64]][@count] = %[[VAL_75]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_77:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_75]], %[[VAL_76]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_77]] {
// TEMPLATED-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:              %[[VAL_80:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_79]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_64]][@comp] = %[[VAL_80]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_81]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_82]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_4]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_64]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_83]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]$inputs] = %[[VAL_5]] : <@A::@A<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@comp] : <[@count: index, @comp: !struct.type<@D::@D<[3]>>, @params: !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>]>, !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]] = %[[VAL_84]] : <@A::@A<[]>>, !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_85:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_86:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@aux1] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@s] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@s2] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@aux] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@s1] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@D_[[MEMBER1]]] : <@A::@A<[]>>, !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_85]][@D_[[MEMBER1]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_97]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_98]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_99]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_100]], %[[VAL_86]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_101]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_102]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_103]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_104]], %[[VAL_86]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_88]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_89]], %[[VAL_106]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_109:[0-9a-zA-Z_\.]+]] = %[[VAL_107]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_109]], %[[VAL_110]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_111]]) %[[VAL_109]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_112:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_113]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_114]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_115]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_116]]{{\[}}%[[VAL_117]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_118]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_119]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_120]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_122]]{{\[}}%[[VAL_123]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_124]], %[[VAL_89]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_112]], %[[VAL_125]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_126]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_127]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_128]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_129]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_131]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_130]]{{\[}}%[[VAL_132]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_134]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_91]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_136]], %[[VAL_91]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_141:[0-9a-zA-Z_\.]+]] = %[[VAL_139]] to %[[VAL_138]] step %[[VAL_140]] {
// TEMPLATED-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_137]]{{\[}}%[[VAL_141]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_87]]{{\[}}%[[VAL_141]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_144]], %[[VAL_145]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_143]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_146]], %[[VAL_147]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_149]], %[[VAL_150]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_148]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_90]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_155:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_156:[0-9a-zA-Z_\.]+]] = %[[VAL_154]] to %[[VAL_153]] step %[[VAL_155]] {
// TEMPLATED-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_156]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_152]]{{\[}}%[[VAL_156]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_159]], %[[VAL_160]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_161]], %[[VAL_162]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_93]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_164]], %[[VAL_165]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_92]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_163]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_166]], %[[VAL_167]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_93]], %[[VAL_168]]) : (!struct.type<@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_96]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @D::@D::@constrain(%[[VAL_95]], %[[VAL_169]]) : (!struct.type<@D::@D<[3]>>, !felt.type<"bn128">) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_170:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_170]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_171]][@"$component"] = %[[VAL_172]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_172]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_173]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_171]][@out.a] = %[[VAL_174]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_171]][@out.b] = %[[VAL_175]] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_171]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_176:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_177:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_178]], %[[VAL_177]]) : (!struct.type<@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_176]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_178]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_179]], @b = %[[VAL_180]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_183]], %[[VAL_184]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_185]], %[[VAL_186]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
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
// TEMPLATED-NEXT:        struct.member @C_[[MEMBER2:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:        struct.member @C_[[MEMBER2]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_187:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_195]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_194]]{{\[}}%[[VAL_196]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_188]][@out] = %[[VAL_197]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$b$tag1" = %[[VAL_198]], @"$tag$in$tag3" = %[[VAL_199]] }  : <[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_201]], @params = %[[VAL_200]] }  : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_187]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_204]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_203]]{{\[}}%[[VAL_205]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_193]][@in] = %[[VAL_206]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_208]], %[[VAL_209]] : index
// TEMPLATED-NEXT:          %[[VAL_211:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_210]], %[[VAL_211]], %[[VAL_209]] : index
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_214:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_212]], %[[VAL_213]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_214]] {
// TEMPLATED-NEXT:            %[[VAL_215:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_216:[0-9a-zA-Z_\.]+]] = arith.constant 8 : index
// TEMPLATED-NEXT:            %[[VAL_217:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_215]], %[[VAL_216]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_202]][@count] = %[[VAL_217]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_218:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_219:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_217]], %[[VAL_218]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_219]] {
// TEMPLATED-NEXT:              %[[VAL_220:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@params] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_221:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_193]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:              %[[VAL_222:[0-9a-zA-Z_\.]+]] = function.call @C::@C::@compute(%[[VAL_221]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_202]][@comp] = %[[VAL_222]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_188]][@C_[[MEMBER2]]$inputs] = %[[VAL_193]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_223:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_202]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_188]][@C_[[MEMBER2]]] = %[[VAL_223]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          function.return %[[VAL_188]] : !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_224:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, %[[VAL_225:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_226:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_227:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_228:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_229:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_230:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_224]][@out] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_231:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_224]][@C_[[MEMBER2]]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_232:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_224]][@C_[[MEMBER2]]$inputs] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED-NEXT:          %[[VAL_233:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_234:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_235:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_234]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_236:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_233]]{{\[}}%[[VAL_235]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_237:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_230]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_238:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_236]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_237]], %[[VAL_238]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_239:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_230]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_240:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_236]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_239]], %[[VAL_240]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_241:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_228]], %[[VAL_241]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_242:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_243:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_244:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_225]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_245:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_246:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_245]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_247:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_244]]{{\[}}%[[VAL_246]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_248:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_249:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_248]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_250:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_249]], %[[VAL_250]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_251:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_248]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_252:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_247]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_251]], %[[VAL_252]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_253:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_229]], %[[VAL_253]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_254:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_232]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.call @C::@C::@constrain(%[[VAL_231]], %[[VAL_254]]) : (!struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @C {
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$tag1"
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag3"
// TEMPLATED-NEXT:      struct.def @C {
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_255:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) -> !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_256:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_257:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_258:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_256]] : !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_259:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>, %[[VAL_260:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_261:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_262:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_263:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_261]], %[[VAL_263]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @D {
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag1"
// TEMPLATED-NEXT:      struct.def @D {
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_264:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@D::@D<[@"$tag$in$tag1"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_265:[0-9a-zA-Z_\.]+]] = struct.new : <@D::@D<[@"$tag$in$tag1"]>>
// TEMPLATED-NEXT:          %[[VAL_266:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_265]] : !struct.type<@D::@D<[@"$tag$in$tag1"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_267:[0-9a-zA-Z_\.]+]]: !struct.type<@D::@D<[@"$tag$in$tag1"]>>, %[[VAL_268:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_269:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_270:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_269]], %[[VAL_270]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
