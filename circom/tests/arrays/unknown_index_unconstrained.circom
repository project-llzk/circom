// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template UnknownIndex() {
    signal input in;
    signal output out;

    var arr2[10] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    // non-quadractic constraint
    // out <== arr[acc];
    out <-- arr2[in];
}

component main = UnknownIndex();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
