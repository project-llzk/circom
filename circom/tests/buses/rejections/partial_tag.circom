// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;
bus Pair() { signal {size} x[2]; }
template Main() {
    signal {size} s;
    s.size = 7;
    s <== 3;
    Pair() a;
    a.x[0] <== s;
    signal output out;
    // TEMPLATED: partial_tag.circom:[[@LINE+1]]:{{[0-9]+}}: tag a.x.size read before all array elements are initialized
    out <== a.x.size;
}
component main = Main();

// CONCRETE: Tag value has not been previously initialized
// CONCRETE: partial_tag.circom{{.*}}:{{[0-9]+}}:
