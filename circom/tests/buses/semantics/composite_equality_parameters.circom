// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Symbolic nominal parameters must agree for every alternative, even when both
// sides are composite expressions with identical POD layouts.
pragma circom 2.2.3;

bus B(N) { signal x; }

template Main(N, M, P, choose) {
    B(N) input a;
    B(M) input b;
    B(P) input c;
    (choose ? a : b) === c;
    (choose ? a : (choose ? a : b)) === (choose ? c : c);
    [a, b] === [c, c];
}

component main = Main(1, 1, 1, 0);

// CONCRETE-LABEL: function.def @constrain(
// CONCRETE-COUNT-4: constrain.eq

// TEMPLATED-LABEL: function.def @constrain(
// TEMPLATED-DAG: %[[M:[a-zA-Z0-9_.-]+]] = poly.read_const @M
// TEMPLATED-DAG: %[[N:[a-zA-Z0-9_.-]+]] = poly.read_const @N
// TEMPLATED-DAG: %[[P:[a-zA-Z0-9_.-]+]] = poly.read_const @P
// TEMPLATED-NOT: constrain.eq
// TEMPLATED: %[[FIRST_N:[a-zA-Z0-9_.-]+]] = bool.cmp eq(%[[N]], %[[P]])
// TEMPLATED-NEXT: bool.assert %[[FIRST_N]]
// TEMPLATED: %[[FIRST_M:[a-zA-Z0-9_.-]+]] = bool.cmp eq(%[[M]], %[[P]])
// TEMPLATED-NEXT: bool.assert %[[FIRST_M]]
// TEMPLATED: constrain.eq
// TEMPLATED-NOT: constrain.eq
// TEMPLATED: %[[NESTED_N:[a-zA-Z0-9_.-]+]] = bool.cmp eq(%[[N]], %[[P]])
// TEMPLATED-NEXT: bool.assert %[[NESTED_N]]
// TEMPLATED: %[[NESTED_M:[a-zA-Z0-9_.-]+]] = bool.cmp eq(%[[M]], %[[P]])
// TEMPLATED-NEXT: bool.assert %[[NESTED_M]]
// TEMPLATED: constrain.eq
// TEMPLATED-NOT: constrain.eq
// TEMPLATED: %[[ARRAY_N:[a-zA-Z0-9_.-]+]] = bool.cmp eq(%[[N]], %[[P]])
// TEMPLATED-NEXT: bool.assert %[[ARRAY_N]]
// TEMPLATED: %[[ARRAY_M:[a-zA-Z0-9_.-]+]] = bool.cmp eq(%[[M]], %[[P]])
// TEMPLATED-NEXT: bool.assert %[[ARRAY_M]]
// TEMPLATED: constrain.eq
