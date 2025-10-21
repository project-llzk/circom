// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template FibonacciTmpl(N) {
    signal output out;

    var a = 0;
    var b = 1;
    var next = 0;

    var counter = N;
    while (counter > 2) { // known iteration count
        next = a + b;
        a = b;
        b = next;

        counter--;
    }

    if (N == 0) {
        out <-- 0;
    } else if (N == 1) {
        out <-- 1;
    } else {
        out <-- a + b;
    }
}

component main = FibonacciTmpl(5);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
