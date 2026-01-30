// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL: *
// COM: Template parameters expressions are currently unsupported as array dimensions for inputs.

pragma circom 2.0.0;

template ArrayDims(N) {
    signal input arr[N + 1];
}

component main = ArrayDims(7);

// CHECK-LABEL: module attributes {
