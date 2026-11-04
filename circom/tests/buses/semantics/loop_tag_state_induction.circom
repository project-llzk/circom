// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Induction-dependent writes in a fixed loop must contribute their tags and
// initialized leaves even when the loop does not access a tagged component.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Expand() {
    signal input {size} in;
    signal output {size} out[in.size];
    out.size = in.size;
    for (var j = 0; j < in.size; j++) { out[j] <== in; }
}

template Main() {
    Tagged() source;
    source.x.size = 2;
    source.x <== 3;
    signal {size} values[2];
    for (var i = 0; i < 2; i++) {
        if (i == 0) { values[0] <== source.x; }
    }
    values[1] <== source.x;
    component child = Expand();
    child.in <== values[0];
    signal output direct[values.size];
    signal output from_component[child.out.size];
    for (var k = 0; k < values.size; k++) {
        direct[k] <== values[k];
        from_component[k] <== child.out[k];
    }
    // Undeclared tags propagate through nested loops and induction aliases too.
    signal inferred[2][2];
    for (var row = 0; row < 2; row++) {
        for (var col = 0; col < 2; col++) {
            var sum = row + col;
            if (sum < 2) { inferred[row][col] <== source.x; }
        }
    }
    inferred[1][1] <== source.x;
    signal {size} nested;
    nested <== inferred[0][0];
    signal output from_nested[nested.size];
    for (var n = 0; n < nested.size; n++) { from_nested[n] <== inferred[n][0]; }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_{{[0-9]+}} {
// CONCRETE: struct.member @direct : !array.type<2 x !felt.type<"bn128">>
// CONCRETE: struct.member @from_component : !array.type<2 x !felt.type<"bn128">>
// CONCRETE: struct.member @from_nested : !array.type<2 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @direct : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED: struct.member @from_component : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED: struct.member @from_nested : !array.type<2 x !felt.type<"bn128">>
