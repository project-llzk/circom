// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template BoolNot() {
    signal input a, b;
    signal output out;

    out <-- !(a < b) ? 1 : 0;
}

component main = BoolNot();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
