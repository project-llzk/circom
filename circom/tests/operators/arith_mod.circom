// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template ArithRemainder() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in != 0 ? 1 % in : 0;

    out <== inv;
    in * out === 0;
}

component main = ArithRemainder();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
