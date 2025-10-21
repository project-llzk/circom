// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// XFAIL:.*

pragma circom 2.0.0;

template InnerConditional9(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        // Values of 'a' at the header per iteration:
        // i=0: [0, 0, 0, 0]
        // i=1: [3996, 0, 0, 0]
        // i=2: [3996, 3996, 0, 0]
        // i=3: [3996, 3996, 3552, 0]
        if (i < 2) {
            // runs when i∈{0,1}
            for (var j = 0; j < N; j++) {
                a[i] += 999;
            }
        } else {
            // runs when i∈{2,3}
            for (var j = 0; j < N; j++) {
                a[i] += 888;
            }
        }
    }
    // At this point, 'a = [3996, 3996, 3552, 3552]', so 'out = 7992'
    out <-- a[0] + a[1];
}

component main = InnerConditional9(4);
//CHECK-LABEL:  module attributes {veridise.lang = "llzk"} {
