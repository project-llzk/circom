// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --implicit-check-not=panicked --input-file %t/concrete.stderr
// RUN: if %circom --stabilize --llzk=templated -o %t %s > %t/templated.stdout 2> %t/templated.stderr; then cat %t/templated.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=TEMPLATED --implicit-check-not=panicked --input-file %t/templated.stderr
// END.

// The else branch must use the incoming bound, not the then branch's update.
pragma circom 2.2.3;

bus Pair() { signal {size} x[2]; }

template Main(CHOOSE) {
    signal {size} s;
    s.size = 7;
    s <== 3;
    Pair() a;
    signal output out;
    var bound = 1;
    if (CHOOSE) {
        bound = 2;
        out <== 0;
    } else {
        for (var i = 0; i < bound; i++) { a.x[i] <== s; }
        // TEMPLATED: branch_constants_else_state.circom:[[@LINE+1]]:{{[0-9]+}}: tag a.x.size read before all array elements are initialized
        out <== a.x.size;
    }
}

component main = Main(0);

// CONCRETE: Tag value has not been previously initialized
// CONCRETE: branch_constants_else_state.circom{{.*}}:{{[0-9]+}}:
