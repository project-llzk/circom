// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function factorial(x) {
    if (x == 0 || x == 1) return 1;
    return x * factorial(x - 1);
}

template Caller() {
    signal input inp;
    signal output outp;
    outp <-- factorial(inp);
}

component main = Caller();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
