// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk
// END.

// Declaring a binary tag does not generate an equality for an unconstrained assignment.

pragma circom 2.2.3;
bus Bit() { signal {binary} x; }
template Main() {
    signal input in;
    Bit() a;
    a.x <-- in;
}
component main = Main();

// CHECK-LABEL: struct.def @Main{{(_[0-9]+)?}} {
// CHECK: function.def @constrain(
// CHECK-NOT: constrain.eq
// CHECK: function.return
