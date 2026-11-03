// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The size of the field a depends on the n of the component -> adapted to not have assignments of different sizes
// Array of buses with different sizes as inputs
// Choose n,m,l to make the array homogeneus or heterogeneus

bus Simple(n){
    signal a[n];
    signal b[n];
}

template A(n, m){
    Simple(n) input in[m];
    Simple(n) output out[m];

    if (n % 2 == 0){
        out <== in;
    } else{
        for (var i = 0; i < n; i++){
            out[i].a <== in[i].b;
            out[i].b <== in[i].a;
        }
    }
}

template B(n1, m1, n2, m2, n3, m3){
    Simple(n1) input in1[m1];
    Simple(n2) input in2[m2];
    Simple(n3) input in3[m3];
    signal output out[3];

    var sizes[3] = [n1, n2, n3];
    var sizes_m[3] = [m1, m2, m3];

    component aux[3];

    for (var i = 0; i < 3; i++){
        aux[i] = A(sizes[i], sizes_m[i]);
        for (var j_m = 0; j_m < sizes_m[i]; j_m++){
            if (i == 0){
                aux[i].in[j_m].a <-- in1[j_m].a;
                aux[i].in[j_m].b <-- in1[j_m].b;
                aux[i].in[j_m].a === in1[j_m].a;
                in1[j_m].b === aux[i].in[j_m].b;
            } else if (i == 1){
                aux[i].in[j_m].a <-- in2[j_m].a;
                aux[i].in[j_m].b <-- in2[j_m].b;
                in2[j_m].a === aux[i].in[j_m].a;
                in2[j_m].b === aux[i].in[j_m].b;
            } else{
                aux[i].in[j_m].a <-- in3[j_m].a;
                aux[i].in[j_m].b <-- in3[j_m].b;
                in3[j_m].a === aux[i].in[j_m].a;
                in3[j_m].b === aux[i].in[j_m].b;
            }
        }
        out[i] <-- aux[i].out[0].b[0];
        out[i] === aux[i].out[0].b[0];
    }
}

component main = B(2, 5, 6,3,8,3);

