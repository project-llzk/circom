// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Array1() {
    signal output out[5][2];

    for (var i = 0; i < 5; i++) {
      out[i][0] <== i;
    }

    for (var i = 0; i < 5; i++) {
      out[i][1] <== i;
    }
}

component main = Array1();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
