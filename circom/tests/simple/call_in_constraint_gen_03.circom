// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function f(i) {
    if (i < 10) {
        return i + 2;
    } else {
        return i + 3;
    }
}

template T() {
    signal input inp;
    signal output outp;

    // error[T3001]: Non quadratic constraints are not allowed!
    outp <== f(inp);
}

component main = T();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
