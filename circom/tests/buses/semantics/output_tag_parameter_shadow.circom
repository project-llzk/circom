// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Declaring and writing a shadowing local must preserve parameter-valued
// constants captured before and after its scope in exported output tags.
pragma circom 2.2.3;

template Source(N) {
    signal output {before, after, shadow, captured} out;
    var size = N;
    {
        var N = 1;
        N = 3;
        out.shadow = N;
        var captured[1] = [size];
        out.captured = captured[0];
    }
    out.before = size;
    var restored = N;
    out.after = restored;
    out <== 7;
}

template Parent(M) {
    component source = Source(M);
    signal output before[source.out.before];
    signal output after[source.out.after];
    signal output shadow[source.out.shadow];
    signal output captured[source.out.captured];
    for (var i = 0; i < source.out.before; i++) { before[i] <== source.out; }
    for (var j = 0; j < source.out.after; j++) { after[j] <== source.out; }
    for (var k = 0; k < source.out.shadow; k++) { shadow[k] <== source.out; }
    for (var l = 0; l < source.out.captured; l++) { captured[l] <== source.out; }
}

component main = Parent(2);

// CONCRETE-LABEL: struct.def @Parent{{_[0-9]+}} {
// CONCRETE-DAG: struct.member @before : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-DAG: struct.member @after : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-DAG: struct.member @shadow : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-DAG: struct.member @captured : !array.type<2 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Parent {
// TEMPLATED-DAG: struct.member @before : !array.type<@M x !felt.type<"bn128">>
// TEMPLATED-DAG: struct.member @after : !array.type<@M x !felt.type<"bn128">>
// TEMPLATED-DAG: struct.member @shadow : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED-DAG: struct.member @captured : !array.type<@M x !felt.type<"bn128">>
