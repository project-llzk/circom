// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: %circom --stabilize --llzk concrete --llzk_plaintext --llzk_strip_debug_info -o %t %s
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

pragma circom 2.1.0;

template Copy(n) {
    signal input in[n];
    signal output out[n];
    out <== in;
}

template Forward(mode) {
    component source[2];
    component first[2];
    component second[2];
    source[0] = Copy(2);
    source[1] = Copy(4);
    first[0] = Copy(2);
    first[1] = Copy(4);
    second[0] = Copy(2);
    second[1] = Copy(4);
    source[0].in <-- [1, 2];
    source[1].in <-- [3, 4, 5, 6];
    for (var i = 0; i < 2; i++) {
        // Aliases must select the same concrete component record.
        var j = i;
        if (mode == 0) { first[i].in <-- source[j].out; }
        if (mode == 1) { source[j].out --> first[i].in; }
        if (mode == 2) { first[i].in <== source[j].out; }
        if (mode == 3) { source[j].out ==> first[i].in; }

        // A reassigned index must not reuse the previous dispatch's selection.
        j = 1 - j;
        if (mode == 0) { second[j].in <-- source[j].out; }
        if (mode == 1) { source[j].out --> second[j].in; }
        if (mode == 2) { second[j].in <== source[j].out; }
        if (mode == 3) { source[j].out ==> second[j].in; }
    }
    first[0].out === [1, 2];
    first[1].out === [3, 4, 5, 6];
    second[0].out === [1, 2];
    second[1].out === [3, 4, 5, 6];
}

template Main() {
    component witnessLeft = Forward(0);
    component witnessRight = Forward(1);
    component constrainedLeft = Forward(2);
    component constrainedRight = Forward(3);
}

component main = Main();

// The read after reassignment must be consumed in its own dispatch branch.
// CHECK-LABEL: struct.def @Forward_
// CHECK: felt.sub
// CHECK: %[[SOURCE:[0-9a-zA-Z_.-]+]] = struct.readm {{.*}}[@out]
// CHECK: pod.write {{.*}}[@in] = %[[SOURCE]]
