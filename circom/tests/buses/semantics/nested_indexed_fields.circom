// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Indexed nested arguments preserve field order and feed both derived layout
// parameters and hidden input tags.

pragma circom 2.2.3;

bus Tagged(ds, i) { signal {size} z[ds[i]]; signal a; }
bus Rows(ds, i) { Tagged(ds[i], 0) rows[2]; signal a; }

template Forward(N) {
    Rows([[N + 1, 5], [7, 8]], 0) input in;
    Rows([[N + 1, 5], [7, 8]], 0) output out;
    out <== in;
    signal output sized[in.rows.z.size];
    for (var i = 0; i < in.rows.z.size; i++) { sized[i] <== in.a; }
}

template Main() {
    Rows([[2 + 1, 5], [7, 8]], 0) source;
    source.rows.z.size = 4;
    for (var r = 0; r < 2; r++) {
        for (var c = 0; c < 3; c++) { source.rows[r].z[c] <== 1; }
        source.rows[r].a <== 1;
    }
    source.a <== 1;
    component forwarded = Forward(2);
    forwarded.in <== source;
}

component main = Main();

// CONCRETE-LABEL: struct.def @Forward_0 {
// CONCRETE: struct.member @out : !pod.type<[@rows: !array.type<2 x !pod.type<[@z: !array.type<3 x !felt.type<"bn128">>, @a: !felt.type<"bn128">]>>, @a: !felt.type<"bn128">]>
// CONCRETE: struct.member @sized : !array.type<4 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Forward {
// TEMPLATED: struct.member @out : !pod.type<[@rows: !array.type<2 x !pod.type<[@z: !array.type<@"$layout$(N_Add_1)" x !felt.type<"bn128">>, @a: !felt.type<"bn128">]>>, @a: !felt.type<"bn128">]>
// TEMPLATED: struct.member @sized : !array.type<@"$tag$in$rows$z$size" x !felt.type<"bn128">>
