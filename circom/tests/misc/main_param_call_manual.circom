// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

// Manually converted from `main_param_call.circom` to avoid the array parameter to the main function.

function f() {
    return 42;
}

template T(n) {
    signal output out <== n;
}

template MainWrapper() {
    component a = T(f());
    signal output out <== a.out;
}

component main = MainWrapper();

// CHECK-LABEL: module attributes {
