// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A runtime inline switch cannot supply a divergent tag to a component layout.
// Concrete execution currently panics before reaching the backend because an
// unknown inline-switch selector produces a scalar value even for bus operands.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main() {
    signal input choose;
    Tagged() left;
    Tagged() right;
    Tagged() merged;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;
    merged <== choose ? left : right;
    // TEMPLATED: inline_switch_tag_merge_unequal.circom:[[@LINE+1]]:{{[0-9]+}}: component child requires a value for tag in.x.size
    component child = Expand();
    child.in <== merged;
    signal output out;
    out <== child.out.x[0];
}

component main = Main();

// CONCRETE: panicked at {{.*}}constraint_generation/src/execute.rs:
// CONCRETE-NEXT: internal error: entered unreachable code
