// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(a) {
    var b[2][4][3] = a;
    return b;
}

template CallRetTest() {
    signal input x[2][4][3];
    signal output y[2][4][3];

    y <-- sum(x);
}

component main = CallRetTest();

// CHECK-LABEL: module attributes {
