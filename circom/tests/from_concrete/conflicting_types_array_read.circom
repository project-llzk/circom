// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL: *

pragma circom 2.0.0;

template Inner(P) {
    signal input in[4];
    signal output out[4];
    for (var k = 0; k < 4; k++) {
        out[k] <== in[k] + P;
    }
}

template Outer() {
    signal input in[8];
    signal output out[8];

    component inner[2];
    signal mid[2 * 4];

    for (var i = 0; i < 8; i++) {
        mid[i] <== in[i];
    }

    for (var i = 0; i < 2; i++) {
        inner[i] = Inner(i);
        for (var k = 0; k < 4; k++) {
            // Failed to generate LLZK IR: Conflicting types to read array at loc("conflicting_types_array_read.circom":31:13)
            inner[i].in[k] <== mid[i * 4 + k];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var k = 0; k < 4; k++) {
            out[i * 4 + k] <== inner[i].out[k];
        }
    }
}

component main = Outer();
