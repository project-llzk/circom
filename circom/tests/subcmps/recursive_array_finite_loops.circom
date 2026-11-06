// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk --implicit-check-not=scf.while
// END.

pragma circom 2.2.3;

// Each constructor sees the induction variable's value for its iteration.
template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0][0];
    } else {
        component child[1];
        for (var i = 0; i < 1; i++) {
            child[i] = R(n - i - 1, [a[0]]);
        }
        out <== child[0].out;
    }
}

component main = R(128, [[7, 8], [9, 10]]);

// CHECK-LABEL: poly.template @R$arrays$1_1_2$values$0_0 {
// CHECK-LABEL: poly.template @R$arrays$1_2_2$values$0_128 {
// CHECK: struct.member @child : !array.type<1 x !struct.type<@R$arrays$1_1_2$values$0_127::
