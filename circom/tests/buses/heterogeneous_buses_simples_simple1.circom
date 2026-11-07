// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Simple case, same buses for all the elements in the heterogeneus array of components
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(){
    signal a;
    signal b;
}

template A(n){
    Simple input in;
    Simple output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.b;
        out.b <== in.a;
    }
}

template B(n){
    Simple input in[3];
    Simple output out[3];

    for (var i = 0; i < 3; i++){
        out[i] <== A(n[i])(in[i]);
    }
}

component main = B([2, 2, 2]);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_1 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: struct.member @A_[[MEMBER0:[0-9]+_[0-9]+]] : !array.type<3 x !struct.type<@A_0::@A_0<[]>>>
// CONCRETE: struct.member @A_[[MEMBER0]]$inputs : !array.type<3 x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[VALUE3:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// CONCRETE: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE3]], %[[N3]]
// CONCRETE: scf.if %[[READY2]] {
// CONCRETE: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@count]
// CONCRETE: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// CONCRETE: pod.write %[[ELEMENT3]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[ELEMENT3]][@params]
// CONCRETE: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN1]]) : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[ELEMENT3]][@comp] = %[[CHILD1]]
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[VALUE1:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: pod.write %[[VALUE1]][@b] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4:[0-9a-zA-Z_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[B3]]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[B4]]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@a]
// TEMPLATED: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: constrain.eq %[[B5]], %[[A5]]
// TEMPLATED: function.return
// TEMPLATED: poly.expr @"anon_var_[[MEMBER0:[0-9]+_[0-9]+]]@[[OFFSET0:[0-9]+]]" {
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: struct.member @A_[[MEMBER1:[0-9]+_[0-9]+]] : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @A_[[MEMBER1]]$inputs : !array.type<@"anon_var_[[MEMBER0]]@[[OFFSET0]]" x !pod.type<[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT1:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE5:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE5]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[ELEMENT3]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@params]
// TEMPLATED: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@in]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A::@A::@compute(%[[IN1]]) {(%{{[0-9a-zA-Z_.-]+}})} : (!pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT3]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
