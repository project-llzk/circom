// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
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
    signal a[m];
    Simple1(n) b[m];
    Simple(n) c;
}

template A(n,m){
    Compuesto(n,m) input in;
    Compuesto(n,m) output out;

    if (n % 2 == 0){
        out <== in;
    } else{
        out.a <== in.a;
        out.b <== in.b;
        out.c.a <== in.c.b;
        out.c.b <== in.c.a;
    }
}

template B(n1, m1, n2, m2, n3, m3){
    Compuesto(n1,m1) input in1;
    Compuesto(n2,m2) input in2;
    Compuesto(n3,m3) input in3;
    signal output out[3];

    var sizes_n[3] = [n1, n2, n3];
    var sizes_m[3] = [m1, m2, m3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes_n[i], sizes_m[i]);
        for (var j_m = 0; j_m < sizes_m[i]; j_m++){
            if (i == 0){
                aux[i].in.a[j_m] <== in1.a[j_m];
                for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                    aux[i].in.b[j_m].a[j_n] <== in1.b[j_m].a[j_n];
                }
            } else if (i == 1){
                aux[i].in.a[j_m] <== in2.a[j_m];
                for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                    aux[i].in.b[j_m].a[j_n] <== in2.b[j_m].a[j_n];
                }
            } else{
                aux[i].in.a[j_m] <== in3.a[j_m];
                for (var j_n = 0; j_n < sizes_n[i]; j_n++){
                    aux[i].in.b[j_m].a[j_n] <== in3.b[j_m].a[j_n];
                }
            }
        }
        for (var j_n = 0; j_n < sizes_n[i]; j_n++){
            if (i == 0){
                aux[i].in.c.a[j_n] <== in1.c.a[j_n];
                aux[i].in.c.b[j_n] <== in1.c.b[j_n];
            } else if (i == 1){
                aux[i].in.c.a[j_n] <== in2.c.a[j_n];
                aux[i].in.c.b[j_n] <== in2.c.b[j_n];
            } else{
                aux[i].in.c.a[j_n] <== in3.c.a[j_n];
                aux[i].in.c.b[j_n] <== in3.c.b[j_n];
            }
        }
        out[i] <== aux[i].out.c.b[0];
    }
}

component main = B(4, 5,6, 3,5,3);

