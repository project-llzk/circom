// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

// Each complement must be reduced to a field element: ~(~0) is zero.
template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0];
    } else if (~(~0)) {
        out <== 99;
    } else {
        component child = R(~(~0), a);
        out <== child.out;
    }
}

component main = R(1, [7, 8]);

// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_2$values$0_0::
