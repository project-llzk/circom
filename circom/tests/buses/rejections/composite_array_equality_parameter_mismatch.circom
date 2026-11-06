// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;

bus B(N) { signal x; }

template Main() {
    B(1) input a;
    B(2) input b;
    // Nested array pairs must still validate nominal bus parameters.
    [[a, a]] === [[b, b]];
}

component main = Main();

// CONCRETE: Trying to compare two different instances of a bus
// TEMPLATED: incompatible parameters for bus B: 1 and 2
