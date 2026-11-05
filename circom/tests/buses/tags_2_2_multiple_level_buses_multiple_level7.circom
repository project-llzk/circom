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
// TEMPLATED-LABEL: struct.def @A {
// CHECK: struct.member @aux1 : !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>
// CHECK: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_2::@B_2<[]>>
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 3, 5, 99]>>
// CHECK: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>]>
// CONCRETE: struct.member @D_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@D_0::@D_0<[]>>
// TEMPLATED: struct.member @D_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@D::@D<[3]>>
// CHECK: struct.member @D_[[MEMBER1]]$inputs : !pod.type<[@in: !felt.type<"bn128">]>
// CHECK: function.def @compute(
// CHECK: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %{{[a-zA-Z0-9_.-]+}} : <[@in: !felt.type<"bn128">]>, !felt.type<"bn128">
// CHECK: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// CHECK: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CHECK: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CHECK: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CHECK: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CHECK: scf.if %[[READY1]] {
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE1]][@params]
// CHECK: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @D_0::@D_0::@compute(%[[IN1]]) : (!felt.type<"bn128">) -> !struct.type<@D_0::@D_0<[]>>
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @D::@D::@compute(%[[IN1]]) : (!felt.type<"bn128">) -> !struct.type<@D::@D<[3]>>
// CHECK: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @B_2::@B_2::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B_2::@B_2<[]>>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = function.call @B::@B::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!pod.type<[@a: !felt.type<"bn128">, @b: !array.type<2 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// CHECK: function.return %{{[a-zA-Z0-9_.-]+}}
// CHECK: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@aux1]
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s2]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@aux]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s1]
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2:[a-zA-Z0-9_.-]+]][@aux1]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s2]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@aux]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@s1]
// TEMPLATED: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@out]
// CHECK: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@B_[[MEMBER0]]]
// CHECK: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@B_[[MEMBER0]]$inputs]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE2]][@D_[[MEMBER1]]]
// CHECK: %[[FIELD10:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE2]][@D_[[MEMBER1]]$inputs]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CHECK: constrain.eq %[[A1]], %[[VALUE4:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CHECK: constrain.eq %[[A2]], %[[VALUE4]]
// CHECK: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  1 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD3]], %[[VALUE6]]
// TEMPLATED: constrain.eq %[[FIELD2]], %[[VALUE6]]
// CHECK: %[[VALUE7:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD4]], %[[VALUE7]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[FIELD3]], %[[VALUE7]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// CHECK: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[B1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT5]], %[[FIELD3]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT5]], %[[FIELD2]]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CHECK: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT7]], %[[FIELD4]]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT7]], %[[FIELD3]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CHECK: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[B3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD10]][@in]
// CHECK: constrain.eq %[[IN3]], %[[ELEMENT9]]
// CHECK: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD6]], %[[VALUE14]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[FIELD6]]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// TEMPLATED: constrain.eq %[[FIELD5]], %[[VALUE14]]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A3]], %[[FIELD5]]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// CHECK: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[B4]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE15]]]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE15]]]
// CHECK: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CHECK: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@a]
// CHECK: constrain.eq %[[A4]], %[[A5]]
// CHECK: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@b]
// CHECK: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@b]
// CHECK: constrain.eq %[[B5]], %[[B6]]
// CHECK: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@in]
// CHECK: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@a]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// CHECK: constrain.eq %[[A6]], %[[A7]]
// CHECK: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// CHECK: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// CHECK: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[B8]]{{\[}}%[[VALUE16]]]
// CHECK: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CHECK: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// CHECK: constrain.eq %[[A8]], %[[A9]]
// CHECK: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@b]
// CHECK: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@b]
// CHECK: constrain.eq %[[B9]], %[[B10]]
// CHECK: %[[FIELD11:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD7]][@out]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@a]
// CHECK: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@a]
// CHECK: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@b]
// CHECK: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@b]
// CHECK: constrain.eq %[[B11]], %[[B12]]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD8]][@in]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD10]][@in]
// CHECK: function.return
// CONCRETE-LABEL: struct.def @B_2 {
// TEMPLATED: poly.param @"$tag$in$a$tag2"
// TEMPLATED: poly.param @"$tag$in$b$b$tag1"
// TEMPLATED: poly.param @"$tag$in$b$tag3"
// TEMPLATED: poly.param @"$tag$in$tag4"
// TEMPLATED-LABEL: struct.def @B {
// CHECK: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @C_[[MEMBER2:[0-9]+_[0-9]+]] : !struct.type<@C_1::@C_1<[]>>
// TEMPLATED: struct.member @C_[[MEMBER2:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// CHECK: struct.member @C_[[MEMBER2]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CHECK: function.def @compute(
// CHECK: pod.write %[[POD2:[a-zA-Z0-9_.-]+]][@in] = %{{[a-zA-Z0-9_.-]+}} : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CHECK: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2:[a-zA-Z0-9_.-]+]][@count]
// CHECK: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT2]], %[[N3]]
// CHECK: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CHECK: %[[VALUE17:[a-zA-Z0-9_.-]+]] = arith.select %[[READY2]], %[[N4]], %[[N3]]
// CHECK: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE17]], %[[N5]]
// CHECK: scf.if %[[READY3]] {
// CHECK: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@count]
// CHECK: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 8 : index
// CHECK: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT3]], %[[N6]]
// CHECK: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// CHECK: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CHECK: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N7]]
// CHECK: scf.if %[[READY4]] {
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[STATE2]][@params]
// CHECK: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2]][@in]
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @C_1::@C_1::@compute(%[[IN7]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C_1::@C_1<[]>>
// TEMPLATED: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @C::@C::@compute(%[[IN7]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// CHECK: pod.write %[[STATE2]][@comp] = %[[CHILD3]]
// CHECK: function.return %{{[a-zA-Z0-9_.-]+}}
// CHECK: function.def @constrain(
// CHECK: %[[FIELD12:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19:[a-zA-Z0-9_.-]+]][@out]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = struct.readm %[[VALUE19]][@C_[[MEMBER2]]]
// CHECK: %[[FIELD14:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19]][@C_[[MEMBER2]]$inputs]
// CHECK: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20:[a-zA-Z0-9_.-]+]][@b]
// CHECK: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD12]][@a]
// CHECK: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@a]
// CHECK: constrain.eq %[[A12]], %[[A13]]
// CHECK: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD12]][@b]
// CHECK: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@b]
// CHECK: constrain.eq %[[B14]], %[[B15]]
// CHECK: %[[VALUE22:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE23:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE22]], %[[VALUE23]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE22]]
// CHECK: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE20]][@b]
// CHECK: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[B16]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CHECK: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD14]][@in]
// CHECK: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@a]
// CHECK: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@a]
// CHECK: constrain.eq %[[A14]], %[[A15]]
// CHECK: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@b]
// CHECK: %[[B18:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@b]
// CHECK: constrain.eq %[[B17]], %[[B18]]
// CHECK: %[[VALUE25:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: %[[VALUE26:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE25]], %[[VALUE26]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE25]]
// CHECK: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD14]][@in]
// CHECK: function.return
// CONCRETE-LABEL: struct.def @C_1 {
// TEMPLATED: poly.param @"$tag$in$b$tag1"
// TEMPLATED: poly.param @"$tag$in$tag3"
// TEMPLATED-LABEL: struct.def @C {
// CHECK: function.def @constrain(
// CHECK: %[[VALUE27:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE28:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE27]], %[[VALUE28]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE27]]
// CHECK: function.return
// CONCRETE-LABEL: struct.def @D_0 {
// TEMPLATED: poly.param @"$tag$in$tag1"
// TEMPLATED-LABEL: struct.def @D {
// CHECK: function.def @constrain(
// CHECK: %[[VALUE29:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE30:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE29]], %[[VALUE30]]
// TEMPLATED: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[VALUE29]]
// CHECK: function.return
