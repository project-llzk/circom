// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;

bus Point(N) { signal x; }

template Main(choose) {
    Point(3) input a;
    Point(2) input b;
    Point(2) output out;
    // The true branch has the same POD layout but different nominal parameters.
    // TEMPLATED: inline_switch_parameter_mismatch.circom:[[@LINE+1]]:{{[0-9]+}}: incompatible parameters for bus Point: 2 and 3
    out <== choose ? a : b;
}

component main = Main(1);

// CONCRETE: trying to assign a different instance of the bus
