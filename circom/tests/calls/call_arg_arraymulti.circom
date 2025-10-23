// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(a) {
    var agg = 0;
    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 2; j++) {
            agg += a[i][j];
        }
    }
    return agg;
}

template CallArgTest() {
    signal input x[3][2];
    signal output y;

    y <-- sum(x);
}

component main = CallArgTest();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
