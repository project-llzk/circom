// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A later valid iteration must not hide an earlier instance's missing tag.

pragma circom 2.2.3;

bus Output() { signal x; }

template Child() {
    signal input {size} in;
    Output() output out;
    out.x <== in + in.size;
}

template Main() {
    signal a <== 5;
    signal {size} b;
    b.size = 3;
    b <== 7;
    component children[2];
    for (var i = 0; i < 2; i++) { children[i] = Child(); }
    for (var j = 0; j < 2; j++) {
        if (j == 0) { children[j].in <== a; }
        else { children[j].in <== b; }
    }
}

component main = Main();

// CONCRETE: Missing tag: input signal in requires tag size
// TEMPLATED: component children[0] requires input tag in.size
