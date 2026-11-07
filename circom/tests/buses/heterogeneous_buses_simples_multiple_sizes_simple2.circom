// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n];
    signal b[n];
}

template A(n){
    Simple(n) input in;
    Simple(n) output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.b;
        out.b <== in.a;
    }
}

template B(n1, n2, n3){
    Simple(n1) input in1;
    Simple(n2) input in2;
    Simple(n3) input in3;
    signal output out[3];

    var sizes[3] = [n1, n2, n3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i]);
        if (i == 0){
            aux[i].in.a <== in1.a;
            aux[i].in.b <== in1.b;
        } else if (i == 1){
            aux[i].in.a <== in2.a;
            aux[i].in.b <== in2.b;
        } else{
            aux[i].in.a <== in3.a;
            aux[i].in.b <== in3.b;
        }
        out[i] <== aux[i].out.b[0];
    }
}

component main = B(2, 3, 2);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[VALUE3:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: pod.write %[[VALUE3]][@b] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE6:[0-9a-zA-Z_.-]+]][@b]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[B4]]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE6]][@a]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[A5]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_2 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[IN1:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}} : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE: pod.write %[[IDX_21:[0-9a-zA-Z_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@idx_2] = %[[IDX_21]]
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_22:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_22]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[IDX_22]][@params]
// CONCRETE: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN2]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_1::@A_1::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
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
// TEMPLATED: poly.param @n1 : index
// TEMPLATED: poly.param @n2 : index
// TEMPLATED: poly.param @n3 : index
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[IN1:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}} : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED: pod.write %[[ELEMENT1:[0-9a-zA-Z_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE6:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE6]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@count]
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: pod.write %[[ELEMENT2]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N4]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@params]
// TEMPLATED: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@in]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%{{[0-9a-zA-Z_.-]+}})} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT2]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
