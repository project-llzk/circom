// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template A() {
    signal output val;

    val <-- 0;
    val === 0;
}

component main = A();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
