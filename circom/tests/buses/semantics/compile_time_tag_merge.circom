// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Literal, template-parameter, and constant-tag conditions preserve tag values
// for both component and local bus layouts.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main(N) {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;

    Tagged() zero;
    if (0) { zero <-- left; }
    else { zero <-- right; }
    Tagged() one;
    if (1) { one <-- left; }
    else { one <-- right; }
    Tagged() param;
    if (N != 0) { param <-- left; }
    else { param <-- right; }
    Tagged() tag;
    if (left.x.size == 2) { tag <-- left; }
    else { tag <-- right; }

    component fromZero = Expand();
    component fromOne = Expand();
    component fromParam = Expand();
    component fromTag = Expand();
    fromZero.in <== zero;
    fromOne.in <== one;
    fromParam.in <== param;
    fromTag.in <== tag;
    signal output out;
    out <== fromZero.out.x[0] + fromOne.out.x[0] + fromParam.out.x[0] + fromTag.out.x[0];

    Vec(zero.x.size) output localZero;
    Vec(one.x.size) output localOne;
    Vec(param.x.size) output localParam;
    Vec(tag.x.size) output localTag;
    for (var i = 0; i < zero.x.size; i++) { localZero.x[i] <== zero.x; }
    for (var i = 0; i < one.x.size; i++) { localOne.x[i] <== one.x; }
    for (var i = 0; i < param.x.size; i++) { localParam.x[i] <== param.x; }
    for (var i = 0; i < tag.x.size; i++) { localTag.x[i] <== tag.x; }
}

component main = Main(1);

// CONCRETE-LABEL: struct.def @Expand_0 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @Expand_1 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE-LABEL: struct.def @Main_2 {
// CONCRETE: struct.member @localZero : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @localOne : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @localParam : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @localTag : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// CONCRETE: struct.member @fromOne : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: struct.member @fromParam : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: struct.member @fromTag : !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: struct.member @fromZero : !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Expand_0::@Expand_0::@compute(%[[IN1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_0::@Expand_0<[]>>
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Expand_1::@Expand_1::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @Expand_1::@Expand_1::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: %[[CHILD4:[a-zA-Z0-9_.-]+]] = function.call @Expand_1::@Expand_1::@compute(%[[IN4:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand_1::@Expand_1<[]>>
// CONCRETE: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]

// TEMPLATED: poly.param @"$tag$in$x$size" : index
// TEMPLATED-LABEL: struct.def @Expand {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED: poly.param @N
// TEMPLATED: poly.param @"$layout$((N_NotEq_0)?2:3)" : index
// TEMPLATED: poly.expr @"N_NotEq_0?2:3@[[OFFSET0:[0-9]+]]" {
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @localZero : !pod.type<[@x: !array.type<3 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @localOne : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @localParam : !pod.type<[@x: !array.type<@"$layout$((N_NotEq_0)?2:3)" x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @localTag : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @fromOne : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: struct.member @fromParam : !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED: struct.member @fromTag : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: struct.member @fromZero : !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Expand::@Expand::@compute(%[[IN1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[3]>>
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Expand::@Expand::@compute(%[[IN2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: %[[CHILD3:[a-zA-Z0-9_.-]+]] = function.call @Expand::@Expand::@compute(%[[IN3:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[@"N_NotEq_0?2:3@[[OFFSET0]]"]>>
// TEMPLATED: %[[CHILD4:[a-zA-Z0-9_.-]+]] = function.call @Expand::@Expand::@compute(%[[IN4:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
