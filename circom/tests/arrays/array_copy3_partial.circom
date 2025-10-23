// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

// Parital vector copy version of `array_copy3_loop.circom` test. The outer dimension is traversed
//  explicitly but the inner dimension is treated as a vector copy. Output is identical.
template Array3(n) {
    signal input inp[n][n];
    signal output out[n][n];

    for (var i = 0; i < n; i++) {
        out[i] <== inp[i];
    }
}

component main = Array3(5);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
