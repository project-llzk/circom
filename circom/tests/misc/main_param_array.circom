// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template T(n, S) {
    signal output out[n] <== S;
}

component main = T(5, [11,22,33,44,55]);

// CHECK-LABEL: module attributes {
