// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Array of buses with different sizes as inputs
// The bus contains other buses
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n];
    signal b[n];
}

bus Simple1(n){
    signal a[n];
}

bus Compuesto(n,m){
    signal a[m]; //3
    Simple1(n) b[m]; //6
    Simple(n) c; //4
}

template A(n1, n2, m){
    Compuesto(n1, n2) input in[m];
    Compuesto(n1, n2) output out[m];

    if (n1 % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < m; i++){
            out[i].a <== in[i].a;
            out[i].b <== in[i].b;
            out[i].c.a <== in[i].c.b;
            out[i].c.b <== in[i].c.a;
        }
    }
}

template B(n1,n1a, m1, n2,n2a, m2, n3,n3a, m3){
    Compuesto(n1,n1a) input in1[m1];// 26
    Compuesto(n2,n2a) input in2[m2];// 26
    Compuesto(n3,n3a) input in3[m3];// 26
    signal output out[3];

    var sizes_n[3] = [n1, n2, n3];
    var sizes_a[3] = [n1a, n2a, n3a];
    var sizes_m[3] = [m1, m2, m3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes_n[i], sizes_a[i], sizes_m[i]);

        for (var l = 0; l < sizes_m[i]; l++){
            if (i == 0){
                for (var j_m = 0; j_m < sizes_a[i]; j_m++){
                    aux[i].in[l].a[j_m] <== in1[l].a[j_m];
                    for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                        aux[i].in[l].b[j_m].a[j_n] <== in1[l].b[j_m].a[j_n];
                    }
                }
            } else if (i == 1){
                for (var j_m = 0; j_m < sizes_a[i]; j_m++){
                    aux[i].in[l].a[j_m] <== in2[l].a[j_m];
                    aux[i].in[l].b[j_m].a <== in2[l].b[j_m].a;
                }
            } else{
                aux[i].in[l].a <== in3[l].a;
                aux[i].in[l].b <== in3[l].b;
            }
            for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                aux[i].in[l].c.a[j_n] <== in3[l].c.a[j_n];
                aux[i].in[l].c.b[j_n] <== in3[l].c.b[j_n];
            }
        }
        out[i] <== aux[i].out[0].b[0].a[0];
    }
}

component main = B(2, 6, 6, 2,7,8,32,5,21);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<6 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE1:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE3:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2]]]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[B1]]{{\[}}%[[VALUE4:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE4]]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
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
// CONCRETE: struct.member @out : !array.type<8 x !pod.type<[@a: !array.type<7 x !felt.type<"bn128">>, @b: !array.type<7 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE6:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE7:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE6]]]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A7]], %[[A8]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CONCRETE: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[B5]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE8]]]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A10]]
// CONCRETE: %[[C3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@c]
// CONCRETE: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@c]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@a]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !array.type<21 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>, @b: !array.type<32 x !felt.type<"bn128">>]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE9:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE11:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE10]]]
// CONCRETE: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@a]
// CONCRETE: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CONCRETE: constrain.eq %[[A13]], %[[A14]]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@b]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@b]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[B9]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B10]]{{\[}}%[[VALUE12]]]
// CONCRETE: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@a]
// CONCRETE: %[[A16:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CONCRETE: constrain.eq %[[A15]], %[[A16]]
// CONCRETE: %[[C5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@c]
// CONCRETE: %[[C6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@c]
// CONCRETE: %[[A17:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@a]
// CONCRETE: %[[A18:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@a]
// CONCRETE: constrain.eq %[[A17]], %[[A18]]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@b]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@b]
// CONCRETE: constrain.eq %[[B11]], %[[B12]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<6 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>]>, @idx_1: !pod.type<[@in: !array.type<8 x !pod.type<[@a: !array.type<7 x !felt.type<"bn128">>, @b: !array.type<7 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>]>, @idx_2: !pod.type<[@in: !array.type<21 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>, @b: !array.type<32 x !felt.type<"bn128">>]>]>>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[A19:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT13:[a-zA-Z0-9_.-]+]] : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE: pod.write %[[ELEMENT14:[a-zA-Z0-9_.-]+]][@a] = %[[A19]]
// CONCRETE: array.write %[[IN1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE14:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT14]]
// CONCRETE: pod.write %[[IDX_21:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %[[VALUE15:[a-zA-Z0-9_.-]+]][@idx_2] = %[[IDX_21]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_22]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22]][@params]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_2::@A_2::@compute(%[[IN2]]) : (!array.type<21 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>, @b: !array.type<32 x !felt.type<"bn128">>]>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @A_1::@A_1::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!array.type<8 x !pod.type<[@a: !array.type<7 x !felt.type<"bn128">>, @b: !array.type<7 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN4:[a-zA-Z0-9_.-]+]]) : (!array.type<6 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: function.return %[[VALUE16:[a-zA-Z0-9_.-]+]]

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n1 : index
// TEMPLATED: poly.param @n2 : index
// TEMPLATED: poly.param @m : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<@m x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT1:[a-zA-Z0-9_.-]+]][@a] = %[[A1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: array.write %[[VALUE1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT1]]
// TEMPLATED: pod.write %[[ELEMENT2:[a-zA-Z0-9_.-]+]][@b] = %[[B1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[ELEMENT3:[a-zA-Z0-9_.-]+]][@c] = %[[C1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.return %[[VALUE3:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE5]]]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@b]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE7:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE7]]]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[C2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@c]
// TEMPLATED: %[[C3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@c]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@b]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@b]
// TEMPLATED: constrain.eq %[[B4]], %[[B5]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@a]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A8]]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@b]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE11:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@b]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE12]]]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT14]][@c]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@b]
// TEMPLATED: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE14:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[C5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@c]
// TEMPLATED: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[B8]]
// TEMPLATED: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[C6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@c]
// TEMPLATED: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@a]
// TEMPLATED: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[C7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT17]][@c]
// TEMPLATED: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[C7]][@b]
// TEMPLATED: constrain.eq %[[B9]], %[[A13]]
// TEMPLATED: function.return
// TEMPLATED: poly.param @n1 : index
// TEMPLATED: poly.param @n1a : index
// TEMPLATED: poly.param @m1 : index
// TEMPLATED: poly.param @n2 : index
// TEMPLATED: poly.param @n2a : index
// TEMPLATED: poly.param @m2 : index
// TEMPLATED: poly.param @n3 : index
// TEMPLATED: poly.param @n3a : index
// TEMPLATED: poly.param @m3 : index
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[A14:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE17:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT18:[a-zA-Z0-9_.-]+]] : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED: pod.write %[[ELEMENT19:[a-zA-Z0-9_.-]+]][@a] = %[[A14]]
// TEMPLATED: array.write %[[IN1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE18:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT19]]
// TEMPLATED: pod.write %[[ELEMENT20:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT21:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE19:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE19]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT21]][@count]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[ELEMENT21]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT21]][@params]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT20]][@in]
// TEMPLATED: %[[N11:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@n1]
// TEMPLATED: %[[N21:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@n2]
// TEMPLATED: %[[M1:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@m]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%[[VALUE20:[a-zA-Z0-9_.-]+]]), (%[[VALUE21:[a-zA-Z0-9_.-]+]]), (%[[VALUE22:[a-zA-Z0-9_.-]+]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT21]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE23:[a-zA-Z0-9_.-]+]]
