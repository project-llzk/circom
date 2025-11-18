// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

// like inner_conditional_7 but with 'i' and 'j' uses swapped (and a larger constant)
template InnerConditional8(N) {
    signal output out;

    var a[N];
    for (var i = 0; i < N; i++) {
        // Values of 'a' at the header per iteration:
        // i=0: [0, 0, 0, 0]
        // i=1: [1776, 0, 0, 0]
        // i=2: [1776, 1776, 0, 0]
        // i=3: [1776, 1776, 1776, 0]
        for (var j = 0; j < N; j++) {
            if (j > 1) {
                a[i] += 999;
            } else {
                a[i] -= 111;
            }
        }
    }
    // At this point, 'a[x] = 1776' for all 'x', so 'out = 3552'
    out <-- a[0] + a[1];
}

component main = InnerConditional8(4);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
