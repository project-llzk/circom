// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus Bus1(){
    signal a[5];
    signal b[3];
}

bus Bus2(){
    signal {tag2} a;
    Bus1() {tag3} b[2];
}

template B(){
    Bus2() input {tag4} in;
    Bus1() output out <== in.b[1];

    in.b.tag3 === 5;
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
// CONCRETE-NEXT:        struct.member @D_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:        struct.member @D_[[MEMBER1]]$inputs : !pod.type<[@in: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@A_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
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
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_20]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s2] = %[[VAL_21]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
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
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_57]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_57]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_61]], %[[VAL_62]] : index
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_63]], %[[VAL_64]], %[[VAL_62]] : index
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_65]], %[[VAL_66]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_67]] {
// CONCRETE-NEXT:            %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// CONCRETE-NEXT:            %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_68]], %[[VAL_69]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_70]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_70]], %[[VAL_71]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_72]] {
// CONCRETE-NEXT:              %[[VAL_73:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_74:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:              %[[VAL_75:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_74]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_75]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_76]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_77]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_7]] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_78]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]$inputs] = %[[VAL_11]] : <@A_2::@A_2<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_10]][@comp] : <[@count: index, @comp: !struct.type<@D_0::@D_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]] = %[[VAL_79]] : <@A_2::@A_2<[]>>, !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A_2::@A_2<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_80:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@A_2<[]>>, %[[VAL_81:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@aux1] : <@A_2::@A_2<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@s] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@s2] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@aux] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@s1] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@B_[[MEMBER0]]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@B_[[MEMBER0]]$inputs] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@D_[[MEMBER1]]] : <@A_2::@A_2<[]>>, !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@D_[[MEMBER1]]$inputs] : <@A_2::@A_2<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
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
// CONCRETE-NEXT:          %[[VAL_158:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_88]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_159]], %[[VAL_160]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_158]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_161]], %[[VAL_162]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_88]], %[[VAL_163]]) : (!struct.type<@B_1::@B_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// CONCRETE-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.call @D_0::@D_0::@constrain(%[[VAL_90]], %[[VAL_164]]) : (!struct.type<@D_0::@D_0<[]>>, !felt.type<"bn128">) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_165:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute(%[[VAL_165]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_166]][@"$component"] = %[[VAL_167]] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_167]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_169:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_168]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_166]][@out.a] = %[[VAL_169]] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_166]][@out.b] = %[[VAL_170]] : <@A_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          function.return %[[VAL_166]] : !struct.type<@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_171:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@"$bus_entry"<[]>>, %[[VAL_172:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@"$component"] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          function.call @A_2::@A_2::@constrain(%[[VAL_173]], %[[VAL_172]]) : (!struct.type<@A_2::@A_2<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CONCRETE-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@out.a] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_175:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@out.b] : <@A_2::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_176:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_173]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
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
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_182:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_182]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_186:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_185]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_184]]{{\[}}%[[VAL_186]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          struct.writem %[[VAL_183]][@out] = %[[VAL_187]] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          function.return %[[VAL_183]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_188:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_189:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_188]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_189]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_192]] : !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_191]]{{\[}}%[[VAL_193]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-NEXT:          %[[VAL_195:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_196:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_195]], %[[VAL_196]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_190]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_194]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_197]], %[[VAL_198]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_199]], %[[VAL_200]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_201]], %[[VAL_202]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @D_0 {
// CONCRETE-NEXT:      struct.def @D_0 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_203:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@D_0::@D_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = struct.new : <@D_0::@D_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_204]] : !struct.type<@D_0::@D_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_205:[0-9a-zA-Z_\.]+]]: !struct.type<@D_0::@D_0<[]>>, %[[VAL_206:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_207]], %[[VAL_208]] : !felt.type<"bn128">, !felt.type<"bn128">
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
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 5, 99]>>
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
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$a$tag2" = %[[VAL_58]], @"$tag$in$b$tag3" = %[[VAL_59]], @"$tag$in$tag4" = %[[VAL_60]] }  : <[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_62]], @params = %[[VAL_61]] }  : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_65]], %[[VAL_66]] : index
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_67]], %[[VAL_68]], %[[VAL_66]] : index
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_69]], %[[VAL_70]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_71]] {
// TEMPLATED-NEXT:            %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_73:[0-9a-zA-Z_\.]+]] = arith.constant 17 : index
// TEMPLATED-NEXT:            %[[VAL_74:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_72]], %[[VAL_73]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_63]][@count] = %[[VAL_74]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_75:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_76:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_74]], %[[VAL_75]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_76]] {
// TEMPLATED-NEXT:              %[[VAL_77:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_78:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:              %[[VAL_79:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_78]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 5, 99]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_63]][@comp] = %[[VAL_79]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 5, 99]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_80]][@out] : <@B::@B<[7, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_81]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_4]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_63]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_82]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]$inputs] = %[[VAL_5]] : <@A::@A<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@comp] : <[@count: index, @comp: !struct.type<@D::@D<[3]>>, @params: !pod.type<[@"$tag$in$tag1": !felt.type<"bn128">]>]>, !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@D_[[MEMBER1]]] = %[[VAL_83]] : <@A::@A<[]>>, !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_85:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@aux1] : <@A::@A<[]>>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@s] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@s2] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@aux] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@s1] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@D_[[MEMBER1]]] : <@A::@A<[]>>, !struct.type<@D::@D<[3]>>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_84]][@D_[[MEMBER1]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_96]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_97]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_98]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_99]], %[[VAL_85]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_100]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_101]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_102]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_103]], %[[VAL_85]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_87]], %[[VAL_104]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = felt.const  2 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_88]], %[[VAL_105]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = scf.while (%[[VAL_108:[0-9a-zA-Z_\.]+]] = %[[VAL_106]]) : (!felt.type<"bn128">) -> !felt.type<"bn128"> {
// TEMPLATED-NEXT:            %[[VAL_109:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = bool.cmp lt(%[[VAL_108]], %[[VAL_109]]) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.condition(%[[VAL_110]]) %[[VAL_108]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          } do {
// TEMPLATED-NEXT:          ^bb0(%[[VAL_111:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128">):
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_112]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_113]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_116:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_117:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_115]]{{\[}}%[[VAL_116]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_117]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_118:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_119:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_118]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_120:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_119]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_122:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_111]] : !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_123:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_121]]{{\[}}%[[VAL_122]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:            constrain.eq %[[VAL_123]], %[[VAL_88]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            %[[VAL_124:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:            %[[VAL_125:[0-9a-zA-Z_\.]+]] = felt.add %[[VAL_111]], %[[VAL_124]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:            scf.yield %[[VAL_125]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_126]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_127]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = felt.const  0 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_130]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_129]]{{\[}}%[[VAL_131]]] : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_133]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_90]], %[[VAL_134]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_135]], %[[VAL_90]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_140:[0-9a-zA-Z_\.]+]] = %[[VAL_138]] to %[[VAL_137]] step %[[VAL_139]] {
// TEMPLATED-NEXT:            %[[VAL_141:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_136]]{{\[}}%[[VAL_140]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_142:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_86]]{{\[}}%[[VAL_140]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_144:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_143]], %[[VAL_144]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_145:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_141]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_146:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_142]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_145]], %[[VAL_146]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          %[[VAL_148:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_149:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@a] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_148]], %[[VAL_149]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_147]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = arith.constant 2 : index
// TEMPLATED-NEXT:          %[[VAL_153:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_154:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          scf.for %[[VAL_155:[0-9a-zA-Z_\.]+]] = %[[VAL_153]] to %[[VAL_152]] step %[[VAL_154]] {
// TEMPLATED-NEXT:            %[[VAL_156:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_150]]{{\[}}%[[VAL_155]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_157:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_151]]{{\[}}%[[VAL_155]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:            %[[VAL_158:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_159:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_158]], %[[VAL_159]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_160:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_156]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            %[[VAL_161:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_157]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:            constrain.eq %[[VAL_160]], %[[VAL_161]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_162:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_92]][@out] : <@B::@B<[7, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_163:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_164:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_163]], %[[VAL_164]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_165:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_91]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_166:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_162]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_165]], %[[VAL_166]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_167:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_93]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_92]], %[[VAL_167]]) : (!struct.type<@B::@B<[7, 5, 99]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> ()
// TEMPLATED-NEXT:          %[[VAL_168:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_95]][@in] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.call @D::@D::@constrain(%[[VAL_94]], %[[VAL_168]]) : (!struct.type<@D::@D<[3]>>, !felt.type<"bn128">) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !array.type<3 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_169:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_170:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_171:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_169]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_170]][@"$component"] = %[[VAL_171]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_172:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_171]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_173:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_172]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_174:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_172]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_170]][@out.a] = %[[VAL_173]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_170]][@out.b] = %[[VAL_174]] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return %[[VAL_170]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_175:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_176:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_177:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_175]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_177]], %[[VAL_176]]) : (!struct.type<@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// TEMPLATED-NEXT:          %[[VAL_178:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_175]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_179:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_175]][@out.b] : <@A::@"$bus_entry"<[]>>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_180:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_177]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_181:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_178]], @b = %[[VAL_179]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_182:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_183:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_182]], %[[VAL_183]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_184:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_180]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_185:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_181]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_184]], %[[VAL_185]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @B {
// TEMPLATED-NEXT:      poly.param @"$tag$in$a$tag2"
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$tag3"
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag4"
// TEMPLATED-NEXT:      struct.def @B {
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_186:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$tag3", @"$tag$in$tag4"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_187:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:          %[[VAL_188:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_189:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_190:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_191:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_186]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_192:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_193:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_192]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_194:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_191]]{{\[}}%[[VAL_193]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_187]][@out] = %[[VAL_194]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          function.return %[[VAL_187]] : !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_195:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, %[[VAL_196:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_197:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_198:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_199:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_200:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_195]][@out] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_201:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_196]][@b] : <[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>, !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED-NEXT:          %[[VAL_202:[0-9a-zA-Z_\.]+]] = felt.const  1 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_203:[0-9a-zA-Z_\.]+]] = cast.toindex %[[VAL_202]] : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_204:[0-9a-zA-Z_\.]+]] = array.read %[[VAL_201]]{{\[}}%[[VAL_203]]] : <2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-NEXT:          %[[VAL_205:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_206:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_205]], %[[VAL_206]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_207:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_200]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_208:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_204]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_207]], %[[VAL_208]] : !array.type<3 x !felt.type<"bn128">>, !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_209:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_198]], %[[VAL_209]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_210:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_199]], %[[VAL_210]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @D {
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag1"
// TEMPLATED-NEXT:      struct.def @D {
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_211:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) -> !struct.type<@D::@D<[@"$tag$in$tag1"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_212:[0-9a-zA-Z_\.]+]] = struct.new : <@D::@D<[@"$tag$in$tag1"]>>
// TEMPLATED-NEXT:          %[[VAL_213:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_212]] : !struct.type<@D::@D<[@"$tag$in$tag1"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_214:[0-9a-zA-Z_\.]+]]: !struct.type<@D::@D<[@"$tag$in$tag1"]>>, %[[VAL_215:[0-9a-zA-Z_\.]+]]: !felt.type<"bn128"> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_216:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_217:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_216]], %[[VAL_217]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
