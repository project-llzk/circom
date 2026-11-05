// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefixes=CHECK,CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefixes=CHECK,TEMPLATED
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

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED-LABEL: struct.def @A {
// CHECK: struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CHECK: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_1::@B_1<[]>>
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 3, 5, 99]>>
// CHECK: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CHECK: function.def @compute(
// CHECK: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %{{[a-zA-Z0-9_.-]+}} : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CHECK: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// CHECK: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CHECK: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CHECK: %[[VALUE2:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CHECK: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// CHECK: scf.if %[[READY2]] {
// CHECK: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// CHECK: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 17 : index
// CHECK: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CHECK: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CHECK: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CHECK: scf.if %[[READY3]] {
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE1]][@params]
// CHECK: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B_1::@B_1::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_1::@B_1<[]>>
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B::@B::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// CHECK: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CHECK: function.return %{{[a-zA-Z0-9_.-]+}}
// CHECK: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux1]
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s2]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s1]
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@aux1]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s2]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s1]
// TEMPLATED: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@out]
// CHECK: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// CHECK: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CHECK: constrain.eq %[[A1]], %[[VALUE6:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CHECK: constrain.eq %[[A2]], %[[VALUE6]]
// CHECK: %[[VALUE8:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD3]], %[[VALUE8]]
// TEMPLATED: constrain.eq %[[FIELD2]], %[[VALUE8]]
// CHECK: %[[VALUE9:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD4]], %[[VALUE9]]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[FIELD3]], %[[VALUE9]]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@b]
// CHECK: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[B1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT4]], %[[FIELD3]]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT4]], %[[FIELD2]]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@b]
// CHECK: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT6]], %[[FIELD4]]
// TEMPLATED: constrain.eq %[[ELEMENT6]], %[[FIELD3]]
// CHECK: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD6]], %[[VALUE14]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[FIELD6]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// TEMPLATED: constrain.eq %[[FIELD5]], %[[VALUE14]]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A3]], %[[FIELD5]]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// CHECK: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE15]]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE15]]]
// CHECK: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CHECK: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@a]
// CHECK: constrain.eq %[[A4]], %[[A5]]
// CHECK: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@b]
// CHECK: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CHECK: constrain.eq %[[B4]], %[[B5]]
// CHECK: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@in]
// CHECK: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@a]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// CHECK: constrain.eq %[[A6]], %[[A7]]
// CHECK: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@b]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// CHECK: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// CHECK: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE16]]]
// CHECK: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@a]
// CHECK: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CHECK: constrain.eq %[[A8]], %[[A9]]
// CHECK: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@b]
// CHECK: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@b]
// CHECK: constrain.eq %[[B8]], %[[B9]]
// CHECK: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD7]][@out]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@a]
// CHECK: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@a]
// CHECK: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@b]
// CHECK: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@b]
// CHECK: constrain.eq %[[B10]], %[[B11]]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD8]][@in]
// CHECK: function.return
// CONCRETE-LABEL: struct.def @B_1 {
// TEMPLATED: poly.param @"$tag$in$a$tag2"
// TEMPLATED: poly.param @"$tag$in$b$b$tag1"
// TEMPLATED: poly.param @"$tag$in$b$tag3"
// TEMPLATED: poly.param @"$tag$in$tag4"
// TEMPLATED-LABEL: struct.def @B {
// CHECK: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C_0::@C_0<[]>>
// TEMPLATED: struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// CHECK: struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CHECK: function.def @compute(
// CHECK: pod.write %[[POD2:[a-zA-Z0-9_.-]+]][@in] = %{{[a-zA-Z0-9_.-]+}} : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CHECK: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2:[a-zA-Z0-9_.-]+]][@count]
// CHECK: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT3]], %[[N6]]
// CHECK: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CHECK: %[[VALUE17:[a-zA-Z0-9_.-]+]] = arith.select %[[READY4]], %[[N7]], %[[N6]]
// CHECK: %[[N8:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY5:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE17]], %[[N8]]
// CHECK: scf.if %[[READY5]] {
// CHECK: %[[COUNT4:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@count]
// CHECK: %[[N9:[a-zA-Z0-9_.-]+]] = arith.constant 8 : index
// CHECK: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT4]], %[[N9]]
// CHECK: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// CHECK: %[[N10:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY6:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N10]]
// CHECK: scf.if %[[READY6]] {
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE2]][@params]
// CHECK: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2]][@in]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @C_0::@C_0::@compute(%[[IN4]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C_0::@C_0<[]>>
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @C::@C::@compute(%[[IN4]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// CHECK: pod.write %[[STATE2]][@comp] = %[[CHILD2]]
// CHECK: function.return %{{[a-zA-Z0-9_.-]+}}
// CHECK: function.def @constrain(
// CHECK: %[[FIELD10:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19:[a-zA-Z0-9_.-]+]][@out]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE19]][@C_[[MEMBER1]]]
// CHECK: %[[FIELD12:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19]][@C_[[MEMBER1]]$inputs]
// CHECK: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20:[a-zA-Z0-9_.-]+]][@b]
// CHECK: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B12]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD10]][@a]
// CHECK: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CHECK: constrain.eq %[[A12]], %[[A13]]
// CHECK: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD10]][@b]
// CHECK: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@b]
// CHECK: constrain.eq %[[B13]], %[[B14]]
// CHECK: %[[VALUE22:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE23:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE22]], %[[VALUE23]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE22]]
// CHECK: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20]][@b]
// CHECK: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[B15]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD12]][@in]
// CHECK: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@a]
// CHECK: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// CHECK: constrain.eq %[[A14]], %[[A15]]
// CHECK: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@b]
// CHECK: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@b]
// CHECK: constrain.eq %[[B16]], %[[B17]]
// CHECK: %[[VALUE25:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: %[[VALUE26:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE25]], %[[VALUE26]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE25]]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD12]][@in]
// CHECK: function.return
// CONCRETE-LABEL: struct.def @C_0 {
// TEMPLATED: poly.param @"$tag$in$b$tag1"
// TEMPLATED: poly.param @"$tag$in$tag3"
// TEMPLATED-LABEL: struct.def @C {
// CHECK: function.def @constrain(
// CHECK: %[[VALUE27:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE28:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE27]], %[[VALUE28]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE27]]
// CHECK: function.return
