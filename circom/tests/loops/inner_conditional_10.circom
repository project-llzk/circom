// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Sigma() {
    signal input inp;
    signal output out;
}

template Poseidon() {
    signal input inp;

    component sigmaF[2];
    for (var i=0; i<4; i++) {
        if (i < 1 || i >= 3) {
            var k = i < 1 ? 0 : 1;
            sigmaF[k] = Sigma();
            sigmaF[k].inp <== inp;
        }
    }
}

component main = Poseidon();

// CHECK-LABEL: module attributes {
