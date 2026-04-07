// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function sum(a, b, c, d) {
    if (a < 7) {
        return b;
    } else if (a > 12) {
        return c;
    } else {
        return d;
    }
}

template CallArgTest() {
    signal input a;
    signal input b[2][3];
    signal input c[2][3];
    signal input d[2][3];
    signal output z[2][3];

    z <-- sum(a, b, c, d);
}

component main = CallArgTest();

// CHECK-LABEL: module attributes {
