// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A runtime branch cannot supply a divergent tag as a hidden component parameter.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main() {
    signal input choose;
    Tagged() left;
    Tagged() right;
    Tagged() merged;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;
    if (choose) { merged <-- left; }
    else { merged <-- right; }
    component child = Expand();
    child.in <== merged;
    signal output out;
    out <== child.out.x[0];
}

component main = Main();

// TEMPLATED-DAG: component child requires a value for tag in.x.size
// TEMPLATED-DAG: runtime_tag_component.circom{{.*}}:{{[0-9]+}}:
