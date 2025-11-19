// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template Simple4(a) {
    signal output b;
    signal input c;
    signal input d;
    var x;
    var y;

    x = a;
    y = 11;

    b <== a;
}

component main = Simple4(10);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
