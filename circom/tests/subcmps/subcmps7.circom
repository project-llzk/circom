// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
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
    //n.i <== i;
    //o <== n.o;
}

component main = SubCmp();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
// CHECK:     struct.field @n : !struct.type<@Nop<[1]>>
