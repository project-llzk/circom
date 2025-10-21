// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template UnknownIndexLoadStore() {
    signal input in;
    signal output out[8];

    var unused1[9] = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    var arr2[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var unused2[11] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    out[in] <-- arr2[in];
}

component main = UnknownIndexLoadStore();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
