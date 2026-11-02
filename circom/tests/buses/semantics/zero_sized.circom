// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk
// END.

// Empty inputs complete without decrementing an input counter.

pragma circom 2.2.3;
bus Vec(N) { signal x[N]; }
template Empty() {
    Vec(0) input in;
    signal output out;
    out <== 7;
}
template Main() {
    Vec(0) input in;
    signal output out;
    component child = Empty();
    child.in <== in;
    out <== child.out;
}
component main = Main();

// CHECK: module attributes
// CHECK-NOT: arith.subi
