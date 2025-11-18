// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template UnknownIndexStore() {
    signal input in;
    signal output out[8];

    out[in] <-- 999;
}

component main = UnknownIndexStore();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
