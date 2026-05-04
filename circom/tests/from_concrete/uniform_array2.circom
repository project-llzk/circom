// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template C(n) {
    signal output outp;
    outp <== n;
}

template Caller(n) {
    signal outp[2];

    component c[2];
    for (var i = 0; i < 2; i++) {
      c[i] = C(n);
      outp[i] <== c[i].outp;
    }
}

component main = Caller(5);
