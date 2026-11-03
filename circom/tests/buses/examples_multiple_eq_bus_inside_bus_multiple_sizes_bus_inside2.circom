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
        if (i == 0){
            aux[i].in.a <-- in1.a;
            in1.a === aux[i].in.a;
            for (var j_m = 0; j_m < sizes_m[i]; j_m++){
                aux[i].in.b[j_m].a <-- in1.b[j_m].a;
                in1.b[j_m].a === aux[i].in.b[j_m].a;
            }
        } else if (i == 1){
            aux[i].in.a <-- in2.a;
            aux[i].in.b <-- in2.b;
            in2.a === aux[i].in.a;
            in2.b === aux[i].in.b;
        } else{
            aux[i].in.a <-- in3.a;
            aux[i].in.b <-- in3.b;
            in3.a === aux[i].in.a;
            in3.b === aux[i].in.b;
        }
        for (var j_n = 0; j_n < sizes_n[i]; j_n++){
            aux[i].in.c.a[j_n] <-- in3.c.a[j_n];
            aux[i].in.c.b[j_n] <-- in3.c.b[j_n];
            in3.c.a[j_n] ===  aux[i].in.c.a[j_n];
            in3.c.b[j_n] ===  aux[i].in.c.b[j_n];
        }
        out[i] <-- aux[i].out.c.b[0];
        out[i] === aux[i].out.c.b[0];
    }
}

component main = B(3, 4,5, 6,9,3);

