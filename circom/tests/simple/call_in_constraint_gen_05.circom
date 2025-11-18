// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f(a, b) {
    return a + b;
}

template T() {
    signal input inp1;
    signal input inp2;
    signal input inp3;

    // Circom generates constraint "inp1 = inp2 + inp3"
    inp1 === f(inp2, inp3);
}

component main = T();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
