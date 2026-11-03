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

template B(){
    miBus(3) input in;
    miBus(3) output out[3] <== [in, in, in];
}

template A(){
    miBus(3) input in[3];

    miBus(3) output out[3][3] <== [in, B()(in[1]), in];

    in[1].a === out[1][1].a;
}

component main = A();

// Check bus/array layouts and the operands of nested writes and equalities.
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B_0::@B_0<[]>>
// CONCRETE: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT1:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE1:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE1]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// CONCRETE: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 2 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@params]
// CONCRETE: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B_0::@B_0::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B_0::@B_0<[]>>
// CONCRETE: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3]][@B_[[MEMBER0]]]
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3]][@B_[[MEMBER0]]$inputs]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE4:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@in]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@a]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@b]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE7:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE4]]{{\[}}%[[VALUE7]]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@b]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD2]][@out]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE8:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE9]]]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A5]], %[[A6]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[B6]]
// CONCRETE: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE10:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE11:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE4]]{{\[}}%[[VALUE11]]]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@a]
// CONCRETE: constrain.eq %[[A7]], %[[A8]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE4]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@a]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]], %[[VALUE14:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A10]]
// CONCRETE: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@in]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_0 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[VALUE15:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]] = %[[VALUE17:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE18:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE19:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD5]]{{\[}}%[[VALUE20:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@a]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE21:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@b]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE21]][@b]
// CONCRETE: constrain.eq %[[B9]], %[[B10]]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD5]]{{\[}}%[[VALUE22:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CONCRETE: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE21]][@a]
// CONCRETE: constrain.eq %[[A13]], %[[A14]]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@b]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE21]][@b]
// CONCRETE: constrain.eq %[[B11]], %[[B12]]
// CONCRETE: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD5]]{{\[}}%[[VALUE23:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// CONCRETE: %[[A16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE21]][@a]
// CONCRETE: constrain.eq %[[A15]], %[[A16]]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@b]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE21]][@b]
// CONCRETE: constrain.eq %[[B13]], %[[B14]]
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<3,3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: struct.member @B_[[MEMBER0:[0-9]+_[0-9]+]] : !struct.type<@B::@B<[]>>
// TEMPLATED: struct.member @B_[[MEMBER0]]$inputs : !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[POD1:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT1:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE1:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE1]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 2 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@in]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @B::@B::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@B::@B<[]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3]][@B_[[MEMBER0]]]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3]][@B_[[MEMBER0]]$inputs]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE4:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@in]
// TEMPLATED: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@a]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: constrain.eq %[[A1]], %[[A2]]
// TEMPLATED: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[IN2]][@b]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@b]
// TEMPLATED: constrain.eq %[[B1]], %[[B2]]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[FIELD2]][@out]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE6:[a-zA-Z0-9_.-]+]], %[[VALUE7:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE8:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE6]], %[[VALUE7]]]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: constrain.eq %[[A3]], %[[A4]]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@b]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: constrain.eq %[[B3]], %[[B4]]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE4]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]], %[[VALUE11:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: constrain.eq %[[A5]], %[[A6]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@in]
// TEMPLATED: function.return
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE12:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD5]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE13]]]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@a]
// TEMPLATED: constrain.eq %[[A7]], %[[A8]]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@b]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// TEMPLATED: constrain.eq %[[B5]], %[[B6]]
// TEMPLATED: function.return
