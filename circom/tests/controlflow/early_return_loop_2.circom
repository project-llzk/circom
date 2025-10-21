// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

function earlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        return in;
        assert(0 == 1); // This can be ignored because of the early return above
    }
    return -1;
}

template EarlyReturn() {
    signal input inp;
    signal output outp;

    outp <== earlyReturnFn(inp);
}

component main = EarlyReturn();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
