// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template Sigma() {
    signal input inp;
    signal output out;
}

// Equivalent to inner_conditional_10 but refactored slightly.
template Poseidon() {
    signal input inp;

    component sigmaF[2];

    for (var i=0; i<4; i++) {
        if (i < 1) {
            sigmaF[0] = Sigma();
            sigmaF[0].inp <== inp;
        } else if (i >= 3) {
            sigmaF[1] = Sigma();
            sigmaF[1].inp <== inp;
        }
    }
}

component main = Poseidon();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
