// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t && %circom --stabilize --llzk --llzk_plaintext --llzk_strip_debug_info -o %t %s | sed -n 's/.*Written successfully:.* \(.*\)/\1/p' | xargs cat | FileCheck %s --enable-var-scope
// END.
// XFAIL:.*

pragma circom 2.0.0;

function create_large_array(t) {
    if (t == 2) {
        return [
            11,
            22,
            33,
            44
        ];
    } else if (t == 3) {
        return [
            11,
            22,
            33,
            44,
            55,
            66,
            77,
            88,
            99
        ];
    } else {
        assert(0);
        return [0];
    }
}

template Mixer(t, S, r) {
    signal input inp;
    signal output out;

    var lc = 0;
    for (var i = 0; i < t; i++) {
        lc += S[t*r+i] * inp;
    }
    out <== lc;
}

template Main(t) {
    signal input inp;
    signal output out;

    var S[t*t] = create_large_array(t);

    component mix[t];
    var lc = 0;
    for (var r = 0; r < t; r++) {
        mix[r] = Mixer(t, S, r);
        mix[r].inp <-- inp;
        lc += mix[r].out;
    }
    out <-- lc;
}

component main = Main(2);

// CHECK-LABEL: module attributes {
