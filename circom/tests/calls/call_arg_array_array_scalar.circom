// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(a, b, c) {
    return a[0][0][0] + a[1][0][0] + a[2][0][0] + a[3][0][0] + b[0][0] + b[1][2] + c;
}

template CallArgTest() {
    signal input x[4][2][3];
    signal input y[2][3];
    signal input z;
    signal output q;

    q <-- sum(x, y, z);
}

component main = CallArgTest();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
