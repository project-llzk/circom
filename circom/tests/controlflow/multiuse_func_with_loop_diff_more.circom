// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

function f(s, count, offset) {
    var sum = 0;
    for (var i = 0; i < count; i++) {
        sum += s[i + offset];
    }
    return sum;
}

template MultiUse() {
    signal input inp[10];
    signal output outp[3];

    outp[0] <-- f(inp, 2, 1);
    outp[1] <-- f(inp, 2, 0);
    outp[2] <-- f(inp, 2, 3);
}

component main = MultiUse();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
