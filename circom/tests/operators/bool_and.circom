// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template BoolAnd() {
    signal input a, b;
    signal output out;

    out <-- (a > 0 && b > 0) ? 1 : 0;
}

component main = BoolAnd();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
