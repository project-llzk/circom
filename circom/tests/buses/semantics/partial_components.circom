// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Nested partial writes in loops complete both entries of a mixed component array.

pragma circom 2.2.3;
bus Point() { signal x; signal y; }
bus Points() { Point() points[2]; }
template Sum(N) {
    Points() input in;
    signal output out;
    out <== in.points[0].x + in.points[0].y + in.points[1].x + in.points[1].y + N;
}
template Main() {
    signal input in[4];
    component children[2];
    children[0] = Sum(2);
    children[1] = Sum(3);
    for (var j = 0; j < 2; j++) {
        for (var i = 0; i < 2; i++) {
            children[j].in.points[i].x <== in[2*i];
            children[j].in.points[i].y <== in[2*i + 1];
        }
    }
    signal output out;
    out <== children[0].out + children[1].out;
}
component main = Main();

// Each component starts with four inputs; x and y writes each consume one.
// Check the leaf-to-parent updates and only compute when the remainder is zero.
// CONCRETE-LABEL: struct.def @Main_2 {
// CONCRETE: struct.member @children : !pod.type<[@idx_0: !struct.type<@Sum_0::@Sum_0<[]>>, @idx_1: !struct.type<@Sum_1::@Sum_1<[]>>]>
// CONCRETE: struct.member @children$inputs : !pod.type<[@idx_0: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>, @idx_1: !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>]>
// CONCRETE: function.def @compute(
// CONCRETE: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// CONCRETE: %[[STATE1:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N1]], @params = %[[POD1:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Sum_0::@Sum_0<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// CONCRETE: %[[STATE2:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N2]], @params = %[[POD1]] }  : <[@count: index, @comp: !struct.type<@Sum_1::@Sum_1<[]>>, @params: !pod.type<[]>]>
// CONCRETE: %[[VALUE1:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE2:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE3:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE1]]]
// CONCRETE: %[[VALUE4:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE5:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant true
// CONCRETE: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE4]], %[[N4]]
// CONCRETE: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE4]], %[[N5]]
// CONCRETE: %[[IDX_11:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE6:[a-zA-Z0-9_.-]+]][@idx_1]
// CONCRETE: %[[IDX_12:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7:[a-zA-Z0-9_.-]+]][@idx_1]
// CONCRETE: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_12]][@in]
// CONCRETE: %[[POINTS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IN1]][@points]
// CONCRETE: %[[VALUE8:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE9:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS1]]{{\[}}%[[VALUE8]]]
// CONCRETE: %[[X1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@x]
// CONCRETE: pod.write %[[ELEMENT2]][@x] = %[[ELEMENT1]]
// CONCRETE: array.write %[[POINTS1]]{{\[}}%[[VALUE8]]] = %[[ELEMENT2]]
// CONCRETE: pod.write %[[IN1]][@points] = %[[POINTS1]]
// CONCRETE: pod.write %[[IDX_12]][@in] = %[[IN1]]
// CONCRETE: pod.write %[[VALUE7]][@idx_1] = %[[IDX_12]]
// CONCRETE: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_11]][@count]
// CONCRETE: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT1]], %[[N6]]
// CONCRETE: pod.write %[[IDX_11]][@count] = %[[REMAINING1]]
// CONCRETE: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N7]]
// CONCRETE: scf.if %[[READY3]] {
// CONCRETE: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_11]][@params]
// CONCRETE: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_12]][@in]
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Sum_1::@Sum_1::@compute(%[[IN2]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE: pod.write %[[IDX_11]][@comp] = %[[CHILD1]]
// CONCRETE: pod.write %[[VALUE6]][@idx_1] = %[[IDX_11]]
// CONCRETE: %[[IDX_01:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE6]][@idx_0]
// CONCRETE: %[[IDX_02:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7]][@idx_0]
// CONCRETE: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02]][@in]
// CONCRETE: %[[POINTS2:[a-zA-Z0-9_.-]+]] = pod.read %[[IN3]][@points]
// CONCRETE: %[[VALUE10:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE9]]
// CONCRETE: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS2]]{{\[}}%[[VALUE10]]]
// CONCRETE: %[[X2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@x]
// CONCRETE: pod.write %[[ELEMENT3]][@x] = %[[ELEMENT1]]
// CONCRETE: array.write %[[POINTS2]]{{\[}}%[[VALUE10]]] = %[[ELEMENT3]]
// CONCRETE: pod.write %[[IN3]][@points] = %[[POINTS2]]
// CONCRETE: pod.write %[[IDX_02]][@in] = %[[IN3]]
// CONCRETE: pod.write %[[VALUE7]][@idx_0] = %[[IDX_02]]
// CONCRETE: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_01]][@count]
// CONCRETE: %[[N8:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N8]]
// CONCRETE: pod.write %[[IDX_01]][@count] = %[[REMAINING2]]
// CONCRETE: %[[N9:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N9]]
// CONCRETE: scf.if %[[READY4]] {
// CONCRETE: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_01]][@params]
// CONCRETE: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_02]][@in]
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Sum_0::@Sum_0::@compute(%[[IN4]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE: pod.write %[[IDX_01]][@comp] = %[[CHILD2]]
// CONCRETE: pod.write %[[VALUE6]][@idx_0] = %[[IDX_01]]
// CONCRETE: %[[VALUE11:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE12:[a-zA-Z0-9_.-]+]]
// CONCRETE: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE3]]{{\[}}%[[VALUE11]]]
// CONCRETE: %[[VALUE13:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE5]]
// CONCRETE: %[[N10:[a-zA-Z0-9_.-]+]] = arith.constant true
// CONCRETE: %[[N11:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY5:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE13]], %[[N11]]
// CONCRETE: %[[N12:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[READY6:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE13]], %[[N12]]
// CONCRETE: %[[IDX_13:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14:[a-zA-Z0-9_.-]+]]#0[@idx_1]
// CONCRETE: %[[IDX_14:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14]]#1[@idx_1]
// CONCRETE: %[[IN5:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_14]][@in]
// CONCRETE: %[[POINTS3:[a-zA-Z0-9_.-]+]] = pod.read %[[IN5]][@points]
// CONCRETE: %[[VALUE15:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE9]]
// CONCRETE: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS3]]{{\[}}%[[VALUE15]]]
// CONCRETE: %[[Y1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT5]][@y]
// CONCRETE: pod.write %[[ELEMENT5]][@y] = %[[ELEMENT4]]
// CONCRETE: array.write %[[POINTS3]]{{\[}}%[[VALUE15]]] = %[[ELEMENT5]]
// CONCRETE: pod.write %[[IN5]][@points] = %[[POINTS3]]
// CONCRETE: pod.write %[[IDX_14]][@in] = %[[IN5]]
// CONCRETE: pod.write %[[VALUE14]]#1[@idx_1] = %[[IDX_14]]
// CONCRETE: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_13]][@count]
// CONCRETE: %[[N13:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING3:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT3]], %[[N13]]
// CONCRETE: pod.write %[[IDX_13]][@count] = %[[REMAINING3]]
// CONCRETE: %[[N14:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY7:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING3]], %[[N14]]
// CONCRETE: scf.if %[[READY7]] {
// CONCRETE: %[[PARAMS3:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_13]][@params]
// CONCRETE: %[[IN6:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_14]][@in]
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @Sum_1::@Sum_1::@compute(%[[IN6]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_1::@Sum_1<[]>>
// CONCRETE: pod.write %[[IDX_13]][@comp] = %[[CHILD3]]
// CONCRETE: pod.write %[[VALUE14]]#0[@idx_1] = %[[IDX_13]]
// CONCRETE: %[[IDX_03:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14]]#0[@idx_0]
// CONCRETE: %[[IDX_04:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE14]]#1[@idx_0]
// CONCRETE: %[[IN7:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_04]][@in]
// CONCRETE: %[[POINTS4:[a-zA-Z0-9_.-]+]] = pod.read %[[IN7]][@points]
// CONCRETE: %[[VALUE16:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE9]]
// CONCRETE: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS4]]{{\[}}%[[VALUE16]]]
// CONCRETE: %[[Y2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@y]
// CONCRETE: pod.write %[[ELEMENT6]][@y] = %[[ELEMENT4]]
// CONCRETE: array.write %[[POINTS4]]{{\[}}%[[VALUE16]]] = %[[ELEMENT6]]
// CONCRETE: pod.write %[[IN7]][@points] = %[[POINTS4]]
// CONCRETE: pod.write %[[IDX_04]][@in] = %[[IN7]]
// CONCRETE: pod.write %[[VALUE14]]#1[@idx_0] = %[[IDX_04]]
// CONCRETE: %[[COUNT4:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_03]][@count]
// CONCRETE: %[[N15:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// CONCRETE: %[[REMAINING4:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT4]], %[[N15]]
// CONCRETE: pod.write %[[IDX_03]][@count] = %[[REMAINING4]]
// CONCRETE: %[[N16:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// CONCRETE: %[[READY8:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING4]], %[[N16]]
// CONCRETE: scf.if %[[READY8]] {
// CONCRETE: %[[PARAMS4:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_03]][@params]
// CONCRETE: %[[IN8:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_04]][@in]
// CONCRETE: %[[CHILD4:[a-zA-Z0-9_.-]+]] = function.call @Sum_0::@Sum_0::@compute(%[[IN8]]) : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum_0::@Sum_0<[]>>
// CONCRETE: pod.write %[[IDX_03]][@comp] = %[[CHILD4]]
// CONCRETE: pod.write %[[VALUE14]]#0[@idx_0] = %[[IDX_03]]
// CONCRETE: %[[IDX_05:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE17:[a-zA-Z0-9_.-]+]]#0[@idx_0]
// CONCRETE: %[[COMP1:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_05]][@comp]
// CONCRETE: %[[IDX_15:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE17]]#0[@idx_1]
// CONCRETE: %[[COMP2:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_15]][@comp]
// CONCRETE: %[[IDX_06:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE17]]#0[@idx_0]
// CONCRETE: %[[COMP3:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_06]][@comp]
// CONCRETE: %[[IDX_16:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE17]]#0[@idx_1]
// CONCRETE: %[[COMP4:[a-zA-Z0-9_.-]+]] = pod.read %[[IDX_16]][@comp]
// CONCRETE: function.return %[[VALUE18:[a-zA-Z0-9_.-]+]]

// TEMPLATED: #[[$ATTR_0:[0-9a-zA-Z_\.]+]] = affine_map<(d0) -> (d0)>
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @children : !array.type<2 x !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>>
// TEMPLATED: struct.member @children$inputs : !array.type<2 x !pod.type<[@in: !pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// TEMPLATED: %[[STATE1:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N1]], @params = %[[POD1:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[2]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE1:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE2:[a-zA-Z0-9_.-]+]]
// TEMPLATED: array.write %[[VALUE3:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE1]]] = %[[VALUE4:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 4 : index
// TEMPLATED: %[[STATE2:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[N2]], @params = %[[POD2:[a-zA-Z0-9_.-]+]] }  : <[@count: index, @comp: !struct.type<@Sum::@Sum<[3]>>, @params: !pod.type<[@N: !felt.type<"bn128">]>]>
// TEMPLATED: %[[VALUE5:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE6:[a-zA-Z0-9_.-]+]]
// TEMPLATED: array.write %[[VALUE3]]{{\[}}%[[VALUE5]]] = %[[VALUE7:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[VALUE8:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE9:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[ELEMENT1:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE10:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE8]]]
// TEMPLATED: %[[VALUE11:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE12:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[ELEMENT2:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE13:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE11]]]
// TEMPLATED: %[[ELEMENT3:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE11]]]
// TEMPLATED: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@in]
// TEMPLATED: %[[POINTS1:[a-zA-Z0-9_.-]+]] = pod.read %[[IN1]][@points]
// TEMPLATED: %[[VALUE15:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE16:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[ELEMENT4:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS1]]{{\[}}%[[VALUE15]]]
// TEMPLATED: %[[X1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT4]][@x]
// TEMPLATED: pod.write %[[ELEMENT4]][@x] = %[[ELEMENT1]]
// TEMPLATED: array.write %[[POINTS1]]{{\[}}%[[VALUE15]]] = %[[ELEMENT4]]
// TEMPLATED: pod.write %[[IN1]][@points] = %[[POINTS1]]
// TEMPLATED: pod.write %[[ELEMENT2]][@in] = %[[IN1]]
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@count]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N3]]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE17:[a-zA-Z0-9_.-]+]] = arith.select %[[READY1]], %[[N4]], %[[N3]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE17]], %[[N5]]
// TEMPLATED: scf.if %[[READY2]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@count]
// TEMPLATED: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[N6]]
// TEMPLATED: pod.write %[[ELEMENT3]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N7:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N7]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT3]][@params]
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT2]][@in]
// TEMPLATED: %[[N8:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS1]][@N]
// TEMPLATED: %[[VALUE18:[a-zA-Z0-9_.-]+]] = cast.toindex %[[N8]]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Sum::@Sum::@compute(%[[IN2]]) {(%[[VALUE18]])} : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT3]][@comp] = %[[CHILD1]]
// TEMPLATED: array.write %[[VALUE13]]{{\[}}%[[VALUE11]]] = %[[ELEMENT2]]
// TEMPLATED: array.write %[[VALUE14]]{{\[}}%[[VALUE11]]] = %[[ELEMENT3]]
// TEMPLATED: %[[VALUE19:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE20:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[ELEMENT5:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE10]]{{\[}}%[[VALUE19]]]
// TEMPLATED: %[[VALUE21:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE12]]
// TEMPLATED: %[[ELEMENT6:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE13]]{{\[}}%[[VALUE21]]]
// TEMPLATED: %[[ELEMENT7:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE14]]{{\[}}%[[VALUE21]]]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@in]
// TEMPLATED: %[[POINTS2:[a-zA-Z0-9_.-]+]] = pod.read %[[IN3]][@points]
// TEMPLATED: %[[VALUE22:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE16]]
// TEMPLATED: %[[ELEMENT8:[a-zA-Z0-9_.-]+]] = array.read %[[POINTS2]]{{\[}}%[[VALUE22]]]
// TEMPLATED: %[[Y1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT8]][@y]
// TEMPLATED: pod.write %[[ELEMENT8]][@y] = %[[ELEMENT5]]
// TEMPLATED: array.write %[[POINTS2]]{{\[}}%[[VALUE22]]] = %[[ELEMENT8]]
// TEMPLATED: pod.write %[[IN3]][@points] = %[[POINTS2]]
// TEMPLATED: pod.write %[[ELEMENT6]][@in] = %[[IN3]]
// TEMPLATED: %[[COUNT3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@count]
// TEMPLATED: %[[N9:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT3]], %[[N9]]
// TEMPLATED: %[[N10:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE23:[a-zA-Z0-9_.-]+]] = arith.select %[[READY4]], %[[N10]], %[[N9]]
// TEMPLATED: %[[N11:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY5:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE23]], %[[N11]]
// TEMPLATED: scf.if %[[READY5]] {
// TEMPLATED: %[[COUNT4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@count]
// TEMPLATED: %[[N12:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[REMAINING2:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT4]], %[[N12]]
// TEMPLATED: pod.write %[[ELEMENT7]][@count] = %[[REMAINING2]]
// TEMPLATED: %[[N13:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY6:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING2]], %[[N13]]
// TEMPLATED: scf.if %[[READY6]] {
// TEMPLATED: %[[PARAMS2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT7]][@params]
// TEMPLATED: %[[IN4:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT6]][@in]
// TEMPLATED: %[[N14:[a-zA-Z0-9_.-]+]] = pod.read %[[PARAMS2]][@N]
// TEMPLATED: %[[VALUE24:[a-zA-Z0-9_.-]+]] = cast.toindex %[[N14]]
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Sum::@Sum::@compute(%[[IN4]]) {(%[[VALUE24]])} : (!pod.type<[@points: !array.type<2 x !pod.type<[@x: !felt.type<"bn128">, @y: !felt.type<"bn128">]>>]>) -> !struct.type<@Sum::@Sum<[#[[$ATTR_0]]]>>
// TEMPLATED: pod.write %[[ELEMENT7]][@comp] = %[[CHILD2]]
// TEMPLATED: array.write %[[VALUE13]]{{\[}}%[[VALUE21]]] = %[[ELEMENT6]]
// TEMPLATED: array.write %[[VALUE14]]{{\[}}%[[VALUE21]]] = %[[ELEMENT7]]
// TEMPLATED: %[[VALUE25:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE26:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[ELEMENT9:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE27:[a-zA-Z0-9_.-]+]]#0{{\[}}%[[VALUE25]]]
// TEMPLATED: %[[COMP1:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT9]][@comp]
// TEMPLATED: %[[VALUE28:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE29:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[ELEMENT10:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE27]]#0{{\[}}%[[VALUE28]]]
// TEMPLATED: %[[COMP2:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT10]][@comp]
// TEMPLATED: %[[N15:[a-zA-Z0-9_.-]+]] = arith.constant 2 : index
// TEMPLATED: %[[N16:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[N17:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[ELEMENT11:[a-zA-Z0-9_.-]+]] = array.read %[[VALUE27]]#0{{\[}}%[[VALUE30:[a-zA-Z0-9_.-]+]]]
// TEMPLATED: %[[COMP3:[a-zA-Z0-9_.-]+]] = pod.read %[[ELEMENT11]][@comp]
// TEMPLATED: array.write %[[VALUE31:[a-zA-Z0-9_.-]+]]{{\[}}%[[VALUE30]]] = %[[COMP3]]
// TEMPLATED: function.return %[[VALUE32:[a-zA-Z0-9_.-]+]]
