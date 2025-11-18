// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template InnerConditional5(N, T) {
    signal output out[N];

    for (var i = 0; i < N; i++) {
        if (T == 0) {
            out[i] <-- 777;
        } else {
            out[i] <-- 999;
        }
    }
}

template runner() {
    signal output out;

    component a = InnerConditional5(4, 0);
    component b = InnerConditional5(5, 1);

    out <-- a.out[1] + b.out[0];
}

component main = runner();

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
