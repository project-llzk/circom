// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Ordinary signal tags must determine array and component layouts without any buses.

pragma circom 2.2.3;

template Vec(N) {
    signal input in;
    signal output out[N];
    for (var i = 0; i < N; i++) { out[i] <== in; }
}

template Expand() {
    signal input {size} in;
    signal output out[in.size];
    component child = Vec(in.size);
    child.in <== in;
    out <== child.out;
}

template Main() {
    signal {size} source;
    source.size = 2;
    source <== 5;
    component expanded = Expand();
    expanded.in <== source;
    signal output out[2];
    out <== expanded.out;
}

component main = Main();

// CONCRETE-LABEL: struct.def @Expand_1 {
// CONCRETE: struct.member @out : !array.type<2 x !felt.type
// CONCRETE: struct.member @child : !struct.type<@Vec_0::@Vec_0<[]>>

// TEMPLATED-LABEL: poly.template @Expand {
// TEMPLATED: poly.param @"$tag$in$size" : index
// TEMPLATED: struct.member @out : !array.type<@"$tag$in$size" x !felt.type
// TEMPLATED: struct.member @child : !struct.type<@Vec::@Vec<[@"$tag$in$size"]>>
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @expanded : !struct.type<@Expand::@Expand<[2]>>
