// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Simple case, same buses for all the elements in the heterogeneus array of components.
// The bus contains other buses
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(){
    signal a;
    signal b;
}

bus Simple1(){
    signal a;
}

bus Compuesto(){
    signal a;
    Simple1 b;
    Simple c;
}

template A(n){
    Compuesto input in;
    Compuesto output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.a;
        out.b <== in.b;
        out.c.a <== in.c.b;
        out.c.b <== in.c.a;
    }
}

template B(n){
    Compuesto input in[3];
    Compuesto output out[3];

    for (var i = 0; i < 3; i++){
        out[i] <== A(n[i])(in[i]);
    }
}

component main = B([2, 4, 5]);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE1:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2]][@b]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[B1]][@a]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[C1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@c]
// CONCRETE: %[[C2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2]][@c]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[C1]][@a]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@a]
// CONCRETE: constrain.eq %[[A5]], %[[A6]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[C1]][@b]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A7]], %[[A8]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@b]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[B5]][@a]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A10]]
// CONCRETE: %[[C3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@c]
// CONCRETE: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@c]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@a]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[VALUE5:[a-zA-Z0-9_.-]+]][@a] = %[[A13:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE5]][@b] = %[[B9:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE5]][@c] = %[[C5:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE6:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE7:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE8:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@a]
// CONCRETE: constrain.eq %[[A15]], %[[A14]]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE8]][@b]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@b]
// CONCRETE: %[[A16:[a-zA-Z0-9_.-]+]] = pod.read %[[B11]][@a]
// CONCRETE: %[[A17:[a-zA-Z0-9_.-]+]] = pod.read %[[B10]][@a]
// CONCRETE: constrain.eq %[[A16]], %[[A17]]
// CONCRETE: %[[C6:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE8]][@c]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@b]
// CONCRETE: %[[C7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@c]
// CONCRETE: %[[A18:[a-zA-Z0-9_.-]+]] = pod.read %[[C7]][@a]
// CONCRETE: constrain.eq %[[A18]], %[[B12]]
// CONCRETE: %[[C8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE8]][@c]
// CONCRETE: %[[A19:[a-zA-Z0-9_.-]+]] = pod.read %[[C8]][@a]
// CONCRETE: %[[C9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@c]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[C9]][@b]
// CONCRETE: constrain.eq %[[B13]], %[[A19]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: struct.member @A_[[MEMBER0:[0-9]+_[0-9]+]] : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @A_[[MEMBER0]]$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[IDX_21:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT1:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE: pod.write %[[VALUE9:[a-zA-Z0-9_.-]+]][@idx_2] = %[[IDX_21]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_22]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22]][@params]
// CONCRETE: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_2::@A_2::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @A_1::@A_1::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: function.return %[[VALUE10:[a-zA-Z0-9_.-]+]]

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[VALUE1:[a-zA-Z0-9_.-]+]][@a] = %[[A1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[VALUE1]][@b] = %[[B1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[VALUE1]][@c] = %[[C1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@a]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[B3]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[C2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@c]
// TEMPLATED: %[[C3:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@c]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@b]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@b]
// TEMPLATED: constrain.eq %[[B4]], %[[B5]]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@a]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A8]]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[B7]][@a]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@c]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@b]
// TEMPLATED: %[[C5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@c]
// TEMPLATED: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[B8]]
// TEMPLATED: %[[C6:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@c]
// TEMPLATED: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@a]
// TEMPLATED: %[[C7:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@c]
// TEMPLATED: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[C7]][@b]
// TEMPLATED: constrain.eq %[[B9]], %[[A13]]
// TEMPLATED: function.return
// TEMPLATED: poly.expr @"anon_var_[[MEMBER0:[0-9]+_[0-9]+]]@[[OFFSET0:[0-9]+]]" {
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED: struct.member @A_[[MEMBER1:[0-9]+_[0-9]+]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @A_[[MEMBER1]]$inputs : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT1:[a-zA-Z0-9_.-]+]][@in] = %[[ELEMENT2:[a-zA-Z0-9_.-]+]] : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE5:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE5]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[ELEMENT3]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@params]
// TEMPLATED: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@in]
// TEMPLATED: %[[N6:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[IN1]]) {(%[[VALUE6:[a-zA-Z0-9_.-]+]])} : (!pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT3]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE7:[a-zA-Z0-9_.-]+]]
