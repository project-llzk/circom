// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// Equal output tags still require completion before their values propagate.

pragma circom 2.2.3;

bus Tagged(N) { signal {size} x[N]; }

template Child(N) {
    signal {size} source;
    source.size = 2;
    source <== 1;
    Tagged(N) output out;
    out.x[0] <== source;
}

template Main(idx) {
    component children[2];
    children[0] = Child(2);
    children[1] = Child(2);
    signal {size} selected;
    selected <== children[idx].out.x[0];
    // TEMPLATED: dynamic_component_tags_incomplete.circom:[[@LINE+1]]:{{[0-9]+}}: tag selected.size has no value
    signal output out[selected.size];
    for (var i = 0; i < selected.size; i++) { out[i] <== selected; }
}

component main = Main(0);

// CONCRETE: Tag value has not been previously initialized
