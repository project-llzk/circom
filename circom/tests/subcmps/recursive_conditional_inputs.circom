// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t %s > %t/stdout
// RUN: FileCheck %s --input-file %t/*_llzk/*.llzk
// END.

// Each recursive specialization must only retain its surviving branch's inputs.
pragma circom 2.2.3;

template R(n, a) {
    signal output out;
    if (n == 0) {
        signal input base;
        out <== base + a[0];
    } else {
        signal input step;
        component child = R(n - 1, a);
        child.base <== step;
        out <== child.out;
    }
}

component main = R(1, [7]);

// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_0 {
// CHECK: function.def @compute({{.*}}function.arg_name = "base"})
// CHECK-LABEL: poly.template @R$arrays$1_1$values$0_1 {
// CHECK: function.def @compute({{.*}}function.arg_name = "step"})
