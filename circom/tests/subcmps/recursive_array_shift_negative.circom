// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

// Negative counts reverse direction, including inside constant function calls.
function next(n) {
    return n << -1;
}

template R(n, a) {
    signal output out;
    if (n == 0) {
        out <== a[0];
    } else if ((1 >> -1) == 2 && (4 << -1) == 2) {
        component child = R(next(n), a);
        out <== child.out;
    } else {
        out <== 99;
    }
}

component main = R(1, [7, 8]);

// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_2$values$0_0::
