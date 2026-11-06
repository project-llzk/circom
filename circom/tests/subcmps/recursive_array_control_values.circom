// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

// Array contents controlling termination propagate through scalar-only wrappers.
template R(a) {
    signal output out;
    if (a[0] == 0) {
        out <== a[0];
    } else {
        component child = R([a[0] - 1]);
        out <== child.out;
    }
}

template Wrapper(n) {
    component child = R([n]);
    signal output out;
    out <== child.out;
}

component main = Wrapper(1);

// CHECK-LABEL: poly.template @R$arrays$0_1$values$0_array_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$0_1$values$0_array_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$0_1$values$0_array_0::
