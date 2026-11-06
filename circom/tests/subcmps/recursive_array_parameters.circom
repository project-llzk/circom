// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// The recursive call changes the array shape from [2, 2] to [1, 2].
// Its base case must not retain a recursive child in the generated struct.
pragma circom 2.2.3;

template R(n, a) {
    signal output out;

    if (n == 0) {
        out <== a[0][0];
    } else {
        component child = R(n - 1, [a[0]]);
        out <== child.out;
    }
}

component main = R(1, [[7, 8], [9, 10]]);

// CONCRETE-LABEL: poly.template @R_0 {
// CONCRETE-NOT: struct.member @child
// CONCRETE: felt.const 7 :
// CONCRETE-LABEL: poly.template @R_1 {
// CONCRETE: struct.member @child : !struct.type<@R_0::@R_0<[]>>

// TEMPLATED-LABEL: poly.template @R$arrays$1_1_2$values$0_0 {
// TEMPLATED: poly.param @"$array$a$0"
// TEMPLATED-NOT: struct.member @child
// TEMPLATED-NOT: scf.if
// TEMPLATED-LABEL: poly.template @R$arrays$1_2_2$values$0_1 {
// TEMPLATED: struct.member @child : !struct.type<@R$arrays$1_1_2$values$0_0::
