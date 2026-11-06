// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: ! %circom --llzk=templated --llzk_plaintext -o %t %s > %t/diagnostics 2>&1
// RUN: FileCheck %s --input-file %t/diagnostics
// END.

pragma circom 2.2.3;

function isZero(n) {
    var values[100000000000000000000];
    values[0] = n;
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
// CHECK-NOT: panicked
