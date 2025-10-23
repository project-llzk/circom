// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.1.0;

function f(a, b) {
    return a + b;
}

// In circom, `signal` and `var` are both field elements, so there's
// actually no difference in the function type between the two calls.
template CallDiffTypeTest() {
    signal input in1;
    signal input in2;
    signal output out1;
    signal output out2;

    out1 <== f(in1, in2); // f: (felt, felt) -> felt

    var a = 1;
    var x = f(a, in2); // f: (felt, felt) -> felt
    out2 <== x;
}

component main = CallDiffTypeTest();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
