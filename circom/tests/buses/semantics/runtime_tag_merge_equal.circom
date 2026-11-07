// REQUIRES: circom
// RUN: rm -rf %t && mkdir %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/templated.stdout 2> %t/templated.stderr
// RUN: FileCheck %s --check-prefix=TEMPLATED --input-file %t/*_llzk/*.llzk
// END.

// Concrete mode is not run because of an upstream bug: execution decrements the
// bus initialization counter for both runtime branches. Debug builds panic with
// subtraction overflow; release builds reach the uninitialized-tag diagnostic.

// Equal tags survive runtime branches for both component and local bus layouts.

pragma circom 2.2.3;

bus Tagged() { signal {size} x; }
bus Vec(N) { signal x[N]; }

template Expand() {
    Tagged() input in;
    Vec(in.x.size) output out;
    for (var i = 0; i < in.x.size; i++) { out.x[i] <== in.x; }
}

template Main() {
    signal input choose;
    Tagged() left;
    Tagged() right;
    Tagged() merged;
    left.x.size = 2;
    right.x.size = 2;
    left.x <== 5;
    right.x <== 7;
    if (choose) { merged <-- left; }
    else { merged <-- right; }
    component child = Expand();
    child.in <== merged;
    signal output out;
    out <== child.out.x[0];
    Vec(merged.x.size) output local;
    for (var i = 0; i < merged.x.size; i++) { local.x[i] <== merged.x; }
}

component main = Main();

// TEMPLATED: poly.param @"$tag$in$x$size" : index
// TEMPLATED-LABEL: struct.def @Expand {
// TEMPLATED: struct.member @out : !pod.type<[@x: !array.type<@"$tag$in$x$size" x !felt.type<"bn128">>]>
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: struct.member @local : !pod.type<[@x: !array.type<2 x !felt.type<"bn128">>]>
// TEMPLATED: struct.member @child : !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: function.def @compute(
// TEMPLATED: %[[VALUE1:[0-9a-zA-Z_.-]+]] = scf.if %{{[0-9a-zA-Z_.-]+}} -> (!pod.type<[@x: !felt.type<"bn128">]>) {
// TEMPLATED: struct.writem %[[VALUE3:[0-9a-zA-Z_.-]+]][@merged] = %[[VALUE4:[0-9a-zA-Z_.-]+]]
// TEMPLATED: scf.yield %[[VALUE4]]
// TEMPLATED: } else {
// TEMPLATED: struct.writem %[[VALUE3]][@merged] = %[[VALUE5:[0-9a-zA-Z_.-]+]]
// TEMPLATED: scf.yield %[[VALUE5]]
// TEMPLATED: }
// TEMPLATED: pod.write %{{[0-9a-zA-Z_.-]+}}[@in] = %[[VALUE1]]
// TEMPLATED: %{{[0-9a-zA-Z_.-]+}} = function.call @Expand::@Expand::@compute(%{{[0-9a-zA-Z_.-]+}}) : (!pod.type<[@x: !felt.type<"bn128">]>) -> !struct.type<@Expand::@Expand<[2]>>
// TEMPLATED: function.return %[[VALUE3]]
