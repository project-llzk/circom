// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED --implicit-check-not=bool.assert
// END.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }
bus Box(N) { Vec(N) values; }

template Make(N) {
    var M = N + 1;
    Box(M) output out;
    M = N + 2;
    for (var i = 0; i < N + 1; i++) { out.values.x[i] <== i; }
}

template Forward(N) {
    // This caller-local alias must not replace Make's declaration-time value.
    var M = N + 7;
    Box(N + 1) output out;
    component child = Make(N);
    out <== child.out;
}

template Main(N) {
    Box(N + 1) output out;
    component direct = Make(N);
    component forwarded = Forward(N);
    out <== direct.out;
    out === forwarded.out;
}

component main = Main(2);

// CONCRETE-LABEL: struct.def @"$bus_entry" {
// CONCRETE: struct.member @out.values.x : !array.type<3 x !felt.type

// TEMPLATED: struct.member @child : !struct.type<@Make::@Make<[@N, @"$layout$(N_Add_1)"]>>
// TEMPLATED: struct.member @direct : !struct.type<@Make::@Make<[@N, @"$layout$(N_Add_1)"]>>
// TEMPLATED-LABEL: poly.template @Make {
// TEMPLATED: poly.param @"$layout$(N_Add_1)" : index
// TEMPLATED: struct.member @out : !pod.type<[@values: !pod.type<[@x: !array.type<@"$layout$(N_Add_1)" x !felt.type
