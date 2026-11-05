// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;

bus B(N) { signal x; }

template Child(N) {
    B(N) output out;
    out.x <== 1;
}

template Main(idx) {
    component children[2];
    children[0] = Child(2);
    children[1] = Child(2);
    B(3) output out;
    // A symbolic selection must retain the children's nominal bus parameters.
    // TEMPLATED: dynamic_component_parameter_mismatch.circom:[[@LINE+1]]:{{[0-9]+}}: incompatible parameters for bus B: 3 and 2
    out <== children[idx].out;
}

component main = Main(0);

// CONCRETE: trying to assign a different instance of the bus
