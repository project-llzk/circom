// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Array parameters carry scalar values across calls, including after local writes.
pragma circom 2.2.3;

template Pick(ds, i) {
    signal output out;
    out <== ds[i];
}

template Nested(ds) {
    component child = Pick(ds[1], 1);
    signal output out;
    out <== child.out;
}

template Mutated(ds) {
    ds[0] = 7;
    component child = Pick(ds, 0);
    signal output out;
    out <== child.out;
}

template Empty(ds) {
    signal output out;
    out <== 1;
}

template Main(N) {
    var table[2][2] = [[2, 3], [4, 5]];
    var empty[0];
    component symbolic = Pick([N, N + 1], 1);
    component slice = Pick(table[1], 1);
    component nested = Nested([[2, 3], [4, 5]]);
    component mutated = Mutated([2, 3]);
    component zero = Empty(empty);
    signal output out;
    out <== symbolic.out + slice.out + nested.out + mutated.out + zero.out;
}

component main = Main(2);

// CONCRETE-LABEL: poly.template @Pick_0 {
// CONCRETE: felt.const 3 : <"bn128">
// CONCRETE-LABEL: poly.template @Pick_3 {
// CONCRETE: felt.const 7 : <"bn128">

// TEMPLATED-LABEL: poly.template @Empty$arrays$0_0 {
// TEMPLATED-NEXT: struct.def @Empty$arrays$0_0 {
// TEMPLATED-LABEL: poly.template @Main {
// TEMPLATED: struct.member @nested : !struct.type<@Nested$arrays$0_2_2::@Nested$arrays$0_2_2<[2, 3, 4, 5]>>
// TEMPLATED: struct.member @symbolic : !struct.type<@Pick$arrays$0_2::@Pick$arrays$0_2<[@N, @"N_Add_1@{{[0-9_]+}}", 1]>>
// TEMPLATED: struct.member @zero : !struct.type<@Empty$arrays$0_0::@Empty$arrays$0_0<[]>>
// TEMPLATED-LABEL: poly.template @Mutated$arrays$0_2 {
// TEMPLATED: poly.expr @"ds[0]@{{[0-9_]+}}" {
// TEMPLATED: %[[SEVEN:[0-9a-zA-Z_.-]+]] = felt.const 7 : <"bn128">
// TEMPLATED: array.write %[[ARRAY:[0-9a-zA-Z_.-]+]][%[[ZERO:[0-9a-zA-Z_.-]+]]] = %[[SEVEN]]
// TEMPLATED: %[[ELEMENT:[0-9a-zA-Z_.-]+]] = array.read %[[ARRAY]][%[[ZERO]]]
// TEMPLATED: poly.yield %[[ELEMENT]] : !felt.type<"bn128">
