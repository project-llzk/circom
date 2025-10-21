// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

// Vector copy version of `array_copy2_loop.circom` test. Output is identical except for basic blocks.
template Array2(n) {
    signal input inp[n];
    signal output out[n];

    out <== inp;
}

component main = Array2(5);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
