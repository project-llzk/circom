// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.1.0;

function sum(a) {
    return a[0] + a[1] + a[2] + a[3];
}

template CallArgTest() {
    signal input x[4];
    signal output y;

    y <-- sum(x);
}

component main = CallArgTest();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
