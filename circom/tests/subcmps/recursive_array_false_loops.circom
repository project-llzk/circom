// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk --implicit-check-not=scf.while
// END.

// Statically false loops must preserve known recursion parameters.
pragma circom 2.2.3;

template R(n, a) {
    signal output out;
    while (0) {
        n++;
    }
    if (n == 0) {
        out <== a[0][0];
    } else {
        component child = R(n - 1, [a[0]]);
        out <== child.out;
    }
}

component main = R(1, [[7, 8], [9, 10]]);

// CHECK-LABEL: poly.template @R$arrays$1_1_2$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_2_2$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_1_2$values$0_0::
