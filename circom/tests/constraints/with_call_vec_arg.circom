// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function feeShiftTable(a, i) {
    return a[i];
}

template ComputeFee() {
    signal output feeOut[2];
    var temp[2][2] = [[3,9],[6,7]];

    for (var i = 0; i < 2; i++) {
        feeOut[i] <== feeShiftTable(temp[i], i);
    }
}

component main = ComputeFee();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
