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

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_3 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CONCRETE: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_2::@B_2<[]>>
// CONCRETE: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE: struct.member @D_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@D_0::@D_0<[]>>
// CONCRETE: struct.member @D_[[MEMBER1]]$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT1:[a-zA-Z0-9_.-]+]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@params]
// CONCRETE: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @D_0::@D_0::@compute(%[[IN1]]) : (!felt.type<"bn128">) -> !struct.type<@D_0::@D_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @B_2::@B_2::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_2::@B_2<[]>>
// CONCRETE: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@aux1]
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s2]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@aux]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s1]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@B_[[MEMBER0]]]
// CONCRETE: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@D_[[MEMBER1]]]
// CONCRETE: %[[FIELD10:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@D_[[MEMBER1]]$inputs]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE3:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[VALUE4:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: constrain.eq %[[A2]], %[[VALUE4]]
// CONCRETE: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD3]], %[[VALUE6]]
// CONCRETE: %[[VALUE7:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD4]], %[[VALUE7]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[B1]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT5]], %[[FIELD3]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CONCRETE: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE11:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT7]], %[[FIELD4]]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD10]][@in]
// CONCRETE: constrain.eq %[[IN3]], %[[ELEMENT9]]
// CONCRETE: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD6]], %[[VALUE14]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[FIELD6]]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[B4]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE15]]]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[B6]]
// CONCRETE: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@in]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@a]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[A7]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[B8]]{{\[}}%[[VALUE16]]]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// CONCRETE: constrain.eq %[[A8]], %[[A9]]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@b]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@b]
// CONCRETE: constrain.eq %[[B9]], %[[B10]]
// CONCRETE: %[[FIELD11:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD7]][@out]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@a]
// CONCRETE: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@b]
// CONCRETE: constrain.eq %[[B11]], %[[B12]]
// CONCRETE: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@in]
// CONCRETE: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD10]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_2 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @C_[[MEMBER2:[0-9]+_[0-9]+]] : !struct.type<@C_1::@C_1<[]>>
// CONCRETE: struct.member @C_[[MEMBER2]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD2:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT14:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT2]], %[[N3]]
// CONCRETE: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE17:[a-zA-Z0-9_.-]+]] = arith.select %[[READY2]], %[[N4]], %[[N3]]
// CONCRETE: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE17]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@count]
// CONCRETE: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 8 : index
// CONCRETE: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT3]], %[[N6]]
// CONCRETE: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// CONCRETE: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N7]]
// CONCRETE: scf.if %[[READY4]] {
// CONCRETE: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@params]
// CONCRETE: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2]][@in]
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @C_1::@C_1::@compute(%[[IN7]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C_1::@C_1<[]>>
// CONCRETE: pod.write %[[STATE2]][@comp] = %[[CHILD3]]
// CONCRETE: function.return %[[VALUE18:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD12:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD13:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19]][@C_[[MEMBER2]]]
// CONCRETE: %[[FIELD14:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19]][@C_[[MEMBER2]]$inputs]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20:[a-zA-Z0-9_.-]+]][@b]
// CONCRETE: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%[[VALUE21:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD12]][@a]
// CONCRETE: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@a]
// CONCRETE: constrain.eq %[[A12]], %[[A13]]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD12]][@b]
// CONCRETE: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@b]
// CONCRETE: constrain.eq %[[B14]], %[[B15]]
// CONCRETE: %[[VALUE22:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE23:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE22]], %[[VALUE23]]
// CONCRETE: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20]][@b]
// CONCRETE: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[B16]]{{\[}}%[[VALUE24:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD14]][@in]
// CONCRETE: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@a]
// CONCRETE: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@a]
// CONCRETE: constrain.eq %[[A14]], %[[A15]]
// CONCRETE: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@b]
// CONCRETE: %[[B18:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@b]
// CONCRETE: constrain.eq %[[B17]], %[[B18]]
// CONCRETE: %[[VALUE25:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: %[[VALUE26:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE25]], %[[VALUE26]]
// CONCRETE: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD14]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @C_1 {
// CONCRETE: function.def @constrain(
// CONCRETE: %[[VALUE27:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE28:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE27]], %[[VALUE28]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @D_0 {
// CONCRETE: function.def @constrain(
// CONCRETE: %[[VALUE29:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE30:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE29]], %[[VALUE30]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// TEMPLATED: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// TEMPLATED: struct.member @D_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@D::@D<[3]>>
// TEMPLATED: struct.member @D_[[MEMBER1]]$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT1:[a-zA-Z0-9_.-]+]] : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// TEMPLATED: scf.if %[[READY1]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @D::@D::@compute(%[[IN1]]) : (!felt.type<"bn128">) -> !struct.type<@D::@D<[3]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @B::@B::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2:[a-zA-Z0-9_.-]+]][@aux1]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s2]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@aux]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s1]
// TEMPLATED: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@out]
// TEMPLATED: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@B_[[MEMBER0]]]
// TEMPLATED: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@B_[[MEMBER0]]$inputs]
// TEMPLATED: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@D_[[MEMBER1]]]
// TEMPLATED: %[[FIELD10:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@D_[[MEMBER1]]$inputs]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE3:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[VALUE4:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[VALUE4]]
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD2]], %[[VALUE6]]
// TEMPLATED: %[[VALUE7:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD3]], %[[VALUE7]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[B1]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT5]], %[[FIELD2]]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@b]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE11:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT7]], %[[FIELD3]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD10]][@in]
// TEMPLATED: constrain.eq %[[IN3]], %[[ELEMENT9]]
// TEMPLATED: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD5]], %[[VALUE14]]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A3]], %[[FIELD5]]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[B4]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE15]]]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@b]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@b]
// TEMPLATED: constrain.eq %[[B5]], %[[B6]]
// TEMPLATED: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@in]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@b]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[B8]]{{\[}}%[[VALUE16]]]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// TEMPLATED: constrain.eq %[[A8]], %[[A9]]
// TEMPLATED: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@b]
// TEMPLATED: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@b]
// TEMPLATED: constrain.eq %[[B9]], %[[B10]]
// TEMPLATED: %[[FIELD11:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD7]][@out]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@a]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@b]
// TEMPLATED: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@b]
// TEMPLATED: constrain.eq %[[B11]], %[[B12]]
// TEMPLATED: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@in]
// TEMPLATED: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD10]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$a$tag2"
// TEMPLATED: poly.param @"$tag$in$b$b$tag1"
// TEMPLATED: poly.param @"$tag$in$b$tag3"
// TEMPLATED: poly.param @"$tag$in$tag4"
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @C_[[MEMBER2:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED: struct.member @C_[[MEMBER2]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD2:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT14:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT2]], %[[N3]]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE17:[a-zA-Z0-9_.-]+]] = arith.select %[[READY2]], %[[N4]], %[[N3]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE17]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@count]
// TEMPLATED: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 8 : index
// TEMPLATED: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT3]], %[[N6]]
// TEMPLATED: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// TEMPLATED: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N7]]
// TEMPLATED: scf.if %[[READY4]] {
// TEMPLATED: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@params]
// TEMPLATED: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2]][@in]
// TEMPLATED: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @C::@C::@compute(%[[IN7]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED: pod.write %[[STATE2]][@comp] = %[[CHILD3]]
// TEMPLATED: function.return %[[VALUE18:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD12:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[FIELD13:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19]][@C_[[MEMBER2]]]
// TEMPLATED: %[[FIELD14:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19]][@C_[[MEMBER2]]$inputs]
// TEMPLATED: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20:[a-zA-Z0-9_.-]+]][@b]
// TEMPLATED: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%[[VALUE21:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD12]][@a]
// TEMPLATED: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[A13]]
// TEMPLATED: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD12]][@b]
// TEMPLATED: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@b]
// TEMPLATED: constrain.eq %[[B14]], %[[B15]]
// TEMPLATED: %[[VALUE22:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE23:[a-zA-Z0-9_.-]+]], %[[VALUE22]]
// TEMPLATED: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20]][@b]
// TEMPLATED: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[B16]]{{\[}}%[[VALUE24:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD14]][@in]
// TEMPLATED: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@a]
// TEMPLATED: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@a]
// TEMPLATED: constrain.eq %[[A14]], %[[A15]]
// TEMPLATED: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@b]
// TEMPLATED: %[[B18:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@b]
// TEMPLATED: constrain.eq %[[B17]], %[[B18]]
// TEMPLATED: %[[VALUE25:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE26:[a-zA-Z0-9_.-]+]], %[[VALUE25]]
// TEMPLATED: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD14]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$b$tag1"
// TEMPLATED: poly.param @"$tag$in$tag3"
// TEMPLATED-LABEL: struct.def @C {
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[VALUE27:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE28:[a-zA-Z0-9_.-]+]], %[[VALUE27]]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$tag1"
// TEMPLATED-LABEL: struct.def @D {
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[VALUE29:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE30:[a-zA-Z0-9_.-]+]], %[[VALUE29]]
// TEMPLATED: function.return
