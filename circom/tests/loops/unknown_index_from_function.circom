// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

function identity(n) {
    return n;
}

template Example(n) {
    signal input a[n];
    signal input b;
    signal output c[n];
    
    for(var i = 0; i < n; i++) {
        c[i] <-- a[identity(b)];
    }
}

component main = Example(3);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
