// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template CmpEQ(n) {
    signal input a[n];
    signal output b[n];

    if (n == 0) {
      b[0] <== a[0];
    } else {
      b[1] <== a[1];
    }
}

component main = CmpEQ(5);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
