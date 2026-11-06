// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

function isZero(n) {
    if (n == 0) {
        return 1;
    }
    return 0;
}

function identity(n) {
    return n;
}

function previous(n) {
    var result = 0;
    for (var i = 0; i < 1; i++) {
        var n = 0;
        n++;
        result++;
    }
    return identity(n - result);
}

template R(n, a) {
    signal output out;
    if (isZero(n)) {
        out <== a[0][0];
    } else {
        component child = R(previous(n), [a[0]]);
        out <== child.out;
    }
}

component main = R(previous(3), [[7, 8], [9, 10]]);

// CHECK-LABEL: poly.template @R$arrays$1_1_2$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_1_2$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_1_2$values$0_0::
// CHECK-LABEL: poly.template @R$arrays$1_2_2$values$0_2 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_1_2$values$0_1::
