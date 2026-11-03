// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

pragma circom 2.2.3;
bus Point() { signal x; }
template Child() {
    Point() input {binary} in;
    signal output out;
    out <== in.x;
}
template Main() {
    Point() input in;
    // TEMPLATED: missing_tag.circom:[[@LINE+1]]:{{[0-9]+}}: component child requires input tag in.binary
    component child = Child();
    child.in <== in;
    signal output out;
    out <== child.out;
}
component main = Main();

// CONCRETE: input signal in requires tag binary
// CONCRETE: missing_tag.circom{{.*}}:{{[0-9]+}}:
