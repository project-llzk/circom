// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

function id(n) { return n; }

template Child(N) {
    signal input in[id(N)];
    signal output {size} out[id(N)];
    out.size = N;
    out <== in;
}

template Main(N) {
    signal input in[id(N)];
    signal output out[id(N)];
    component child = Child(N);
    child.in <== in;
    out <== child.out;
}

component main = Main(2);

// CONCRETE-LABEL: struct.def @Child_{{[0-9]+}} {
// CONCRETE: struct.member @out : !array.type<2 x !felt.type<"bn128">>

// TEMPLATED: llzk.main = !struct.type<@Main::@Main<[2, 2]>>
// TEMPLATED: poly.param @"$layout$id(N)" : index
// TEMPLATED-LABEL: struct.def @Child {
// TEMPLATED: struct.member @out : !array.type<@"$layout$id(N)" x !felt.type<"bn128">>
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @child : !struct.type<@Child::@Child<[@N, @"$layout$id(N)"]>>
