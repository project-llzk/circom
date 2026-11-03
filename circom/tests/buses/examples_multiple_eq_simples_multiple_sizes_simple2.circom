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
            aux[i].in.a <-- in1.a;
            aux[i].in.b <-- in1.b;
            aux[i].in.a === in1.a;
            in1.b === aux[i].in.b;
        } else if (i == 1){
            aux[i].in.a <-- in2.a;
            aux[i].in.b <-- in2.b;
            aux[i].in.a === in2.a;
            in2.b === aux[i].in.b;
        } else{
            aux[i].in.a <-- in3.a;
            aux[i].in.b <-- in3.b;
            in3.a === aux[i].in.a;
            in3.b === aux[i].in.b;
        }
        out[i] <-- aux[i].out.b[0];
        out[i] === aux[i].out.b[0];
    }
}

component main = B(2, 3, 2);

// Check bus layouts and leaf equalities; component calls follow input completion.
// CONCRETE-LABEL: struct.def @A_0 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE1:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[A1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// CONCRETE: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A1]], %[[A2]]
// CONCRETE: %[[B1:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// CONCRETE: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE2]][@b]
// CONCRETE: constrain.eq %[[B1]], %[[B2]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @A_1 {
// CONCRETE: struct.member @out : !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[VALUE3:[a-zA-Z0-9_.-]+]][@a] = %[[B3:[a-zA-Z0-9_.-]+]]
// CONCRETE: pod.write %[[VALUE3]][@b] = %[[A3:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.return %[[VALUE4:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE5:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE6:[a-zA-Z0-9_.-]+]][@b]
// CONCRETE: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@a]
// CONCRETE: constrain.eq %[[A4]], %[[B4]]
// CONCRETE: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE6]][@a]
// CONCRETE: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD2]][@b]
// CONCRETE: constrain.eq %[[B5]], %[[A5]]
// CONCRETE: function.return
// CONCRETE-LABEL: struct.def @B_2 {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// CONCRETE: struct.member @aux : !pod.type<[@idx_0: !struct.type<@A_0::@A_0<[]>>, @idx_1: !struct.type<@A_1::@A_1<[]>>, @idx_2: !struct.type<@A_0::@A_0<[]>>]>
// CONCRETE: struct.member @aux$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>]>, @idx_2: !pod.type<[@in: !pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: pod.write %[[IN1:[a-zA-Z0-9_.-]+]][@a] = %[[A6:[a-zA-Z0-9_.-]+]] : <[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>, !array.type<2 x !felt.type<"bn128">>
// CONCRETE: pod.write %[[IDX_21:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// CONCRETE: pod.write %[[VALUE7:[a-zA-Z0-9_.-]+]][@idx_2] = %[[IDX_21]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22:[a-zA-Z0-9_.-]+]][@count]
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 2 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N1]]
// CONCRETE: pod.write %[[IDX_22]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N2]]
// CONCRETE: scf.if %[[READY1]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_22]][@params]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_21]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A_0::@A_0::@compute(%[[IN2]]) : (!pod.type<[@a: !array.type<2 x !felt.type<"bn128">>, @b: !array.type<2 x !felt.type<"bn128">>]>) -> !struct.type<@A_0::@A_0<[]>>
// CONCRETE: pod.write %[[IDX_22]][@comp] = %[[CHILD1]]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @A_1::@A_1::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@a: !array.type<3 x !felt.type<"bn128">>, @b: !array.type<3 x !felt.type<"bn128">>]>) -> !struct.type<@A_1::@A_1<[]>>
// CONCRETE: function.return %[[VALUE8:[a-zA-Z0-9_.-]+]]
// CONCRETE: function.def @constrain(
// CONCRETE: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE9:[a-zA-Z0-9_.-]+]][@out]
// CONCRETE: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE9]][@aux]
// CONCRETE: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE9]][@aux$inputs]
// CONCRETE: %[[IDX_01:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_01]][@in]
// CONCRETE: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@a]
// CONCRETE: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE10:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A7]], %[[A8]]
// CONCRETE: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE10]][@b]
// CONCRETE: %[[IDX_02:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02]][@in]
// CONCRETE: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@b]
// CONCRETE: constrain.eq %[[B6]], %[[B7]]
// CONCRETE: %[[IDX_11:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_11]][@in]
// CONCRETE: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[IN6]][@a]
// CONCRETE: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE11:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: constrain.eq %[[A9]], %[[A10]]
// CONCRETE: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE11]][@b]
// CONCRETE: %[[IDX_12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_12]][@in]
// CONCRETE: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[IN7]][@b]
// CONCRETE: constrain.eq %[[B8]], %[[B9]]
// CONCRETE: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE12:[a-zA-Z0-9_.-]+]][@a]
// CONCRETE: %[[IDX_23:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_23]][@in]
// CONCRETE: %[[A12:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@a]
// CONCRETE: constrain.eq %[[A11]], %[[A12]]
// CONCRETE: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE12]][@b]
// CONCRETE: %[[IDX_24:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_24]][@in]
// CONCRETE: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[IN9]][@b]
// CONCRETE: constrain.eq %[[B10]], %[[B11]]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_25:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@idx_2]
// CONCRETE: %[[FIELD6:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_25]][@out]
// CONCRETE: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD6]][@b]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[B12]]{{\[}}%[[VALUE14:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@idx_1]
// CONCRETE: %[[FIELD7:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_13]][@out]
// CONCRETE: %[[B13:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD7]][@b]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[B13]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// CONCRETE: %[[IDX_03:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@idx_0]
// CONCRETE: %[[FIELD8:[a-zA-Z0-9_.-]+]] = struct.readm %[[IDX_03]][@out]
// CONCRETE: %[[B14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD8]][@b]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[B14]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// CONCRETE: constrain.eq %[[ELEMENT1]], %[[VALUE17:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[IDX_04:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@idx_0]
// CONCRETE: %[[IDX_05:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_0]
// CONCRETE: %[[IN10:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_05]][@in]
// CONCRETE: %[[IDX_14:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@idx_1]
// CONCRETE: %[[IDX_15:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_1]
// CONCRETE: %[[IN11:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_15]][@in]
// CONCRETE: %[[IDX_26:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD4]][@idx_2]
// CONCRETE: %[[IDX_27:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@idx_2]
// CONCRETE: %[[IN12:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_27]][@in]
// CONCRETE: function.return

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED: poly.param @n : index
// TEMPLATED-LABEL: struct.def @A {
// TEMPLATED: struct.member @out : !pod.type<[@a: !array.type<@n x !felt.type<"bn128">>, @b: !array.type<@n x !felt.type<"bn128">>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: pod.write %[[VALUE1:[a-zA-Z0-9_.-]+]][@a] = %[[B1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[VALUE1]][@b] = %[[A1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD1:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE3:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[A2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: %[[A3:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A2]], %[[A3]]
// TEMPLATED: %[[B2:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
// TEMPLATED: %[[B3:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: constrain.eq %[[B2]], %[[B3]]
// TEMPLATED: %[[B4:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@b]
// TEMPLATED: %[[A4:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@a]
// TEMPLATED: constrain.eq %[[A4]], %[[B4]]
// TEMPLATED: %[[A5:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE4]][@a]
// TEMPLATED: %[[B5:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD1]][@b]
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
// TEMPLATED: pod.write %[[IN1:[a-zA-Z0-9_.-]+]][@a] = %[[VALUE5:[a-zA-Z0-9_.-]+]] : <[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>, !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>
// TEMPLATED: pod.write %[[ELEMENT1:[a-zA-Z0-9_.-]+]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2:[a-zA-Z0-9_.-]+]][@count]
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N2]], %[[N1]]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE6]], %[[N3]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@count]
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[VALUE7:[a-zA-Z0-9_.-]+]]
// TEMPLATED: pod.write %[[ELEMENT2]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N4]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@params]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT1]][@in]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@n]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @A::@A::@compute(%[[IN2]]) {(%[[VALUE8:[a-zA-Z0-9_.-]+]])} : (!pod.type<[@a: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>, @b: !array.type<#[[$ATTR_0]] x !felt.type<"bn128">>]>) -> !struct.type<@A::@A<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT2]][@comp] = %[[CHILD1]]
// TEMPLATED: function.return %[[VALUE9:[a-zA-Z0-9_.-]+]]
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIELD2:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10:[a-zA-Z0-9_.-]+]][@out]
// TEMPLATED: %[[FIELD3:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10]][@aux]
// TEMPLATED: %[[FIELD4:[a-zA-Z0-9_.-]+]] = struct.readm %[[VALUE10]][@aux$inputs]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE11:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE12:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE13:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@in]
// TEMPLATED: %[[A6:[a-zA-Z0-9_.-]+]] = pod.read %[[IN3]][@a]
// TEMPLATED: %[[A7:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A6]], %[[A7]]
// TEMPLATED: %[[B6:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14]][@b]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE15:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@in]
// TEMPLATED: %[[B7:[a-zA-Z0-9_.-]+]] = pod.read %[[IN4]][@b]
// TEMPLATED: constrain.eq %[[B6]], %[[B7]]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE16:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@in]
// TEMPLATED: %[[A8:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@a]
// TEMPLATED: %[[A9:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE17:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: constrain.eq %[[A8]], %[[A9]]
// TEMPLATED: %[[B8:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE17]][@b]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE18:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@in]
// TEMPLATED: %[[B9:[a-zA-Z0-9_.-]+]] = pod.read %[[IN6]][@b]
// TEMPLATED: constrain.eq %[[B8]], %[[B9]]
// TEMPLATED: %[[A10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE19:[a-zA-Z0-9_.-]+]][@a]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE20:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@in]
// TEMPLATED: %[[A11:[a-zA-Z0-9_.-]+]] = pod.read %[[IN7]][@a]
// TEMPLATED: constrain.eq %[[A10]], %[[A11]]
// TEMPLATED: %[[B10:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE19]][@b]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE21:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@in]
// TEMPLATED: %[[B11:[a-zA-Z0-9_.-]+]] = pod.read %[[IN8]][@b]
// TEMPLATED: constrain.eq %[[B10]], %[[B11]]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD2]]{{\[}}%[[VALUE22:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE23:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[FIELD5:[a-zA-Z0-9_.-]+]] = struct.readm %[[ELEMENT11]][@out]
// TEMPLATED: %[[B12:[a-zA-Z0-9_.-]+]] = pod.read %[[FIELD5]][@b]
// TEMPLATED: %[[ELEMENT12:[a-zA-Z0-9_.-]+]] = array.read %[[B12]]{{\[}}%[[VALUE24:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: constrain.eq %[[ELEMENT10]], %[[ELEMENT12]]
// TEMPLATED: %[[ELEMENT13:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD3]]{{\[}}%[[VALUE25:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[ELEMENT14:[a-zA-Z0-9_.-]+]] = array.read %[[FIELD4]]{{\[}}%[[VALUE25]]]
// TEMPLATED: %[[IN9:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT14]][@in]
// TEMPLATED: function.return
