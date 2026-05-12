// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template CompConstant(ct) {
    signal input in;
    signal output out;

    out <== ct * in;
}

template Sign() {
    signal input in;
    signal output sign;

    component comp = CompConstant(10944121435919637611123202872628637544274182200208017171849102093287904247808);

    comp.in <== in;
    sign <== comp.out;
}



component main = Sign();

// CHECK-LABEL: module attributes {
