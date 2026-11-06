// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

// Array declarations create uniform zero-initializers with the same bound dimension.
template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0];
    } else {
        var next[n];
        next[0] = a[0];
        component child = R(n - 1, next);
        out <== child.out;
    }
}

component main = R(2, [7, 8, 9]);

// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_1$values$0_0::
// CHECK-LABEL: poly.template @R$arrays$1_3$values$0_2 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_2$values$0_1::
