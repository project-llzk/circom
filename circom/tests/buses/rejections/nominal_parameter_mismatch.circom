// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;
bus Point(N) { signal x; }
template Main() {
    Point(2) input in;
    Point(3) output out;
    // TEMPLATED: nominal_parameter_mismatch.circom:[[@LINE+1]]:{{[0-9]+}}: incompatible parameters for bus Point: 3 and 2
    out <== in;
}
component main = Main();

// CONCRETE: trying to assign a different instance of the bus
// CONCRETE: nominal_parameter_mismatch.circom{{.*}}:{{[0-9]+}}:
