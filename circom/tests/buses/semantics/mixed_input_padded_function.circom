// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE --implicit-check-not="incompatible mixed component bus input"
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

function row(n) {
    if (n == 2) { return [1, 2]; }
    else if (n == 4) { return [1, 2, 3, 4]; }
    else { return [1, 2, 3, 4, 5, 6]; }
}

bus Grid() { signal values[1][2]; }

template Sink(N) {
    Grid() input in;
    signal output out;
    out <== in.values[0][0] + N;
}

template Main() {
    component children[2];
    children[0] = Sink(2);
    children[1] = Sink(4);
    for (var i = 0; i < 2; i++) {
        children[i].in.values[0] <-- row(2);
    }
    signal output out;
    out <== children[0].out + children[1].out;
}

component main = Main();

// Both mixed dispatch entries must strip the function's six-element padding
// before inserting the selected row and completing the component input.
// CONCRETE-LABEL: struct.def @Main_{{[0-9]+}} {
// CONCRETE: function.def @compute(
// CONCRETE: function.call @row_{{[0-9]+}}::@row_{{[0-9]+}}{{.*}} -> !array.type<6 x !felt.type
// CONCRETE: %[[FIRST:[a-zA-Z0-9_.-]+]] = array.new {{.*}}: <2 x !felt.type
// CONCRETE: %[[SECOND:[a-zA-Z0-9_.-]+]] = array.new {{.*}}: <2 x !felt.type
// CONCRETE: array.insert {{.*}} = %[[SECOND]]
// CONCRETE: function.call @Sink_{{[0-9]+}}::@Sink_{{[0-9]+}}::@compute
// CONCRETE: array.insert {{.*}} = %[[FIRST]]
// CONCRETE: function.call @Sink_{{[0-9]+}}::@Sink_{{[0-9]+}}::@compute
// CONCRETE: function.return

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: function.def @compute(
// TEMPLATED: array.insert
// TEMPLATED: function.call @Sink::@Sink::@compute
// TEMPLATED: function.return
