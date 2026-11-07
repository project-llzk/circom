// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/concrete.stdout
// RUN: FileCheck %s --check-prefix=CONCRETE --input-file %t/*_llzk/*.llzk
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A concrete index selects one tag value; a symbolic index must intersect all
// candidates rather than retaining whichever constructor is visited first.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child(N) {
    Tagged() output out;
    out.x.size = N;
    out.x <== 1;
}

template Main(idx) {
    component children[2];
    children[0] = Child(2);
    children[1] = Child(3);
    Tagged() selected;
    selected <== children[idx].out;
    // TEMPLATED: dynamic_component_tags_unequal.circom:[[@LINE+1]]:{{[0-9]+}}: tag selected.x.size has no value
    signal output out[selected.x.size];
    for (var i = 0; i < selected.x.size; i++) { out[i] <== selected.x; }
}

component main = Main(0);

// CONCRETE: struct.member @out : !array.type<2 x
