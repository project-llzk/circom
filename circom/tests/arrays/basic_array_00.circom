// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template Array00() {
    signal input a[1];
    signal output b[1];

    b[0] <== a[0];
}

component main = Array00();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
