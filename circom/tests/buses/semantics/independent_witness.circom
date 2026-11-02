// REQUIRES: circom
// RUN: rm -rf %t && mkdir -p %t/concrete %t/templated
// RUN: %circom --stabilize --llzk=concrete --llzk_plaintext --llzk_strip_debug_info -o %t/concrete %s > %t/concrete.stdout
// RUN: FileCheck %s --input-file %t/concrete/*_llzk/*.llzk
// RUN: %circom --stabilize --llzk=templated --llzk_plaintext --llzk_strip_debug_info -o %t/templated %s > %t/templated.stdout
// RUN: FileCheck %s --input-file %t/templated/*_llzk/*.llzk
// END.

// Unconstrained copies retain independent witnesses; only the explicit equality remains.

pragma circom 2.2.3;
bus Point() { signal x; signal y; }
bus Points() { Point() points[2]; }
template Main() {
    Points() input in;
    Points() a;
    Points() b;
    a <-- in;
    b <-- a;
    a.points[0].x === b.points[1].y;
}
component main = Main();

// CHECK-LABEL: struct.def @Main{{(_[0-9]+)?}} {
// CHECK: function.def @constrain(
// CHECK-NOT: constrain.eq
// CHECK-NOT: function.return
// CHECK: struct.readm {{.*}}[@a]
// CHECK-NOT: constrain.eq
// CHECK-NOT: function.return
// CHECK: struct.readm {{.*}}[@b]
// CHECK-NOT: constrain.eq
// CHECK-NOT: function.return
// CHECK: constrain.eq
// CHECK-NOT: constrain.eq
// CHECK: function.return
