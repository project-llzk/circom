// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*
// COM: This test requires the upcoming LLZK `poly.template` op with additional `poly` ops for computation of constants.

pragma circom 2.0.0;

template A(n) {
    signal output c <== n \ 4; // this op can be used in a constraint only because it folds to a constant
}

component main = A(12);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
