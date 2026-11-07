// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus Packet(N) { signal {size} x[N]; }

// Scalar recursion preserves input/output tags and derived bus layout parameters.
template Chain(depth, width) {
    Packet(width + 1) input in;
    Packet(width + 1) output out;
    if (depth == 0) {
        out <== in;
    } else {
        component child = Chain(depth - 1, width);
        child.in <== in;
        out <== child.out;
    }
}

template Main() {
    Packet(3) source;
    source.x.size = 7;
    source.x <== [3, 5, 8];
    component chain = Chain(2, 2);
    chain.in <== source;
    signal output size;
    signal output value;
    size <== chain.out.x.size;
    value <== chain.out.x[2];
}

component main = Main();

// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type
// CONCRETE-LABEL: struct.def @Main{{_[0-9]+}} {
// CONCRETE: %[[SIZE:[0-9a-zA-Z_.-]+]] = felt.const 7 :
// CONCRETE-NEXT: struct.writem {{.*}}[@size] = %[[SIZE]] :

// TEMPLATED-LABEL: poly.template @Chain$values$0_0$1_2 {
// TEMPLATED-NOT: struct.member @child
// TEMPLATED: function.def @compute(
// TEMPLATED-LABEL: poly.template @Chain$values$0_2$1_2 {
// TEMPLATED: struct.member @child : !struct.type<@Chain$values$0_1$1_2::
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: function.call @Chain$values$0_2$1_2::
// TEMPLATED: %[[SIZE:[0-9a-zA-Z_.-]+]] = felt.const 7 :
// TEMPLATED-NEXT: struct.writem {{.*}}[@size] = %[[SIZE]] :
