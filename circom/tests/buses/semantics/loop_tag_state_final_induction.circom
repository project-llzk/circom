// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Retained fixed loops preserve their final induction values for tag selection.
// A zero-trip loop preserves its starting value even when it exceeds the bound.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Main() {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;

    var i = 0;
    while (i < 2) { i = i + 1; }
    Tagged() chosen;
    if (i == 2) { chosen <-- left; }
    else { chosen <-- right; }
    signal output out[chosen.x.size];
    for (var j = 0; j < chosen.x.size; j++) { out[j] <== chosen.x; }

    var k = 3;
    while (k < 2) { k = k + 1; }
    Tagged() zero;
    if (k == 3) { zero <-- right; }
    else { zero <-- left; }
    signal output after_zero[zero.x.size];
    for (var j = 0; j < zero.x.size; j++) { after_zero[j] <== zero.x; }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_{{[0-9]+}} {
// CONCRETE-DAG: struct.member @out : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-DAG: struct.member @after_zero : !array.type<3 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED-DAG: struct.member @out : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-DAG: struct.member @after_zero : !array.type<3 x !felt.type<"bn128">>
