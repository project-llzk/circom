// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template InnerConditional7(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        // Values of 'a' at the header per iteration:
        // i=0: [0, 0, 0, 0]
        // i=1: [-111, -111, -111]
        // i=2: [-222, -222, -222]
        // NOTE: Technically there are no negative values, it's instead wrapped modulo the field prime
        for (var j = 0; j < N; j++) {
            if (i > 1) {
                a[j] += 999;
            } else {
                a[j] -= 111;
            }
        }
    }
    // At this point, 'a[x] = 777' for all 'x', so 'out = 1554'
    out <-- a[0] + a[1];
}

component main = InnerConditional7(3);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
