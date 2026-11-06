// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: ! %circom --llzk=templated --llzk_plaintext -o %t %s > %t/diagnostics 2>&1
// RUN: FileCheck %s --input-file %t/diagnostics
// END.

pragma circom 2.2.3;

function unresolved(n) {
    while (1) {
        n++;
    }
    return n;
}

template R(n, a) {
    signal output out;
    if (unresolved(n)) {
        out <== a[0];
    } else {
        component child = R(n, a);
        out <== child.out;
    }
}

component main = R(1, [7, 8]);

// CHECK: recursive template specialization repeats at R
// CHECK-NOT: stack overflow
