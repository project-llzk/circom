// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.3;

template GetWeight(A, B) {
    signal output x;    //signal index 0
    signal output y;    //signal index 1
    signal output out;  //signal index 2
    out <-- A;
}

template ComputeValue() {
    component ws[2];
    ws[0] = GetWeight(999, 0);
    ws[1] = GetWeight(888, 1);

    signal ret[2];
    ret[0] <== ws[0].out;
    ret[1] <== ws[1].out;
}

component main = ComputeValue();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
