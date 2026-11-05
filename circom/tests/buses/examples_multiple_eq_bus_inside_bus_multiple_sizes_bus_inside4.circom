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
                    in1[l].a[j_m] --> aux[i].in[l].a[j_m];
                    in1[l].a[j_m] === aux[i].in[l].a[j_m];
                    for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                        aux[i].in[l].b[j_m].a[j_n] <-- in1[l].b[j_m].a[j_n];
                        aux[i].in[l].b[j_m].a[j_n] === in1[l].b[j_m].a[j_n];
                    }
                }
            } else if (i == 1){
                for (var j_m = 0; j_m < sizes_a[i]; j_m++){
                    aux[i].in[l].a[j_m] <-- in2[l].a[j_m];
                    aux[i].in[l].b[j_m].a <-- in2[l].b[j_m].a;
                    in2[l].a[j_m] === aux[i].in[l].a[j_m];
                    in2[l].b[j_m].a === aux[i].in[l].b[j_m].a;
                }
            } else{
                aux[i].in[l].a <-- in3[l].a;
                aux[i].in[l].b <-- in3[l].b;
                in3[l].a === aux[i].in[l].a;
                aux[i].in[l].b === in3[l].b;
            }
            for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                aux[i].in[l].c.a[j_n] <-- in3[l].c.a[j_n];
                aux[i].in[l].c.b[j_n] <-- in3[l].c.b[j_n];
                aux[i].in[l].c.a[j_n] === in3[l].c.a[j_n];
                in3[l].c.b[j_n] ===  aux[i].in[l].c.b[j_n];
            }
        }
        out[i] <-- aux[i].out[0].b[0].a[0];
        out[i] === aux[i].out[0].b[0].a[0];
    }
}

component main = B(2, 6, 6, 2,7,8,32,5,21);

