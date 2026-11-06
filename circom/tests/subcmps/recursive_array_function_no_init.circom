// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: ! %circom --no_init --llzk=templated --llzk_plaintext -o %t %s > %t/diagnostics 2>&1
// RUN: FileCheck %s --input-file %t/diagnostics
// END.

pragma circom 2.2.3;

// Without the generated zero initializer, the explicit initializer must not
// make the evaluator ignore the declared length of two at the initial call.
function isZero(n) {
    var values[2] = [0];
    return values[0] == 0;
}

template R(n, a) {
    signal output out;
    if (isZero(n)) {
        out <== a[0];
    } else {
        component child = R(n, a);
        out <== child.out;
    }
}

component main = R(1, [7, 8]);

// CHECK: recursive template specialization repeats at R
