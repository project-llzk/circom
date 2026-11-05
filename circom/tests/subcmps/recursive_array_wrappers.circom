// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Scalar recursion counts propagate through wrappers. Different counts need
// different specializations, while different array values can reuse them.
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

template Wrapper(n, a) {
    component child = R(n, a);
    signal output out;
    out <== child.out;
}

template Main(depth) {
    component first = Wrapper(depth, [[7, 8], [9, 10]]);
    component second = Wrapper(depth - 1, [[11, 12], [13, 14]]);
    component third = Wrapper(depth, [[17, 18], [19, 20]]);
    signal output out[3];
    out[0] <== first.out;
    out[1] <== second.out;
    out[2] <== third.out;
}

component main = Main(3);

// CONCRETE-LABEL: poly.template @Main_
// CONCRETE: struct.member @first : !struct.type<@Wrapper_
// CONCRETE: struct.member @second : !struct.type<@Wrapper_
// CONCRETE: struct.member @third : !struct.type<@Wrapper_
// CONCRETE-LABEL: poly.template @R_0 {
// CONCRETE-NOT: struct.member @child
// CONCRETE-LABEL: poly.template @R_1 {
// CONCRETE: struct.member @child : !struct.type<@R_0::@R_0<[]>>

// TEMPLATED-LABEL: poly.template @Main$values$0_3 {
// TEMPLATED: struct.member @first : !struct.type<@Wrapper$arrays$1_2_2$values$0_3::{{.*}}<[7, 8, 9, 10]>>
// TEMPLATED: struct.member @second : !struct.type<@Wrapper$arrays$1_2_2$values$0_2::{{.*}}<[11, 12, 13, 14]>>
// TEMPLATED: struct.member @third : !struct.type<@Wrapper$arrays$1_2_2$values$0_3::{{.*}}<[17, 18, 19, 20]>>
// TEMPLATED-LABEL: poly.template @R$arrays$1_1_2$values$0_0 {
// TEMPLATED-NOT: struct.member @child
// TEMPLATED-LABEL: poly.template @R$arrays$1_1_2$values$0_1 {
// TEMPLATED: struct.member @child : !struct.type<@R$arrays$1_1_2$values$0_0::
// TEMPLATED-LABEL: poly.template @R$arrays$1_1_2$values$0_2 {
// TEMPLATED: struct.member @child : !struct.type<@R$arrays$1_1_2$values$0_1::
