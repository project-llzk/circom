// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk --check-prefix=CONCRETE
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk --check-prefix=TEMPLATED
// END.

pragma circom 2.2.3;

bus Packet(N) { signal {size} x[N]; }

// Mutual recursion controlled by array values must expand before tag summaries,
// while array parameters remain available for forwarding derived bus dimensions.
template A(depth, widths) {
    Packet(widths[0] + 1) output out;
    if (depth[0] == 0) {
        out.x.size = widths[0];
        for (var i = 0; i < widths[0] + 1; i++) {
            out.x[i] <== i;
        }
    } else {
        component child = B([depth[0] - 1], widths);
        out <== child.out;
    }
}

template B(depth, widths) {
    Packet(widths[0] + 1) output out;
    component child = A(depth, widths);
    out <== child.out;
}

template Main() {
    component child = A([2], [2]);
    signal output size;
    signal output value;
    size <== child.out.x.size;
    value <== child.out.x[2];
}

component main = Main();

// CONCRETE: struct.member @out : !pod.type<[@x: !array.type<3 x !felt.type
// CONCRETE-LABEL: struct.def @Main{{_[0-9]+}} {
// CONCRETE: %[[SIZE:[0-9a-zA-Z_.-]+]] = felt.const 2 :
// CONCRETE-NEXT: struct.writem {{.*}}[@size] = %[[SIZE]] :

// TEMPLATED-LABEL: poly.template @A$shapes$0_1$1_1$values$0_array_0$1_array_2$arrays$0_1$1_1 {
// TEMPLATED-NOT: struct.member @child
// TEMPLATED: function.def @compute(
// TEMPLATED-LABEL: poly.template @B$shapes$0_1$1_1$values$0_array_1$1_array_2$arrays$0_1$1_1 {
// TEMPLATED: struct.member @child : !struct.type<@A$shapes$0_1$1_1$values$0_array_1$1_array_2$arrays$0_1$1_1::
// TEMPLATED-LABEL: struct.def @Main {
// TEMPLATED: %[[SIZE:[0-9a-zA-Z_.-]+]] = felt.const 2 :
// TEMPLATED-NEXT: struct.writem {{.*}}[@size] = %[[SIZE]] :
