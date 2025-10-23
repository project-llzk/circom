// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template ArithAdd() {
    signal input a;
    signal input b;
    signal output x;
    x <== a + b;
}

component main = ArithAdd();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
