// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Dynamic component reads retain only tags shared by every selectable output,
// using each constructor's own ordinary arguments and hidden input tags.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Child(OFFSET) {
    signal input {size} in;
    Tagged() output out;
    out.x.size = in.size + OFFSET;
    out.x <== in;
    signal output {size} scalar;
    scalar.size = in.size + OFFSET;
    scalar <== in;
}

template Main(N, idx) {
    signal {size} left;
    signal {size} right;
    left.size = 2;
    right.size = 1;
    left <== 5;
    right <== 7;
    component children[2];
    children[0] = Child(0);
    children[1] = Child(1);
    children[0].in <== left;
    children[1].in <== right;
    Tagged() selected;
    selected <== children[idx].out;
    signal {size} scalar <== children[idx].scalar;
    signal output out[selected.x.size];
    signal output scalarOut[scalar.size];
    for (var i = 0; i < selected.x.size; i++) { out[i] <== selected.x; }
    for (var j = 0; j < scalar.size; j++) { scalarOut[j] <== scalar; }

    component matrix[2][2];
    for (var row = 0; row < 2; row++) {
        for (var col = 0; col < 2; col++) {
            matrix[row][col] = Child(row);
            matrix[row][col].in <== left;
        }
    }
    Tagged() selectedRow;
    selectedRow <== matrix[0][idx].out;
    signal output rowOut[selectedRow.x.size];
    for (var k = 0; k < selectedRow.x.size; k++) { rowOut[k] <== selectedRow.x; }

    component bounded[N];
    for (var n = 0; n < N; n++) {
        bounded[n] = Child(1);
        bounded[n].in <== right;
    }
    Tagged() selectedLoop;
    selectedLoop <== bounded[idx].out;
    signal output loopOut[selectedLoop.x.size];
    for (var m = 0; m < selectedLoop.x.size; m++) { loopOut[m] <== selectedLoop.x; }
}

component main = Main(2, 1);

// CONCRETE-DAG: struct.member @out : !array.type<2 x
// CONCRETE-DAG: struct.member @scalarOut : !array.type<2 x
// CONCRETE-DAG: struct.member @rowOut : !array.type<2 x
// CONCRETE-DAG: struct.member @loopOut : !array.type<2 x

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED-DAG: struct.member @out : !array.type<2 x
// TEMPLATED-DAG: struct.member @scalarOut : !array.type<2 x
// TEMPLATED-DAG: struct.member @rowOut : !array.type<2 x
// TEMPLATED-DAG: struct.member @loopOut : !array.type<2 x
