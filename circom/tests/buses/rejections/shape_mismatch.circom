// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;
bus Vec(N) { signal x[N]; }
template Main() {
    Vec(2) input in;
    Vec(3) output out;
    out <== in;
}
component main = Main();

// CONCRETE-DAG: trying to assign a different instance of the bus
// CONCRETE-DAG: shape_mismatch.circom{{.*}}:{{[0-9]+}}:
// TEMPLATED-DAG: incompatible parameters for bus Vec: 3 and 2
// TEMPLATED-DAG: shape_mismatch.circom{{.*}}:{{[0-9]+}}:
