// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template FixIdxNested() {
    signal input in[16];
    signal output out[16];
    
    var arr[16] = [0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 1, 6, 11];

    for (var i = 0; i < 16; i++) {
        out[i] <== in[arr[i]];
    }
}

component main = FixIdxNested();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
