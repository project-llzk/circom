// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template UnknownIndexOverwriteKnown() {
    signal input in;
    signal output out;

    var scalar1 = 45;
    var arr1[10] = [00, 01, 02, 03, 04, 05, 06, 07, 08, 09];
    var arr2[10] = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
    var arr3[10] = [20, 21, 22, 23, 24, 25, 26, 27, 28, 29];

    arr2[in] = 99;
    scalar1 = 46;

    assert(arr2[9] == 19);
    assert(arr2[9] == 99);

    assert(arr1[9] == 09);
    assert(arr1[4] == 04);
    assert(arr3[0] == 20);
    assert(arr3[7] == 27);

    assert(scalar1 == 46);
}

component main = UnknownIndexOverwriteKnown();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
