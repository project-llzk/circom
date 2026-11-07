// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Output tags capture parameter aliases and derived local values before a
// caller substitutes them into component arguments and bus dimensions.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template Source(N) {
    signal output {size, shifted} out;
    var size = N;
    out.size = size;
    var next = size + 1;
    size = N + 3;
    out.shifted = next;
    out <== 7;
}

template Expand(N) {
    signal input in;
    signal output out[N];
    for (var i = 0; i < N; i++) { out[i] <== in; }
}

template Parent(M) {
    component source = Source(M);
    component direct = Expand(source.out.size);
    direct.in <== source.out;
    Vec(source.out.shifted) output out;
    for (var i = 0; i < source.out.shifted; i++) { out.x[i] <== direct.out[0]; }
}

component main = Parent(2);

// CONCRETE-LABEL: struct.def @Expand{{_[0-9]+}} {
// CONCRETE: struct.member @out : !array.type<2 x !felt.type<"bn128">>
// CONCRETE-LABEL: struct.def @Parent{{_[0-9]+}} {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>

// TEMPLATED: llzk.main = !struct.type<@Parent::@"$bus_entry"<[2, 3]>>
// TEMPLATED-LABEL: poly.template @Parent {
// TEMPLATED: poly.param [[DIM:@"\$layout\$[^" ]+"]] : index
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<[[DIM]] x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @direct : !struct.type<@Expand::@Expand<[@M]>>
