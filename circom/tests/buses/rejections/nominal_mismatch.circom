// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;
bus A() { signal x; }
bus B() { signal x; }
template Main() {
    A() input in;
    B() output out;
    // CONCRETE: nominal_mismatch.circom":[[@LINE+2]]:{{[0-9]+}}
    // TEMPLATED: nominal_mismatch.circom":[[@LINE+1]]:{{[0-9]+}}
    out <== in;
}
component main = Main();

// CONCRETE: Expected same type of bus but found different types.

// TEMPLATED: Expected same type of bus but found different types.
