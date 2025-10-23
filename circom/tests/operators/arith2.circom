// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Arith2() {
    signal input a;
    signal input b;
    signal input c;
    signal output x;
    x <== a * b * 10;
}

component main = Arith2();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
