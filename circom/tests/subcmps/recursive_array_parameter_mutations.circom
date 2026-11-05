// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Parameter writes select the base case, including writes before a shadowing
// declaration. A shadowing declaration alone must preserve the outer count.
pragma circom 2.2.3;

template Mutated(n, a) {
    signal output out;
    n = 0;
    if (n == 0) {
        out <== a[0][0];
    } else {
        component child = Mutated(n - 1, [a[0]]);
        out <== child.out;
    }
}

template Nested(n, a) {
    signal output out;
    { n = 0; var n = 99; }
    if (n == 0) {
        out <== a[0][0];
    } else {
        component child = Nested(n - 1, [a[0]]);
        out <== child.out;
    }
}

template Shadow(n, a) {
    signal output out;
    { var n = 0; }
    if (n == 0) {
        out <== a[0][0];
    } else {
        component child = Shadow(n - 1, [a[0]]);
        out <== child.out;
    }
}

template Main() {
    component mutated = Mutated(3, [[7, 8], [9, 10]]);
    component nested = Nested(3, [[11, 12], [13, 14]]);
    component shadow = Shadow(1, [[17, 18], [19, 20]]);
    signal output out[3];
    out[0] <== mutated.out;
    out[1] <== nested.out;
    out[2] <== shadow.out;
}

component main = Main();

// CONCRETE-LABEL: poly.template @Mutated_0 {
// CONCRETE-NOT: struct.member @child
// CONCRETE-LABEL: poly.template @Nested_1 {
// CONCRETE-NOT: struct.member @child
// CONCRETE-LABEL: poly.template @Shadow_2 {
// CONCRETE-NOT: struct.member @child
// CONCRETE-LABEL: poly.template @Shadow_3 {
// CONCRETE: struct.member @child : !struct.type<@Shadow_2::@Shadow_2<[]>>

// TEMPLATED-LABEL: poly.template @Mutated$arrays$1_2_2$values$0_3 {
// TEMPLATED-NOT: struct.member @child
// TEMPLATED-NOT: scf.if
// TEMPLATED-LABEL: poly.template @Nested$arrays$1_2_2$values$0_3 {
// TEMPLATED-NOT: struct.member @child
// TEMPLATED-NOT: scf.if
// TEMPLATED-LABEL: poly.template @Shadow$arrays$1_1_2$values$0_0 {
// TEMPLATED-NOT: struct.member @child
// TEMPLATED-LABEL: poly.template @Shadow$arrays$1_2_2$values$0_1 {
// TEMPLATED: struct.member @child : !struct.type<@Shadow$arrays$1_1_2$values$0_0::
