// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A partial symbolic-length bus field must not propagate a tag value into a
// component's hidden layout parameters, even when copying its initialized element.

pragma circom 2.2.3;

bus Tagged(N) { signal {size} x[N]; }

template Expand() {
    signal input {size} in;
    signal output out[in.size];
    for (var i = 0; i < in.size; i++) { out[i] <== in; }
}

template Main(N) {
    signal {size} s;
    s.size = 2;
    s <== 3;
    Tagged(N) a;
    a.x[0] <== s;
    component child = Expand();
    child.in <== a.x[0];
    signal output out;
    out <== child.out[0];
}

component main = Main(2);

// CONCRETE-DAG: Tag value has not been previously initialized
// CONCRETE-DAG: partial_symbolic_tag_propagation.circom{{.*}}:{{[0-9]+}}:

// TEMPLATED-DAG: component child requires a value for tag in.size
// TEMPLATED-DAG: partial_symbolic_tag_propagation.circom{{.*}}:{{[0-9]+}}:
