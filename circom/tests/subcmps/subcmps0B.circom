// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

// Like SubCmps1 but simpler (no constraints and fewer operations)
template IsZero() {
    signal input in;
    signal output out;
    out <-- -in;
}

template SubCmps0B(n) {
    signal input ins[n];
    signal output outs[n];
    var temp;
    component zeros[n];
    for (var i = 0; i < n; i++) {
        zeros[i] = IsZero();
        zeros[i].in <-- ins[i];
        outs[i] <-- zeros[i].out;
        temp = zeros[i].out;
    }
}

component main = SubCmps0B(2);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
