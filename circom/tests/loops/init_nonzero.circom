// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

// Ensure that non-zero initialization of for-loop iteration variable is handled properly.
template NonZeroInit() {
    signal input a[9];
    signal output b[9];

    for (var i = 4; i < 7; i++) {
        b[i] <-- a[i];
    }
    for (var i = 7; i < 9; i++) {
        b[i] <-- a[i];
    }
    for (var i = 0; i < 4; i++) {
        b[i] <-- a[i];
    }
}

component main = NonZeroInit();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
