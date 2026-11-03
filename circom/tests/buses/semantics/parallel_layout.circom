// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s
// END.

// Forward derived layout arguments through parallel components whose callers
// do not declare buses themselves, including nested parallel annotations.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template ZChild(N) {
    Vec(N + 1) values;
    for (var i = 0; i < N + 1; i++) { values.x[i] <== i; }
    signal output out;
    out <== values.x[N];
}

template Middle(N) {
    component child = parallel (parallel ZChild(N + 1));
    signal output out;
    out <== child.out;
}

template Main(N) {
    component child = parallel Middle(N);
    signal output out;
    out <== child.out;
}

component main = Main(2);
