// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

function feeShiftTable() {
    var out[2] = [3,9];
    return out;
}

template ComputeFee() {
    signal output feeOut[3][2];

    for (var i = 0; i < 3; i++) {
        feeOut[i] <== feeShiftTable();
    }
}

component main = ComputeFee();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
