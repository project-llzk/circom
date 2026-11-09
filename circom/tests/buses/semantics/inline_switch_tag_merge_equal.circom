// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: if %circom --stabilize --llzk=concrete -o %t %s > %t/concrete.stdout 2> %t/concrete.stderr; then cat %t/concrete.stdout; exit 1; fi
// RUN: FileCheck %s --check-prefix=CONCRETE --input-file %t/concrete.stderr
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/templated.stdout 2> %t/templated.stderr
// RUN: FileCheck %s --check-prefix=TEMPLATED --input-file %t/*_llzk/*.llzk
// END.

// Equal tags survive runtime inline switches for signals and buses, including
// nested switches, component input tags, and local bus layouts.
// Concrete execution currently panics before reaching the backend because an
// unknown inline-switch selector produces a scalar value even for bus operands.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template ExpandSignal() {
    signal input {size} in;
    Vec(in.size) output out;
    for (var i = 0; i < in.size; i++) { out.x[i] <== in; }
}

template Main() {
    signal input choose;
    signal input other;
    Tagged() left;
    Tagged() right;
    Tagged() merged;
    left.x.size = 1 + 1;
    right.x.size = 2;
    left.x <== 5;
    right.x <== 7;
    merged <== choose ? left : right;
    component child = Expand();
    child.in <== merged;
    Vec(merged.x.size) output local;
    for (var i = 0; i < merged.x.size; i++) { local.x[i] <== merged.x; }

    signal {size} selected;
    selected <== choose ? (other ? left.x : right.x) : right.x;
    component scalar = ExpandSignal();
    scalar.in <== selected;
    Vec(selected.size) output localSignal;
    for (var i = 0; i < selected.size; i++) { localSignal.x[i] <== selected; }
    assert(merged.x.size == 2);
    assert(selected.size == 2);
    signal output out;
    out <== child.out.x[1] + scalar.out.x[1];
}

component main = Main();

// CONCRETE: panicked at {{.*}}constraint_generation/src/execute.rs:
// CONCRETE-NEXT: internal error: entered unreachable code

// TEMPLATED: poly.param @"$tag$in$x$size" : index
// TEMPLATED-LABEL: struct.def @Expand {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED: poly.param @"$tag$in$size" : index
// TEMPLATED-LABEL: struct.def @ExpandSignal {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$size" x !felt.type<"bn128">>]>
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @local : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @localSignal : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @child : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: struct.member @scalar : !struct.type<@ExpandSignal::@ExpandSignal<[2]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[BUS:[0-9a-zA-Z_.-]+]] = scf.if %{{[0-9a-zA-Z_.-]+}} -> (!pod.type<[@x: !felt.type<"bn128">]>) {
// TEMPLATED: struct.writem %{{[0-9a-zA-Z_.-]+}}[@merged] = %[[BUS]]
// TEMPLATED: function.call @Expand::@Expand::@compute({{.*}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: %[[SIGNAL:[0-9a-zA-Z_.-]+]] = scf.if %{{[0-9a-zA-Z_.-]+}} -> (!felt.type<"bn128">) {
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = scf.if %{{[0-9a-zA-Z_.-]+}} -> (!felt.type<"bn128">) {
// TEMPLATED: struct.writem %{{[0-9a-zA-Z_.-]+}}[@selected] = %[[SIGNAL]]
// TEMPLATED: function.call @ExpandSignal::@ExpandSignal::@compute({{.*}}) : (!felt.type<"bn128">) -> !struct.type<@ExpandSignal::@ExpandSignal<[2]>>
