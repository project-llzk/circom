// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// A later constructor with a valid tag must not hide the earlier missing tag
// or replace the source location in its diagnostic.

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
    // TEMPLATED: component_array_missing_tag.circom:[[@LINE+1]]:{{[0-9]+}}: component children[0] requires input tag in.size
    children[0] = Child();
    children[1] = Child();
    children[0].in <== a;
    children[1].in <== b;
}

component main = Main();

// CONCRETE-DAG: Missing tag: input signal in requires tag size
// CONCRETE-DAG: component_array_missing_tag.circom{{.*}}:{{[0-9]+}}:
