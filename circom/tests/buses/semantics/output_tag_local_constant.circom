// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Output tag summaries must capture local constants before crossing template
// boundaries, including callers with an unrelated binding of the same name.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }

template Source() {
    Tagged() output out;
    var size = 2;
    out.x.size = size;
    out.x <== 7;
}

template NoSize() {
    component source = Source();
    signal output out[source.out.x.size];
    for (var i = 0; i < source.out.x.size; i++) { out[i] <== source.out.x; }
}

template WithSize() {
    var size = 3;
    component source = Source();
    signal output out[source.out.x.size];
    for (var i = 0; i < source.out.x.size; i++) { out[i] <== source.out.x; }
}

template Main() {
    component withoutSize = NoSize();
    component withSize = WithSize();
    signal output out;
    out <== withoutSize.out[1] + withSize.out[1];
}

component main = Main();

// CONCRETE-LABEL: struct.def @NoSize{{_[0-9]+}} {
// CONCRETE: struct.member @out : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-LABEL: struct.def @WithSize{{_[0-9]+}} {
// CONCRETE: struct.member @out : !array.type<2 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @NoSize {
// TEMPLATED: struct.member @out : !array.type<2 x !felt.type<"bn128">>
// TEMPLATED-LABEL: struct.def @WithSize {
// TEMPLATED: struct.member @out : !array.type<2 x !felt.type<"bn128">>
