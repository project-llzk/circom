// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A parameter-bound loop may execute zero times, so its propagated tag cannot
// specialize a downstream component layout.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Expand() {
    signal input {size} in;
    signal output out[in.size];
    for (var j = 0; j < in.size; j++) { out[j] <== in; }
}

template Main(N) {
    Tagged() source;
    source.x.size = 2;
    source.x <== 3;
    signal {size} s;
    var i = 0;
    while (i < N) {
        s <== source.x;
        i++;
    }
    component child = Expand();
    child.in <== s;
    signal output out;
    out <== child.out[0];
}

component main = Main(0);

// CONCRETE: trying to access to a signal that is not initialized
// TEMPLATED: component child requires a value for tag in.size
