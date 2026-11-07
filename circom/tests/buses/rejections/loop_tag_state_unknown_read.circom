// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A parameter-bound loop cannot prove completion for a subsequent tag read.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

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
    signal output out[s.size];
    for (var j = 0; j < s.size; j++) { out[j] <== s; }
}

component main = Main(0);

// CONCRETE: Tag value has not been previously initialized
// TEMPLATED: tag s.size read before all array elements are initialized
