// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template BitwiseAnd() {
    signal input v;
    signal output type;
    signal check_v;
    type <-- v & 5;
    check_v <== type*32;
}

component main = BitwiseAnd();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
