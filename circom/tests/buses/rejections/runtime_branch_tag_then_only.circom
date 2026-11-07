// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// Swapping the runtime branches must still discard the one-sided propagated tag.
// A runtime array write keeps the selector unknown to compile-time tag analysis.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Expand() {
    signal input {size} in;
    Vec(in.size) output out;
    for (var i = 0; i < in.size; i++) { out.x[i] <== in; }
}

template Main() {
    signal input index;
    var choose[2] = [1, 1];
    choose[index] = 0;
    signal plain;
    signal {size} tagged;
    signal merged;
    plain <== 5;
    tagged.size = 2;
    tagged <== 7;
    if (choose[0]) { merged <== tagged; }
    else { merged <== plain; }
    component child = Expand();
    child.in <== merged;
    signal output out;
    out <== child.out.x[0];
}

component main = Main();

// CONCRETE: There are constraints depending on the value of a condition that can be unknown
// TEMPLATED: component child requires input tag in.size
