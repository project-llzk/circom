// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL: *
// COM: Template parameters expressions are currently unsupported as array dimensions.

pragma circom 2.0.0;

template ArrayDims(N) {
    var M = N + 1;
    var arr[M];
}

component main = ArrayDims(7);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
