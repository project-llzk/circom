// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Completing every leaf across enclosing bus arrays and indexed field dimensions
// makes the propagated tag available for an output layout.

pragma circom 2.2.3;

bus Tagged(ds, i) { signal {size} z[ds[i]]; signal a; }
bus Rows(ds, i) { Tagged(ds[i], 0) rows[2]; signal a; }

template Main() {
    signal {size} s;
    s.size = 4;
    s <== 1;
    Rows([[3, 5], [7, 8]], 0) data;
    data.rows[0].a <== 1;
    data.rows[1].a <== 1;
    data.a <== 1;
    data.rows[0].z <== [s, s, s];
    data.rows[1].z[0] <== s;
    data.rows[1].z[1] <== s;
    data.rows[1].z[2] <== s;
    signal output out[data.rows.z.size];
    for (var i = 0; i < data.rows.z.size; i++) { out[i] <== s; }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_0 {
// CONCRETE: struct.member @out : !array.type<4 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @out : !array.type<4 x !felt.type<"bn128">>