// Check bus layouts and leaf equalities; component calls follow input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<6 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%[[VALUE2]]]
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
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE6:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%[[VALUE6]]]
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
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %{{[a-zA-Z0-9_.-]+}}[@out]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%[[VALUE10]]]
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
// CONCRETE: array.write %[[A19:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <5 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE: pod.write %[[ELEMENT14:[a-zA-Z0-9_.-]+]][@a] = %[[A19]]
// CONCRETE: array.write %[[IN1:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[ELEMENT14]]
// CONCRETE: pod.write %[[IDX_21:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %{{[a-zA-Z0-9_.-]+}}[@idx_2] = %[[IDX_21]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_22]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[IDX_22]][@params]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_2::@A_2::@compute(%[[IN2]]) : (!array.type<21 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<32 x !felt.type<"bn128">>, @b: !array.type<32 x !felt.type<"bn128">>]>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @A_1::@A_1::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!array.type<8 x !pod.type<[@a: !array.type<7 x !felt.type<"bn128">>, @b: !array.type<7 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = function.call @A_0::@A_0::@compute(%{{[a-zA-Z0-9_.-]+}}) : (!array.type<6 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: function.return %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE17:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE17]][@aux]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE17]][@aux$inputs]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE20:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A20:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@a]
// CONCRETE: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[A20]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_01:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_01]][@in]
// CONCRETE: %[[ELEMENT18:[a-zA-Z0-9_.-]+]] = array.read %[[IN5]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A21:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT18]][@a]
// CONCRETE: %[[ELEMENT19:[a-zA-Z0-9_.-]+]] = array.read %[[A21]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT17]], %[[ELEMENT19]]
// CONCRETE: %[[IDX_02:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02]][@in]
// CONCRETE: %[[ELEMENT20:[a-zA-Z0-9_.-]+]] = array.read %[[IN6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT20]][@b]
// CONCRETE: %[[ELEMENT21:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A22:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT21]][@a]
// CONCRETE: %[[ELEMENT22:[a-zA-Z0-9_.-]+]] = array.read %[[A22]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[ELEMENT23:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE20]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT23]][@b]
// CONCRETE: %[[ELEMENT24:[a-zA-Z0-9_.-]+]] = array.read %[[B14]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A23:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT24]][@a]
// CONCRETE: %[[ELEMENT25:[a-zA-Z0-9_.-]+]] = array.read %[[A23]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT22]], %[[ELEMENT25]]
// CONCRETE: %[[ELEMENT26:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE31:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A24:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT26]][@a]
// CONCRETE: %[[ELEMENT27:[a-zA-Z0-9_.-]+]] = array.read %[[A24]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_11]][@in]
// CONCRETE: %[[ELEMENT28:[a-zA-Z0-9_.-]+]] = array.read %[[IN7]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A25:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT28]][@a]
// CONCRETE: %[[ELEMENT29:[a-zA-Z0-9_.-]+]] = array.read %[[A25]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT27]], %[[ELEMENT29]]
// CONCRETE: %[[ELEMENT30:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE31]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT30]][@b]
// CONCRETE: %[[ELEMENT31:[a-zA-Z0-9_.-]+]] = array.read %[[B15]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A26:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT31]][@a]
// CONCRETE: %[[IDX_12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_12]][@in]
// CONCRETE: %[[ELEMENT32:[a-zA-Z0-9_.-]+]] = array.read %[[IN8]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT32]][@b]
// CONCRETE: %[[ELEMENT33:[a-zA-Z0-9_.-]+]] = array.read %[[B16]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A27:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT33]][@a]
// CONCRETE: constrain.eq %[[A26]], %[[A27]]
// CONCRETE: %[[ELEMENT34:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE40:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A28:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT34]][@a]
// CONCRETE: %[[IDX_23:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_23]][@in]
// CONCRETE: %[[ELEMENT35:[a-zA-Z0-9_.-]+]] = array.read %[[IN9]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A29:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT35]][@a]
// CONCRETE: constrain.eq %[[A28]], %[[A29]]
// CONCRETE: %[[IDX_24:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN10:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_24]][@in]
// CONCRETE: %[[ELEMENT36:[a-zA-Z0-9_.-]+]] = array.read %[[IN10]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT36]][@b]
// CONCRETE: %[[ELEMENT37:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE40]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B18:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT37]][@b]
// CONCRETE: %[[ELEMENT38:[a-zA-Z0-9_.-]+]] = array.read %[[B17]]{{\[}}%[[VALUE45:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT39:[a-zA-Z0-9_.-]+]] = array.read %[[B18]]{{\[}}%[[VALUE45]]]
// CONCRETE: %[[A30:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT38]][@a]
// CONCRETE: %[[A31:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT39]][@a]
// CONCRETE: constrain.eq %[[A30]], %[[A31]]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_25:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN11:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_25]][@in]
// CONCRETE: %[[ELEMENT41:[a-zA-Z0-9_.-]+]] = array.read %[[IN11]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT41]][@c]
// CONCRETE: %[[A32:[a-zA-Z0-9_.-]+]] = pod.read %[[C7]][@a]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[A32]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN12:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_13]][@in]
// CONCRETE: %[[ELEMENT43:[a-zA-Z0-9_.-]+]] = array.read %[[IN12]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT43]][@c]
// CONCRETE: %[[A33:[a-zA-Z0-9_.-]+]] = pod.read %[[C8]][@a]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[A33]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_03:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN13:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_03]][@in]
// CONCRETE: %[[ELEMENT45:[a-zA-Z0-9_.-]+]] = array.read %[[IN13]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT45]][@c]
// CONCRETE: %[[A34:[a-zA-Z0-9_.-]+]] = pod.read %[[C9]][@a]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[A34]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[ELEMENT47:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE40]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT47]][@c]
// CONCRETE: %[[A35:[a-zA-Z0-9_.-]+]] = pod.read %[[C10]][@a]
// CONCRETE: %[[ELEMENT48:[a-zA-Z0-9_.-]+]] = array.read %[[A35]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %{{[a-zA-Z0-9_.-]+}}, %[[ELEMENT48]]
// CONCRETE: %[[ELEMENT49:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE40]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT49]][@c]
// CONCRETE: %[[B19:[a-zA-Z0-9_.-]+]] = pod.read %[[C11]][@b]
// CONCRETE: %[[ELEMENT50:[a-zA-Z0-9_.-]+]] = array.read %[[B19]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_26:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN14:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_26]][@in]
// CONCRETE: %[[ELEMENT51:[a-zA-Z0-9_.-]+]] = array.read %[[IN14]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT51]][@c]
// CONCRETE: %[[B20:[a-zA-Z0-9_.-]+]] = pod.read %[[C12]][@b]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[B20]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN15:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_14]][@in]
// CONCRETE: %[[ELEMENT53:[a-zA-Z0-9_.-]+]] = array.read %[[IN15]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT53]][@c]
// CONCRETE: %[[B21:[a-zA-Z0-9_.-]+]] = pod.read %[[C13]][@b]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[B21]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_04:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN16:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_04]][@in]
// CONCRETE: %[[ELEMENT55:[a-zA-Z0-9_.-]+]] = array.read %[[IN16]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[C14:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT55]][@c]
// CONCRETE: %[[B22:[a-zA-Z0-9_.-]+]] = pod.read %[[C14]][@b]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[B22]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT50]], %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: %[[ELEMENT57:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_27:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_27]][@out]
// CONCRETE: %[[ELEMENT58:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B23:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT58]][@b]
// CONCRETE: %[[ELEMENT59:[a-zA-Z0-9_.-]+]] = array.read %[[B23]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A36:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT59]][@a]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[A36]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_15:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_15]][@out]
// CONCRETE: %[[ELEMENT61:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD8]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B24:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT61]][@b]
// CONCRETE: %[[ELEMENT62:[a-zA-Z0-9_.-]+]] = array.read %[[B24]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A37:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT62]][@a]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[A37]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[IDX_05:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_05]][@out]
// CONCRETE: %[[ELEMENT64:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD9]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[B25:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT64]][@b]
// CONCRETE: %[[ELEMENT65:[a-zA-Z0-9_.-]+]] = array.read %[[B25]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: %[[A38:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT65]][@a]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = array.read %[[A38]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// CONCRETE: constrain.eq %[[ELEMENT57]], %{{[a-zA-Z0-9_.-]+}}
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[IDX_07:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[IDX_07]][@in]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[IDX_17:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[IDX_17]][@in]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[IDX_29:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[IDX_29]][@in]
// CONCRETE: function.return

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n1 : index
// TEMPLATED: poly.param @n2 : index
// TEMPLATED: poly.param @m : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<@m x !pod.type<[@a: !array.type<@n2 x !felt.type<"bn128">>, @b: !array.type<@n2 x !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<@n1 x !felt.type<"bn128">>, @b: !array.type<@n1 x !felt.type<"bn128">>]>]>>
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
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@a]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A8]]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@b]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@b]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE12]]]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT14]][@c]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@b]
// TEMPLATED: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@c]
// TEMPLATED: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[B8]]
// TEMPLATED: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@c]
// TEMPLATED: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[C6]][@a]
// TEMPLATED: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
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
// TEMPLATED: array.write %[[A14:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %{{[a-zA-Z0-9_.-]+}} : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED: pod.write %[[ELEMENT19:[a-zA-Z0-9_.-]+]][@a] = %[[A14]]
// TEMPLATED: array.write %[[IN1:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}] = %[[ELEMENT19]]
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
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[PARAMS1]][@n1]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[PARAMS1]][@n2]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[PARAMS1]][@m]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%{{[a-zA-Z0-9_.-]+}}), (%{{[a-zA-Z0-9_.-]+}}), (%{{[a-zA-Z0-9_.-]+}})} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT21]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[a-zA-Z0-9_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE24:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE24]][@aux]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE24]][@aux$inputs]
// TEMPLATED: %[[VALUE25:[a-zA-Z0-9_.-]+]] = array.new %[[SIZE_N1:[a-zA-Z0-9_.-]+]], %[[SIZE_N2:[a-zA-Z0-9_.-]+]], %[[SIZE_N3:[a-zA-Z0-9_.-]+]] : <3 x !felt.type<"bn128">>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE25]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE27:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE29:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE29]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE27]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT27:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE33:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT27]][@a]
// TEMPLATED: %[[ELEMENT28:[a-zA-Z0-9_.-]+]] = array.read %[[A15]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT29:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT29]][@in]
// TEMPLATED: %[[ELEMENT30:[a-zA-Z0-9_.-]+]] = array.read %[[IN3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A16:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT30]][@a]
// TEMPLATED: %[[ELEMENT31:[a-zA-Z0-9_.-]+]] = array.read %[[A16]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT28]], %[[ELEMENT31]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE25]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT33:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT33]][@in]
// TEMPLATED: %[[ELEMENT34:[a-zA-Z0-9_.-]+]] = array.read %[[IN4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT34]][@b]
// TEMPLATED: %[[ELEMENT35:[a-zA-Z0-9_.-]+]] = array.read %[[B10]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A17:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT35]][@a]
// TEMPLATED: %[[ELEMENT36:[a-zA-Z0-9_.-]+]] = array.read %[[A17]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT37:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE33]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT37]][@b]
// TEMPLATED: %[[ELEMENT38:[a-zA-Z0-9_.-]+]] = array.read %[[B11]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A18:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT38]][@a]
// TEMPLATED: %[[ELEMENT39:[a-zA-Z0-9_.-]+]] = array.read %[[A18]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT36]], %[[ELEMENT39]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE27]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT41:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE48:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A19:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT41]][@a]
// TEMPLATED: %[[ELEMENT42:[a-zA-Z0-9_.-]+]] = array.read %[[A19]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT43:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT43]][@in]
// TEMPLATED: %[[ELEMENT44:[a-zA-Z0-9_.-]+]] = array.read %[[IN5]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A20:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT44]][@a]
// TEMPLATED: %[[ELEMENT45:[a-zA-Z0-9_.-]+]] = array.read %[[A20]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT42]], %[[ELEMENT45]]
// TEMPLATED: %[[ELEMENT46:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE48]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT46]][@b]
// TEMPLATED: %[[ELEMENT47:[a-zA-Z0-9_.-]+]] = array.read %[[B12]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A21:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT47]][@a]
// TEMPLATED: %[[ELEMENT48:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT48]][@in]
// TEMPLATED: %[[ELEMENT49:[a-zA-Z0-9_.-]+]] = array.read %[[IN6]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT49]][@b]
// TEMPLATED: %[[ELEMENT50:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A22:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT50]][@a]
// TEMPLATED: constrain.eq %[[A21]], %[[A22]]
// TEMPLATED: %[[SNAPSHOT_N1:[a-zA-Z0-9_.-]+]] = array.new %[[SIZE_N1]], %[[SIZE_N2]], %[[SIZE_N3]] : <3 x !felt.type<"bn128">>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[SNAPSHOT_N1]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT52:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE60:[a-zA-Z0-9_.-]+]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A23:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT52]][@a]
// TEMPLATED: %[[ELEMENT53:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT53]][@in]
// TEMPLATED: %[[ELEMENT54:[a-zA-Z0-9_.-]+]] = array.read %[[IN7]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A24:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT54]][@a]
// TEMPLATED: constrain.eq %[[A23]], %[[A24]]
// TEMPLATED: %[[SNAPSHOT_N2:[a-zA-Z0-9_.-]+]] = array.new %[[SIZE_N1]], %[[SIZE_N2]], %[[SIZE_N3]] : <3 x !felt.type<"bn128">>
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[SNAPSHOT_N2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT56:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT56]][@in]
// TEMPLATED: %[[ELEMENT57:[a-zA-Z0-9_.-]+]] = array.read %[[IN8]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT57]][@b]
// TEMPLATED: %[[ELEMENT58:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE60]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[ELEMENT58]][@b]
// TEMPLATED: %[[ELEMENT59:[a-zA-Z0-9_.-]+]] = array.read %[[B14]]{{\[}}%[[VALUE68:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT60:[a-zA-Z0-9_.-]+]] = array.read %{{[a-zA-Z0-9_.-]+}}{{\[}}%[[VALUE68]]]
// TEMPLATED: %[[A25:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT59]][@a]
// TEMPLATED: %[[A26:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT60]][@a]
// TEMPLATED: constrain.eq %[[A25]], %[[A26]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[VALUE25]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT62:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT62]][@in]
// TEMPLATED: %[[ELEMENT63:[a-zA-Z0-9_.-]+]] = array.read %[[IN9]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT63]][@c]
// TEMPLATED: %[[A27:[a-zA-Z0-9_.-]+]] = pod.read %[[C8]][@a]
// TEMPLATED: %[[ELEMENT64:[a-zA-Z0-9_.-]+]] = array.read %[[A27]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT65:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE60]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT65]][@c]
// TEMPLATED: %[[A28:[a-zA-Z0-9_.-]+]] = pod.read %[[C9]][@a]
// TEMPLATED: %[[ELEMENT66:[a-zA-Z0-9_.-]+]] = array.read %[[A28]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT64]], %[[ELEMENT66]]
// TEMPLATED: %[[ELEMENT67:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE60]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT67]][@c]
// TEMPLATED: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[C10]][@b]
// TEMPLATED: %[[ELEMENT68:[a-zA-Z0-9_.-]+]] = array.read %[[B16]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT69:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[IN10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT69]][@in]
// TEMPLATED: %[[ELEMENT70:[a-zA-Z0-9_.-]+]] = array.read %[[IN10]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[C11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT70]][@c]
// TEMPLATED: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[C11]][@b]
// TEMPLATED: %[[ELEMENT71:[a-zA-Z0-9_.-]+]] = array.read %[[B17]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT68]], %[[ELEMENT71]]
// TEMPLATED: %[[ELEMENT72:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[ELEMENT73:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[ELEMENT73]][@out]
// TEMPLATED: %[[ELEMENT74:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD5]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[B18:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT74]][@b]
// TEMPLATED: %[[ELEMENT75:[a-zA-Z0-9_.-]+]] = array.read %[[B18]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: %[[A29:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT75]][@a]
// TEMPLATED: %[[ELEMENT76:[a-zA-Z0-9_.-]+]] = array.read %[[A29]]{{\[}}%{{[a-zA-Z0-9_.-]+}}]
// TEMPLATED: constrain.eq %[[ELEMENT72]], %[[ELEMENT76]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = array.read %[[FIELD3]]{{\[}}%[[VALUE86:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT78:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE86]]]
// TEMPLATED: %{{[a-zA-Z0-9_.-]+}} = pod.read %[[ELEMENT78]][@in]
// TEMPLATED: function.return
