// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f(s, n) {
    var sum = 0;
    for (var i = 0; i < n; i++) {
        sum += s[i];
    }
    return sum;
}

template MultiUse() {
    signal input inp[10];
    signal output outp[3];

    outp[0] <-- f(inp, 2);
    outp[1] <-- f(inp, 5);
    outp[2] <-- f(inp, 9);
}

component main = MultiUse();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