// Check bus layouts and leaf equalities; component calls follow input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE1:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE3:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2]]]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@a]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@b]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE5]]]
// CONCRETE: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
// CONCRETE: constrain.eq %[[A3]], %[[A4]]
// CONCRETE: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@b]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// CONCRETE: constrain.eq %[[B3]], %[[B4]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_2 {
// CONCRETE: struct.member @out : !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE7:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE9:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE8]]]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@a]
// CONCRETE: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// CONCRETE: constrain.eq %[[A5]], %[[A6]]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@b]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[B6]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_3 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_2::@A_2<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>]>, @idx_1: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>]>, @idx_2: !pod.type<[@in: !array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[ELEMENT7:[a-zA-Z0-9_.-]+]][@a] = %[[A7:[a-zA-Z0-9_.-]+]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE: array.write %[[IN1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT7]]
// CONCRETE: pod.write %[[IDX_01:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %[[VALUE11:[a-zA-Z0-9_.-]+]][@idx_0] = %[[IDX_01]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 2 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_02]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02]][@params]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_01]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN2]]) : (!array.type<5 x !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[IDX_02]][@comp] = %[[CHILD1]]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @A_1::@A_1::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!array.type<3 x !pod.type<[@a: !array.type<6 x !felt.type<"bn128">>, @b: !array.type<6 x !felt.type<"bn128">>]>>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @A_2::@A_2::@compute(%[[IN4:[a-zA-Z0-9_.-]+]]) : (!array.type<3 x !pod.type<[@a: !array.type<8 x !felt.type<"bn128">>, @b: !array.type<8 x !felt.type<"bn128">>]>>) -> !struct.type<@A_2::@A_2<[]>>
// CONCRETE: function.return %[[VALUE12:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE13:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE13]][@aux]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE13]][@aux$inputs]
// CONCRETE: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_03:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_03]][@in]
// CONCRETE: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[IN5]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@a]
// CONCRETE: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE17:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE18:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@a]
// CONCRETE: constrain.eq %[[A8]], %[[A9]]
// CONCRETE: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE17]]{{\[}}%[[VALUE19:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@b]
// CONCRETE: %[[IDX_04:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_04]][@in]
// CONCRETE: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[IN6]]{{\[}}%[[VALUE20:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT12]][@b]
// CONCRETE: constrain.eq %[[B7]], %[[B8]]
// CONCRETE: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE22:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT13]][@a]
// CONCRETE: %[[IDX_11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_11]][@in]
// CONCRETE: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[IN7]]{{\[}}%[[VALUE23:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT14]][@a]
// CONCRETE: constrain.eq %[[A10]], %[[A11]]
// CONCRETE: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21]]{{\[}}%[[VALUE24:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@b]
// CONCRETE: %[[IDX_12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_12]][@in]
// CONCRETE: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[IN8]]{{\[}}%[[VALUE25:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@b]
// CONCRETE: constrain.eq %[[B9]], %[[B10]]
// CONCRETE: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE26:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE27:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT17]][@a]
// CONCRETE: %[[IDX_21:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[ELEMENT18:[a-zA-Z0-9_.-]+]] = array.read %[[IN9]]{{\[}}%[[VALUE28:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[A13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT18]][@a]
// CONCRETE: constrain.eq %[[A12]], %[[A13]]
// CONCRETE: %[[ELEMENT19:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE26]]{{\[}}%[[VALUE29:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT19]][@b]
// CONCRETE: %[[IDX_22:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN10:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22]][@in]
// CONCRETE: %[[ELEMENT20:[a-zA-Z0-9_.-]+]] = array.read %[[IN10]]{{\[}}%[[VALUE30:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT20]][@b]
// CONCRETE: constrain.eq %[[B11]], %[[B12]]
// CONCRETE: %[[ELEMENT21:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE31:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_23:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_23]][@out]
// CONCRETE: %[[ELEMENT22:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD7]]{{\[}}%[[VALUE32:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT22]][@b]
// CONCRETE: %[[ELEMENT23:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%[[VALUE33:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_13]][@out]
// CONCRETE: %[[ELEMENT24:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD8]]{{\[}}%[[VALUE34:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT24]][@b]
// CONCRETE: %[[ELEMENT25:[a-zA-Z0-9_.-]+]] = array.read %[[B14]]{{\[}}%[[VALUE35:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_05:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[FIELD9:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_05]][@out]
// CONCRETE: %[[ELEMENT26:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD9]]{{\[}}%[[VALUE36:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[B15:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT26]][@b]
// CONCRETE: %[[ELEMENT27:[a-zA-Z0-9_.-]+]] = array.read %[[B15]]{{\[}}%[[VALUE37:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT21]], %[[VALUE38:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[IDX_06:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[IDX_07:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_0]
// CONCRETE: %[[IN11:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_07]][@in]
// CONCRETE: %[[IDX_14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[IDX_15:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_1]
// CONCRETE: %[[IN12:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_15]][@in]
// CONCRETE: %[[IDX_24:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[IDX_25:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@idx_2]
// CONCRETE: %[[IN13:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_25]][@in]
// CONCRETE: function.return

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED: poly.param @m : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !array.type<@m x !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT1:[a-zA-Z0-9_.-]+]][@a] = %[[B1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: array.write %[[VALUE1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE2:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT1]]
// TEMPLATED: pod.write %[[ELEMENT2:[a-zA-Z0-9_.-]+]][@b] = %[[A1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.return %[[VALUE3:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE4:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE5:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE5]]]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@a]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@b]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[B3]]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%[[VALUE7:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@b]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE8:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[B4]]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE6]]{{\[}}%[[VALUE9:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@a]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD1]]{{\[}}%[[VALUE10:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@b]
// TEMPLATED: constrain.eq %[[B5]], %[[A5]]
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
// TEMPLATED: struct.member @aux$inputs : !array.type<3 x !pod.type<[@in: !array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[ELEMENT9:[a-zA-Z0-9_.-]+]][@a] = %[[VALUE11:[a-zA-Z0-9_.-]+]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED: array.write %[[IN1:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]] = %[[ELEMENT9]]
// TEMPLATED: pod.write %[[ELEMENT10:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE13:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE13]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@count]
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[VALUE14:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[ELEMENT11]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N4]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@params]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@in]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[M1:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@m]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%[[VALUE15:[a-zA-Z0-9_.-]+]]), (%[[VALUE16:[a-zA-Z0-9_.-]+]])} : (!array.type<#[[$ATTR_0]] x !pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>>) -> !struct.type<@A::@A<[#[[$ATTR_0]], #[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT11]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE17:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE18:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE18]][@aux]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE18]][@aux$inputs]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE19:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE20:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE22:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE21]]{{\[}}%[[VALUE23:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT15:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE24:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT15]][@in]
// TEMPLATED: %[[ELEMENT16:[a-zA-Z0-9_.-]+]] = array.read %[[IN3]]{{\[}}%[[VALUE25:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT16]][@a]
// TEMPLATED: %[[ELEMENT17:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE26:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE27:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT17]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[ELEMENT18:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE26]]{{\[}}%[[VALUE28:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT18]][@b]
// TEMPLATED: %[[ELEMENT19:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE29:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT19]][@in]
// TEMPLATED: %[[ELEMENT20:[a-zA-Z0-9_.-]+]] = array.read %[[IN4]]{{\[}}%[[VALUE30:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT20]][@b]
// TEMPLATED: constrain.eq %[[B6]], %[[B7]]
// TEMPLATED: %[[ELEMENT21:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE31:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE32:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT21]][@a]
// TEMPLATED: %[[ELEMENT22:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE33:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT22]][@in]
// TEMPLATED: %[[ELEMENT23:[a-zA-Z0-9_.-]+]] = array.read %[[IN5]]{{\[}}%[[VALUE34:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT23]][@a]
// TEMPLATED: constrain.eq %[[A8]], %[[A9]]
// TEMPLATED: %[[ELEMENT24:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE31]]{{\[}}%[[VALUE35:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT24]][@b]
// TEMPLATED: %[[ELEMENT25:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE36:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT25]][@in]
// TEMPLATED: %[[ELEMENT26:[a-zA-Z0-9_.-]+]] = array.read %[[IN6]]{{\[}}%[[VALUE37:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT26]][@b]
// TEMPLATED: constrain.eq %[[B8]], %[[B9]]
// TEMPLATED: %[[ELEMENT27:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE38:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE39:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT27]][@a]
// TEMPLATED: %[[ELEMENT28:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE40:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT28]][@in]
// TEMPLATED: %[[ELEMENT29:[a-zA-Z0-9_.-]+]] = array.read %[[IN7]]{{\[}}%[[VALUE41:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT29]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[ELEMENT30:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE38]]{{\[}}%[[VALUE42:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT30]][@b]
// TEMPLATED: %[[ELEMENT31:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE43:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT31]][@in]
// TEMPLATED: %[[ELEMENT32:[a-zA-Z0-9_.-]+]] = array.read %[[IN8]]{{\[}}%[[VALUE44:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT32]][@b]
// TEMPLATED: constrain.eq %[[B10]], %[[B11]]
// TEMPLATED: %[[ELEMENT33:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE45:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT34:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE46:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[ELEMENT34]][@out]
// TEMPLATED: %[[ELEMENT35:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD5]]{{\[}}%[[VALUE47:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT35]][@b]
// TEMPLATED: %[[ELEMENT36:[a-zA-Z0-9_.-]+]] = array.read %[[B12]]{{\[}}%[[VALUE48:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT33]], %[[ELEMENT36]]
// TEMPLATED: %[[ELEMENT37:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE49:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT38:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE49]]]
// TEMPLATED: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT38]][@in]
// TEMPLATED: function.return
