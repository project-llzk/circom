// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.1.0;

function overwrite(a, b) {
    a[0] = b[1];
    a[1] = b[0];
    return a[0] + a[1];
}

template Gotcha() {
    signal input x[2];
    signal input y[2];
    signal output p;
    log(x[0]);
    p <== overwrite(x, y);
    log(x[0]);
}

component main = Gotcha();

// CHECK-LABEL: module attributes {
