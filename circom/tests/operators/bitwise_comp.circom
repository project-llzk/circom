// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template BitwiseComplement() {
    signal input v;
    signal output type;
    signal check_v;
    type <-- ~v;
    check_v <== type*32;
}

component main = BitwiseComplement();
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
