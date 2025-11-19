// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(a, b) {
    b[0] = a[1];
    b[1] = a[0];
    return a[0][0];
}

template CallArgTest() {
    signal input x[2][3];
    signal input y[2][3];
    signal output z[2][3];
    signal output q;

    q <-- sum(x, y);
}

component main = CallArgTest();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
