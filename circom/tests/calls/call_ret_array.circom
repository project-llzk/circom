// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(a) {
    return a;
}

template CallRetTest() {
    signal input x[4];
    signal output y[4];

    y <-- sum(x);
}

component main = CallRetTest();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
