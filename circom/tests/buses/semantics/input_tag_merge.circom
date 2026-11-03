// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

// Conditions using hidden input-tag parameters can select a compile-time layout.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Select() {
    Tagged() input left;
    Tagged() input right;
    Tagged() merged;
    if (left.x.size == 2) { merged <-- left; }
    else { merged <-- right; }
    Vec(merged.x.size) output out;
    for (var i = 0; i < merged.x.size; i++) { out.x[i] <== merged.x; }
}

template Main() {
    Tagged() left;
    Tagged() right;
    left.x.size = 2;
    right.x.size = 3;
    left.x <== 5;
    right.x <== 7;
    component selected = Select();
    selected.left <== left;
    selected.right <== right;
    signal output out;
    out <== selected.out.x[0];
}

component main = Main();

// CONCRETE-LABEL: struct.def @Main_1 {
// CONCRETE: struct.member @selected : !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE: function.def @compute(
// CONCRETE: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Select_0::@Select_0::@compute(%[[LEFT1:[a-zA-Z0-9_.-]+]], %[[RIGHT1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Select_0::@Select_0::@compute(%[[LEFT2:[a-zA-Z0-9_.-]+]], %[[RIGHT2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select_0::@Select_0<[]>>
// CONCRETE: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// CONCRETE-LABEL: struct.def @Select_0 {
// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>

// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @selected : !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[CHILD1:[a-zA-Z0-9_.-]+]] = function.call @Select::@Select::@compute(%[[LEFT1:[a-zA-Z0-9_.-]+]], %[[RIGHT1:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED: %[[CHILD2:[a-zA-Z0-9_.-]+]] = function.call @Select::@Select::@compute(%[[LEFT2:[a-zA-Z0-9_.-]+]], %[[RIGHT2:[a-zA-Z0-9_.-]+]]) : (!pod.type<[@x: !felt.type<"bn128">]>, !pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Select::@Select<[2, 3, 2]>>
// TEMPLATED: function.return %[[VALUE1:[a-zA-Z0-9_.-]+]]
// TEMPLATED: poly.param @"$tag$left$x$size"
// TEMPLATED: poly.param @"$tag$right$x$size"
// TEMPLATED: poly.param @"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" : index
// TEMPLATED-LABEL: struct.def @Select {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$layout$(($tag$left$x$size_Eq_2)?$tag$left$x$size:$tag$right$x$size)" x !felt.type<"bn128">>]>
