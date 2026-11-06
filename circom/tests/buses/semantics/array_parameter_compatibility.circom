// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus Vec(ds) { signal x[ds[0]]; }
bus Token(ds) { signal x; }

template Copy(a, b) {
    Vec(a) input in;
    Vec(b) output out;
    out <== in;
}

template MatrixCopy(a, b) {
    Token(a) input in;
    Token(b) output out;
    out <== in;
}

// Compare distinct array formals both in main and after component scalarization.
// Every element matters for nominal compatibility, even if it is not a dimension.
template Main(a, b) {
    Vec(a) input in;
    Vec(b) output direct;
    Vec(b) output out;
    direct <== in;
    component copy = Copy(a, b);
    copy.in <== in;
    out <== copy.out;

    component matrix = MatrixCopy([[2, 3], [4, 5]], [[2, 3], [4, 5]]);
    matrix.in.x <== in.x[0];
    signal output matrix_out;
    matrix_out <== matrix.out.x;
}

component main = Main([2, 3], [2, 3]);

// CONCRETE-LABEL: struct.def @Copy_{{[0-9]+}} {
// CONCRETE: function.def @constrain(
// CONCRETE: constrain.eq
// CONCRETE-LABEL: struct.def @MatrixCopy_{{[0-9]+}} {
// CONCRETE: function.def @constrain(
// CONCRETE: constrain.eq

// TEMPLATED-LABEL: struct.def @Copy$arrays$0_2$1_2 {
// TEMPLATED: function.def @constrain(
// TEMPLATED: %[[FIRST:[a-zA-Z0-9_.-]+]] = bool.cmp eq({{.*}}) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT: bool.assert %[[FIRST]]
// TEMPLATED: %[[SECOND:[a-zA-Z0-9_.-]+]] = bool.cmp eq({{.*}}) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED-NEXT: bool.assert %[[SECOND]]
// TEMPLATED: constrain.eq
// Main's literal array arguments already prove compatibility.
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: function.def @constrain(
// TEMPLATED-NOT: bool.assert
// TEMPLATED: constrain.eq
// TEMPLATED-LABEL: struct.def @MatrixCopy$arrays$0_2_2$1_2_2 {
// TEMPLATED: function.def @constrain(
// TEMPLATED-COUNT-4: bool.cmp eq({{.*}}) : !felt.type<"bn128">, !felt.type<"bn128">
// TEMPLATED: constrain.eq
