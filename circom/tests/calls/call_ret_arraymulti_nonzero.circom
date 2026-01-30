// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.3;

function long_gt(a, b) {
    for (var i = 1; i >= 0; i--) {
        if (a[i] > b[i]) {
            return 1;
        }
        if (a[i] < b[i]) {
            return 2;
        }
    }
    return 0;
}

function long_scalar_mult() {
    return [[99, 88, 77], [66, 55, 44]];
}

template Test() {
    var norm[2][3] = long_scalar_mult();
    var out[1] = [long_gt(norm[0], norm[1])];
}

component main = Test();

// CHECK-LABEL: module attributes {
