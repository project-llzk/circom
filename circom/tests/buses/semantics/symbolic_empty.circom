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
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Empty_0::@Empty_0::@compute(%[[IN1:[a-zA-Z0-9_.-]+]])
// CONCRETE-NOT: arith.subi
// CONCRETE: %[[POD1:[a-zA-Z0-9_.-]+]] = pod.new { @comp = %[[CHILD1]] }
// CONCRETE-NOT: arith.subi
// CONCRETE: pod.write %[[POD2:[a-zA-Z0-9_.-]+]][@in] = %[[VALUE1:[a-zA-Z0-9_.-]+]]
// CONCRETE-NOT: arith.subi
// CONCRETE: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @child : !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED: struct.member @child$inputs : !pod.type<[@in: !pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>]>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[VALUE1:[a-zA-Z0-9_.-]+]] = poly.read_const @N
// TEMPLATED: %[[VALUE2:[a-zA-Z0-9_.-]+]] = cast.tofelt %[[VALUE1]]
// TEMPLATED: %[[VALUE3:[a-zA-Z0-9_.-]+]] = poly.read_const @N
// TEMPLATED: %[[VALUE4:[a-zA-Z0-9_.-]+]] = cast.tofelt %[[VALUE3]]
// TEMPLATED: %[[POD1:[a-zA-Z0-9_.-]+]] = pod.new { @N = %[[VALUE4]] }
// TEMPLATED: %[[N1:[a-zA-Z0-9_.-]+]] = pod.read %[[POD1]][@N]
// TEMPLATED: %[[VALUE5:[a-zA-Z0-9_.-]+]] = cast.toindex %[[N1]]
// TEMPLATED: %[[N2:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY1:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE5]], %[[N2]]
// TEMPLATED: %[[VALUE6:[a-zA-Z0-9_.-]+]] = scf.if %[[READY1]] -> (!struct.type<@Empty::@Empty<[@N]>>) {
// TEMPLATED: %[[IN1:[a-zA-Z0-9_.-]+]] = pod.read %[[VALUE7:[a-zA-Z0-9_.-]+]][@in]
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Empty::@Empty::@compute(%[[IN1]]) : (!pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED: scf.yield %[[CHILD1]]
// TEMPLATED: } else {
// TEMPLATED: scf.yield %[[VALUE8:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[STATE1:[a-zA-Z0-9_.-]+]] = pod.new { @count = %[[VALUE5]], @params = %[[POD1]], @comp = %[[VALUE6]] }
// TEMPLATED: %[[IN2:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2:[a-zA-Z0-9_.-]+]][@in]
// TEMPLATED: pod.write %[[POD2]][@in] = %[[VALUE9:[a-zA-Z0-9_.-]+]]
// TEMPLATED: %[[COUNT1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[N3:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY2:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[COUNT1]], %[[N3]]
// TEMPLATED: %[[N4:[a-zA-Z0-9_.-]+]] = arith.constant 1 : index
// TEMPLATED: %[[VALUE10:[a-zA-Z0-9_.-]+]] = arith.select %[[READY2]], %[[N4]], %[[N3]]
// TEMPLATED: %[[N5:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY3:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[VALUE10]], %[[N5]]
// TEMPLATED: scf.if %[[READY3]] {
// TEMPLATED: %[[COUNT2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@count]
// TEMPLATED: %[[VALUE11:[a-zA-Z0-9_.-]+]] = cast.toindex %[[VALUE2]]
// TEMPLATED: %[[REMAINING1:[a-zA-Z0-9_.-]+]] = arith.subi %[[COUNT2]], %[[VALUE11]]
// TEMPLATED: pod.write %[[STATE1]][@count] = %[[REMAINING1]]
// TEMPLATED: %[[N6:[a-zA-Z0-9_.-]+]] = arith.constant 0 : index
// TEMPLATED: %[[READY4:[a-zA-Z0-9_.-]+]] = arith.cmpi eq, %[[REMAINING1]], %[[N6]]
// TEMPLATED: scf.if %[[READY4]] {
// TEMPLATED: %[[PARAMS1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@params]
// TEMPLATED: %[[IN3:[a-zA-Z0-9_.-]+]] = pod.read %[[POD2]][@in]
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Empty::@Empty::@compute(%[[IN3]]) : (!pod.type<[@x: !array.type<@N x !felt.type<"bn128">>]>) -> !struct.type<@Empty::@Empty<[@N]>>
// TEMPLATED: pod.write %[[STATE1]][@comp] = %[[CHILD2]]
// TEMPLATED: %[[COMP1:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@comp]
// TEMPLATED: %[[COMP2:[a-zA-Z0-9_.-]+]] = pod.read %[[STATE1]][@comp]
// TEMPLATED: function.return %[[VALUE12:[a-zA-Z0-9_.-]+]]
