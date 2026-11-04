// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Fixed positive loops initialize scalar tags and account for every array leaf.
// Both propagated component tags and direct tag reads retain their layout values.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Expand() {
    signal input {size} in;
    signal output out[in.size];
    for (var j = 0; j < in.size; j++) { out[j] <== in; }
}

template Main() {
    Tagged() source;
    source.x.size = 2;
    source.x <== 3;
    signal {size} scalar;
    var i = 0;
    while (i < 1) {
        scalar <== source.x;
        i++;
    }
    signal {size} values[2];
    for (var j = 0; j < 2; j++) { values[j] <== source.x; }
    component single = Expand();
    single.in <== scalar;
    component repeated = Expand();
    repeated.in <== values[0];
    signal output direct[scalar.size];
    for (var k = 0; k < scalar.size; k++) { direct[k] <== single.out[k]; }
    signal output from_array[values.size];
    for (var l = 0; l < values.size; l++) { from_array[l] <== repeated.out[l]; }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_{{[0-9]+}} {
// CONCRETE: struct.member @direct : !array.type<2 x !felt.type<"bn128">>
// CONCRETE: struct.member @from_array : !array.type<2 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @direct : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED: struct.member @from_array : !array.type<2 x !felt.type<"bn128">>
