// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function f(a) {
    return a[0][0];
}

// The two calls to `f()` have different argument types which requires
// two versions of `f()` to be generated.
template CallDiffTypeTest() {
    signal input inA[10][5][5];
    signal input inB[10][5];
    signal output outA[5];
    signal output outB;

    outA <== f(inA); // f: (felt[10][5][5]) -> felt[5]
    outB <== f(inB); // f: (felt[10][5]) -> felt
}

component main = CallDiffTypeTest();

// CHECK-LABEL: module attributes {
