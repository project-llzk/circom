// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function earlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        if (i == 0) {
            return in;
        }
        assert(0 == 1); // Unreachable because of the early return above
    }
    return -1;
}

function noEarlyReturnFn(in) {
    for (var i = 0; i < 6; i++) {
        if (i == 99) {
            return in;
        }
        assert(in == 0);
    }
    return -1;
}


template EarlyReturn() {
    signal input inp;
    signal output outp[2];

    outp[0] <== noEarlyReturnFn(inp);
    outp[1] <== earlyReturnFn(inp);
}

component main = EarlyReturn();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
