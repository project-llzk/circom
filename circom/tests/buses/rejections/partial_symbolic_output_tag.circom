// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// Component summaries must preserve unknown completion for symbolic output
// arrays instead of exposing tags after only the first element is initialized.

pragma circom 2.2.3;

bus Tagged(N) { signal {size} x[N]; }

template Partial(N) {
    signal {size} s;
    s.size = 2;
    s <== 3;
    Tagged(N) output out;
    out.x[0] <== s;
}

template Main() {
    component child = Partial(2);
    // TEMPLATED: partial_symbolic_output_tag.circom:[[@LINE+1]]:{{[0-9]+}}: tag child.out.x.size read before all array elements are initialized
    signal output out[child.out.x.size];
    for (var i = 0; i < child.out.x.size; i++) { out[i] <== child.out.x[0]; }
}

component main = Main();

// CONCRETE: Tag value has not been previously initialized
// CONCRETE: partial_symbolic_output_tag.circom{{.*}}:{{[0-9]+}}:
