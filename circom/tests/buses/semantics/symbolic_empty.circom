// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// A zero dimension forwarded through template parameters compiles in both modes.

pragma circom 2.2.3;
bus Vec(N) { signal x[N]; }
template Empty(N) {
    Vec(N) input in;
    signal output out;
    out <== 7;
}
template Main(N) {
    Vec(N) input in;
    component child = Empty(N);
    child.in <== in;
    signal output out;
    out <== child.out;
}
component main = Main(0);

// Concrete zero inputs compute immediately. A symbolic N tests for zero
// before construction and skips the decrement when the input count is zero.
// CONCRETE-LABEL: struct.def @Main_1 {
// CONCRETE-NOT: arith.subi
// CONCRETE: struct.member @child : !struct.type<@Empty_0::@Empty_0<[]>>
// CONCRETE-NOT: arith.subi
// CONCRETE: struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !array.type<0 x !felt.type<"bn128">>]>]>
// CONCRETE-NOT: arith.subi
// CONCRETE: function.def @compute(
// CONCRETE-NOT: arith.subi
// CONCRETE: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @Empty_0::@Empty_0::@compute(%{{[0-9a-zA-Z_.-]+}})
// CONCRETE-NOT: arith.subi
// CONCRETE: %{{[0-9a-zA-Z_.-]+}} = pod.new { @comp = %[[CHILD1]] }
// CONCRETE-NOT: arith.subi
// CONCRETE: pod.write %{{[0-9a-zA-Z_.-]+}}[@in] = %{{[0-9a-zA-Z_.-]+}}
// CONCRETE-NOT: arith.subi
// CONCRETE: function.return %{{[0-9a-zA-Z_.-]+}}

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @child : !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED: struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[VALUE1:[0-9a-zA-Z_.-]+]] = poly.read_const @N
// TEMPLATED: %[[VALUE2:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VALUE1]]
// TEMPLATED: %[[VALUE3:[0-9a-zA-Z_.-]+]] = poly.read_const @N
// TEMPLATED: %[[VALUE4:[0-9a-zA-Z_.-]+]] = cast.tofelt %[[VALUE3]]
// TEMPLATED: %[[POD1:[0-9a-zA-Z_.-]+]] = pod.new { @N = %[[VALUE4]] }
// TEMPLATED: %[[N1:[0-9a-zA-Z_.-]+]] = pod.read %[[POD1]][@N]
// TEMPLATED: %[[VALUE5:[0-9a-zA-Z_.-]+]] = cast.toindex %[[N1]]
// TEMPLATED: %[[N2:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE5]], %[[N2]]
// TEMPLATED: %[[VALUE6:[0-9a-zA-Z_.-]+]] = scf.if %[[READY1]] -> (!struct.type<@Empty::@Empty<[@N]>>) {
// TEMPLATED: %[[IN1:[0-9a-zA-Z_.-]+]] = pod.read %{{[0-9a-zA-Z_.-]+}}[@in]
// TEMPLATED: %[[CHILD1:[0-9a-zA-Z_.-]+]] = function.call @Empty::@Empty::@compute(%[[IN1]]) : (!pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED: scf.yield %[[CHILD1]]
// TEMPLATED: } else {
// TEMPLATED: scf.yield %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: %[[STATE1:[0-9a-zA-Z_.-]+]] = pod.new { @count = %[[VALUE5]], @params = %[[POD1]], @comp = %[[VALUE6]] }
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[POD2:[0-9a-zA-Z_.-]+]][@in]
// TEMPLATED: pod.write %[[POD2]][@in] = %{{[0-9a-zA-Z_.-]+}}
// TEMPLATED: %[[COUNT1:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N3:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N3]]
// TEMPLATED: %[[N4:[0-9a-zA-Z_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE10:[0-9a-zA-Z_.-]+]] = arith.select %[[READY2]], %[[N4]], %[[N3]]
// TEMPLATED: %[[N5:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[VALUE10]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[COUNT2:[0-9a-zA-Z_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[VALUE11:[0-9a-zA-Z_.-]+]] = cast.toindex %[[VALUE2]]
// TEMPLATED: %[[REMAINING1:[0-9a-zA-Z_.-]+]] = arith.subi %[[COUNT2]], %[[VALUE11]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N6:[0-9a-zA-Z_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY4:[0-9a-zA-Z_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N6]]
// TEMPLATED: scf.if %[[READY4]] {
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN3:[0-9a-zA-Z_.-]+]] = pod.read %[[POD2]][@in]
// TEMPLATED: %[[CHILD2:[0-9a-zA-Z_.-]+]] = function.call @Empty::@Empty::@compute(%[[IN3]]) : (!pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD2]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@comp]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = pod.read %[[STATE1]][@comp]
// TEMPLATED: function.return %{{[0-9a-zA-Z_.-]+}}
