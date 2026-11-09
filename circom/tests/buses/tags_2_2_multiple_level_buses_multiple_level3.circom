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

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE: struct.member @s : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @s2 : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 17 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// CONCRETE: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @B_1::@B_1::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@out]
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@aux1]
// CONCRETE: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@s]
// CONCRETE: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@s2]
// CONCRETE: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@aux]
// CONCRETE: %[[FIELD6:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@s1]
// CONCRETE: %[[FIELD7:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// CONCRETE: %[[FIELD8:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[VALUE6:[0-9a-zA-Z_.-]+]]
// CONCRETE: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A2]], %[[VALUE6]]
// CONCRETE: %[[VALUE8:[0-9a-zA-Z_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT3]], %[[VALUE8]]
// CONCRETE: %[[VALUE10:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT4]], %[[VALUE10]]
// CONCRETE: %[[VALUE12:[0-9a-zA-Z_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT5]], %[[VALUE12]]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[FIELD3]]
// CONCRETE: %[[VALUE15:[0-9a-zA-Z_.-]+]] = felt.const  12 : <"bn128">
// CONCRETE: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT7]], %[[VALUE15]]
// CONCRETE: %[[VALUE17:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT8]], %[[VALUE17]]
// CONCRETE: %[[VALUE19:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[ELEMENT9:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT9]], %[[VALUE19]]
// CONCRETE: %[[ELEMENT10:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@b]
// CONCRETE: constrain.eq %[[B2]], %[[FIELD4]]
// CONCRETE: %[[VALUE22:[0-9a-zA-Z_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD6]], %[[VALUE22]]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[FIELD6]]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@b]
// CONCRETE: %[[ELEMENT11:[0-9a-zA-Z_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE23:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT12:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE23]]]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@a]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@b]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT12]][@b]
// CONCRETE: constrain.eq %[[B4]], %[[B5]]
// CONCRETE: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD8]][@in]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@a]
// CONCRETE: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[A7]]
// CONCRETE: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@b]
// CONCRETE: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@b]
// CONCRETE: %[[ELEMENT13:[0-9a-zA-Z_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE24:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT14:[0-9a-zA-Z_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE24]]]
// CONCRETE: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT13]][@a]
// CONCRETE: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT14]][@a]
// CONCRETE: constrain.eq %[[A8]], %[[A9]]
// CONCRETE: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT13]][@b]
// CONCRETE: %[[B9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT14]][@b]
// CONCRETE: constrain.eq %[[B8]], %[[B9]]
// CONCRETE: %[[FIELD9:[0-9a-zA-Z_.-]+]] = struct.readm %[[FIELD7]][@out]
// CONCRETE: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD9]][@a]
// CONCRETE: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[B10:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B11:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD9]][@b]
// CONCRETE: constrain.eq %[[B10]], %[[B11]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD8]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_1 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE: struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD2:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: %[[COUNT3:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE2:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N6:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY4:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT3]], %[[N6]]
// CONCRETE: %[[N7:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE25:[0-9a-zA-Z_.-]+]] = arith.select %[[READY4]], %[[N7]], %[[N6]]
// CONCRETE: %[[N8:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY5:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE25]], %[[N8]]
// CONCRETE: scf.if %[[READY5]] {
// CONCRETE: %[[COUNT4:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE2]][@count]
// CONCRETE: %[[N9:[0-9a-zA-Z_.-]+]] = arith.constant 8 : index
// CONCRETE: %[[REMAINING2:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT4]], %[[N9]]
// CONCRETE: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// CONCRETE: %[[N10:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY6:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N10]]
// CONCRETE: scf.if %[[READY6]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE2]][@params]
// CONCRETE: %[[IN4:[0-9a-zA-Z_.-]+]] = pod.read %[[POD2]][@in]
// CONCRETE: %[[CHILD2:[0-9a-zA-Z_.-]+]] = function.call @C_0::@C_0::@compute(%[[IN4]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C_0::@C_0<[]>>
// CONCRETE: pod.write %[[STATE2]][@comp] = %[[CHILD2]]
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD10:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE27:[0-9a-zA-Z_.-]+]][@out]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = struct.readm %[[VALUE27]][@C_[[MEMBER1]]]
// CONCRETE: %[[FIELD12:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE27]][@C_[[MEMBER1]]$inputs]
// CONCRETE: %[[B12:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE28:[0-9a-zA-Z_.-]+]][@b]
// CONCRETE: %[[ELEMENT16:[0-9a-zA-Z_.-]+]] = array.read %[[B12]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD10]][@a]
// CONCRETE: %[[A13:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT16]][@a]
// CONCRETE: constrain.eq %[[A12]], %[[A13]]
// CONCRETE: %[[B13:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD10]][@b]
// CONCRETE: %[[B14:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT16]][@b]
// CONCRETE: constrain.eq %[[B13]], %[[B14]]
// CONCRETE: %[[VALUE30:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE31:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE30]], %[[VALUE31]]
// CONCRETE: %[[B15:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE28]][@b]
// CONCRETE: %[[ELEMENT17:[0-9a-zA-Z_.-]+]] = array.read %[[B15]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[IN5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD12]][@in]
// CONCRETE: %[[A14:[0-9a-zA-Z_.-]+]] = pod.read %[[IN5]][@a]
// CONCRETE: %[[A15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT17]][@a]
// CONCRETE: constrain.eq %[[A14]], %[[A15]]
// CONCRETE: %[[B16:[0-9a-zA-Z_.-]+]] = pod.read %[[IN5]][@b]
// CONCRETE: %[[B17:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT17]][@b]
// CONCRETE: constrain.eq %[[B16]], %[[B17]]
// CONCRETE: %[[VALUE33:[0-9a-zA-Z_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: %[[VALUE34:[0-9a-zA-Z_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE33]], %[[VALUE34]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD12]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @C_0 {
// CONCRETE: function.def @constrain(
// CONCRETE: %[[VALUE35:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE36:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE35]], %[[VALUE36]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED: struct.member @s : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: struct.member @s2 : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 17 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@in]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @B::@B::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@aux1]
// TEMPLATED: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@s]
// TEMPLATED: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@s2]
// TEMPLATED: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@aux]
// TEMPLATED: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@s1]
// TEMPLATED: %[[FIELD6:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@out]
// TEMPLATED: %[[FIELD7:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// TEMPLATED: %[[FIELD8:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// TEMPLATED: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[VALUE6:[0-9a-zA-Z_.-]+]]
// TEMPLATED: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[VALUE6]]
// TEMPLATED: constrain.eq %[[FIELD2]], %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[FIELD2]]
// TEMPLATED: constrain.eq %[[FIELD3]], %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[FIELD3]]
// TEMPLATED: %[[VALUE12:[0-9a-zA-Z_.-]+]] = felt.const  99 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD5]], %[[VALUE12]]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A3]], %[[FIELD5]]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE13:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE13]]]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@b]
// TEMPLATED: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@b]
// TEMPLATED: constrain.eq %[[B4]], %[[B5]]
// TEMPLATED: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD8]][@in]
// TEMPLATED: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@a]
// TEMPLATED: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@b]
// TEMPLATED: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE14:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE14]]]
// TEMPLATED: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@a]
// TEMPLATED: constrain.eq %[[A8]], %[[A9]]
// TEMPLATED: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@b]
// TEMPLATED: %[[B9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@b]
// TEMPLATED: constrain.eq %[[B8]], %[[B9]]
// TEMPLATED: %[[FIELD9:[0-9a-zA-Z_.-]+]] = struct.readm %[[FIELD7]][@out]
// TEMPLATED: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@a]
// TEMPLATED: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD9]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[B10:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@b]
// TEMPLATED: %[[B11:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD9]][@b]
// TEMPLATED: constrain.eq %[[B10]], %[[B11]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD8]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$a$tag2"
// TEMPLATED: poly.param @"$tag$in$b$b$tag1"
// TEMPLATED: poly.param @"$tag$in$b$tag3"
// TEMPLATED: poly.param @"$tag$in$tag4"
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED: struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD2:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: %[[COUNT3:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE2:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N6:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY4:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT3]], %[[N6]]
// TEMPLATED: %[[N7:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE15:[0-9a-zA-Z_.-]+]] = arith.select %[[READY4]], %[[N7]], %[[N6]]
// TEMPLATED: %[[N8:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY5:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE15]], %[[N8]]
// TEMPLATED: scf.if %[[READY5]] {
// TEMPLATED: %[[COUNT4:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE2]][@count]
// TEMPLATED: %[[N9:[0-9a-zA-Z_.-]+]] = arith.constant 8 : index
// TEMPLATED: %[[REMAINING2:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT4]], %[[N9]]
// TEMPLATED: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// TEMPLATED: %[[N10:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY6:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N10]]
// TEMPLATED: scf.if %[[READY6]] {
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE2]][@params]
// TEMPLATED: %[[IN4:[0-9a-zA-Z_.-]+]] = pod.read %[[POD2]][@in]
// TEMPLATED: %[[CHILD2:[0-9a-zA-Z_.-]+]] = function.call @C::@C::@compute(%[[IN4]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED: pod.write %[[STATE2]][@comp] = %[[CHILD2]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD10:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE17:[0-9a-zA-Z_.-]+]][@out]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = struct.readm %[[VALUE17]][@C_[[MEMBER1]]]
// TEMPLATED: %[[FIELD12:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE17]][@C_[[MEMBER1]]$inputs]
// TEMPLATED: %[[B12:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE18:[0-9a-zA-Z_.-]+]][@b]
// TEMPLATED: %[[ELEMENT10:[0-9a-zA-Z_.-]+]] = array.read %[[B12]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD10]][@a]
// TEMPLATED: %[[A13:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[A13]]
// TEMPLATED: %[[B13:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD10]][@b]
// TEMPLATED: %[[B14:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@b]
// TEMPLATED: constrain.eq %[[B13]], %[[B14]]
// TEMPLATED: %[[VALUE20:[0-9a-zA-Z_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED: constrain.eq %{{[0-9a-zA-Z_.-]+}}, %[[VALUE20]]
// TEMPLATED: %[[B15:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE18]][@b]
// TEMPLATED: %[[ELEMENT11:[0-9a-zA-Z_.-]+]] = array.read %[[B15]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[IN5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD12]][@in]
// TEMPLATED: %[[A14:[0-9a-zA-Z_.-]+]] = pod.read %[[IN5]][@a]
// TEMPLATED: %[[A15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@a]
// TEMPLATED: constrain.eq %[[A14]], %[[A15]]
// TEMPLATED: %[[B16:[0-9a-zA-Z_.-]+]] = pod.read %[[IN5]][@b]
// TEMPLATED: %[[B17:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@b]
// TEMPLATED: constrain.eq %[[B16]], %[[B17]]
// TEMPLATED: %[[VALUE23:[0-9a-zA-Z_.-]+]] = felt.const  99 : <"bn128">
// TEMPLATED: constrain.eq %{{[0-9a-zA-Z_.-]+}}, %[[VALUE23]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD12]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$b$tag1"
// TEMPLATED: poly.param @"$tag$in$tag3"
// TEMPLATED-LABEL: struct.def @C {
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[VALUE25:[0-9a-zA-Z_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: constrain.eq %{{[0-9a-zA-Z_.-]+}}, %[[VALUE25]]
// TEMPLATED: function.return
