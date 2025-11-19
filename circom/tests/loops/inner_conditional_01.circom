// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --llzk -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

template InnerConditional1(N) {
    signal output out;

    var acc = 0;
    for (var i = 1; i <= N; i++) {
        if (i < 5) {
            acc += i;
        } else {
            acc -= i;
        }
    }
    //Values at loop header per iteration
    //  N, acc, i
    // 10,   0, 1
    // 10,   1, 2
    // 10,   3, 3
    // 10,   6, 4
    // 10,  10, 5
    // 10,   5, 6
    // 10,  -1, 7
    // 10,  -8, 8
    // 10, -16, 9
    // 10, -25, 10

    out <-- acc;
}

component main = InnerConditional1(10);

// CHECK-LABEL: module attributes {veridise.lang = "llzk"} {