// Check bus layouts and leaf equalities; component calls follow input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>, @b: !array.type<4 x !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[VALUE1:[a-zA-Z0-9_.-]+]][@a] = %[[A1:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE1]][@b] = %[[B1:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE1]][@c] = %[[C1:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A2]]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@b]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE5]]]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[A5]]
// CONCRETE: %[[C2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@c]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[C2]][@b]
// CONCRETE: %[[C3:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@c]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[C3]][@a]
// CONCRETE: constrain.eq %[[A6]], %[[B4]]
// CONCRETE: %[[C4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@c]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[C4]][@a]
// CONCRETE: %[[C5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@c]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[C5]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[A7]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[VALUE6:[a-zA-Z0-9_.-]+]][@a] = %[[A8:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE6]][@b] = %[[B6:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE6]][@c] = %[[C6:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE7:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE8:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE9:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: constrain.eq %[[A10]], %[[A9]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE9]][@b]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[B8]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE10]]]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %[[C7:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE9]][@c]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[C7]][@b]
// CONCRETE: %[[C8:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@c]
// CONCRETE: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[C8]][@a]
// CONCRETE: constrain.eq %[[A13]], %[[B9]]
// CONCRETE: %[[C9:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE9]][@c]
// CONCRETE: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[C9]][@a]
// CONCRETE: %[[C10:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@c]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[C10]][@b]
// CONCRETE: constrain.eq %[[B10]], %[[A14]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<9 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<9 x !felt.type<"bn128">>, @b: !array.type<9 x !felt.type<"bn128">>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[VALUE11:[a-zA-Z0-9_.-]+]][@a] = %[[A15:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE11]][@b] = %[[B11:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE11]][@c] = %[[C11:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE12:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE13:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[A17:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@a]
// CONCRETE: constrain.eq %[[A17]], %[[A16]]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14]][@b]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@b]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[B12]]{{\[}}%[[VALUE15]]]
// CONCRETE: %[[A18:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[A19:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A18]], %[[A19]]
// CONCRETE: %[[C12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14]][@c]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[C12]][@b]
// CONCRETE: %[[C13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@c]
// CONCRETE: %[[A20:[a-zA-Z0-9_.-]+]] = pod.read %[[C13]][@a]
// CONCRETE: constrain.eq %[[A20]], %[[B14]]
// CONCRETE: %[[C14:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14]][@c]
// CONCRETE: %[[A21:[a-zA-Z0-9_.-]+]] = pod.read %[[C14]][@a]
// CONCRETE: %[[C15:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD3]][@c]
// CONCRETE: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[C15]][@b]
// CONCRETE: constrain.eq %[[B15]], %[[A21]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<4 x !felt.type<"bn128">>, @b: !array.type<4 x !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !felt.type<"bn128">>]>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<9 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<9 x !felt.type<"bn128">>, @b: !array.type<9 x !felt.type<"bn128">>]>]>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[IN1:[a-zA-Z0-9_.-]+]][@a] = %[[A22:[a-zA-Z0-9_.-]+]] : <[@a: !array.type<4 x !felt.type<"bn128">>, @b: !array.type<4 x !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, !array.type<4 x !felt.type<"bn128">>
// CONCRETE: pod.write %[[IDX_01:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %[[VALUE16:[a-zA-Z0-9_.-]+]][@idx_0] = %[[IDX_01]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_02]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02]][@params]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_01]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN2]]) : (!pod.type<[@a: !array.type<4 x !felt.type<"bn128">>, @b: !array.type<4 x !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[IDX_02]][@comp] = %[[CHILD1]]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @A_1::@A_1::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<5 x !felt.type<"bn128">>, @b: !array.type<5 x !felt.type<"bn128">>]>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @A_2::@A_2::@compute(%[[IN4:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !pod.type<[@a: !array.type<9 x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<9 x !felt.type<"bn128">>, @b: !array.type<9 x !felt.type<"bn128">>]>]>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: function.return %[[VALUE17:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE18:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE18]][@aux]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE18]][@aux$inputs]
// CONCRETE: %[[A23:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE19:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[IDX_03:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_03]][@in]
// CONCRETE: %[[A24:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@a]
// CONCRETE: constrain.eq %[[A23]], %[[A24]]
// CONCRETE: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE19]][@b]
// CONCRETE: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[B16]]{{\[}}%[[VALUE20:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A25:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: %[[IDX_04:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_04]][@in]
// CONCRETE: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[IN6]][@b]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[B17]]{{\[}}%[[VALUE21:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A26:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@a]
// CONCRETE: constrain.eq %[[A25]], %[[A26]]
// CONCRETE: %[[A27:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE22:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[IDX_11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_11]][@in]
// CONCRETE: %[[A28:[a-zA-Z0-9_.-]+]] = pod.read %[[IN7]][@a]
// CONCRETE: constrain.eq %[[A27]], %[[A28]]
// CONCRETE: %[[B18:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE22]][@b]
// CONCRETE: %[[IDX_12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_12]][@in]
// CONCRETE: %[[B19:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@b]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[B18]]{{\[}}%[[VALUE23:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[B19]]{{\[}}%[[VALUE23]]]
// CONCRETE: %[[A29:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@a]
// CONCRETE: %[[A30:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CONCRETE: constrain.eq %[[A29]], %[[A30]]
// CONCRETE: %[[A31:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE24:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[IDX_21:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[A32:[a-zA-Z0-9_.-]+]] = pod.read %[[IN9]][@a]
// CONCRETE: constrain.eq %[[A31]], %[[A32]]
// CONCRETE: %[[B20:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE24]][@b]
// CONCRETE: %[[IDX_22:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN10:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22]][@in]
// CONCRETE: %[[B21:[a-zA-Z0-9_.-]+]] = pod.read %[[IN10]][@b]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[B20]]{{\[}}%[[VALUE25:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B21]]{{\[}}%[[VALUE25]]]
// CONCRETE: %[[A33:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@a]
// CONCRETE: %[[A34:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@a]
// CONCRETE: constrain.eq %[[A33]], %[[A34]]
// CONCRETE: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE26:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE27:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[C16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE24]][@c]
// CONCRETE: %[[A35:[a-zA-Z0-9_.-]+]] = pod.read %[[C16]][@a]
// CONCRETE: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[A35]]{{\[}}%[[VALUE28:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_23:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN11:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_23]][@in]
// CONCRETE: %[[C17:[a-zA-Z0-9_.-]+]] = pod.read %[[IN11]][@c]
// CONCRETE: %[[A36:[a-zA-Z0-9_.-]+]] = pod.read %[[C17]][@a]
// CONCRETE: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[A36]]{{\[}}%[[VALUE29:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN12:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_13]][@in]
// CONCRETE: %[[C18:[a-zA-Z0-9_.-]+]] = pod.read %[[IN12]][@c]
// CONCRETE: %[[A37:[a-zA-Z0-9_.-]+]] = pod.read %[[C18]][@a]
// CONCRETE: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[A37]]{{\[}}%[[VALUE30:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_05:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN13:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_05]][@in]
// CONCRETE: %[[C19:[a-zA-Z0-9_.-]+]] = pod.read %[[IN13]][@c]
// CONCRETE: %[[A38:[a-zA-Z0-9_.-]+]] = pod.read %[[C19]][@a]
// CONCRETE: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[A38]]{{\[}}%[[VALUE31:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT14]], %[[VALUE32:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[C20:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE24]][@c]
// CONCRETE: %[[B22:[a-zA-Z0-9_.-]+]] = pod.read %[[C20]][@b]
// CONCRETE: %[[ELEMENT18:[a-zA-Z0-9_.-]+]] = array.read %[[B22]]{{\[}}%[[VALUE33:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_24:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN14:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_24]][@in]
// CONCRETE: %[[C21:[a-zA-Z0-9_.-]+]] = pod.read %[[IN14]][@c]
// CONCRETE: %[[B23:[a-zA-Z0-9_.-]+]] = pod.read %[[C21]][@b]
// CONCRETE: %[[ELEMENT19:[a-zA-Z0-9_.-]+]] = array.read %[[B23]]{{\[}}%[[VALUE34:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN15:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_14]][@in]
// CONCRETE: %[[C22:[a-zA-Z0-9_.-]+]] = pod.read %[[IN15]][@c]
// CONCRETE: %[[B24:[a-zA-Z0-9_.-]+]] = pod.read %[[C22]][@b]
// CONCRETE: %[[ELEMENT20:[a-zA-Z0-9_.-]+]] = array.read %[[B24]]{{\[}}%[[VALUE35:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_06:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN16:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_06]][@in]
// CONCRETE: %[[C23:[a-zA-Z0-9_.-]+]] = pod.read %[[IN16]][@c]
// CONCRETE: %[[B25:[a-zA-Z0-9_.-]+]] = pod.read %[[C23]][@b]
// CONCRETE: %[[ELEMENT21:[a-zA-Z0-9_.-]+]] = array.read %[[B25]]{{\[}}%[[VALUE36:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT18]], %[[VALUE37:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[ELEMENT22:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE38:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_25:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_25]][@out]
// CONCRETE: %[[C24:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@c]
// CONCRETE: %[[B26:[a-zA-Z0-9_.-]+]] = pod.read %[[C24]][@b]
// CONCRETE: %[[ELEMENT23:[a-zA-Z0-9_.-]+]] = array.read %[[B26]]{{\[}}%[[VALUE39:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_15:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_15]][@out]
// CONCRETE: %[[C25:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@c]
// CONCRETE: %[[B27:[a-zA-Z0-9_.-]+]] = pod.read %[[C25]][@b]
// CONCRETE: %[[ELEMENT24:[a-zA-Z0-9_.-]+]] = array.read %[[B27]]{{\[}}%[[VALUE40:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_07:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_07]][@out]
// CONCRETE: %[[C26:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD9]][@c]
// CONCRETE: %[[B28:[a-zA-Z0-9_.-]+]] = pod.read %[[C26]][@b]
// CONCRETE: %[[ELEMENT25:[a-zA-Z0-9_.-]+]] = array.read %[[B28]]{{\[}}%[[VALUE41:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT22]], %[[VALUE42:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[IDX_08:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[IDX_09:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN17:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_09]][@in]
// CONCRETE: %[[IDX_16:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[IDX_17:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN18:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_17]][@in]
// CONCRETE: %[[IDX_26:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[IDX_27:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN19:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_27]][@in]
// CONCRETE: function.return

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED: poly.param @m : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<@m x !felt.type<"bn128">>, @b: !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>]>
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
// TEMPLATED: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[B2]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[B3]]{{\[}}%[[VALUE5]]]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
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
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[B7]]{{\[}}%[[VALUE6:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[B6]]{{\[}}%[[VALUE6]]]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
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
// TEMPLATED: pod.write %[[IN1:[a-zA-Z0-9_.-]+]][@a] = %[[VALUE7:[a-zA-Z0-9_.-]+]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED: pod.write %[[ELEMENT5:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE8:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE8]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@count]
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[VALUE9:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[ELEMENT6]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N4]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@params]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@in]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[M1:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@m]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%[[VALUE10:[a-zA-Z0-9_.-]+]]), (%[[VALUE11:[a-zA-Z0-9_.-]+]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>, @c: !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT6]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE12:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE13:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE13]][@aux]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE13]][@aux$inputs]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE16:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE17:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A14:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE18:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE19:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@in]
// TEMPLATED: %[[A15:[a-zA-Z0-9_.-]+]] = pod.read %[[IN3]][@a]
// TEMPLATED: constrain.eq %[[A14]], %[[A15]]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE16]]{{\[}}%[[VALUE20:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE18]][@b]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[B10]]{{\[}}%[[VALUE21:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A16:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@a]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE22:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@in]
// TEMPLATED: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@b]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[B11]]{{\[}}%[[VALUE23:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A17:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// TEMPLATED: constrain.eq %[[A16]], %[[A17]]
// TEMPLATED: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14]]{{\[}}%[[VALUE24:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A18:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE25:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE26:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@in]
// TEMPLATED: %[[A19:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@a]
// TEMPLATED: constrain.eq %[[A18]], %[[A19]]
// TEMPLATED: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14]]{{\[}}%[[VALUE27:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE25]][@b]
// TEMPLATED: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE28:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT17]][@in]
// TEMPLATED: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[IN6]][@b]
// TEMPLATED: %[[ELEMENT18:[a-zA-Z0-9_.-]+]] = array.read %[[B12]]{{\[}}%[[VALUE29:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT19:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE30:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE29]]]
// TEMPLATED: %[[A20:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT18]][@a]
// TEMPLATED: %[[A21:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT19]][@a]
// TEMPLATED: constrain.eq %[[A20]], %[[A21]]
// TEMPLATED: %[[ELEMENT20:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14]]{{\[}}%[[VALUE31:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A22:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE32:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: %[[ELEMENT21:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE33:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT21]][@in]
// TEMPLATED: %[[A23:[a-zA-Z0-9_.-]+]] = pod.read %[[IN7]][@a]
// TEMPLATED: constrain.eq %[[A22]], %[[A23]]
// TEMPLATED: %[[ELEMENT22:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14]]{{\[}}%[[VALUE34:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE32]][@b]
// TEMPLATED: %[[ELEMENT23:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE35:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT23]][@in]
// TEMPLATED: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@b]
// TEMPLATED: %[[ELEMENT24:[a-zA-Z0-9_.-]+]] = array.read %[[B14]]{{\[}}%[[VALUE36:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT25:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE37:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE36]]]
// TEMPLATED: %[[A24:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT24]][@a]
// TEMPLATED: %[[A25:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT25]][@a]
// TEMPLATED: constrain.eq %[[A24]], %[[A25]]
// TEMPLATED: %[[ELEMENT26:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14]]{{\[}}%[[VALUE38:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[C8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE32]][@c]
// TEMPLATED: %[[A26:[a-zA-Z0-9_.-]+]] = pod.read %[[C8]][@a]
// TEMPLATED: %[[ELEMENT27:[a-zA-Z0-9_.-]+]] = array.read %[[A26]]{{\[}}%[[VALUE39:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT28:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE40:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT28]][@in]
// TEMPLATED: %[[C9:[a-zA-Z0-9_.-]+]] = pod.read %[[IN9]][@c]
// TEMPLATED: %[[A27:[a-zA-Z0-9_.-]+]] = pod.read %[[C9]][@a]
// TEMPLATED: %[[ELEMENT29:[a-zA-Z0-9_.-]+]] = array.read %[[A27]]{{\[}}%[[VALUE41:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT27]], %[[ELEMENT29]]
// TEMPLATED: %[[C10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE32]][@c]
// TEMPLATED: %[[B16:[a-zA-Z0-9_.-]+]] = pod.read %[[C10]][@b]
// TEMPLATED: %[[ELEMENT30:[a-zA-Z0-9_.-]+]] = array.read %[[B16]]{{\[}}%[[VALUE42:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT31:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE43:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT31]][@in]
// TEMPLATED: %[[C11:[a-zA-Z0-9_.-]+]] = pod.read %[[IN10]][@c]
// TEMPLATED: %[[B17:[a-zA-Z0-9_.-]+]] = pod.read %[[C11]][@b]
// TEMPLATED: %[[ELEMENT32:[a-zA-Z0-9_.-]+]] = array.read %[[B17]]{{\[}}%[[VALUE44:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT30]], %[[ELEMENT32]]
// TEMPLATED: %[[ELEMENT33:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE45:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT34:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE46:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[ELEMENT34]][@out]
// TEMPLATED: %[[C12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@c]
// TEMPLATED: %[[B18:[a-zA-Z0-9_.-]+]] = pod.read %[[C12]][@b]
// TEMPLATED: %[[ELEMENT35:[a-zA-Z0-9_.-]+]] = array.read %[[B18]]{{\[}}%[[VALUE47:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT33]], %[[ELEMENT35]]
// TEMPLATED: %[[ELEMENT36:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE48:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT37:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE48]]]
// TEMPLATED: %[[IN11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT37]][@in]
// TEMPLATED: function.return
