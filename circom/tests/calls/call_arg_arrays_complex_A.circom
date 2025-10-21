// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.1.0;

function sum(a, b) {
    a[0] = b[1];
    return b;
}

template CallArgTest() {
    signal input x[2][3];
    signal input y[2][3];
    signal output z[2][3];

    z <-- sum(x, y);
}

component main = CallArgTest();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
