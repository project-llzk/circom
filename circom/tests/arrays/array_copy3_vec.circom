// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

// Vector copy version of `array_copy3_loop.circom` test. Output is very similar except the
//  vector version comes through the circom front-end as a flattened array which mean lvar
//  indexing is slightly different here. There is only one loop iteration variable instead
//  of two and the additional statements for updating index variables are not necessary.
template Array3(n) {
    signal input inp[n][n];
    signal output out[n][n];

    out <== inp;
}

component main = Array3(5);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
