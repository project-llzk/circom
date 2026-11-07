// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus Bus1(){
    signal a[5];
    signal {binary} b;
}

template B(){
    Bus1 input in;
    Bus1 output out <== in;

    in.b.binary === 19;
}

template A(){
    signal input a[5];
    signal output b[5];

    Bus1 aux;
    aux.b.binary = 19;
    aux.a <== a;
    aux.b <== 0;

    aux.b.binary === 19;

    Bus1 output out <== B()(aux);

    b <== a;
}

component main = A();

// Check tag-dependent layouts, calls, and the values used by explicit equalities.
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @b : !array.type<5 x !felt.type<"bn128">>
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 6 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// CONCRETE: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @B_0::@B_0::@compute(%[[IN1]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@b]
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@out]
// CONCRETE: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@aux]
// CONCRETE: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// CONCRETE: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[VALUE5:[0-9a-zA-Z_.-]+]]
// CONCRETE: %[[VALUE6:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[VALUE6]]
// CONCRETE: %[[VALUE7:[0-9a-zA-Z_.-]+]] = felt.const  19 : <"bn128">
// CONCRETE: %[[VALUE8:[0-9a-zA-Z_.-]+]] = felt.const  19 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE7]], %[[VALUE8]]
// CONCRETE: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@in]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@a]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@a]
// CONCRETE: constrain.eq %[[A2]], %[[A3]]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@b]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@b]
// CONCRETE: constrain.eq %[[B2]], %[[B3]]
// CONCRETE: %[[FIELD6:[0-9a-zA-Z_.-]+]] = struct.readm %[[FIELD4]][@out]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@b]
// CONCRETE: constrain.eq %[[B4]], %[[B5]]
// CONCRETE: constrain.eq %[[FIELD1]], %[[VALUE5]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD5]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD7:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD7]][@a]
// CONCRETE: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[A7]]
// CONCRETE: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD7]][@b]
// CONCRETE: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10]][@b]
// CONCRETE: constrain.eq %[[B6]], %[[B7]]
// CONCRETE: %[[VALUE11:[0-9a-zA-Z_.-]+]] = felt.const  19 : <"bn128">
// CONCRETE: %[[VALUE12:[0-9a-zA-Z_.-]+]] = felt.const  19 : <"bn128">
// CONCRETE: constrain.eq %[[VALUE11]], %[[VALUE12]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @b : !array.type<5 x !felt.type<"bn128">>
// TEMPLATED: struct.member @aux : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[19]>>
// TEMPLATED: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 6 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@in]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @B::@B::@compute(%[[IN1]]) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>) -> !struct.type<@B::@B<[19]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@b]
// TEMPLATED: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@aux]
// TEMPLATED: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@out]
// TEMPLATED: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// TEMPLATED: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// TEMPLATED: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[VALUE5:[0-9a-zA-Z_.-]+]]
// TEMPLATED: %[[VALUE6:[0-9a-zA-Z_.-]+]] = felt.const  0 : <"bn128">
// TEMPLATED: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[VALUE6]]
// TEMPLATED: %[[VALUE7:[0-9a-zA-Z_.-]+]] = felt.const  19 : <"bn128">
// TEMPLATED: %[[VALUE8:[0-9a-zA-Z_.-]+]] = felt.const  19 : <"bn128">
// TEMPLATED: constrain.eq %[[VALUE7]], %[[VALUE8]]
// TEMPLATED: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@in]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@a]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@b]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[B3]]
// TEMPLATED: %[[FIELD6:[0-9a-zA-Z_.-]+]] = struct.readm %[[FIELD4]][@out]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@a]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@b]
// TEMPLATED: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@b]
// TEMPLATED: constrain.eq %[[B4]], %[[B5]]
// TEMPLATED: constrain.eq %[[FIELD1]], %[[VALUE5]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD5]][@in]
// TEMPLATED: function.return
// TEMPLATED: poly.param @"$tag$in$b$binary"
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !felt.type<"bn128">]>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD7:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD7]][@a]
// TEMPLATED: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10:[0-9a-zA-Z_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD7]][@b]
// TEMPLATED: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10]][@b]
// TEMPLATED: constrain.eq %[[B6]], %[[B7]]
// TEMPLATED: %[[VALUE11:[0-9a-zA-Z_.-]+]] = felt.const  19 : <"bn128">
// TEMPLATED: constrain.eq %{{[0-9a-zA-Z_.-]+}}, %[[VALUE11]]
// TEMPLATED: function.return
