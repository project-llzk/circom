// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template VariantIndex(n) {
    signal input in;
    signal output out[n*n];

    var x = 1;
    for (var i = 0; i<n; i++) {
        x = x + i;
        out[x] <-- (in >> i);
    }
}

component main = VariantIndex(2);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
