// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template B() {
    signal input a;
    signal input b;
    signal output c;

    c <== a * b;
}

template A() {
    signal input a[2];
    signal input b[2];
    signal output c[4];
    signal x;

    for (var i = 0; i < 4; i++) {
        if (i % 2 == 0) {
            c[i] <== a[i \ 2];
        } else {
            c[i] <== b[i \ 2];
        }
    }

    x <== c[0];
}

component main {public [a, b]} = A();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
