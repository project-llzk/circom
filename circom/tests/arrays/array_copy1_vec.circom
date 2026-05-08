// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
pragma circom 2.0.0;

// Vector copy version of `array_copy1_loop.circom` test. Output is identical except for basic blocks.
template Array1(n, S) {
    signal output out[n];

    out <== S;
}

component main = Array1(5, [11,22,33,44,55]);

// CHECK-LABEL: module attributes {
