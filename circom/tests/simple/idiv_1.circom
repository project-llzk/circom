// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*
// COM: This test requires the upcoming LLZK `poly.template` op with additional `poly` ops for computation of constants.

pragma circom 2.0.0;

template A() {
    var c = 1 \ -1;
    assert(c == 0); // 0 quotient means circom uses unsigned division
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
