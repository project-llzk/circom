// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// A parameter alias preserves differing branch tags for a later layout read.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Main(N) {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;

    var choose = N;
    Tagged() selected;
    if (choose) { selected <-- left; }
    else { selected <-- right; }

    Vec(selected.x.size) output out;
    for (var i = 0; i < selected.x.size; i++) { out.x[i] <== selected.x; }
}

component main = Main(1);

// CONCRETE-LABEL: struct.def @Main{{_[0-9]+}} {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>

// TEMPLATED-LABEL: poly.template @Main {
// TEMPLATED: poly.param @"$layout$(N?2:3)" : index
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$layout$(N?2:3)" x !felt.type<"bn128">>]>
