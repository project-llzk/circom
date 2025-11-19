// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.3;

template GetWeight(A) {
    signal input inp;
}

template ComputeValue() {
    component getWeights[2];

    getWeights[0] = GetWeight(0);
    getWeights[0].inp <-- 888;

    getWeights[1] = GetWeight(1);
    getWeights[1].inp <-- 999;
}

component main = ComputeValue();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
