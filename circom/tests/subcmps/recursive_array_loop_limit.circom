// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: ! %circom --llzk=templated --llzk_plaintext -o %t %s > %t/diagnostics 2>&1
// RUN: FileCheck %s --input-file %t/diagnostics
// END.

pragma circom 2.2.3;

// Exhausting the unrolling budget must not specialize using a partial iteration.
template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0];
    } else {
        var i = 0;
        while (i >= 0) {
            i++;
        }
        component child = R(n - i - 1, [a[0]]);
        out <== child.out;
    }
}

component main = R(1, [7, 8]);

// CHECK: recursive template specialization repeats at R
