// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus B(N) { signal x; }

template Main(N, M, P, Q) {
    B(N) input a;
    B(M) input b;
    B(P) input c;
    B(Q) input d;
    // Compare corresponding elements, without N == Q or M == P assertions.
    [a, b] === [c, d];
}

component main = Main(1, 1, 1, 1);

// CONCRETE-LABEL: function.def @constrain(
// CONCRETE: constrain.eq

// TEMPLATED-LABEL: function.def @constrain(
// TEMPLATED-DAG: %[[N:[0-9a-zA-Z_.-]+]] = poly.read_const @N
// TEMPLATED-DAG: %[[M:[0-9a-zA-Z_.-]+]] = poly.read_const @M
// TEMPLATED-DAG: %[[P:[0-9a-zA-Z_.-]+]] = poly.read_const @P
// TEMPLATED-DAG: %[[Q:[0-9a-zA-Z_.-]+]] = poly.read_const @Q
// TEMPLATED-NOT: bool.assert
// TEMPLATED: %[[FIRST:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[N]], %[[P]])
// TEMPLATED-NEXT: bool.assert %[[FIRST]]
// TEMPLATED-NOT: bool.assert
// TEMPLATED: %[[SECOND:[0-9a-zA-Z_.-]+]] = bool.cmp eq(%[[M]], %[[Q]])
// TEMPLATED-NEXT: bool.assert %[[SECOND]]
// TEMPLATED-NOT: bool.assert
// TEMPLATED: constrain.eq
// TEMPLATED-NOT: bool.assert
// TEMPLATED: function.return
