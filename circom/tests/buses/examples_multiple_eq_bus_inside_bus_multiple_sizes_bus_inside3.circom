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
            aux[i].in <-- in1;
            in1 === aux[i].in;
        } else if (i == 1){
            for (var j = 0; j < sizes[i]; j++){
                aux[i].in[j] <-- in2[j];
                in2[j] === aux[i].in[j];
            }
        } else{
            aux[i].in <-- in3;
            in3 === aux[i].in;
        }
        out[i] <-- aux[i].out[0];
        out[i] === aux[i].out[0];
    }
}

component main = B(2, 3, 5);

// Check bus layouts and leaf equalities; component calls follow input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT1:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE2:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT2:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE2]]]
// CONCRETE: %[[A1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: %[[A3:[0-9a-zA-Z_.-]+]] = pod.read %[[B1]][@a]
// CONCRETE: %[[A4:[0-9a-zA-Z_.-]+]] = pod.read %[[B2]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[C1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT1]][@c]
// CONCRETE: %[[C2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT2]][@c]
// CONCRETE: %[[A5:[0-9a-zA-Z_.-]+]] = pod.read %[[C1]][@a]
// CONCRETE: %[[A6:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@a]
// CONCRETE: constrain.eq %[[A5]], %[[A6]]
// CONCRETE: %[[B3:[0-9a-zA-Z_.-]+]] = pod.read %[[C1]][@b]
// CONCRETE: %[[B4:[0-9a-zA-Z_.-]+]] = pod.read %[[C2]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT3:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %[[ELEMENT3]]
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@b] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@c] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT6:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE8:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: %[[ELEMENT7:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT7]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A8]]
// CONCRETE: %[[ELEMENT8:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE8]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT8]][@b]
// CONCRETE: %[[ELEMENT9:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT9]][@b]
// CONCRETE: %[[A10:[0-9a-zA-Z_.-]+]] = pod.read %[[B7]][@a]
// CONCRETE: %[[A11:[0-9a-zA-Z_.-]+]] = pod.read %[[B6]][@a]
// CONCRETE: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[ELEMENT10:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE8]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C4:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT10]][@c]
// CONCRETE: %[[B8:[0-9a-zA-Z_.-]+]] = pod.read %[[C4]][@b]
// CONCRETE: %[[ELEMENT11:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C5:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT11]][@c]
// CONCRETE: %[[A12:[0-9a-zA-Z_.-]+]] = pod.read %[[C5]][@a]
// CONCRETE: constrain.eq %[[A12]], %[[B8]]
// CONCRETE: %[[ELEMENT12:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE8]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C6:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT12]][@c]
// CONCRETE: %[[A13:[0-9a-zA-Z_.-]+]] = pod.read %[[C6]][@a]
// CONCRETE: %[[ELEMENT13:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C7:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT13]][@c]
// CONCRETE: %[[B9:[0-9a-zA-Z_.-]+]] = pod.read %[[C7]][@b]
// CONCRETE: constrain.eq %[[B9]], %[[A13]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT14:[0-9a-zA-Z_.-]+]][@a] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: array.write %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}] = %[[ELEMENT14]]
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@b] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@c] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %{{[0-9a-zA-Z_.-]+}}[@out]
// CONCRETE: %[[ELEMENT17:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE21:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT17]][@a]
// CONCRETE: %[[ELEMENT18:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A16:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT18]][@a]
// CONCRETE: constrain.eq %[[A16]], %[[A15]]
// CONCRETE: %[[ELEMENT19:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE21]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT19]][@b]
// CONCRETE: %[[ELEMENT20:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[B12:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT20]][@b]
// CONCRETE: %[[A17:[0-9a-zA-Z_.-]+]] = pod.read %[[B12]][@a]
// CONCRETE: %[[A18:[0-9a-zA-Z_.-]+]] = pod.read %[[B11]][@a]
// CONCRETE: constrain.eq %[[A17]], %[[A18]]
// CONCRETE: %[[ELEMENT21:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE21]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT21]][@c]
// CONCRETE: %[[B13:[0-9a-zA-Z_.-]+]] = pod.read %[[C9]][@b]
// CONCRETE: %[[ELEMENT22:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C10:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT22]][@c]
// CONCRETE: %[[A19:[0-9a-zA-Z_.-]+]] = pod.read %[[C10]][@a]
// CONCRETE: constrain.eq %[[A19]], %[[B13]]
// CONCRETE: %[[ELEMENT23:[0-9a-zA-Z_.-]+]] = array.read %[[VALUE21]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT23]][@c]
// CONCRETE: %[[A20:[0-9a-zA-Z_.-]+]] = pod.read %[[C11]][@a]
// CONCRETE: %[[ELEMENT24:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[C12:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT24]][@c]
// CONCRETE: %[[B14:[0-9a-zA-Z_.-]+]] = pod.read %[[C12]][@b]
// CONCRETE: constrain.eq %[[B14]], %[[A20]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, @idx_2: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[IDX_01:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, !array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@idx_0] = %[[IDX_01]]
// CONCRETE: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_02:[0-9a-zA-Z_.-]+]][@count]
// CONCRETE: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 8 : index
// CONCRETE: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_02]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[IDX_02]][@params]
// CONCRETE: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_01]][@in]
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN1]]) : (!array.type<2 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[IDX_02]][@comp] = %[[CHILD1]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_2::@A_2::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!array.type<5 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = function.call @A_1::@A_1::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!array.type<3 x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE33:[0-9a-zA-Z_.-]+]][@out]
// CONCRETE: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE33]][@aux]
// CONCRETE: %[[FIELD6:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE33]][@aux$inputs]
// CONCRETE: %[[IDX_03:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN4:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_03]][@in]
// CONCRETE: %[[ELEMENT25:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE35:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT26:[0-9a-zA-Z_.-]+]] = array.read %[[IN4]]{{\[}}%[[VALUE35]]]
// CONCRETE: %[[A21:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT25]][@a]
// CONCRETE: %[[A22:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT26]][@a]
// CONCRETE: constrain.eq %[[A21]], %[[A22]]
// CONCRETE: %[[B15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT25]][@b]
// CONCRETE: %[[B16:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT26]][@b]
// CONCRETE: %[[A23:[0-9a-zA-Z_.-]+]] = pod.read %[[B15]][@a]
// CONCRETE: %[[A24:[0-9a-zA-Z_.-]+]] = pod.read %[[B16]][@a]
// CONCRETE: constrain.eq %[[A23]], %[[A24]]
// CONCRETE: %[[C13:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT25]][@c]
// CONCRETE: %[[C14:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT26]][@c]
// CONCRETE: %[[A25:[0-9a-zA-Z_.-]+]] = pod.read %[[C13]][@a]
// CONCRETE: %[[A26:[0-9a-zA-Z_.-]+]] = pod.read %[[C14]][@a]
// CONCRETE: constrain.eq %[[A25]], %[[A26]]
// CONCRETE: %[[B17:[0-9a-zA-Z_.-]+]] = pod.read %[[C13]][@b]
// CONCRETE: %[[B18:[0-9a-zA-Z_.-]+]] = pod.read %[[C14]][@b]
// CONCRETE: constrain.eq %[[B17]], %[[B18]]
// CONCRETE: %[[ELEMENT27:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[IDX_11:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN5:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_11]][@in]
// CONCRETE: %[[ELEMENT28:[0-9a-zA-Z_.-]+]] = array.read %[[IN5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A27:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT27]][@a]
// CONCRETE: %[[A28:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT28]][@a]
// CONCRETE: constrain.eq %[[A27]], %[[A28]]
// CONCRETE: %[[B19:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT27]][@b]
// CONCRETE: %[[B20:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT28]][@b]
// CONCRETE: %[[A29:[0-9a-zA-Z_.-]+]] = pod.read %[[B19]][@a]
// CONCRETE: %[[A30:[0-9a-zA-Z_.-]+]] = pod.read %[[B20]][@a]
// CONCRETE: constrain.eq %[[A29]], %[[A30]]
// CONCRETE: %[[C15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT27]][@c]
// CONCRETE: %[[C16:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT28]][@c]
// CONCRETE: %[[A31:[0-9a-zA-Z_.-]+]] = pod.read %[[C15]][@a]
// CONCRETE: %[[A32:[0-9a-zA-Z_.-]+]] = pod.read %[[C16]][@a]
// CONCRETE: constrain.eq %[[A31]], %[[A32]]
// CONCRETE: %[[B21:[0-9a-zA-Z_.-]+]] = pod.read %[[C15]][@b]
// CONCRETE: %[[B22:[0-9a-zA-Z_.-]+]] = pod.read %[[C16]][@b]
// CONCRETE: constrain.eq %[[B21]], %[[B22]]
// CONCRETE: %[[IDX_21:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN6:[0-9a-zA-Z_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[ELEMENT29:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE40:[0-9a-zA-Z_.-]+]]]
// CONCRETE: %[[ELEMENT30:[0-9a-zA-Z_.-]+]] = array.read %[[IN6]]{{\[}}%[[VALUE40]]]
// CONCRETE: %[[A33:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT29]][@a]
// CONCRETE: %[[A34:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT30]][@a]
// CONCRETE: constrain.eq %[[A33]], %[[A34]]
// CONCRETE: %[[B23:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT29]][@b]
// CONCRETE: %[[B24:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT30]][@b]
// CONCRETE: %[[A35:[0-9a-zA-Z_.-]+]] = pod.read %[[B23]][@a]
// CONCRETE: %[[A36:[0-9a-zA-Z_.-]+]] = pod.read %[[B24]][@a]
// CONCRETE: constrain.eq %[[A35]], %[[A36]]
// CONCRETE: %[[C17:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT29]][@c]
// CONCRETE: %[[C18:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT30]][@c]
// CONCRETE: %[[A37:[0-9a-zA-Z_.-]+]] = pod.read %[[C17]][@a]
// CONCRETE: %[[A38:[0-9a-zA-Z_.-]+]] = pod.read %[[C18]][@a]
// CONCRETE: constrain.eq %[[A37]], %[[A38]]
// CONCRETE: %[[B25:[0-9a-zA-Z_.-]+]] = pod.read %[[C17]][@b]
// CONCRETE: %[[B26:[0-9a-zA-Z_.-]+]] = pod.read %[[C18]][@b]
// CONCRETE: constrain.eq %[[B25]], %[[B26]]
// CONCRETE: %[[ELEMENT31:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[IDX_22:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[FIELD7:[0-9a-zA-Z_.-]+]] = struct.readm %[[IDX_22]][@out]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = array.read %[[FIELD7]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[IDX_12:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[FIELD8:[0-9a-zA-Z_.-]+]] = struct.readm %[[IDX_12]][@out]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = array.read %[[FIELD8]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[IDX_04:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[FIELD9:[0-9a-zA-Z_.-]+]] = struct.readm %[[IDX_04]][@out]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = array.read %[[FIELD9]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// CONCRETE: %[[A39:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT31]][@a]
// CONCRETE: %[[A40:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE45:[0-9a-zA-Z_.-]+]][@a]
// CONCRETE: constrain.eq %[[A39]], %[[A40]]
// CONCRETE: %[[B27:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT31]][@b]
// CONCRETE: %[[B28:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE45]][@b]
// CONCRETE: %[[A41:[0-9a-zA-Z_.-]+]] = pod.read %[[B27]][@a]
// CONCRETE: %[[A42:[0-9a-zA-Z_.-]+]] = pod.read %[[B28]][@a]
// CONCRETE: constrain.eq %[[A41]], %[[A42]]
// CONCRETE: %[[C19:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT31]][@c]
// CONCRETE: %[[C20:[0-9a-zA-Z_.-]+]] = pod.read %[[VALUE45]][@c]
// CONCRETE: %[[A43:[0-9a-zA-Z_.-]+]] = pod.read %[[C19]][@a]
// CONCRETE: %[[A44:[0-9a-zA-Z_.-]+]] = pod.read %[[C20]][@a]
// CONCRETE: constrain.eq %[[A43]], %[[A44]]
// CONCRETE: %[[B29:[0-9a-zA-Z_.-]+]] = pod.read %[[C19]][@b]
// CONCRETE: %[[B30:[0-9a-zA-Z_.-]+]] = pod.read %[[C20]][@b]
// CONCRETE: constrain.eq %[[B29]], %[[B30]]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[IDX_06:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[IDX_06]][@in]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[IDX_14:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[IDX_14]][@in]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[IDX_24:[0-9a-zA-Z_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[IDX_24]][@in]
// CONCRETE: function.return

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
// TEMPLATED: pod.write %[[ELEMENT14:[0-9a-zA-Z_.-]+]][@in] = %{{[0-9a-zA-Z_.-]+}} : <[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>]>, !array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT15:[0-9a-zA-Z_.-]+]][@count]
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE16:[0-9a-zA-Z_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE16]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT15]][@count]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 4 : index
// TEMPLATED: %[[VALUE17:[0-9a-zA-Z_.-]+]] = arith.muli %[[N4]], %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[VALUE17]]
// TEMPLATED: pod.write %[[ELEMENT15]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT15]][@params]
// TEMPLATED: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT14]][@in]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @A::@A::@compute(%[[IN1]]) {(%{{[0-9a-zA-Z_.-]+}})} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !felt.type<"bn128">, @b: !pod.type<[@a: !felt.type<"bn128">]>, @c: !pod.type<[@a: !felt.type<"bn128">, @b: !felt.type<"bn128">]>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT15]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD2:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE21:[0-9a-zA-Z_.-]+]][@out]
// TEMPLATED: %[[FIELD3:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE21]][@aux]
// TEMPLATED: %[[FIELD4:[0-9a-zA-Z_.-]+]] = struct.readm %[[VALUE21]][@aux$inputs]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = array.read %[[VALUE22:[0-9a-zA-Z_.-]+]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[ELEMENT17:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[ELEMENT17]][@in]
// TEMPLATED: %[[ELEMENT18:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE26:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT19:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE26]]]
// TEMPLATED: %[[A14:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT18]][@a]
// TEMPLATED: %[[A15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT19]][@a]
// TEMPLATED: constrain.eq %[[A14]], %[[A15]]
// TEMPLATED: %[[B10:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT18]][@b]
// TEMPLATED: %[[B11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT19]][@b]
// TEMPLATED: %[[A16:[0-9a-zA-Z_.-]+]] = pod.read %[[B10]][@a]
// TEMPLATED: %[[A17:[0-9a-zA-Z_.-]+]] = pod.read %[[B11]][@a]
// TEMPLATED: constrain.eq %[[A16]], %[[A17]]
// TEMPLATED: %[[C8:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT18]][@c]
// TEMPLATED: %[[C9:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT19]][@c]
// TEMPLATED: %[[A18:[0-9a-zA-Z_.-]+]] = pod.read %[[C8]][@a]
// TEMPLATED: %[[A19:[0-9a-zA-Z_.-]+]] = pod.read %[[C9]][@a]
// TEMPLATED: constrain.eq %[[A18]], %[[A19]]
// TEMPLATED: %[[B12:[0-9a-zA-Z_.-]+]] = pod.read %[[C8]][@b]
// TEMPLATED: %[[B13:[0-9a-zA-Z_.-]+]] = pod.read %[[C9]][@b]
// TEMPLATED: constrain.eq %[[B12]], %[[B13]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = array.read %[[VALUE22]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[ELEMENT21:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[ELEMENT22:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[IN3:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT22]][@in]
// TEMPLATED: %[[ELEMENT23:[0-9a-zA-Z_.-]+]] = array.read %[[IN3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A20:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT21]][@a]
// TEMPLATED: %[[A21:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT23]][@a]
// TEMPLATED: constrain.eq %[[A20]], %[[A21]]
// TEMPLATED: %[[B14:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT21]][@b]
// TEMPLATED: %[[B15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT23]][@b]
// TEMPLATED: %[[A22:[0-9a-zA-Z_.-]+]] = pod.read %[[B14]][@a]
// TEMPLATED: %[[A23:[0-9a-zA-Z_.-]+]] = pod.read %[[B15]][@a]
// TEMPLATED: constrain.eq %[[A22]], %[[A23]]
// TEMPLATED: %[[C10:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT21]][@c]
// TEMPLATED: %[[C11:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT23]][@c]
// TEMPLATED: %[[A24:[0-9a-zA-Z_.-]+]] = pod.read %[[C10]][@a]
// TEMPLATED: %[[A25:[0-9a-zA-Z_.-]+]] = pod.read %[[C11]][@a]
// TEMPLATED: constrain.eq %[[A24]], %[[A25]]
// TEMPLATED: %[[B16:[0-9a-zA-Z_.-]+]] = pod.read %[[C10]][@b]
// TEMPLATED: %[[B17:[0-9a-zA-Z_.-]+]] = pod.read %[[C11]][@b]
// TEMPLATED: constrain.eq %[[B16]], %[[B17]]
// TEMPLATED: %[[ELEMENT24:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[ELEMENT24]][@in]
// TEMPLATED: %[[ELEMENT25:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE35:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT26:[0-9a-zA-Z_.-]+]] = array.read %{{[0-9a-zA-Z_.-]+}}{{\[}}%[[VALUE35]]]
// TEMPLATED: %[[A26:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT25]][@a]
// TEMPLATED: %[[A27:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT26]][@a]
// TEMPLATED: constrain.eq %[[A26]], %[[A27]]
// TEMPLATED: %[[B18:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT25]][@b]
// TEMPLATED: %[[B19:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT26]][@b]
// TEMPLATED: %[[A28:[0-9a-zA-Z_.-]+]] = pod.read %[[B18]][@a]
// TEMPLATED: %[[A29:[0-9a-zA-Z_.-]+]] = pod.read %[[B19]][@a]
// TEMPLATED: constrain.eq %[[A28]], %[[A29]]
// TEMPLATED: %[[C12:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT25]][@c]
// TEMPLATED: %[[C13:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT26]][@c]
// TEMPLATED: %[[A30:[0-9a-zA-Z_.-]+]] = pod.read %[[C12]][@a]
// TEMPLATED: %[[A31:[0-9a-zA-Z_.-]+]] = pod.read %[[C13]][@a]
// TEMPLATED: constrain.eq %[[A30]], %[[A31]]
// TEMPLATED: %[[B20:[0-9a-zA-Z_.-]+]] = pod.read %[[C12]][@b]
// TEMPLATED: %[[B21:[0-9a-zA-Z_.-]+]] = pod.read %[[C13]][@b]
// TEMPLATED: constrain.eq %[[B20]], %[[B21]]
// TEMPLATED: %[[ELEMENT27:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD2]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[ELEMENT28:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD3]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[FIELD5:[0-9a-zA-Z_.-]+]] = struct.readm %[[ELEMENT28]][@out]
// TEMPLATED: %[[ELEMENT29:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD5]]{{\[}}%{{[0-9a-zA-Z_.-]+}}]
// TEMPLATED: %[[A32:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT27]][@a]
// TEMPLATED: %[[A33:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT29]][@a]
// TEMPLATED: constrain.eq %[[A32]], %[[A33]]
// TEMPLATED: %[[B22:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT27]][@b]
// TEMPLATED: %[[B23:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT29]][@b]
// TEMPLATED: %[[A34:[0-9a-zA-Z_.-]+]] = pod.read %[[B22]][@a]
// TEMPLATED: %[[A35:[0-9a-zA-Z_.-]+]] = pod.read %[[B23]][@a]
// TEMPLATED: constrain.eq %[[A34]], %[[A35]]
// TEMPLATED: %[[C14:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT27]][@c]
// TEMPLATED: %[[C15:[0-9a-zA-Z_.-]+]] = pod.read %[[ELEMENT29]][@c]
// TEMPLATED: %[[A36:[0-9a-zA-Z_.-]+]] = pod.read %[[C14]][@a]
// TEMPLATED: %[[A37:[0-9a-zA-Z_.-]+]] = pod.read %[[C15]][@a]
// TEMPLATED: constrain.eq %[[A36]], %[[A37]]
// TEMPLATED: %[[B24:[0-9a-zA-Z_.-]+]] = pod.read %[[C14]][@b]
// TEMPLATED: %[[B25:[0-9a-zA-Z_.-]+]] = pod.read %[[C15]][@b]
// TEMPLATED: constrain.eq %[[B24]], %[[B25]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = array.read %[[FIELD3]]{{\[}}%[[VALUE40:[0-9a-zA-Z_.-]+]]]
// TEMPLATED: %[[ELEMENT31:[0-9a-zA-Z_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE40]]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[ELEMENT31]][@in]
// TEMPLATED: function.return
