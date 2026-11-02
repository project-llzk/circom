// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus Bus1(){
    signal a[5];
    signal {tag1} b;
}

bus Bus2(){
    signal {tag2} a;
    Bus1() {tag3} b;
}

template C(){
    input Bus1() {tag3} in;

    in.b.tag1 === 3;
}

template B(){
    Bus2() input {tag4} in;
    Bus1() output out <== in.b;

    in.b.tag3 === 5;
    C()(in.b);

    in.tag4 === 99;
}

template A(){
    signal input a[5];

    Bus1() {tag3} aux1;
    aux1.tag3 = 5;
    aux1.a <== a;

    signal {tag1} s;
    s.tag1 = 3;
    s <== 44;
    aux1.b <== s;

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
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @aux1 : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {signal}
// CONCRETE-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        struct.member @s1 : !felt.type<"bn128"> {signal}
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@A_2<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CONCRETE-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_5]], @params = %[[VAL_4]] }  : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          pod.write %[[VAL_3]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = felt.const  44 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_9]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_3]][@b] = %[[VAL_9]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_11]] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_11]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          pod.write %[[VAL_7]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_15]], %[[VAL_16]] : index
// CONCRETE-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_17]], %[[VAL_18]], %[[VAL_16]] : index
// CONCRETE-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_19]], %[[VAL_20]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_21]] {
// CONCRETE-NEXT:            %[[VAL_22:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@count] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// CONCRETE-NEXT:            %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_22]], %[[VAL_23]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_6]][@count] = %[[VAL_24]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_24]], %[[VAL_25]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_26]] {
// CONCRETE-NEXT:              %[[VAL_27:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@params] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_28:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_7]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:              %[[VAL_29:[0-9a-zA-Z_\.]+]] = function.call @B_1::@B_1::@compute(%[[VAL_28]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_6]][@comp] = %[[VAL_29]] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          %[[VAL_30:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_31:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_30]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_31]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_7]] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_6]][@comp] : <[@count: index, @comp: !struct.type<@B_1::@B_1<[]>>, @params: !pod.type<[]>]>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_32]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.return %[[VAL_1]] : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_33:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@A_2<[]>>, %[[VAL_34:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@aux1] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_37:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@s] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_38:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@aux] : <@A_2::@A_2<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@s1] : <@A_2::@A_2<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@B_[[MEMBER0]]] : <@A_2::@A_2<[]>>, !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_33]][@B_[[MEMBER0]]$inputs] : <@A_2::@A_2<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// CONCRETE-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_42]], %[[VAL_34]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = felt.const  44 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_37]], %[[VAL_43]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_44]], %[[VAL_37]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_39]], %[[VAL_45]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_46]], %[[VAL_39]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_48]], %[[VAL_49]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_47]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_36]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_50]], %[[VAL_51]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_53]], %[[VAL_54]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_52]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_38]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_57]], %[[VAL_58]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_55]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_59]], %[[VAL_60]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_40]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_62]], %[[VAL_63]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_35]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_61]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_64]], %[[VAL_65]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          function.call @B_1::@B_1::@constrain(%[[VAL_40]], %[[VAL_66]]) : (!struct.type<@B_1::@B_1<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:      struct.def @"$bus_entry" {
// CONCRETE-NEXT:        struct.member @"$component" : !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @out.b : !felt.type<"bn128"> {llzk.pub, signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_67:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A_2::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = struct.new : <@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = function.call @A_2::@A_2::@compute(%[[VAL_67]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_68]][@"$component"] = %[[VAL_69]] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_69]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_71:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_70]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          struct.writem %[[VAL_68]][@out.a] = %[[VAL_71]] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          struct.writem %[[VAL_68]][@out.b] = %[[VAL_72]] : <@A_2::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return %[[VAL_68]] : !struct.type<@A_2::@"$bus_entry"<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_73:[0-9a-zA-Z_\.]+]]: !struct.type<@A_2::@"$bus_entry"<[]>>, %[[VAL_74:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@"$component"] : <@A_2::@"$bus_entry"<[]>>, !struct.type<@A_2::@A_2<[]>>
// CONCRETE-NEXT:          function.call @A_2::@A_2::@constrain(%[[VAL_75]], %[[VAL_74]]) : (!struct.type<@A_2::@A_2<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// CONCRETE-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@out.a] : <@A_2::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_77:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@out.b] : <@A_2::@"$bus_entry"<[]>>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_78:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_75]][@out] : <@A_2::@A_2<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_76]], @b = %[[VAL_77]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_80]], %[[VAL_81]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_78]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_79]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_82]], %[[VAL_83]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @B_1 {
// CONCRETE-NEXT:      struct.def @B_1 {
// CONCRETE-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// CONCRETE-NEXT:        struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:        struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {signal}
// CONCRETE-NEXT:        function.def @compute(%[[VAL_84:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) -> !struct.type<@B_1::@B_1<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = struct.new : <@B_1::@B_1<[]>>
// CONCRETE-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.new : <[]>
// CONCRETE-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:          %[[VAL_88:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_87]], @params = %[[VAL_86]] }  : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          struct.writem %[[VAL_85]][@out] = %[[VAL_90]] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_84]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          pod.write %[[VAL_89]][@in] = %[[VAL_91]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@count] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_93]], %[[VAL_94]] : index
// CONCRETE-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// CONCRETE-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_95]], %[[VAL_96]], %[[VAL_94]] : index
// CONCRETE-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_97]], %[[VAL_98]] : index
// CONCRETE-NEXT:          scf.if %[[VAL_99]] {
// CONCRETE-NEXT:            %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@count] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_101:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// CONCRETE-NEXT:            %[[VAL_102:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_100]], %[[VAL_101]] : index
// CONCRETE-NEXT:            pod.write %[[VAL_88]][@count] = %[[VAL_102]] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, index
// CONCRETE-NEXT:            %[[VAL_103:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// CONCRETE-NEXT:            %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_102]], %[[VAL_103]] : index
// CONCRETE-NEXT:            scf.if %[[VAL_104]] {
// CONCRETE-NEXT:              %[[VAL_105:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@params] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !pod.type<[]>
// CONCRETE-NEXT:              %[[VAL_106:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_89]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:              %[[VAL_107:[0-9a-zA-Z_\.]+]] = function.call @C_0::@C_0::@compute(%[[VAL_106]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:              pod.write %[[VAL_88]][@comp] = %[[VAL_107]] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:            }
// CONCRETE-NEXT:          }
// CONCRETE-NEXT:          struct.writem %[[VAL_85]][@C_[[MEMBER1]]$inputs] = %[[VAL_89]] : <@B_1::@B_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@comp] : <[@count: index, @comp: !struct.type<@C_0::@C_0<[]>>, @params: !pod.type<[]>]>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          struct.writem %[[VAL_85]][@C_[[MEMBER1]]] = %[[VAL_108]] : <@B_1::@B_1<[]>>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_85]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_109:[0-9a-zA-Z_\.]+]]: !struct.type<@B_1::@B_1<[]>>, %[[VAL_110:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_111:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@out] : <@B_1::@B_1<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_112:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@C_[[MEMBER1]]] : <@B_1::@B_1<[]>>, !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:          %[[VAL_113:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_109]][@C_[[MEMBER1]]$inputs] : <@B_1::@B_1<[]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE-NEXT:          %[[VAL_114:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_115]], %[[VAL_116]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_117:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_111]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_114]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_117]], %[[VAL_118]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_119:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_120:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_119]], %[[VAL_120]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_110]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          constrain.eq %[[VAL_123]], %[[VAL_124]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// CONCRETE-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_122]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_121]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_125]], %[[VAL_126]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_127]], %[[VAL_128]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_113]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE-NEXT:          function.call @C_0::@C_0::@constrain(%[[VAL_112]], %[[VAL_129]]) : (!struct.type<@C_0::@C_0<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> ()
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:    poly.template @C_0 {
// CONCRETE-NEXT:      struct.def @C_0 {
// CONCRETE-NEXT:        function.def @compute(%[[VAL_130:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@C_0::@C_0<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// CONCRETE-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = struct.new : <@C_0::@C_0<[]>>
// CONCRETE-NEXT:          function.return %[[VAL_131]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:        function.def @constrain(%[[VAL_132:[0-9a-zA-Z_\.]+]]: !struct.type<@C_0::@C_0<[]>>, %[[VAL_133:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// CONCRETE-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// CONCRETE-NEXT:          constrain.eq %[[VAL_134]], %[[VAL_135]] : !felt.type<"bn128">, !felt.type<"bn128">
// CONCRETE-NEXT:          function.return
// CONCRETE-NEXT:        }
// CONCRETE-NEXT:      }
// CONCRETE-NEXT:    }
// CONCRETE-NEXT:  }

// TEMPLATED-LABEL: module attributes {llzk.lang = "circom", llzk.main = !struct.type<@A::@"$bus_entry"<[]>>} {
// TEMPLATED-NEXT:    poly.template @A {
// TEMPLATED-NEXT:      struct.def @A {
// TEMPLATED-NEXT:        struct.member @aux1 : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {signal}
// TEMPLATED-NEXT:        struct.member @s : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        struct.member @s1 : !felt.type<"bn128"> {signal}
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:        struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_0:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@A<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_1:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_2:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_3:[0-9a-zA-Z_\.]+]] = llzk.nondet : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_4:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED-NEXT:          %[[VAL_5:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@a] = %[[VAL_0]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_6:[0-9a-zA-Z_\.]+]] = felt.const  44 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s] = %[[VAL_6]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_7:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_3]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_3]][@b] = %[[VAL_6]] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_8:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@s1] = %[[VAL_8]] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_9:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@a] = %[[VAL_8]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_10:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_2]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_2]][@b] = %[[VAL_3]] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_11:[0-9a-zA-Z_\.]+]] = felt.const  7 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_12:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_13:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_14:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          %[[VAL_15:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$a$tag2" = %[[VAL_11]], @"$tag$in$b$b$tag1" = %[[VAL_12]], @"$tag$in$b$tag3" = %[[VAL_13]], @"$tag$in$tag4" = %[[VAL_14]] }  : <[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_16:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// TEMPLATED-NEXT:          %[[VAL_17:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_16]], @params = %[[VAL_15]] }  : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_18:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          pod.write %[[VAL_4]][@in] = %[[VAL_2]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_19:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_20:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_21:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_19]], %[[VAL_20]] : index
// TEMPLATED-NEXT:          %[[VAL_22:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_23:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_21]], %[[VAL_22]], %[[VAL_20]] : index
// TEMPLATED-NEXT:          %[[VAL_24:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_25:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_23]], %[[VAL_24]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_25]] {
// TEMPLATED-NEXT:            %[[VAL_26:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@count] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_27:[0-9a-zA-Z_\.]+]] = arith.constant 7 : index
// TEMPLATED-NEXT:            %[[VAL_28:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_26]], %[[VAL_27]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_17]][@count] = %[[VAL_28]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_29:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_30:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_28]], %[[VAL_29]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_30]] {
// TEMPLATED-NEXT:              %[[VAL_31:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@params] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_32:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_4]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:              %[[VAL_33:[0-9a-zA-Z_\.]+]] = function.call @B::@B::@compute(%[[VAL_32]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_17]][@comp] = %[[VAL_33]] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          %[[VAL_34:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_35:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_34]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@out] = %[[VAL_35]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]$inputs] = %[[VAL_4]] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED-NEXT:          %[[VAL_36:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_17]][@comp] : <[@count: index, @comp: !struct.type<@B::@B<[7, 3, 5, 99]>>, @params: !pod.type<[@"$tag$in$a$tag2": !felt.type<"bn128">, @"$tag$in$b$b$tag1": !felt.type<"bn128">, @"$tag$in$b$tag3": !felt.type<"bn128">, @"$tag$in$tag4": !felt.type<"bn128">]>]>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@B_[[MEMBER0]]] = %[[VAL_36]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux1] = %[[VAL_3]] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_1]][@aux] = %[[VAL_2]] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          function.return %[[VAL_1]] : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_37:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@A<[]>>, %[[VAL_38:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_39:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@aux1] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_40:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@s] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_41:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@aux] : <@A::@A<[]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_42:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@s1] : <@A::@A<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_43:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_44:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@B_[[MEMBER0]]] : <@A::@A<[]>>, !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED-NEXT:          %[[VAL_45:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_37]][@B_[[MEMBER0]]$inputs] : <@A::@A<[]>>, !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED-NEXT:          %[[VAL_46:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_46]], %[[VAL_38]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_47:[0-9a-zA-Z_\.]+]] = felt.const  44 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_40]], %[[VAL_47]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_48:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_48]], %[[VAL_40]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_49:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_42]], %[[VAL_49]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_50:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_50]], %[[VAL_42]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_51:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_52:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_53:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_52]], %[[VAL_53]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_54:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_51]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_55:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_39]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_54]], %[[VAL_55]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_56:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_57:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_58:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@a] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_57]], %[[VAL_58]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_59:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_56]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_60:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_41]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_61:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_62:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_61]], %[[VAL_62]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_63:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_59]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_64:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_60]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_63]], %[[VAL_64]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_65:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_44]][@out] : <@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_66:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_67:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_66]], %[[VAL_67]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_68:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_43]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_69:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_65]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_68]], %[[VAL_69]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_70:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_45]][@in] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          function.call @B::@B::@constrain(%[[VAL_44]], %[[VAL_70]]) : (!struct.type<@B::@B<[7, 3, 5, 99]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:      struct.def @"$bus_entry" {
// TEMPLATED-NEXT:        struct.member @"$component" : !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:        struct.member @out.a : !array.type<5 x !felt.type<"bn128">> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @out.b : !felt.type<"bn128"> {llzk.pub, signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_71:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) -> !struct.type<@A::@"$bus_entry"<[]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_72:[0-9a-zA-Z_\.]+]] = struct.new : <@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:          %[[VAL_73:[0-9a-zA-Z_\.]+]] = function.call @A::@A::@compute(%[[VAL_71]]) : (!array.type<5 x !felt.type<"bn128">>) -> !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_72]][@"$component"] = %[[VAL_73]] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          %[[VAL_74:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_73]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_75:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_76:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_74]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          struct.writem %[[VAL_72]][@out.a] = %[[VAL_75]] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          struct.writem %[[VAL_72]][@out.b] = %[[VAL_76]] : <@A::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_72]] : !struct.type<@A::@"$bus_entry"<[]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_77:[0-9a-zA-Z_\.]+]]: !struct.type<@A::@"$bus_entry"<[]>>, %[[VAL_78:[0-9a-zA-Z_\.]+]]: !array.type<5 x !felt.type<"bn128">> {function.arg_name = "a"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_79:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@"$component"] : <@A::@"$bus_entry"<[]>>, !struct.type<@A::@A<[]>>
// TEMPLATED-NEXT:          function.call @A::@A::@constrain(%[[VAL_79]], %[[VAL_78]]) : (!struct.type<@A::@A<[]>>, !array.type<5 x !felt.type<"bn128">>) -> ()
// TEMPLATED-NEXT:          %[[VAL_80:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@out.a] : <@A::@"$bus_entry"<[]>>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_81:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_77]][@out.b] : <@A::@"$bus_entry"<[]>>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_82:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_79]][@out] : <@A::@A<[]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_83:[0-9a-zA-Z_\.]+]] = pod.new { @a = %[[VAL_80]], @b = %[[VAL_81]] }  : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_84:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_85:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_84]], %[[VAL_85]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_86:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_82]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_87:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_83]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_86]], %[[VAL_87]] : !felt.type<"bn128">, !felt.type<"bn128">
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
// TEMPLATED-NEXT:        struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {llzk.pub, signal}
// TEMPLATED-NEXT:        struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:        struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {signal}
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_88:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) -> !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_89:[0-9a-zA-Z_\.]+]] = struct.new : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:          %[[VAL_90:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_91:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_92:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_93:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_94:[0-9a-zA-Z_\.]+]] = pod.new : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_95:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          struct.writem %[[VAL_89]][@out] = %[[VAL_95]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_96:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_97:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_98:[0-9a-zA-Z_\.]+]] = pod.new { @"$tag$in$b$tag1" = %[[VAL_96]], @"$tag$in$tag3" = %[[VAL_97]] }  : <[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_99:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// TEMPLATED-NEXT:          %[[VAL_100:[0-9a-zA-Z_\.]+]] = pod.new { @count = %[[VAL_99]], @params = %[[VAL_98]] }  : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_101:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_88]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_102:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          pod.write %[[VAL_94]][@in] = %[[VAL_101]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_103:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:          %[[VAL_104:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_105:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_103]], %[[VAL_104]] : index
// TEMPLATED-NEXT:          %[[VAL_106:[0-9a-zA-Z_\.]+]] = arith.constant 1 : index
// TEMPLATED-NEXT:          %[[VAL_107:[0-9a-zA-Z_\.]+]] = arith.select %[[VAL_105]], %[[VAL_106]], %[[VAL_104]] : index
// TEMPLATED-NEXT:          %[[VAL_108:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:          %[[VAL_109:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_107]], %[[VAL_108]] : index
// TEMPLATED-NEXT:          scf.if %[[VAL_109]] {
// TEMPLATED-NEXT:            %[[VAL_110:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@count] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_111:[0-9a-zA-Z_\.]+]] = arith.constant 6 : index
// TEMPLATED-NEXT:            %[[VAL_112:[0-9a-zA-Z_\.]+]] = arith.subi %[[VAL_110]], %[[VAL_111]] : index
// TEMPLATED-NEXT:            pod.write %[[VAL_100]][@count] = %[[VAL_112]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, index
// TEMPLATED-NEXT:            %[[VAL_113:[0-9a-zA-Z_\.]+]] = arith.constant 0 : index
// TEMPLATED-NEXT:            %[[VAL_114:[0-9a-zA-Z_\.]+]] = arith.cmpi eq, %[[VAL_112]], %[[VAL_113]] : index
// TEMPLATED-NEXT:            scf.if %[[VAL_114]] {
// TEMPLATED-NEXT:              %[[VAL_115:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@params] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_116:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_94]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:              %[[VAL_117:[0-9a-zA-Z_\.]+]] = function.call @C::@C::@compute(%[[VAL_116]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:              pod.write %[[VAL_100]][@comp] = %[[VAL_117]] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:            }
// TEMPLATED-NEXT:          }
// TEMPLATED-NEXT:          struct.writem %[[VAL_89]][@C_[[MEMBER1]]$inputs] = %[[VAL_94]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_118:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_100]][@comp] : <[@count: index, @comp: !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, @params: !pod.type<[@"$tag$in$b$tag1": !felt.type<"bn128">, @"$tag$in$tag3": !felt.type<"bn128">]>]>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          struct.writem %[[VAL_89]][@C_[[MEMBER1]]] = %[[VAL_118]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          function.return %[[VAL_89]] : !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_119:[0-9a-zA-Z_\.]+]]: !struct.type<@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, %[[VAL_120:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_121:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$a$tag2" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_122:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_123:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_124:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag4" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_125:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@out] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_126:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@C_[[MEMBER1]]] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_127:[0-9a-zA-Z_\.]+]] = struct.readm %[[VAL_119]][@C_[[MEMBER1]]$inputs] : <@B::@B<[@"$tag$in$a$tag2", @"$tag$in$b$b$tag1", @"$tag$in$b$tag3", @"$tag$in$tag4"]>>, !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED-NEXT:          %[[VAL_128:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_129:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_130:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_129]], %[[VAL_130]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_131:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_125]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_132:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_128]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_131]], %[[VAL_132]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_133:[0-9a-zA-Z_\.]+]] = felt.const  5 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_123]], %[[VAL_133]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_134:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_135:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_136:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_120]][@b] : <[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_137:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          %[[VAL_138:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_139:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@a] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          constrain.eq %[[VAL_138]], %[[VAL_139]] : !array.type<5 x !felt.type<"bn128">>, !array.type<5 x !felt.type<"bn128">>
// TEMPLATED-NEXT:          %[[VAL_140:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_137]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_141:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_136]][@b] : <[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_140]], %[[VAL_141]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_142:[0-9a-zA-Z_\.]+]] = felt.const  99 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_124]], %[[VAL_142]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_143:[0-9a-zA-Z_\.]+]] = pod.read %[[VAL_127]][@in] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED-NEXT:          function.call @C::@C::@constrain(%[[VAL_126]], %[[VAL_143]]) : (!struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> ()
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:    poly.template @C {
// TEMPLATED-NEXT:      poly.param @"$tag$in$b$tag1"
// TEMPLATED-NEXT:      poly.param @"$tag$in$tag3"
// TEMPLATED-NEXT:      struct.def @C {
// TEMPLATED-NEXT:        function.def @compute(%[[VAL_144:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) -> !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>> attributes {function.allow_non_native_field_ops, function.allow_witness} {
// TEMPLATED-NEXT:          %[[VAL_145:[0-9a-zA-Z_\.]+]] = struct.new : <@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:          %[[VAL_146:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_147:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return %[[VAL_145]] : !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:        function.def @constrain(%[[VAL_148:[0-9a-zA-Z_\.]+]]: !struct.type<@C::@C<[@"$tag$in$b$tag1", @"$tag$in$tag3"]>>, %[[VAL_149:[0-9a-zA-Z_\.]+]]: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]> {function.arg_name = "in"}) attributes {function.allow_constraint, function.allow_non_native_field_ops} {
// TEMPLATED-NEXT:          %[[VAL_150:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$b$tag1" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_151:[0-9a-zA-Z_\.]+]] = poly.read_const @"$tag$in$tag3" : !felt.type<"bn128">
// TEMPLATED-NEXT:          %[[VAL_152:[0-9a-zA-Z_\.]+]] = felt.const  3 : <"bn128">
// TEMPLATED-NEXT:          constrain.eq %[[VAL_150]], %[[VAL_152]] : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT:          function.return
// TEMPLATED-NEXT:        }
// TEMPLATED-NEXT:      }
// TEMPLATED-NEXT:    }
// TEMPLATED-NEXT:  }
