// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Forward derived layout arguments through parallel components whose callers
// do not declare buses themselves, including nested parallel annotations.

pragma circom 2.2.3;

bus Vec(N) { signal x[N]; }

template ZChild(N) {
    Vec(N + 1) values;
    for (var i = 0; i < N + 1; i++) { values.x[i] <== i; }
    signal output out;
    out <== values.x[N];
}

template Middle(N) {
    component child = parallel (parallel ZChild(N + 1));
    signal output out;
    out <== child.out;
}

template Main(N) {
    component child = parallel Middle(N);
    signal output out;
    out <== child.out;
}

component main = Main(2);

// CONCRETE-LABEL: struct.def @Main_2 {
// CONCRETE: struct.member @child : !struct.type<@Middle_1::@Middle_1<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Middle_1::@Middle_1::@compute() : () -> !struct.type<@Middle_1::@Middle_1<[]>>
// CONCRETE: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// CONCRETE-LABEL: struct.def @Middle_1 {
// CONCRETE: struct.member @child : !struct.type<@ZChild_0::@ZChild_0<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @ZChild_0::@ZChild_0::@compute() : () -> !struct.type<@ZChild_0::@ZChild_0<[]>>
// CONCRETE: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// CONCRETE-LABEL: struct.def @ZChild_0 {
// CONCRETE: struct.member @values : !pod.type<[@x: !array.type<4 x !felt.type<"bn128">>]>

// TEMPLATED: poly.param @N
// TEMPLATED: poly.param @"$layout$((N_Add_1)_Add_1)" : index
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @child : !struct.type<@Middle::@Middle<[@N, @"$layout$((N_Add_1)_Add_1)"]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Middle::@Middle::@compute() : () -> !struct.type<@Middle::@Middle<[@N, @"$layout$((N_Add_1)_Add_1)"]>>
// TEMPLATED: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: poly.param @N
// TEMPLATED: poly.param @"$layout$((N_Add_1)_Add_1)" : index
// TEMPLATED-LABEL: struct.def @Middle {
// TEMPLATED: struct.member @child : !struct.type<@ZChild::@ZChild<[@"N_Add_1@{{[0-9_]+}}", @"$layout$((N_Add_1)_Add_1)"]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @ZChild::@ZChild::@compute() : () -> !struct.type<@ZChild::@ZChild<[@"N_Add_1@{{[0-9_]+}}", @"$layout$((N_Add_1)_Add_1)"]>>
// TEMPLATED: function.return %[[VALUE2:[a-zA-Z0-9_.-]+]]
// TEMPLATED: poly.param @N
// TEMPLATED: poly.param @"$layout$(N_Add_1)" : index
// TEMPLATED-LABEL: struct.def @ZChild {
// TEMPLATED: struct.member @values : !pod.type<[@x: !array.type<@"$layout$(N_Add_1)" x !felt.type<"bn128">>]>
