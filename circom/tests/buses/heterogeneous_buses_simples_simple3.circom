// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Simple case, array of buses as inputs, different sizes in the arrays
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(){
    signal a;
    signal b;
}

template A(n){
    Simple input in[n];
    Simple output out[n];

    if (n % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < n; i++){
            out[i].a <== in[i].b;
            out[i].b <== in[i].a;
        }
    }
}

template B(n1, n2, n3){
    Simple input in1[n1];
    Simple input in2[n2];
    Simple input in3[n3];
    Simple output out[3];

    var sizes[3] = [n1, n2, n3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i]);
        for (var j = 0; j < sizes[i]; j++){
            if (i == 0){
                aux[i].in[j] <== in1[j];
            } else if (i == 1){
                aux[i].in[j] <== in2[j];
            } else{
                aux[i].in[j] <== in3[j];
            }
        }
        out[i] <== aux[i].out[0];
    }
}

component main = B(2, 3, 2);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE2:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE2]]]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT3:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %[[ELEMENT3]]
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@b] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE8:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@b]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[B4]]
// CONCRETE: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE8]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[A5]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_2 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[IN1:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}} : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
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
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN2]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_1::@A_1::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT1:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %[[ELEMENT1]]
// TEMPLATED: pod.write %{{[0-9a-zA-Z_.-]+}}[@b] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE5:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6:[0-9a-zA-Z_.-]+]]{{\[}}%[[VALUE5]]]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@b]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[B3]]
// TEMPLATED: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@b]
// TEMPLATED: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[B4]]
// TEMPLATED: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@b]
// TEMPLATED: constrain.eq %[[B5]], %[[A5]]
// TEMPLATED: function.return
// TEMPLATED: poly.param @n1 : index
// TEMPLATED: poly.param @n2 : index
// TEMPLATED: poly.param @n3 : index
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>
// TEMPLATED: struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[IN1:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}} : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>
// TEMPLATED: pod.write %[[ELEMENT10:[0-9a-zA-Z_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE12:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE12]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 2 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[ELEMENT11]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@params]
// TEMPLATED: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@in]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%{{[0-9a-zA-Z_.-]+}})} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT11]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
