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
        if (i == 0){
            aux[i].in <== in1;
        } else if (i == 1){
            for (var j = 0; j < sizes[i]; j++){
                aux[i].in[j] <== in2[j];
            }
        } else{
            aux[i].in <== in3;
        }
        out[i] <== aux[i].out[0];
    }
}

component main = B(2, 3, 5);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%[[VALUE2]]]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[B1]][@a]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[C1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@c]
// CONCRETE: %[[C2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@c]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[C1]][@a]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@a]
// CONCRETE: constrain.eq %[[A5]], %[[A6]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[C1]][@b]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT3:[a-zA-Z0-9_.-]+]][@a] = %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: array.write %{{[a-zA-Z0-9_.-]+}}{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[ELEMENT3]]
// CONCRETE: pod.write %{{[a-zA-Z0-9_.-]+}}[@b] = %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: pod.write %{{[a-zA-Z0-9_.-]+}}[@c] = %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE8:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A8]]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE8]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@b]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[B7]][@a]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@a]
// CONCRETE: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE8]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@c]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@b]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@c]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@a]
// CONCRETE: constrain.eq %[[A12]], %[[B8]]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE8]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@c]
// CONCRETE: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@a]
// CONCRETE: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@c]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[C7]][@b]
// CONCRETE: constrain.eq %[[B9]], %[[A13]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT14:[a-zA-Z0-9_.-]+]][@a] = %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: array.write %{{[a-zA-Z0-9_.-]+}}{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[ELEMENT14]]
// CONCRETE: pod.write %{{[a-zA-Z0-9_.-]+}}[@b] = %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: pod.write %{{[a-zA-Z0-9_.-]+}}[@c] = %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// CONCRETE: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT17]][@a]
// CONCRETE: %[[ELEMENT18:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A16:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT18]][@a]
// CONCRETE: constrain.eq %[[A16]], %[[A15]]
// CONCRETE: %[[ELEMENT19:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT19]][@b]
// CONCRETE: %[[ELEMENT20:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT20]][@b]
// CONCRETE: %[[A17:[a-zA-Z0-9_.-]+]] = pod.read %[[B12]][@a]
// CONCRETE: %[[A18:[a-zA-Z0-9_.-]+]] = pod.read %[[B11]][@a]
// CONCRETE: constrain.eq %[[A17]], %[[A18]]
// CONCRETE: %[[ELEMENT21:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT21]][@c]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[C9]][@b]
// CONCRETE: %[[ELEMENT22:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT22]][@c]
// CONCRETE: %[[A19:[a-zA-Z0-9_.-]+]] = pod.read %[[C10]][@a]
// CONCRETE: constrain.eq %[[A19]], %[[B13]]
// CONCRETE: %[[ELEMENT23:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT23]][@c]
// CONCRETE: %[[A20:[a-zA-Z0-9_.-]+]] = pod.read %[[C11]][@a]
// CONCRETE: %[[ELEMENT24:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT24]][@c]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[C12]][@b]
// CONCRETE: constrain.eq %[[B14]], %[[A20]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, @idx_2: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[IDX_01:[a-zA-Z0-9_.-]+]][@in] = %{{[a-zA-Z0-9_.-]+}} : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: pod.write %{{[a-zA-Z0-9_.-]+}}[@idx_0] = %[[IDX_01]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 8 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_02]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[IDX_02]][@params]
// CONCRETE: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_01]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN1]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[IDX_02]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @A_2::@A_2::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @A_1::@A_1::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<@n x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT1:[a-zA-Z0-9_.-]+]][@a] = %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: array.write %{{[a-zA-Z0-9_.-]+}}{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[ELEMENT1]]
// TEMPLATED: pod.write %{{[a-zA-Z0-9_.-]+}}[@b] = %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: pod.write %{{[a-zA-Z0-9_.-]+}}[@c] = %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE5]]]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@b]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[B2]][@a]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[B3]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[C2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@c]
// TEMPLATED: %[[C3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@c]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@b]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@b]
// TEMPLATED: constrain.eq %[[B4]], %[[B5]]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A8]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@b]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[B7]][@a]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[B6]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@c]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@b]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@c]
// TEMPLATED: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[B8]]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@c]
// TEMPLATED: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@a]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@c]
// TEMPLATED: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[C7]][@b]
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
// TEMPLATED: pod.write %[[ELEMENT14:[a-zA-Z0-9_.-]+]][@in] = %{{[a-zA-Z0-9_.-]+}} : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE16:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE16]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// TEMPLATED: %[[VALUE17:[a-zA-Z0-9_.-]+]] = arith.muli %[[N4]], %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[VALUE17]]
// TEMPLATED: pod.write %[[ELEMENT15]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@params]
// TEMPLATED: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT14]][@in]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[IN1]]) {(%{{[a-zA-Z0-9_.-]+}})} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT15]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
