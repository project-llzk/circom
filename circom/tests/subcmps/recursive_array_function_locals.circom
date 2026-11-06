// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.2.3;

function read(a, i) {
    return a[i];
}

function isZero(n) {
    var values[2][2];
    values[0][0] = n;
    values[1] = values[0];
    values[0][0] = n + 1;
    {
        var values[1] = [99];
        values[0]++;
    }
    return read(values[1], 0) == 0;
}

function previous(n) {
    var values[2];
    values[0] = n;
    values[1] = 1;
    var copy[2] = values;
    copy[0] -= copy[1];
    return copy[0];
}

template R(n, a) {
    signal output out;
    if (isZero(n)) {
        out <== a[0];
    } else {
        component child = R(previous(n), [a[0]]);
        out <== child.out;
    }
}

component main = R(1, [7, 8]);

// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_0 {
// CHECK-NOT: struct.member @child
// CHECK-LABEL: poly.template @R$arrays$1_2$values$0_1 {
// CHECK: struct.member @child : !struct.type<@R$arrays$1_1$values$0_0::
