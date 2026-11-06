// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

// Agreeing assignments establish a constant even when the condition is unknown.
pragma circom 2.2.3;

template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0];
    } else {
        var next = a[0];
        if (a[0]) next = 0;
        else next = 0;
        component child = R(next, a);
        out <== child.out;
    }
}

component main = R(1, [7, 8]);

// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_2$values$0_0::
