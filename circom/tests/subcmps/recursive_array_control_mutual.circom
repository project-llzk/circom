// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

// Both members of a recursive cycle must receive their known array arguments.
template A(a) {
    signal output out;
    if (a[0] == 0) {
        out <== a[0];
    } else {
        component child = B(a);
        out <== child.out;
    }
}

template B(a) {
    component child = A([a[0] - 1]);
    signal output out;
    out <== child.out;
}

component main = A([1]);

// CHECK-LABEL: poly.template @A$arrays$0_1$values$0_array_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @A$arrays$0_1$values$0_array_1 {
// CHECK: struct.member @child : !struct.type<@B$arrays$0_1$values$0_array_1::
// CHECK-LABEL: poly.template @B$arrays$0_1$values$0_array_1 {
// CHECK: struct.member @child : !struct.type<@A$arrays$0_1$values$0_array_0::
