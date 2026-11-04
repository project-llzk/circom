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

template Main(choose) {
    A() input a;
    B() input b;
    A() output out;
    // The false branch has the same POD layout but a different bus identity.
    // TEMPLATED: inline_switch_identity_mismatch.circom:[[@LINE+1]]:{{[0-9]+}}: incompatible bus identities A and B
    out <== choose ? a : b;
}

component main = Main(0);

// CONCRETE: trying to assign a different instance of the bus
