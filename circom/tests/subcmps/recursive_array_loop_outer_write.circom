// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: ! %circom --llzk=templated --llzk_plaintext -o %t %s > %t/diagnostics 2>&1
// RUN: FileCheck %s --input-file %t/diagnostics
// END.

// A write before a local shadow still invalidates the outer recursion parameter.
pragma circom 2.2.3;

template R(n, a) {
    signal output out;
    for (var i = 0; i < 1; i++) {
        n = 1;
        var n = 0;
        n++;
    }
    if (n == 0) {
        out <== a[0];
    } else {
        component child = R(n, a);
        out <== child.out;
    }
}

component main = R(0, [7, 8]);

// CHECK: recursive template specialization repeats at R
