// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f1(a) {
    return a;
}

function f2(a) {
    return a + 1;
}

function example(N, M){
    if (N >= M) { return 1; }
    else { return 0; }
}

template Caller() {
    signal input in;
    signal output out;

    out <== example(f1(in), f2(in));
}

component main = Caller();

// CHECK-LABEL: module attributes {
