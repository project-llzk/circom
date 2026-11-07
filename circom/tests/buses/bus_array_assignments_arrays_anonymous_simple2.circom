// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

bus miBus(n){
    signal a;
    signal b;
}

bus otroBus(n){
    miBus(n) a[3];
}

template B(){
    miBus(3) input in;
    miBus(3) output out[3] <== [in, in, in];
}

template A(){
    otroBus(3) input in;
    miBus(3) input in1;

    miBus(3) output out[2][3] <== [in.a, B()(in1)];

    out[0][1].a === in.a[1].a;
    out[1][1].a === in1.a;
}

component main = A();

// Check bus/array layouts and the operands of nested writes and equalities.
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// CONCRETE: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @B_0::@B_0::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@out]
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// CONCRETE: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@in]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@a]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE6:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE8:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[A3]]{{\[}}%[[VALUE8]]]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[FIELD2]][@out]
// CONCRETE: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE10:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE10]]]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[A7]]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@b]
// CONCRETE: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[B6]]
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE6]][@a]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[A9]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A8]], %[[A10]]
// CONCRETE: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD3]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_0 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A13:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@a]
// CONCRETE: %[[A14:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE22:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A13]], %[[A14]]
// CONCRETE: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CONCRETE: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE22]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: %[[ELEMENT9:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT9]][@a]
// CONCRETE: %[[A16:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE22]][@a]
// CONCRETE: constrain.eq %[[A15]], %[[A16]]
// CONCRETE: %[[B9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT9]][@b]
// CONCRETE: %[[B10:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE22]][@b]
// CONCRETE: constrain.eq %[[B9]], %[[B10]]
// CONCRETE: %[[ELEMENT10:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A17:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CONCRETE: %[[A18:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE22]][@a]
// CONCRETE: constrain.eq %[[A17]], %[[A18]]
// CONCRETE: %[[B11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@b]
// CONCRETE: %[[B12:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE22]][@b]
// CONCRETE: constrain.eq %[[B11]], %[[B12]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<2,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[]>>
// TEMPLATED: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE2:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE2]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@in]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @B::@B::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B::@B<[]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4:[0-9a-zA-Z_.-]+]][@out]
// TEMPLATED: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]]
// TEMPLATED: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE4]][@B_[[MEMBER0]]$inputs]
// TEMPLATED: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@in]
// TEMPLATED: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@a]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5:[0-9a-zA-Z_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[A2]]
// TEMPLATED: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[IN2]][@b]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[B2]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[VALUE6:[0-9a-zA-Z_.-]+]][@a]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = struct.readm %[[FIELD2]][@out]
// TEMPLATED: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE7:[0-9a-zA-Z_.-]+]], %[[VALUE8:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE7]], %[[VALUE8]]]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@b]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[B4]]
// TEMPLATED: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE6]][@a]
// TEMPLATED: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[A7]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A8]]
// TEMPLATED: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}, %{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// TEMPLATED: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A10]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD3]][@in]
// TEMPLATED: function.return
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD5]]{{\[}}%[[VALUE16:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE16]]]
// TEMPLATED: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: constrain.eq %[[A11]], %[[A12]]
// TEMPLATED: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@b]
// TEMPLATED: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@b]
// TEMPLATED: constrain.eq %[[B5]], %[[B6]]
// TEMPLATED: function.return
