// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function array_computation(x, n) {
    var ret[2];
    var i;
    for (i = 0; i < n \ 2; i++) {
        ret[0] += x[i];
    }
    for (i = n \ 2; i < n; i++) {
        ret[1] += x[i];
    }
    return ret;
}

template Caller() {
    signal input inp[5];
    signal output outp[2] <== array_computation(inp, 5);
}

component main = Caller();

// CHECK-LABEL: module attributes {
