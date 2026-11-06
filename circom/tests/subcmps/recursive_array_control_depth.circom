// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

// Scalar arguments keep changing, so array binding must also recover at the depth limit.
template R(n, a) {
    signal output out;
    if (a[0] == 0) {
        out <== a[0];
    } else {
        component child = R(n + 1, [a[0] - 1]);
        out <== child.out;
    }
}

component main = R(0, [1]);

// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_0$1_array_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_1$values$0_1$1_array_0::
// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_1$1_array_0 {
// CHECK-NOT: struct.member @child
