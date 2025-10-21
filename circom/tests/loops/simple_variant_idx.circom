// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template SimpleVariantIdx(n) {
    signal input in;
    signal output out[n];

	var lc;
    for (var i = 0; i < n; i++) {
        out[i] <-- in;
        lc = out[i];
    }
}

component main = SimpleVariantIdx(3);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
