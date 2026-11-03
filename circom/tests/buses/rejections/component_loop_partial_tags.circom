// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// Matching loop syntax must not conflate instances when the ranges differ.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child() {
    Tagged() input in;
    signal output out;
    out <== in.x + in.x.size;
}

template Main() {
    Tagged() source;
    source.x.size = 3;
    source.x <== 5;
    component children[2];
    for (var i = 0; i < 2; i++) { children[i] = Child(); }
    for (var j = 0; j < 1; j++) { children[j].in <== source; }
}

component main = Main();

// CONCRETE: Component children is created but not all its inputs are initialized
// TEMPLATED: component children[1] requires input tag in.x.size
