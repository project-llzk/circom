// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

// Scalar copy version of `array_copy1_vec.circom` test.
template Array1(n, S) {
    signal output out[n];

    for (var i = 0; i < n; i++) {
      out[i] <== S[i];
    }
}

component main = Array1(5, [11,22,33,44,55]);

// CHECK-LABEL: module attributes {
