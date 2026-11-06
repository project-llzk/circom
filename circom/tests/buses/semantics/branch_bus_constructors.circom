// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefixes=CONCRETE,CHECK
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefixes=TEMPLATED,CHECK
// END.

// Same-named scalar and array buses in each branch keep their own constructors,
// even when their declarations share the source range of a declaration group.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Main() {
    signal output out[2];
    if (1) {
        Vec(2) first;
        first.x <== [1, 2];
        out[0] <== first.x[1];
    } else {
        Vec(3) first;
        first.x <== [3, 4, 5];
        out[0] <== first.x[2];
    }
    if (0) {
        Vec(2) second;
        second.x <== [1, 2];
        out[1] <== second.x[1];
    } else {
        Vec(3) second, copies[1];
        Vec(3) expected;
        expected.x <== [3, 4, 5];
        second <== expected;
        copies[0] <== second;
        out[1] <== copies[0].x[2];
    }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_{{[0-9]+}} {
// TEMPLATED-LABEL: struct.def @Main {
// CHECK-DAG: struct.member @first : !pod.type<[@x: !array.type<2 x !felt.type
// CHECK-DAG: struct.member @second : !pod.type<[@x: !array.type<3 x !felt.type
// CHECK-DAG: struct.member @copies : !array.type<1 x !pod.type<[@x: !array.type<3 x !felt.type
