// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

// Vector copy version of `array_copy3_vec.circom` test.
template Array3(n) {
    signal input inp[n][n];
    signal output out[n][n];

    for(var i = 0; i < n; i++) {
        for(var j = 0; j < n; j++) {
            out[i][j] <== inp[i][j];
        }
    }
}

component main = Array3(5);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
