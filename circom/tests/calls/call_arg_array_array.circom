// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(a, b) {
    return a[0] + a[1] + a[2] + a[3] + b[0] + b[1];
}

template CallArgTest() {
    signal input x[4];
    signal input y[2];
    signal output z;

    z <-- sum(x, y);
}

component main = CallArgTest();

// CHECK-LABEL: module attributes {
