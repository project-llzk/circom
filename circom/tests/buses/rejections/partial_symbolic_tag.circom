// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// Initializing one element cannot expose an array-wide tag when the number of
// bus instances depends on a template parameter.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Main(N) {
    signal {size} s;
    s.size = 2;
    s <== 3;
    Tagged() a[N];
    a[0].x <== s;
    Vec(a.x.size) output out;
    for (var i = 0; i < a.x.size; i++) { out.x[i] <== s; }
}

component main = Main(2);

// CONCRETE-DAG: Tag value has not been previously initialized
// CONCRETE-DAG: partial_symbolic_tag.circom{{.*}}:{{[0-9]+}}:

// TEMPLATED-DAG: tag a.x.size read before all array elements are initialized
// TEMPLATED-DAG: partial_symbolic_tag.circom{{.*}}:{{[0-9]+}}:
