// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// Concrete mode is not run because of an upstream bug: execution decrements the
// bus initialization counter for both runtime branches. Debug builds panic with
// subtraction overflow; release builds reach the uninitialized-tag diagnostic.


// Expressions depending on a signal also leave divergent tag values unknown.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Main() {
    signal input choose;
    Tagged() left;
    Tagged() right;
    Tagged() merged;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;
    if (choose != 0) { merged <-- left; }
    else { merged <-- right; }
    // TEMPLATED: runtime_tag_layout.circom:[[@LINE+1]]:{{[0-9]+}}: tag merged.x.size has no value
    Vec(merged.x.size) output out;
    for (var i = 0; i < merged.x.size; i++) { out.x[i] <== merged.x; }
}

component main = Main();
