// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Simple3() {
    signal input a;
    signal output b;
    signal output c;

    b <== a;
    c <== a;
}

component main = Simple3();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
