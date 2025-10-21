// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template ArithPower() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in != 0 ? in ** 2 : 0;

    out <== inv;
    in * out === 0;
}

component main = ArithPower();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
