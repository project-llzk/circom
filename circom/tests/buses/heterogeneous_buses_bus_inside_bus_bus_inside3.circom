// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Simple case, array of buses as inputs, different sizes in the arrays
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
    Compuesto input in[n];
    Compuesto output out[n];

    if (n % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < n; i++){
            out[i].a <== in[i].a;
            out[i].b <== in[i].b;
            out[i].c.a <== in[i].c.b;
            out[i].c.b <== in[i].c.a;
        }
    }
}

template B(n1, n2, n3){
    Compuesto input in1[n1];
    Compuesto input in2[n2];
    Compuesto input in3[n3];
    Compuesto output out[3];

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

component main = B(5, 4, 2);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT1:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %[[ELEMENT1]]
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@b] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@c] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE5:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A2]]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CONCRETE: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@b]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[B3]][@a]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[B2]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@c]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@b]
// CONCRETE: %[[ELEMENT9:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT9]][@c]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[C3]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[B4]]
// CONCRETE: %[[ELEMENT10:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@c]
// CONCRETE: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[C4]][@a]
// CONCRETE: %[[ELEMENT11:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@c]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[C5]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[A7]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !array.type<4 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT12:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE15:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT13:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE15]]]
// CONCRETE: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CONCRETE: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT13]][@a]
// CONCRETE: constrain.eq %[[A8]], %[[A9]]
// CONCRETE: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT12]][@b]
// CONCRETE: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT13]][@b]
// CONCRETE: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[B6]][@a]
// CONCRETE: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[B7]][@a]
// CONCRETE: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[C6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT12]][@c]
// CONCRETE: %[[C7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT13]][@c]
// CONCRETE: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[C6]][@a]
// CONCRETE: %[[A13:[0-9a-zA-Z_.-]+]] = pod.read %[[C7]][@a]
// CONCRETE: constrain.eq %[[A12]], %[[A13]]
// CONCRETE: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[C6]][@b]
// CONCRETE: %[[B9:[0-9a-zA-Z_.-]+]] = pod.read %[[C7]][@b]
// CONCRETE: constrain.eq %[[B8]], %[[B9]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT14:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE18:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT15:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE18]]]
// CONCRETE: %[[A14:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT14]][@a]
// CONCRETE: %[[A15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT15]][@a]
// CONCRETE: constrain.eq %[[A14]], %[[A15]]
// CONCRETE: %[[B10:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT14]][@b]
// CONCRETE: %[[B11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT15]][@b]
// CONCRETE: %[[A16:[0-9a-zA-Z_.-]+]] = pod.read %[[B10]][@a]
// CONCRETE: %[[A17:[0-9a-zA-Z_.-]+]] = pod.read %[[B11]][@a]
// CONCRETE: constrain.eq %[[A16]], %[[A17]]
// CONCRETE: %[[C8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT14]][@c]
// CONCRETE: %[[C9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT15]][@c]
// CONCRETE: %[[A18:[0-9a-zA-Z_.-]+]] = pod.read %[[C8]][@a]
// CONCRETE: %[[A19:[0-9a-zA-Z_.-]+]] = pod.read %[[C9]][@a]
// CONCRETE: constrain.eq %[[A18]], %[[A19]]
// CONCRETE: %[[B12:[0-9a-zA-Z_.-]+]] = pod.read %[[C8]][@b]
// CONCRETE: %[[B13:[0-9a-zA-Z_.-]+]] = pod.read %[[C9]][@b]
// CONCRETE: constrain.eq %[[B12]], %[[B13]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, @idx_1: !pod.type<[@in: !array.type<4 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, @idx_2: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[IN1:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}} : <2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// CONCRETE: pod.write %[[IDX_21:[0-9a-zA-Z_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@idx_2] = %[[IDX_21]]
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_22:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 4 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_22]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[IDX_22]][@params]
// CONCRETE: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A_2::@A_2::@compute(%[[IN2]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_1::@A_1::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!array.type<4 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_0::@A_0::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT1:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %[[ELEMENT1]]
// TEMPLATED: pod.write %{{[0-9a-zA-Z_.-]+}}[@b] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: pod.write %{{[0-9a-zA-Z_.-]+}}[@c] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE5:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6:[0-9a-zA-Z_.-]+]]{{\[}}%[[VALUE5]]]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@b]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[B2]][@a]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[B3]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[C2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@c]
// TEMPLATED: %[[C3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@c]
// TEMPLATED: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@a]
// TEMPLATED: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[C3]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@b]
// TEMPLATED: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[C3]][@b]
// TEMPLATED: constrain.eq %[[B4]], %[[B5]]
// TEMPLATED: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A8]]
// TEMPLATED: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@b]
// TEMPLATED: %[[ELEMENT9:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT9]][@b]
// TEMPLATED: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[B7]][@a]
// TEMPLATED: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[B6]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[ELEMENT10:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[C4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@c]
// TEMPLATED: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[C4]][@b]
// TEMPLATED: %[[ELEMENT11:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[C5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@c]
// TEMPLATED: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[C5]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[B8]]
// TEMPLATED: %[[ELEMENT12:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[C6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT12]][@c]
// TEMPLATED: %[[A13:[0-9a-zA-Z_.-]+]] = pod.read %[[C6]][@a]
// TEMPLATED: %[[ELEMENT13:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[C7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT13]][@c]
// TEMPLATED: %[[B9:[0-9a-zA-Z_.-]+]] = pod.read %[[C7]][@b]
// TEMPLATED: constrain.eq %[[B9]], %[[A13]]
// TEMPLATED: function.return
// TEMPLATED: poly.param @n1 : index
// TEMPLATED: poly.param @n2 : index
// TEMPLATED: poly.param @n3 : index
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED: struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[IN1:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}} : <#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>, !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>
// TEMPLATED: pod.write %[[ELEMENT15:[0-9a-zA-Z_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT16:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE16:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE16]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT16]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 4 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[ELEMENT16]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT16]][@params]
// TEMPLATED: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT15]][@in]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%{{[0-9a-zA-Z_.-]+}})} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT16]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
