// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

// Vector copy version of `array_copy1_loop.circom` test.
template Array4(n, m, S) {
    signal output out[n][m];

    out <== S;
}

component main = Array4(3, 2, [[11,22],[33,44],[55,66]]);

// CHECK-LABEL: module attributes {
