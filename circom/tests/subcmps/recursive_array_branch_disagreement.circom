// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: ! %circom --llzk=templated --llzk_plaintext -o %t %s > %t/diagnostics 2>&1
// RUN: FileCheck %s --input-file %t/diagnostics
// END.

// Disagreeing branches must leave the next recursion parameter unknown.
pragma circom 2.2.3;

template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0];
    } else {
        var next;
        if (a[0]) next = 0;
        else next = 1;
        component child = R(next, a);
        out <== child.out;
    }
}

component main = R(1, [0, 8]);

// CHECK: recursive template specialization repeats at R
