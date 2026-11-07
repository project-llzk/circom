// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// Tags from the selector or just one alternative cannot supply a component layout.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Expand() {
    signal input {size} in;
    Vec(in.size) output out;
    for (var i = 0; i < in.size; i++) { out.x[i] <== in; }
}

template Main() {
    signal input choice;
    signal {size} choose;
    signal {size} left;
    signal right;
    signal {size} merged;
    choose.size = 2;
    left.size = 2;
    choose <== choice;
    left <== 5;
    right <== 7;
    merged <-- choose ? left : right;
    // TEMPLATED: inline_switch_tag_merge_missing.circom:[[@LINE+1]]:{{[0-9]+}}: component child requires a value for tag in.size
    component child = Expand();
    child.in <== merged;
    signal output out;
    out <== child.out.x[0];
}

component main = Main();

// CONCRETE: Tag value has not been previously initialized
// CONCRETE: inline_switch_tag_merge_missing.circom{{.*}}:{{[0-9]+}}:
