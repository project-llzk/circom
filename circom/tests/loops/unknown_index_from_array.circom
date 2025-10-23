// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Example(n) {
    signal input a[n];
    signal input b[n];
    signal output c[n];

    for(var i = 0; i < n; i++) {
        c[i] <-- a[b[2]];
    }
}

component main = Example(3);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
