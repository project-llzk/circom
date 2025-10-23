// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template ForKnown(N) {
    signal output out;

    var acc = 0;
    for (var i = 1; i <= N; i++) {
        acc += i;
    }

    out <-- acc;
}

component main = ForKnown(10);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
