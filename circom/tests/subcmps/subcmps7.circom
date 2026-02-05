// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL: *

pragma circom 2.0.0;

template Nop(n) {
    signal input i;
    signal output o;
}

template SubCmp() {
    signal input i;
    signal output o;
    component n[2];
    n[0] = Nop(1);
    n[1] = Nop(1);
    //n[0].i <== i;
    //o <== n[0].o;
}

component main = SubCmp();

// CHECK-LABEL: module attributes {
// This test is not 100% testable because array support is not complete.
// Currently we only care about having the right type in the field definition.
// CHECK:     struct.field @n : !array.type<2, !struct.type<@Nop<[1]>>>
