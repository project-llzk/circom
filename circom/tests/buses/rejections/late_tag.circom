// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;
bus Point() { signal {size} x; }
template Main() {
    signal input in;
    Point() a;
    a.x <== in;
    // TEMPLATED: late_tag.circom:[[@LINE+1]]:{{[0-9]+}}: tag a.x.size assigned after signal initialization
    a.x.size = 3;
}
component main = Main();

// CONCRETE: tags cannot be assigned to a signal already initialized
// CONCRETE: late_tag.circom{{.*}}:{{[0-9]+}}:
