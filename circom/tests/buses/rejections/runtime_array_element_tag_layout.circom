// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A runtime value at a known index invalidates that element's earlier constant.
// Concrete mode rejects runtime-dependent constraints; templated mode cannot
// derive the tag-dependent bus layout from the divergent runtime branches.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Main() {
    signal input condition;
    var choose[1] = [1];
    choose[0] = condition;
    signal {size} left;
    signal {size} right;
    signal {size} merged;
    left.size = 2;
    right.size = 3;
    left <== 5;
    right <== 7;
    if (choose[0]) { merged <== left; }
    else { merged <== right; }
    Vec(merged.size) output out;
    for (var i = 0; i < merged.size; i++) { out.x[i] <== merged; }
}

component main = Main();

// CONCRETE: There are constraints depending on the value of a condition that can be unknown
// TEMPLATED: tag merged.size has no value
