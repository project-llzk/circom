// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template CmpGT(n) {
    signal input a[n];
    signal output b[n];

    for (var i = n; i > 0; i--) {
      b[i-1] <== a[i-1];
    }
}

component main = CmpGT(5);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
