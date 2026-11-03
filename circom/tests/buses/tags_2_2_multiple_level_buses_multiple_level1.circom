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

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: struct.member @aux1 : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_1::@B_1<[]>>
// CONCRETE: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[VALUE1:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE2:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 7 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@params]
// CONCRETE: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B_1::@B_1::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>) -> !struct.type<@B_1::@B_1<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %[[VALUE3:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux1]
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s1]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[VALUE5:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  44 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD3]], %[[VALUE6]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[FIELD3]]
// CONCRETE: %[[VALUE7:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD5]], %[[VALUE7]]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// CONCRETE: constrain.eq %[[A2]], %[[FIELD5]]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@a]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@b]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@a]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// CONCRETE: constrain.eq %[[A5]], %[[A6]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[B5]][@a]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@a]
// CONCRETE: constrain.eq %[[A7]], %[[A8]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[B5]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD6]][@out]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A10]]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@b]
// CONCRETE: constrain.eq %[[B9]], %[[B10]]
// CONCRETE: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_1 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C_0::@C_0<[]>>
// CONCRETE: struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD2:[a-zA-Z0-9_.-]+]][@in] = %[[B11:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT3]], %[[N6]]
// CONCRETE: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE8:[a-zA-Z0-9_.-]+]] = arith.select %[[READY4]], %[[N7]], %[[N6]]
// CONCRETE: %[[N8:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY5:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE8]], %[[N8]]
// CONCRETE: scf.if %[[READY5]] {
// CONCRETE: %[[COUNT4:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@count]
// CONCRETE: %[[N9:[a-zA-Z0-9_.-]+]] = arith.constant 6 : index
// CONCRETE: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT4]], %[[N9]]
// CONCRETE: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// CONCRETE: %[[N10:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY6:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N10]]
// CONCRETE: scf.if %[[READY6]] {
// CONCRETE: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@params]
// CONCRETE: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2]][@in]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @C_0::@C_0::@compute(%[[IN4]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@C_0::@C_0<[]>>
// CONCRETE: pod.write %[[STATE2]][@comp] = %[[CHILD2]]
// CONCRETE: function.return %[[VALUE9:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD10:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10]][@C_[[MEMBER1]]]
// CONCRETE: %[[FIELD11:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10]][@C_[[MEMBER1]]$inputs]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE11:[a-zA-Z0-9_.-]+]][@b]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@a]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[B12]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@b]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[B12]][@b]
// CONCRETE: constrain.eq %[[B13]], %[[B14]]
// CONCRETE: %[[VALUE12:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: %[[VALUE13:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE12]], %[[VALUE13]]
// CONCRETE: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE11]][@b]
// CONCRETE: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@in]
// CONCRETE: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@a]
// CONCRETE: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[B15]][@a]
// CONCRETE: constrain.eq %[[A13]], %[[A14]]
// CONCRETE: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@b]
// CONCRETE: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[B15]][@b]
// CONCRETE: constrain.eq %[[B16]], %[[B17]]
// CONCRETE: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: %[[VALUE15:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE14]], %[[VALUE15]]
// CONCRETE: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @C_0 {
// CONCRETE: function.def @constrain(
// CONCRETE: %[[VALUE16:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: %[[VALUE17:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE16]], %[[VALUE17]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @aux1 : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: struct.member @aux : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[VALUE1:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE2:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 7 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B::@B::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>) -> !struct.type<@B::@B<[7, 3, 5, 99]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE3:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@aux1]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s1]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@out]
// TEMPLATED: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// TEMPLATED: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// TEMPLATED: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[VALUE5:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  44 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD2]], %[[VALUE6]]
// TEMPLATED: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[FIELD2]]
// TEMPLATED: %[[VALUE7:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD4]], %[[VALUE7]]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[FIELD4]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@b]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@a]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: constrain.eq %[[A3]], %[[A4]]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@b]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[B4]]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@a]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@a]
// TEMPLATED: constrain.eq %[[A5]], %[[A6]]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@b]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@b]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[B5]][@a]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@a]
// TEMPLATED: constrain.eq %[[A7]], %[[A8]]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[B5]][@b]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@b]
// TEMPLATED: constrain.eq %[[B7]], %[[B8]]
// TEMPLATED: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD6]][@out]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A10]]
// TEMPLATED: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// TEMPLATED: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@b]
// TEMPLATED: constrain.eq %[[B9]], %[[B10]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$a$tag2"
// TEMPLATED: poly.param @"$tag$in$b$b$tag1"
// TEMPLATED: poly.param @"$tag$in$b$tag3"
// TEMPLATED: poly.param @"$tag$in$tag4"
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: struct.member @C_[[MEMBER1:[0-9]+_[0-9]+]] : !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED: struct.member @C_[[MEMBER1]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD2:[a-zA-Z0-9_.-]+]][@in] = %[[B11:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT3]], %[[N6]]
// TEMPLATED: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE8:[a-zA-Z0-9_.-]+]] = arith.select %[[READY4]], %[[N7]], %[[N6]]
// TEMPLATED: %[[N8:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY5:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE8]], %[[N8]]
// TEMPLATED: scf.if %[[READY5]] {
// TEMPLATED: %[[COUNT4:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@count]
// TEMPLATED: %[[N9:[a-zA-Z0-9_.-]+]] = arith.constant 6 : index
// TEMPLATED: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT4]], %[[N9]]
// TEMPLATED: pod.write %[[STATE2]][@count] = %[[REMAINING2]]
// TEMPLATED: %[[N10:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY6:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N10]]
// TEMPLATED: scf.if %[[READY6]] {
// TEMPLATED: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE2]][@params]
// TEMPLATED: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2]][@in]
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @C::@C::@compute(%[[IN4]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@C::@C<[@"$tag$in$b$b$tag1", @"$tag$in$b$tag3"]>>
// TEMPLATED: pod.write %[[STATE2]][@comp] = %[[CHILD2]]
// TEMPLATED: function.return %[[VALUE9:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[FIELD10:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10]][@C_[[MEMBER1]]]
// TEMPLATED: %[[FIELD11:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10]][@C_[[MEMBER1]]$inputs]
// TEMPLATED: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE11:[a-zA-Z0-9_.-]+]][@b]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@a]
// TEMPLATED: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[B12]][@a]
// TEMPLATED: constrain.eq %[[A11]], %[[A12]]
// TEMPLATED: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@b]
// TEMPLATED: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[B12]][@b]
// TEMPLATED: constrain.eq %[[B13]], %[[B14]]
// TEMPLATED: %[[VALUE12:[a-zA-Z0-9_.-]+]] = felt.const  5 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE13:[a-zA-Z0-9_.-]+]], %[[VALUE12]]
// TEMPLATED: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE11]][@b]
// TEMPLATED: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@in]
// TEMPLATED: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@a]
// TEMPLATED: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[B15]][@a]
// TEMPLATED: constrain.eq %[[A13]], %[[A14]]
// TEMPLATED: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@b]
// TEMPLATED: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[B15]][@b]
// TEMPLATED: constrain.eq %[[B16]], %[[B17]]
// TEMPLATED: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  99 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE15:[a-zA-Z0-9_.-]+]], %[[VALUE14]]
// TEMPLATED: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD11]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$b$tag1"
// TEMPLATED: poly.param @"$tag$in$tag3"
// TEMPLATED-LABEL: struct.def @C {
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[VALUE16:[a-zA-Z0-9_.-]+]] = felt.const  3 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE17:[a-zA-Z0-9_.-]+]], %[[VALUE16]]
// TEMPLATED: function.return