// Check nested layouts, representative updates, and component input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>, @b: !array.type<4 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2]][@b]
// CONCRETE: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[B1]]{{\[}}%[[VALUE3:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE3]]]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[C1:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@c]
// CONCRETE: %[[C2:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE2]][@c]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[C1]][@a]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@a]
// CONCRETE: constrain.eq %[[A5]], %[[A6]]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[C1]][@b]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A7]], %[[A8]]
// CONCRETE: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5]][@b]
// CONCRETE: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[B5]]{{\[}}%[[VALUE6:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE6]]]
// CONCRETE: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A10]]
// CONCRETE: %[[C3:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD2]][@c]
// CONCRETE: %[[C4:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE5]][@c]
// CONCRETE: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[C3]][@a]
// CONCRETE: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[C4]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[C3]][@b]
// CONCRETE: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[C4]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[VALUE7:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: pod.write %[[VALUE7]][@b] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: pod.write %[[VALUE7]][@c] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[A14:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: %[[A15:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@a]
// CONCRETE: constrain.eq %[[A15]], %[[A14]]
// CONCRETE: %[[B10:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10]][@b]
// CONCRETE: %[[B11:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@b]
// CONCRETE: %[[ELEMENT5:[0-9a-zA-Z_.-]+]] = array.read %[[B11]]{{\[}}%[[VALUE11:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[B10]]{{\[}}%[[VALUE11]]]
// CONCRETE: %[[A16:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[A17:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A16]], %[[A17]]
// CONCRETE: %[[C6:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10]][@c]
// CONCRETE: %[[B12:[0-9a-zA-Z_.-]+]] = pod.read %[[C6]][@b]
// CONCRETE: %[[C7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@c]
// CONCRETE: %[[A18:[0-9a-zA-Z_.-]+]] = pod.read %[[C7]][@a]
// CONCRETE: constrain.eq %[[A18]], %[[B12]]
// CONCRETE: %[[C8:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE10]][@c]
// CONCRETE: %[[A19:[0-9a-zA-Z_.-]+]] = pod.read %[[C8]][@a]
// CONCRETE: %[[C9:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD3]][@c]
// CONCRETE: %[[B13:[0-9a-zA-Z_.-]+]] = pod.read %[[C9]][@b]
// CONCRETE: constrain.eq %[[B13]], %[[A19]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>, @b: !array.type<4 x !felt.type<"bn128">>]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !felt.type<"bn128">>]>]>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: array.write %[[A20:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}} : <3 x !felt.type<"bn128">>, !felt.type<"bn128">
// CONCRETE: pod.write %[[IN1:[0-9a-zA-Z_.-]+]][@a] = %[[A20]]
// CONCRETE: pod.write %[[IDX_21:[0-9a-zA-Z_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@idx_2] = %[[IDX_21]]
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_22:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_22]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[IDX_22]][@params]
// CONCRETE: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A_2::@A_2::@compute(%[[IN2]]) : (!pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !felt.type<"bn128">>]>]>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_1::@A_1::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_0::@A_0::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>, @b: !array.type<4 x !felt.type<"bn128">>]>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_.-]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED: poly.param @m : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<@m x !felt.type<"bn128">>, @b: !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[VALUE1:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: pod.write %[[VALUE1]][@b] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: pod.write %[[VALUE1]][@c] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// TEMPLATED: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4:[0-9a-zA-Z_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE5:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE5]]]
// TEMPLATED: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// TEMPLATED: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[A5]]
// TEMPLATED: %[[C2:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@c]
// TEMPLATED: %[[C3:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@c]
// TEMPLATED: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@a]
// TEMPLATED: %[[A7:[0-9a-zA-Z_.-]+]] = pod.read %[[C3]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@b]
// TEMPLATED: %[[B5:[0-9a-zA-Z_.-]+]] = pod.read %[[C3]][@b]
// TEMPLATED: constrain.eq %[[B4]], %[[B5]]
// TEMPLATED: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@a]
// TEMPLATED: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: constrain.eq %[[A9]], %[[A8]]
// TEMPLATED: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[ELEMENT3:[0-9a-zA-Z_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE6:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT4:[0-9a-zA-Z_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE6]]]
// TEMPLATED: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[C4:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@c]
// TEMPLATED: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[C4]][@b]
// TEMPLATED: %[[C5:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@c]
// TEMPLATED: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[C5]][@a]
// TEMPLATED: constrain.eq %[[A12]], %[[B8]]
// TEMPLATED: %[[C6:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE4]][@c]
// TEMPLATED: %[[A13:[0-9a-zA-Z_.-]+]] = pod.read %[[C6]][@a]
// TEMPLATED: %[[C7:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD1]][@c]
// TEMPLATED: %[[B9:[0-9a-zA-Z_.-]+]] = pod.read %[[C7]][@b]
// TEMPLATED: constrain.eq %[[B9]], %[[A13]]
// TEMPLATED: function.return
// TEMPLATED: poly.param @n1 : index
// TEMPLATED: poly.param @m1 : index
// TEMPLATED: poly.param @n2 : index
// TEMPLATED: poly.param @m2 : index
// TEMPLATED: poly.param @n3 : index
// TEMPLATED: poly.param @m3 : index
// TEMPLATED-LABEL: struct.def @B {
// TEMPLATED: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: struct.member @aux : !array.type<3 x !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: array.write %[[A14:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %{{[0-9a-zA-Z_.-]+}} : <#[[$ATTR_0]] x !felt.type<"bn128">>, !felt.type<"bn128">
// TEMPLATED: pod.write %[[IN1:[0-9a-zA-Z_.-]+]][@a] = %[[A14]]
// TEMPLATED: pod.write %[[ELEMENT6:[0-9a-zA-Z_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE8:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE8]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[N4]]
// TEMPLATED: pod.write %[[ELEMENT7]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@params]
// TEMPLATED: %[[IN2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@in]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[PARAMS1]][@m]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%{{[0-9a-zA-Z_.-]+}}), (%{{[0-9a-zA-Z_.-]+}})} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT7]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
