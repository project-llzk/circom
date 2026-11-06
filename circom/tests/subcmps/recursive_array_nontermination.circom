// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: ! %circom --llzk=templated --llzk_plaintext -o %t %s > %t/diagnostics 2>&1
// RUN: FileCheck %s --input-file %t/diagnostics --check-prefix=TEMPLATED
// END.

// Increasing the recursion count must fail diagnostically before stack overflow.
pragma circom 2.2.3;

template R(n, a) {
    component child = R(n + 1, a);
    signal output out;
    out <== child.out;
}

component main = R(1, [7, 8]);

// TEMPLATED: recursive template specialization depth limit
// TEMPLATED-NOT: stack overflow
// TEMPLATED-NOT: type is circular
