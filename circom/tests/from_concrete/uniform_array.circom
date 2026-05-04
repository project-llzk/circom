// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk=concrete --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.

pragma circom 2.0.0;

template Sum(n) {
    signal input inp[n];
    signal output outp;

    var acc = 0;
    for (var i = 0; i < n; i++) {
        acc += inp[i];
    }

    outp <== acc;
}

template Caller(n, m) {
    signal input inp[m][n];
    signal inter[m];
    signal outp;

    component step1[m];
    for (var i = 0; i < m; i++) {
      step1[i] = Sum(n);
      step1[i].inp <== inp[i];
      inter[i] <== step1[i].outp;
    }

    component step2 = Sum(m);
    step2.inp <== inter;
    outp <== step2.outp;
}

component main = Caller(5, 3);
