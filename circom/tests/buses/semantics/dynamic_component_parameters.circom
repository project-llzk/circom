// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus B(N) { signal x; }

template Child(N) {
    B(N) output out;
    out.x <== 1;
}

template Main(N, idx) {
    component children[2];
    children[0] = Child(2);
    children[1] = Child(2);
    B(2) output out;
    out <== children[idx].out;

    component alternatives[2];
    alternatives[0] = Child(2);
    alternatives[1] = Child(3);
    B(2) output selected;
    selected <== alternatives[0].out;

    component matrix[2][2];
    matrix[0][0] = Child(2);
    matrix[0][1] = Child(2);
    matrix[1][0] = Child(3);
    matrix[1][1] = Child(3);
    B(2) output row;
    row <== matrix[0][idx].out;

    component reused[2];
    var i = 0;
    reused[i] = Child(2);
    i = 1;
    reused[i] = Child(3);
    B(2) output first;
    first <== reused[0].out;

    component looped[2];
    for (var j = 0; j < 2; j++) {
        looped[j] = Child(2);
    }
    B(2) output iterated;
    iterated <== looped[idx].out;

    component bounded[N];
    for (var k = 0; k < N; k++) {
        bounded[k] = Child(2);
    }
    B(2) output parameterized;
    parameterized <== bounded[idx].out;
}

component main = Main(2, 1);

// CONCRETE-LABEL: struct.def @Main_{{[0-9]+}} {
// CONCRETE: constrain.eq

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: constrain.eq
