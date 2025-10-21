// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template CmpLE(n) {
    signal input a[n];
    signal output b[n];

    for (var i = 0; i <= n-1; i++) {
      b[i] <== a[i];
    }
}

component main = CmpLE(5);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
