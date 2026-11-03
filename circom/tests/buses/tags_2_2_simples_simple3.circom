// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus Bus1(){
    signal a[5];
    signal {value} b[2];
}

template B(){
    Bus1 input in;
    Bus1 output out <== in;

    in.b.value === 77;
}

template A(){
    signal input a[5];
    signal output b[5];

    signal {value} s;
    s.value = 77;
    s<== 4;

    signal {value} s1;
    s1.value = 77;
    s1 <== 2;

    Bus1 aux;
    aux.a <== a;
    aux.b[0] <== s1;
    aux.b[1] <== s;

    aux.b.value === 77;

    Bus1 output out <== B()(aux);

    b <== a;
}

component main = A();

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @b : !array.type<5 x !felt.type<"bn128">>
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[VALUE1:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
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
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B_0::@B_0::@compute(%[[IN1]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %[[VALUE3:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@b]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@out]
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s1]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[VALUE5:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD3]], %[[VALUE5]]
// CONCRETE: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// CONCRETE: constrain.eq %[[FIELD4]], %[[VALUE6]]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[VALUE7:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[B1]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT1]], %[[FIELD4]]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT2]], %[[FIELD3]]
// CONCRETE: %[[VALUE10:[a-zA-Z0-9_.-]+]] = felt.const  77 : <"bn128">
// CONCRETE: %[[VALUE11:[a-zA-Z0-9_.-]+]] = felt.const  77 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE10]], %[[VALUE11]]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@a]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// CONCRETE: constrain.eq %[[A2]], %[[A3]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@b]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD6]][@out]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[B6]]
// CONCRETE: constrain.eq %[[FIELD1]], %[[VALUE7]]
// CONCRETE: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE12:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@a]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE13:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[A7]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE13]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  77 : <"bn128">
// CONCRETE: %[[VALUE15:[a-zA-Z0-9_.-]+]] = felt.const  77 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE14]], %[[VALUE15]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @b : !array.type<5 x !felt.type<"bn128">>
// TEMPLATED: struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[77]>>
// TEMPLATED: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[VALUE1:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
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
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B::@B::@compute(%[[IN1]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@B::@B<[77]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE3:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@b]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@s1]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@aux]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@out]
// TEMPLATED: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// TEMPLATED: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// TEMPLATED: %[[VALUE5:[a-zA-Z0-9_.-]+]] = felt.const  4 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD2]], %[[VALUE5]]
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = felt.const  2 : <"bn128">
// TEMPLATED: constrain.eq %[[FIELD3]], %[[VALUE6]]
// TEMPLATED: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[VALUE7:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[B1]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT1]], %[[FIELD3]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT2]], %[[FIELD2]]
// TEMPLATED: %[[VALUE10:[a-zA-Z0-9_.-]+]] = felt.const  77 : <"bn128">
// TEMPLATED: %[[VALUE11:[a-zA-Z0-9_.-]+]] = felt.const  77 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE10]], %[[VALUE11]]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@a]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@b]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[B4]]
// TEMPLATED: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD6]][@out]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@a]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@b]
// TEMPLATED: constrain.eq %[[B5]], %[[B6]]
// TEMPLATED: constrain.eq %[[FIELD1]], %[[VALUE7]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$b$value"
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE12:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE13:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@b]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE13]][@b]
// TEMPLATED: constrain.eq %[[B7]], %[[B8]]
// TEMPLATED: %[[VALUE14:[a-zA-Z0-9_.-]+]] = felt.const  77 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE15:[a-zA-Z0-9_.-]+]], %[[VALUE14]]
// TEMPLATED: function.return
