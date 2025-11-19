// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.1.0;

function f(a) {
    return a[0][0];
}

// The two calls to `f()` have different argument types which requires
// two versions of `f()` to be generated. These functions must also be
// parametric in the size of the last array dimension. The flattened
// circuit thus has 4 versions of `f()`.
template CallDiffTypeTest(N) {
    signal input inA[8][5][N];
    signal input inB[8][N];
    signal output outA[N];
    signal output outB;

    outA <== f(inA); // f: (felt[8][5][N]) -> felt[N]
    outB <== f(inB); // f: (felt[8][N]) -> felt
}

template Main() {
    signal input inA[8][5][3];
    signal input inB[8][3];
    signal input inC[8][5][2];
    signal input inD[8][2];
    
    signal output outA[3];
    signal output outB;
    signal output outC[2];
    signal output outD;

    component crt1 = CallDiffTypeTest(3);
    crt1.inA <== inA;
    crt1.inB <== inB;
    outA <== crt1.outA;
    outB <== crt1.outB;
    component crt2 = CallDiffTypeTest(2);
    crt2.inA <== inC;
    crt2.inB <== inD;
    outC <== crt2.outA;
    outD <== crt2.outB;
}

component main = Main();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
