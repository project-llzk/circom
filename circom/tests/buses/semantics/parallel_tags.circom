// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Analyze the alphabetically later child first, and pass distinct hidden tag
// arguments through both single and nested parallel annotations.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template ZChild() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main() {
    Tagged() a;
    Tagged() b;
    a.x.size = 2;
    b.x.size = 3;
    a.x <== 5;
    b.x <== 7;
    component left = parallel ZChild();
    component right = parallel (parallel ZChild());
    left.in <== a;
    right.in <== b;
    signal output out;
    out <== left.out.x[1] + right.out.x[2];
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_2 {
// CONCRETE: struct.member @left : !struct.type<@ZChild_0::@ZChild_0<[]>>
// CONCRETE: struct.member @right : !struct.type<@ZChild_1::@ZChild_1<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @ZChild_0::@ZChild_0::@compute(%[[IN1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@ZChild_0::@ZChild_0<[]>>
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @ZChild_1::@ZChild_1::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@ZChild_1::@ZChild_1<[]>>
// CONCRETE: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// CONCRETE-LABEL: struct.def @ZChild_0 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @ZChild_1 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @left : !struct.type<@ZChild::@ZChild<[2]>>
// TEMPLATED: struct.member @right : !struct.type<@ZChild::@ZChild<[3]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @ZChild::@ZChild::@compute(%[[IN1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@ZChild::@ZChild<[2]>>
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @ZChild::@ZChild::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@ZChild::@ZChild<[3]>>
// TEMPLATED: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: poly.param @"$tag$in$x$size" : index
// TEMPLATED-LABEL: struct.def @ZChild {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
