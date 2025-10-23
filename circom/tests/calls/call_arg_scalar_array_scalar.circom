// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(x, a, y) {
    return x + a[0] + a[1] + a[2] + a[3] + y;
}

template CallArgTest() {
    signal input x[4];
    signal output y;

    y <-- sum(77, x, 99);
}

component main = CallArgTest();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
