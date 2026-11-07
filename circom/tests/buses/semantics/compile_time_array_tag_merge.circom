// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Indexed local constants select a single branch before divergent tags merge.
// Component parameters verify the selected tags determine the right layout.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main() {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;

    var choose[2] = [1, 0];
    var index = 1;
    // Ordinary fixed loops preserve arrays that the body never writes.
    var total = 0;
    for (var i = 0; i < 2; i++) { total += i; }
    Tagged() one;
    if (choose[0]) { one <-- left; }
    else { one <-- right; }
    Tagged() zero;
    if (choose[index - 0]) { zero <-- left; }
    else { zero <-- right; }

    // Array copies are snapshots, and indexed writes replace the old element.
    var copied[2] = choose;
    choose[0] = 0;
    Tagged() updated;
    if (choose[0]) { updated <-- left; }
    else { updated <-- right; }
    Tagged() snapshot;
    if (copied[0]) { snapshot <-- left; }
    else { snapshot <-- right; }

    // Subarray writes and scalar indices must resolve through nested arrays.
    var matrix[2][2] = [[0, 0], [0, 1]];
    matrix[0] = copied;
    matrix[1][0] = 1;
    Tagged() nested;
    if (matrix[index][copied[1]] && matrix[0][0]) { nested <-- left; }
    else { nested <-- right; }

    component fromOne = Expand();
    component fromZero = Expand();
    component fromUpdated = Expand();
    component fromSnapshot = Expand();
    component fromNested = Expand();
    fromOne.in <== one;
    fromZero.in <== zero;
    fromUpdated.in <== updated;
    fromSnapshot.in <== snapshot;
    fromNested.in <== nested;

    signal output out;
    out <== fromOne.out.x[1] + fromZero.out.x[2] + fromUpdated.out.x[2]
        + fromSnapshot.out.x[1] + fromNested.out.x[1];

    Vec(updated.x.size) output localUpdated;
    Vec(nested.x.size) output localNested;
    for (var i = 0; i < updated.x.size; i++) { localUpdated.x[i] <== updated.x; }
    for (var i = 0; i < nested.x.size; i++) { localNested.x[i] <== nested.x; }
}

component main = Main();

// CONCRETE-LABEL: struct.def @Expand_0 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @Expand_1 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @Main_2 {
// CONCRETE: struct.member @localUpdated : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @localNested : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @fromNested : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: struct.member @fromOne : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: struct.member @fromSnapshot : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: struct.member @fromUpdated : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: struct.member @fromZero : !struct.type<@Expand_1::@Expand_1<[]>>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @localUpdated : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @localNested : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @fromNested : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: struct.member @fromOne : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: struct.member @fromSnapshot : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: struct.member @fromUpdated : !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED: struct.member @fromZero : !struct.type<@Expand::@Expand<[3]>>
