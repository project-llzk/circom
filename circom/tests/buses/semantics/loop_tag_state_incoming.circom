// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// An unrelated unknown loop preserves tags and completion established beforehand.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Expand() {
    signal input {size} in;
    signal output out[in.size];
    for (var j = 0; j < in.size; j++) { out[j] <== in; }
}

template Main(N) {
    Tagged() source;
    source.x.size = 2;
    source.x <== 3;
    signal {size} s;
    s <== source.x;
    var i = 0;
    while (i < N) { i++; }
    component child = Expand();
    child.in <== s;
    signal output direct[s.size];
    for (var j = 0; j < s.size; j++) { direct[j] <== child.out[j]; }
}

component main = Main(0);

// CONCRETE-LABEL: struct.def @Main_{{[0-9]+}} {
// CONCRETE: struct.member @direct : !array.type<2 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @direct : !array.type<2 x !felt.type<"bn128">>
