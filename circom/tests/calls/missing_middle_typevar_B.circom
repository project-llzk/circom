// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f(a) {
    return a[0];
}

template Caller(N) {
    signal input inA[8][5][N];
    signal output out;

    // felt[8][5][N] -> felt[5][N] -> felt[N] -> felt
    out <== f(f(f(inA)));
}

component main = Caller(3);

// CHECK-LABEL: module attributes {
