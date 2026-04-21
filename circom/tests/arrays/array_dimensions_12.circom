// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*
// COM: LLZK does not (currently) allow `function.call` in `poly.expr` which is generated to define the dimension of `out2` here.

pragma circom 2.0.0;

function earlyReturnFn(in) {
    var i = 0;
    while (i < 6) {
        return in;
        assert(0 == 1); // Unreachable because of the early return above
        i++;
    }
    return -1;
}

template EvilArrayDims(N) {
    var x = 12;
    var a[2] = [123, 675];
    x = 6;
    signal input in[x];
    a[1] = N + x;
    signal output out1[a[1]];
    if (earlyReturnFn(N) > 0) {
        a[1] = N + 2;
    } else {
        a[1] = N * 2;
    }
    signal output out2[N > 12 ? a[0] + a[1] : 0];
}

component main = EvilArrayDims(7);

// CHECK-LABEL: module attributes {
