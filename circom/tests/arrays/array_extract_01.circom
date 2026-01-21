// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template A() {
    signal input in[17][13];
    signal output out;

    var sum = 0;
    for(var i = 0; i < 17; i++) {
        var tmp[13];
        tmp = in[i];

        sum += tmp[i % 13];
    }
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
