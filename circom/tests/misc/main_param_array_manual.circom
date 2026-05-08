// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

// Manually converted from `main_param_array.circom` to avoid the array parameter to the main function.

template T(n, S) {
    signal output out[n] <== S;
}

template MainWrapper() {
    component a = T(5, [11,22,33,44,55]);
    signal output out[5] <== a.out;
}

component main = MainWrapper();

// CHECK-LABEL: module attributes {
