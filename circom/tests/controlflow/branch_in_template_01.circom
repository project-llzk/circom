// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Conditional() {
    signal input inp;
    var q;
    if (inp) {
        q = 0;
    } else {
        q = 1;
    }
}

component main = Conditional();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
