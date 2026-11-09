// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// A whole-bus assignment completes symbolic arrays for local tag reads,
// caller tag reads, and propagation through another component.

pragma circom 2.2.3;

bus Tagged(N) { signal {size} x[N]; }

template Forward(N) {
    Tagged(N) input in;
    Tagged(N) output out;
    out <== in;
    signal output local[out.x.size];
    for (var i = 0; i < out.x.size; i++) { local[i] <== out.x[0]; }
}

template Main(N) {
    Tagged(N) source;
    source.x.size = 3;
    for (var i = 0; i < N; i++) { source.x[i] <== 7; }

    component first = Forward(N);
    first.in <== source;
    component second = Forward(N);
    second.in <== first.out;

    signal output out[second.out.x.size];
    for (var i = 0; i < second.out.x.size; i++) { out[i] <== second.out.x[0]; }
}

component main = Main(2);

// CONCRETE-LABEL: struct.def @Forward{{_[0-9]+}} {
// CONCRETE: struct.member @local : !array.type<3 x !felt.type<"bn128">>
// CONCRETE-LABEL: struct.def @Main{{_[0-9]+}} {
// CONCRETE: struct.member @out : !array.type<3 x !felt.type<"bn128">>

// TEMPLATED-LABEL: struct.def @Forward {
// TEMPLATED: struct.member @local : !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @out : !array.type<3 x !felt.type<"bn128">>
// TEMPLATED: struct.member @second : !struct.type<@Forward::@Forward<[@N, 3]>>
