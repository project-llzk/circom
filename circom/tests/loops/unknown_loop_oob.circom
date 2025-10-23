// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template accumulate() {
    signal input i;
    signal output o;
    var r = 0;
    while (r < i) {
        r++;
    }
    o <-- r;
}

template UnknownLoopOOB() {
    signal input m; // Could be out of bounds
    signal input n[2];
    signal output y;

    component a = accumulate();
    a.i <-- m;
    y <-- n[a.o];
}

component main = UnknownLoopOOB();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
