// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template InnerConditional4(N) {
    signal output out[N];
    signal input in;

    for (var i = 0; i < N; i++) {
        if (i < 3) {
            out[i] <-- -in;
        } else {
            out[i] <-- in;
        }
    }
}

component main = InnerConditional4(6);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
